(in-package #:chirp.ps)

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
			       :params (create "request[type]" "tag"))
			:post (create
			       :method "POST"
			       :params (create "_csrf_token" "post"))))))

	   (config (lambda (-web-socket-provider $route-provider)
		     ;; Access to the JSON API
		     (chain -web-socket-provider
			    (prefix "")
			    (uri (lisp (if (envy:config :chirp.config :debug)
					   "ws://localhost:5000"
					   "wss://lispchirp.herokuapp.com"))))
		     (chain $route-provider
			    (when "/"
			      (create
			       :template-uri "/static/landing.html"))
			    (when "/users/:username"
			      (create
			       controller "UserController"
			       template-url "/static/user.html"))
			    ;; (when "/tags/:text"
			    ;;   (create
			    ;;    controller "TagController"
			    ;;    template-url "/static/tag.html"))
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
					       (@ $scope user) (@ response user)))))
			  (setf (@ window onbeforeunload)
				(lambda ()
				  (chain -web-socket (close))))

;
			  ;; (chain -web-socket
			  ;; 	 (onmessage (lambda (event) (chain console (log event)))))

			  ;; Tell our websocket who we're looking at
			  (when (chain -web-socket (ready-state))
			    (chain -web-socket
				   (send (chain angular (to-json (list "user" (@ $route-params username))))))))))

	   ;; (controller "TagController"
	   ;; 	       (list "$scope" "$routeParams" "Chirps"
	   ;; 		(lambda ($scope $route-params -chirps)
	   ;; 		  (setf (@ $scope timeago) timeago)
	   ;; 		  (chain -chirps
	   ;; 			 (tag (create "request[text]" (@ $route-params text)))
	   ;; 			 $promise
	   ;; 			 ;; FIXME: Check errors
	   ;; 			 (then (lambda (response)
	   ;; 				 (setf (@ $scope chirps) (@ response chirps)
	   ;; 				       (@ $scope tag) (@ response tag))
	   ;; 				 ))))
	   ;; 		)
	   ;; 	       )

	   ;; Just get users working first...
	   (controller "NewChirpController"
		       (list "$scope" "Chirps"
			     (lambda ($scope -chirps)
			       (setf (@ $scope new-chirp)
				     (lambda ()
				       (chain console
					      (log "Trying to post a new chirp"
						   (@ $scope chirp content)
						   (@ window csrf-token)))
				       (when (> (@ $scope chirp content length) 0)
					 (chain -chirps
						(post "/api/chirps"
						      (create
						       "request[content]" (@ $scope chirp content)))
						(success (lambda (data)
							   (chain console (log data))))
						(error (lambda (data)
							 (chain console (log data "error!"))))))))
			       nil)))
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
