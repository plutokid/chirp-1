(in-package #:chirp)

(defun json-chirps (chirps &optional (stream *standard-output*))
  ;let ((chirps (select 'chirp :flatp t :caching nil)))
  (json:with-array (stream)
    (dolist (chirp chirps)
      (json:as-array-member (stream)
	(json-chirp chirp stream)))))

(defun json-chirp (chirp &optional (stream *standard-output*))
  (clsql-sys:update-instance-from-records chirp)
  (if-let ((author (find-user (user-id chirp))))
    (with-slots (id content) chirp
      (json:with-object (stream)
;;	(json:encode-object-member "id" id stream)
	(json:encode-object-member "username" (username author) stream)
	(json:encode-object-member "user_url" (user-url author) stream)
	(json:encode-object-member "user_avatar" "/static/gusty.jpg" stream)
	(json:encode-object-member "content" content stream)
	(json:encode-object-member "created_at" (created-at chirp) stream)))))

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
	  ;; Request for a user page
	  ((string= request-type "user")
	   (let ((user (find-user-by-username (getf chirp-params :username))))
	     (json:with-object (s)
	       (json:as-object-member ("chirps" s)
					  (json-chirps (chirps user) s))
	       (json:as-object-member ("user" s)
		 (json-show-user user env s)))))

	  ;; Request for a tag page
	  ((string= request-type "tag")
	   (let ((text (getf chirp-params :text)))
	     (json:with-object (s)
	       (json:as-object-member ("chirps" s)
		 (json-chirps
		  (when-let ((tag (find-tag-by-text text)))
		    (mapcar #'first (chirps tag)))
		  s))
	       (json:encode-object-member "tag" text s))))
	  (t (json-error s "Not a valid request type")))
	))))

(defun json-post-chirp (env)
  (let ((chirp-params (params env :request '(:content))))
    (json-response
      (with-output-to-string (s)
	(if-let ((chirp (make-chirp-for-current-user (print (getf chirp-params :content)) env)))
	  (json:with-object (s)
	    (json:encode-object-member "result" "success" s)
	    (json:as-object-member ("chirp" s)
	      (json-chirp chirp s)))
	  (json-error s "Unable to make chirp with params ~{~a~}" chirp-params))))))
