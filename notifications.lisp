(in-package #:chirp)


(defclass socket-router (hunchensocket:websocket-resource)
  ())

(defvar +resource+ (make-instance 'socket-router))

(defvar *routing-table* (make-hash-table))

(defun notifiy-for-chirp (chirp)
    (unless (slot-boundp chirp 'id)
    (when-let* ((user (find-user (user-id chirp)))
		(client (gethash (user-id user) *routing-table*))
		(message (with-output-to-string (s)
			   (json:with-array (s)
			     (json:encode-array-member "chirp" s)
			     (json:as-array-member (s)
			       (json-chirp chirp s))))))

        (hunchensocket:send-text-message client message))))
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
  (when-let* ((env  (clack.handler.hunchensocket::handle-request
		     (hunchensocket:client-request client)))
	      (user (current-user env)))
    (log4cl:log-info "~a ~a" user client)
    (setf (gethash (id user) *routing-table*) client)))

(defmethod hunchensocket:client-disconnected ((channel socket-router)
					      client)
  ;; Remove client from the *routing-table* when it disconnects

  (when-let* ((env  (hunchensocket:client-request client))
	      (user (current-user env)))
    (remhash (id (current-user env)) *routing-table*)))

;; (defmethod hunchensocket:text-message-received
;;     ((channel hunchensocket:websocket-resource)
;;      (client hunchensocket:websocket-client)
;;      data)

;;   (log4cl:log-info "Got a message! ~a" data)
;;   (print data)
;;   ;; data is JSON here
;;   (case (getf data :message)
;;     ("user_chirps" )
;;     ("single_chirp")))

(defmethod hunchensocket:text-message-received :around
    ((channel socket-router)
     (client hunchensocket:websocket-client)
     message)

  ;; Decode the JSON!
  (let ((data (json:decode-json-from-string message)))
    (call-next-method channel client data)))
