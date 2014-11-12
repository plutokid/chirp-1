(in-package #:chirp)

(defun new-user (env)
  (html-response
    (with-layout ()
      (render-emb "users/new" (list :session (getf env :clack.session))))))

(defun create-user (env)
  (let* ((user-params (params env :user '(:username :password :email)))
	 (user (apply #'make-instance 'user user-params)))
    (setf (password user) (getf user-params :password))
    (update-records-from-instance user)
    (log-user-in user env)
    (redirect-to (user-url user))))

(defun show-user (env)
  (let ((params (params env)))
    (html-response
      (with-layout ()
	(render-emb "users/show" (list :username (getf params :user)))))))
