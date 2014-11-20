(in-package #:chirp.ps)

(setf hunchensocket:*websocket-dispatch-table*
      (list (lambda (req)
	      (make-instance 'hunchensocket:websocket-resource))))

(defmethod hunchensocket:client-connected ((channel hunchensocket:websocket-resource) client)
  (hunchensocket:send-text-message
   client
   (with-output-to-string (s)
     (chirp::json-chirps (clsql:select 'chirp::chirp :flatp t) s))))

(defmethod hunchensocket:text-message-received
    ((channel hunchensocket:websocket-resource)
     (client hunchensocket:websocket-client)
     data)

  (log4cl:log-info "Got a message! ~a" data)
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
	   (module "Chirp" #("angular-websocket" "ngRoute"
			     "ngResource" "ngSanitize" ))
	   ;; Chirp content filter
	   (filter "chirpContent" (lambda ()
				    (lambda (input)
				      (chain -chirp-parser (parse input)))))
	   (filter "timeago" (lambda ()
			       (lambda (input)
				 (timeago input))))
	   (factory "Chirps"
		    (lambda ($resource)
		      ($resource
		       "/api/chirps"
		       nil
		       (create
			:user (create
			       :method "GET"
			       :params (create :request[type] "user"))
			:tag  (create
			       :method "GET"
			       :params (create :request[type] "tag"))))))

	   (config (lambda (-web-socket-provider $route-provider)
		     ;; Access to the JSON API
		     (chain -web-socket-provider
			    (prefix "")
			    (uri (lisp (if (envy:config :chirp.config :debug)
					   "ws://localhost:5000"
					   "wss://lispchirp.herokuapp.com"))))

		     (chain $route-provider
			    ;; (when "/"
			    ;;   (create
			    ;;    :template-uri "/static/landing.html"))
			    (when "/users/:username"
			      (create
			       controller "UserController"
			       template-url "/static/user.html"))
			    (when "/tags/:text"
			      (create
			       controller "TagController"
			       template-url "/static/tag.html"))
			    (otherwise
			     (create
			      redirect-to "/")))))

	   (controller "UserController"
		       (list "$scope" "$routeParams" "Chirps" "WebSocket"
			(lambda ($scope $route-params -chirps -web-socket)
			  (setf (@ $scope timeago) timeago)

			  (chain -chirps
				 (user (create :request[username]
					       (@ $route-params username)))
				 $promise
				 (then (lambda (response)
					 (setf (@ $scope chirps) (@ response chirps)
					       (@ $scope user) (@ response user))
					 (chain console (log (@ $scope user))))))

			  (chain -web-socket
				 (onmessage (lambda (event)
					      (chain console (log event)))))

			  ;; Tell our websocket who we're looking at
			  (when (chain -web-socket (ready-state))
			    (chain -web-socket
				   (send (chain angular (to-json (list "user_channel" (@ $route-params username))))))))))

	   (controller "TagController"
		       (list "$scope" "$routeParams" "Chirps"
			(lambda ($scope $route-params -chirps)
			  (setf (@ $scope timeago) timeago)
			  (chain -chirps
				 (tag (create :request[text] (@ $route-params text)))
				 $promise
				 ;; FIXME: Check errors
				 (then (lambda (response)
					 (chain console (log response))
					 (setf (@ $scope chirps) (@ response chirps)
					       (@ $scope tag) (@ response tag))
					 ))))))
	   ;; (controller "ChirpController"
	   ;; 	       (lambda ($scope -web-socket)

	   ;; 		 (setf (@ $scope timeago) timeago)
	   ;; 		 (chain -web-socket
	   ;; 			(onopen (lambda ()
	   ;; 				  (chain console (log "connected"))
	   ;; 				  )))

	   ;; 		 (chain -web-socket
	   ;; 			(onmessage (lambda (event)
	   ;; 				     (setf data (chain angular (from-json (@ event data))))


	   ;; 				     (setf (@ $scope chirps)
	   ;; 					   (chain (@ data chirps)
	   ;; 						  (map (lambda (chirp)
	   ;; 							 (setf (@ chirp content) (chain -chirp-parser (parse (@ chirp content))))
	   ;; 							 chirp))))
	   ;; 				     (chain console (log "message: " (@ $scope chirps))))))
	   ;; 		 nil))
	   )))
