(in-package #:chirp)

(defun show-tag (env)
  (let ((tag (find-tag-by-text (getf (params env) :tag))))
    (html-response
      (with-layout ()
	(who:with-html-output-to-string (str)
	  (:h1 (str (text tag)))

	  (:ul (loop for (chirp tagging) in (chirps tag)
		  do (clsql:update-instance-from-records chirp)
		  do (htm (:li (str (render-emb "chirp/show"
						(list :chirp chirp
						      :content (format-chirp-content chirp)))))))))))))
