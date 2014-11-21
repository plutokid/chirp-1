(in-package #:chirp)

(defun show-chirp (env)
  (html-response
    (let ((chirp (find-chirp (parse-integer (getf (params env) :id)))))
      (with-layout ()
	(render-emb "chirp/show" `(:chirp ,chirp, :content ,(format-chirp-content chirp)))))))

(defun new-chirp (env)
  (html-response
    (with-layout ()
      (render-emb "chirp/form"
		  (print (list :session (getf env :clack.session)))))))

(defun create-chirp (env)
  (let* ((chirp-params (append (params env :chirp '(:content)) `(:user-id ,(id (user (current-session env))))))
	 (chirp (apply #'make-instance 'chirp chirp-params)))
    (update-records-from-instance chirp)
    (extract-references chirp)
    (redirect-to (chirp-url chirp))))
