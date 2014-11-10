(in-package #:chirp)

(defun json-chirps (&optional (stream *standard-output*))
  (let ((chirps (select 'chirp :flatp t)))
    (json:with-object (stream)
      (json:as-object-member ("chirps" stream)
	(json:with-array (stream)
	  (dolist (chirp chirps)
	    (json:as-array-member (stream)
	      (json-chirp chirp stream))
	    ))))))

(defun json-chirp (chirp &optional (stream *standard-output*))
  (with-slots (id author) chirp
      (json:with-object (stream)
	(json:encode-object-member "id" id stream)
	(json:encode-object-member "username" (username author) stream)
	(json:encode-object-member "user-url" (user-url author) stream)
	(json:encode-object-member "content" (format-chirp-content chirp) stream)
	(json:encode-object-member "created_at" (created-at chirp) stream))))
