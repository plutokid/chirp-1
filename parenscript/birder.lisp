(in-package #:chirp.ps)

(setf hunchensocket:*websocket-dispatch-table*
      (list (lambda (req)
	      (make-instance 'hunchensocket:websocket-resource))))

(defmethod hunchensocket:client-connected ((channel hunchensocket:websocket-resource) client)
  (hunchensocket:send-text-message
   client
   (with-output-to-string (s)
     (chirp::json-chirps s))))

(defmethod hunchensocket:text-message-received
    ((channel hunchensocket:websocket-resource)
     (client hunchensocket:websocket-client)
     data)

  ;; data is JSON here
  (case (getf data :message)
    ("user_chirps" )
    ("single_chirp")))

(defmethod hunchensocket:text-message-received :around
    ((channel hunchensocket:websocket-resource)
     (client hunchensocket:websocket-client)
     message)

  ;; Decode the JSON!
  (let ((data (json:decode-json-from-string message)))
    (call-next-method channel client data)))


(export 'birder)
(defun birder (env)
  (declare (ignore env))
  (chirp::js-response
    (chain angular
	   (module "Chirp" #("angular-websocket" "controllers"
			     "ngSanitize"))
	   (config (lambda (-web-socket-provider)
		     (chain -web-socket-provider
			    (prefix "")
			    (uri (lisp (if (envy:config :chirp.config :debug)
					   "ws://localhost:5000"
					   "wss://lispchirp.herokuapp.com"))))))
	   ;; (config (lambda ($route-provider)
	   ;; 	     (chain $route-provider
	   ;; 		    (when "/users/:username"
	   ;; 		      (create
	   ;; 		       :controller "UserController"
	   ;; 		       :template-uri "user.hmtl")))))
	   )

    (chain angular
	   (module "controllers" #())
	   (controller "UserController"
		       (lambda ($scope -web-socket)
			 ))
	   (controller "ChirpController"
		       (lambda ($scope -web-socket)

			 (setf (@ $scope timeago) timeago)
			 (chain -web-socket
				(onopen (lambda ()
					  (chain console (log "connected"))
					  )))

			 (chain -web-socket
				(onmessage (lambda (event)
					     (setf data (chain angular (from-json (@ event data))))
					     (chain console (log "message: " data))
					     (setf (@ $scope chirps) (@ data chirps)))))
			 nil)))))
