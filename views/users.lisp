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
    (html-response
      (redirect-to (user-url user)))))

(defun show-user (env)
  (let* ((params (getf env :route.parameters))
	 (user   (find-user-by-username (getf params :user)))

	 (chirps (when user
		   (chirps user))))
    (html-response
      (with-layout ()
	(with-html-output-to-string (string)
	  (:h1 :class "title" (str (username user)))

	  (:ul
	   (when chirps
	     (format t "~a" chirps)
	     (loop for chirp in chirps
		do (htm
		    (:li (str (render-emb "chirp/show" (list :chirp chirp :content (format-chirp-content chirp))))))))))))))
