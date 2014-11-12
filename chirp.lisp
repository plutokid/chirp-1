(in-package #:chirp)

(defun index (env)
  (html-response
    (with-layout (:title "Chirp!")
      (who:with-html-output-to-string (str)
	(:div
	 (:h1 :class "title""Welcome to the club")
	 (:p "As the world's leading site dedicated to pretending to be birds, we welcome you under our wing!"))))))

(defroutes *app*
  (GET  "/"             #'index)

  (GET  "/sessions/new" #'new-session)
  (GET  "/logout"       #'end-session)
  (POST "/sessions"     #'create-session)

  (POST "/users"        #'create-user)
  (GET  "/users/new"    #'new-user)
  (GET  "/users/:user"  #'show-user)

  (GET  "/chirps/new"   #'new-chirp)
  (GET  "/chirps/:id"   #'show-chirp)
  (POST "/chirps"       #'create-chirp)

  (GET  "/tags/:tag"    #'show-tag)

  (GET  "/ps/birder.js" #'chirp.ps:birder)
  (GET  "/ps/timeago.js"#'chirp.ps:timeago))

(defun app-wrap (env)
  (funcall '*app* env))

(defvar *acceptor*)

(defun start (&key (port 5000))
  (setf *acceptor*
	(clackup
	 (clack.builder:builder
	  (clack.middleware.static:<clack-middleware-static>
	   :root #P"./static/"
	   :path "/static/")
	  clack.middleware.session:<clack-middleware-session>
	  (clack.middleware.csrf:<clack-middleware-csrf>
	   :one-time-p t)
	  (clack.middleware.clsql:<clack-middleware-clsql>
	   :connection-spec (envy:config :chirp.config :connection-spec)
	   :database-type (envy:config :chirp.config :database-type))
	  #'app-wrap)
	 :server :hunchensocket
	 :port port)))

(defun stop ()
  (clack:stop))
