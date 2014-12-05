(in-package #:chirp)

;; Can be tested with
;; http://www.websocket.org/echo.html

(defclass socket-router (hunchensocket:websocket-resource)
  ())

(defvar +resource+ (make-instance 'socket-router))

(defvar *routing-table* (make-hash-table))

(defun maybe-get-client (user &optional (default nil))
  (let ((id (etypecase user
	       (user   (user-id user))
	       (number user))))
    (gethash id *routing-table* default)))

(defun notify-followers-for-chirp (chirp &optional (author (author chirp)))
  (if-let ((follower-ids (get-follower-ids author)))
    ;; (loop
    ;;    for id in follower-ids
    ;;    for client = (maybe-get-client id)
    ;;    ;; If we found a socket, tell it about the chirp!
    ;;    when client
    ;;    do (notify-for-chirp chirp client))

    (loop for client in (hunchensocket:clients +resource+)
	 do (notify-for-chirp chirp client))))

(defun notify-for-chirp (chirp &optional client)
    (when (slot-boundp chirp 'id)
      (when-let* ((user (find-user (user-id chirp)))
		  (client (or client (maybe-get-client user)))
		  (message (with-output-to-string (s)
			     (json:with-array (s)
			       (json:encode-array-member "chirp" s)
			       (json:as-array-member (s)
				 (json-chirp chirp s))))))

	(hunchensocket:send-text-message client (print message)))))
;; FIXME: Need something like this, but initialize-instance :after never works
;; (defmethod initialize-instance :after ((chirp chirp) &rest initargs)
;;   "Creates a notification about a chirp after it's created and pipes it into
;; the websockets"
;;   (declare (ignore initargs))
;;   (unless (slot-boundp chirp 'id)
;;     (when-let* ((user (find-user (user-id chirp)))
;; 		(client (gethash (user-id user) *routing-table*))
;; 		(message (with-output-to-string (s)
;; 			   (json:with-array (s)
;; 			     (json:encode-array-member "chirp" s)
;; 			     (json:as-array-member (s)
;; 			       (json-chirp chirp s))))))

;;       (hunchensocket:send-text-message client message))))


;; Just use one resource because I can't come up with a clever way to use more
;; FIXME: Channels for things?
(setf hunchensocket:*websocket-dispatch-table*
      (list
       (lambda (req)
	 (declare (ignore req))
	 +resource+)))

(defmethod hunchensocket:client-connected ((channel socket-router)
					   client)
  ;; Add client to the routing table!
  ;; (log4cl:log-error "Connection ~a ~a" channel client)
  ;; (when-let* ((env  (clack.handler.hunchensocket::handle-request
  ;; 		     (hunchensocket:client-request client)))
  ;; 	      (user (current-user env)))
;    (setf (gethash (id user) *routing-table*) client))
    )

(defmethod hunchensocket:client-disconnected ((channel socket-router)
					      client)
  ;; Remove client from the *routing-table* when it disconnects

  (when-let* ((env  (hunchensocket:client-request client))
	      (user (current-user env)))
    (remhash (id (current-user env)) *routing-table*)))

(defmethod hunchensocket:text-message-received
    ((channel hunchensocket:websocket-resource)
     (client hunchensocket:websocket-client)
     data)

  (log4cl:log-info "Got a message! ~a" data))

(defmethod hunchensocket:text-message-received :around
    ((channel socket-router)
     (client hunchensocket:websocket-client)
     message)

  ;; Decode the JSON!
  (let ((data (json:decode-json-from-string message)))
    (call-next-method channel client data)))
