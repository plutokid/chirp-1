(in-package #:chirp)

(defun json-chirps (chirps &optional (stream *standard-output*))
  ;let ((chirps (select 'chirp :flatp t :caching nil)))
  (json:with-object (stream)
    (json:as-object-member ("chirps" stream)
      (json:with-array (stream)
	(dolist (chirp chirps)
	  (json:as-array-member (stream)
	    (json-chirp chirp stream))
	  )))))

(defun json-chirp (chirp &optional (stream *standard-output*))
  (clsql-sys:update-instance-from-records chirp)
  (with-slots (id author) chirp
      (json:with-object (stream)
	(json:encode-object-member "id" id stream)
	(json:encode-object-member "username" (username author) stream)
	(json:encode-object-member "user-url" (user-url author) stream)
	(json:encode-object-member "content" (format-chirp-content chirp) stream)
	(json:encode-object-member "created-at" (created-at chirp) stream))))

(defun json-error (stream datum &rest arguments)
  (json:with-object (stream)
    (json:encode-object-member "result" "error" stream)
    (json:encode-object-member "message" (apply #'format nil datum arguments) stream)))

(clsql:file-enable-sql-reader-syntax)

(defun json-show-chirps (env)
  (json-response
    (with-output-to-string (s)
      (let* ((chirp-params (params env :request '(:type :username :text)))
	     (request-type (string-downcase (getf chirp-params :type))))
	(cond
	  ((string= request-type "user")
	   (json-chirps (find-chirps-by-username (getf chirp-params :username)) s))
	  ((string= request-type "tag")
	   (json-chirps (when-let ((tag (find-tag-by-text (getf chirp-params :text))))
			  (mapcar #'first (chirps tag)))
			s))
	  (t (json-error s "Not a valid request type")))
	))))
