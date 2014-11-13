(in-package #:chirp.ps)

(defmethod hunchensocket:client-connected ((channel hunchensocket:websocket-resource) client)
  (hunchensocket:send-text-message
   client
   (with-output-to-string (s)
     (chirp::json-chirps s))))


(export 'birder)
(defun birder (env)
  (declare (ignore env))
  (chirp::js-response
    (chain angular
	   (module "Chirp" #("angular-websocket" "controllers" "ngSanitize"))
	   (config (lambda (-web-socket-provider)
		     (chain -web-socket-provider
			    (prefix "")
			    (uri (lisp (if (envy:config :chirp.config :debug)
					   "ws://localhost:5000"
					   "wss://lispchirp.herokuapp.com")))))))

    (chain angular
	   (module "controllers" #())
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
