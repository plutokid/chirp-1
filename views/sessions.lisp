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
	(let ((session (make-instance 'session
				      :key (random-hex-string)
				      :user-id (id user))))
	  (clsql:update-records-from-instance session)
	  (setf (gethash :key (getf env :clack.session)) (key session))
	  (redirect-to (user-url user)))

	;; Bad login, try again.
	(html-response
	  (with-layout ()
	    (render-emb "sessions/new" (list :session (getf env :clack.session)
					     :user user))))
	))
  )

(defun end-session (env)
  (when-let ((session (current-session env)))
    (clsql-sys:delete-instance-records session))
  (redirect-to "/"))

(file-enable-sql-reader-syntax)

(defun current-session (env)
  (let ((key (gethash :key (getf env :clack.session))))
    (first (clsql:select 'session :where [= [slot-value 'session 'key] key] :flatp t))))
