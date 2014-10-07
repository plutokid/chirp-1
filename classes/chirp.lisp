(in-package #:chirp)

(defparameter *special-function-chars*
  '((#\# make-tagging)
    (#\@ make-mention)))

(clsql:def-view-class chirp ()
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null)
       :reader id)
   (user-id :type integer
	    :db-constraints :not-null
	    :reader user-id
	    :initarg :user-id)
   (author :type user
	   :db-kind :join
	   :db-info (:join-class user
		     :home-key user-id
		     :foreign-key id))
   (content :type string
	    :accessor content
	    :db-constraints :not-null
	    :initarg :content))
  (:base-table chirps))

(defun all-chirps ()
  (select 'chirp))

(defmethod extract-mentions ((chirp chirp))
  (let ((words (split-sequence #\Space (content chirp))))

    (dolist (word words)
      ;; Strip off any trailing punctuation
      (let ((word (trim-characters word)))

	;; Check if we match any of the special words
	(cond
	  ((word-is-tag-p word)
	   (make-tagging (id chirp) (subseq word 1)))
	  
	  ((word-is-mention-p word)
	   (make-mention (id chirp) (subseq word 1))))))))

(defun find-chirps-by-username (username)
  (let ((user (find-user-by-username username)))
    (when user
      (chirps user))))

(defmethod render ((chirp chirp) (format (eql :html)))
  (who:with-html-output-to-string (str)
    (:div :class "chirp"
	  (str (format nil "~{~a~^ ~}"
		       (loop for word in (split-sequence #\Space (content chirp))
			     for trimmed-word = (trim-characters word)
			     do (cond
				  ((word-is-tag-p word)
				   (htm (:a :href (format nil "/tags/~a" (subseq trimmed-word 1))
					    (str word))))

				  ((word-is-mention-p word)
				   (htm (:a :href (format nil "/users/~a" (subseq trimmed-word 1))
					    (str word))))

				  (t (str word)))))))))

