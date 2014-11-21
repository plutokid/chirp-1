(in-package #:chirp)

(defun sessions-url ()
  "/sessions")

(defun new-session (env)
  (if-let ((session (current-session env)))
    (redirect-to (user-url (user session)))
    (html-response
      (with-layout (:title "What's the secret birdsong?")
	(render-emb "sessions/new" (list :session (getf env :clack.session)
					 :user nil))))))

(defun log-user-in (user env)
  (let ((session (create-session-for-user user)))
    (setf (gethash :key (getf env :clack.session)) (key session))))

(defun create-session (env)
  (let* ((params (params env :user '(:username :password)))
	 (user   (find-user-by-credentials (getf params :username)
					   (getf params :password))))
    (if user
	;; User / password work
	(progn
	  (log-user-in user env)
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

(defun current-user (env)
  (when-let ((session (current-session env)))
    (user session))))

(defun current-user-p (env user)
  (when-let ((current-user (current-user env)))
    (etypecase user
      (user (= (id user) (id current-user)))
      (number (= user (id current-user)))
      (string (string= user (username current-user))))))
