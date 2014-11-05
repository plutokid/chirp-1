(in-package #:chirp)

(defun sessions-url ()
  "/sessions")

(defun new-session (env)
  (html-response
   (with-layout ()
     (render-emb "sessions/new" (list :session (getf env :clack.session) :user nil)))))

(defun create-session (env)
  (let* ((params (params env :user '(:username :password)))
	 (user   (find-user-by-credentials (getf params :username)
					   (getf params :password))))

    ))
