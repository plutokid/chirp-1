(in-package #:chirp)

(defun index (env)
  (html-response
    (with-layout ()
      (who:with-html-output-to-string (str)
	(:h1 :class "title" "Welcome to the club")
	(fmt "~a ~a" env (getf env :clack.session))
	(fmt "CSRF: ~a" (clack.middleware.csrf:csrf-html-tag (getf env :clack.session)))
	(:p "As the world's leading site dedicated to pretending to be birds, we welcome you under our wing!")))))

(defroutes *app*
  (GET  "/"            #'index)
  (GET  "/sessions/new"#'new-session)
  (POST "/sessions"    #'create-session)
  (POST "/users"       #'create-user)
  (GET  "/users/new"   #'new-user)
  (GET  "/users/:user" #'show-user)
  (GET  "/chirps/new"  #'new-chirp)
  (GET  "/chirps/:id"  #'show-chirp)
  (POST "/chirps"      #'create-chirp)
  (GET  "/tags/:tag"   #'show-tag))

(defvar *acceptor*)

(defun start ()
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
	   :connection-spec '("test.sqlite3")
	   :database-type :sqlite3)
	  #'*app*))))

(defun stop ()
  (clack:stop))
