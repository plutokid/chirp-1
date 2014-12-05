(in-package #:chirp)

(defun index (env)
  (html-response

    (with-layout (:title "Chirp!" :session (current-session env))
      (who:with-html-output-to-string (str)
	(:script
	 (str
	  (ps:ps
	    (setf csrf-token
		  (ps:lisp (clack.middleware.csrf:csrf-token (getf env :clack.session)))))))
	 ;; (:div
	 ;;  (:h1 :class "title" "Welcome to the club")
	 ;;  (:p "As the world's leading site dedicated to pretending to be birds, we welcome you under our wing!"))


	(:div :ng-view "true")
	 ))))

(defroutes *app*
  (GET  "/"             #'index)

  (GET  "/sessions/new" #'new-session)
  (GET  "/logout"       #'end-session)
  (POST "/sessions"     #'create-session)

  ;; One page app! (aside from login/out)
  (POST "/users"        #'create-user)
  (GET  "/users/new"    #'new-user)
  ;; (GET  "/users/:user"  #'show-user)

  ;; (GET  "/chirps/new"   #'new-chirp)
  ;; (GET  "/chirps/:id"   #'show-chirp)
  ;; (POST "/chirps"       #'create-chirp)

  ;; (GET  "/tags/:tag"    #'show-tag)

  ;; API
  (GET  "/api/chirps"   #'json-show-chirps)
  (POST "/api/chirps"   #'json-post-chirp)

  ;; Parenscript

  (GET  "/ps/birder.js" #'chirp.ps:birder)
  (GET  "/ps/timeago.js"#'chirp.ps:timeago))

(defun app-wrap (env)
  (funcall '*app* env))

(defvar *acceptor*)

(defun start (&key (port 5000))
  (ensure-environment)
  (chirp.config:configure)
  (create-tables)
  ;; For the websockets, which don't get the special variable that
  ;; dispatched requests do
  (connect-to-db)
  (setf *acceptor*
	(clackup
	 (clack.builder:builder
	  clack.middleware.logger:<clack-middleware-logger>
	  (clack.middleware.static:<clack-middleware-static>
	   :root #P"./static/"
	   :path "/static/")
	  clack.middleware.session:<clack-middleware-session>
	  clack.middleware.csrf:<clack-middleware-csrf>
	  (clack.middleware.clsql:<clack-middleware-clsql>
	   :connection-spec (envy:config :chirp.config :connection-spec)
	   :database-type (envy:config :chirp.config :database-type))
	  #'app-wrap)
	 :server :hunchensocket
	 :port port))

  ;; Start sockets happens after making the acceptor because
  ;; it overrides the websocket dispatcher
  (start-sockets))

(defun stop ()
  (clack:stop))
