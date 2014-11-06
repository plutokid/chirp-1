(in-package #:chirp)

(defun sessions-url ()
  "/sessions")

(defun new-session (env)
  (html-response
   (with-layout ()
     (render-emb "sessions/new" (list :session (getf env :clack.session)
				      :user nil)))))

(defun create-session (env)
  (let* ((params (params env :user '(:username :password)))
	 (user   (find-user-by-credentials (getf params :username)
					   (getf params :password))))
    (if user
	;; User / password work
	(let ((session (make-instance 'session :key (random-hex-string) :user user)))
	  (setf (gethash :key (getf env :clack.session)) (key session))
	  (redirect-to (user-url user)))

	;; Bad login, try again.
	(html-response
	  (with-layout ()
	    (render-emb "sessions/new" (list :session (getf env :clack.session)
					     :user user))))
	)

    )
  )

(defun current-session (env)
  (let ((key (getf (getf env :clack.session) :key)))
    (first (clsql:select 'session :where [= [slot-value 'session 'key] key] :flatp t))))
