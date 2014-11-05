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
	   :reader author
	   :db-kind :join
	   :db-info (:join-class user
		     :home-key user-id
		     :foreign-key id
		     :set nil))
   ;; FIXME: Through associations?
   (mentions :type list
	     :db-kind :join
	     :db-info (:join-class mention
		       :home-key id
		       :foreign-key chirp-id
		       :target-slot mention
		       :set t))
   (tags :type list
	 :reader tags
	 :db-kind :join
	 :db-info (:join-class tagging
			       :home-key id
			       :foreign-key chirp-id
		   :target-slot tag
		   :set t))
   (content :type string
	    :accessor content
	    :db-constraints :not-null
	    :initarg :content))
  (:base-table chirps))

(export '(content content id author mentions format-chirp-content))

;; (defmethod initialize-instance :after ((chirp chirp) &rest initargs)
;;   (declare (ignore initargs))
;;   (when (slot-boundp chirp 'id)
;;     (clsql:update-records-from-instance chirp)
;;     (extract-mentions chirp)))

(file-enable-sql-reader-syntax)

(defun all-chirps ()
  (select 'chirp))

(defmethod extract-mentions ((chirp chirp))
  (let ((words (split-sequence #\Space (content chirp))))

    (dolist (word words)
      (print word)
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

(defun find-chirp (id)
  (first (select 'chirp :where [= [slot-value 'chirp 'id] id] :flatp t)))

(defun chirp-url (chirp)
  (format nil "/chirps/~d" (typecase chirp
			     (chirp (id chirp))
			     (number chirp))))

(defmethod render ((chirp chirp) (format (eql :html)))
  ;; (who:with-html-output-to-string (str)
  ;;   (:div :class "chirp"
  ;; 	  (str (format nil "~{~a~^ ~}"
  ;; 		       (loop for word in (split-sequence #\Space (content chirp))
  ;; 			     for trimmed-word = (trim-characters word)
  ;; 			     do (cond
  ;; 				  ((word-is-tag-p word)
  ;; 				   (htm (:a :href (format nil "/tags/~a" (subseq trimmed-word 1))
  ;; 					    (str word))))

  ;; 				  ((word-is-mention-p word)
  ;; 				   (htm (:a :href (format nil "/users/~a" (subseq trimmed-word 1))
  ;; 					    (str word))))

  ;; 				  (t (str word))))))))

  (format-chirp-content (content chirp)))

(defun make-link (word)
  (print word)
  (let ((trimmed-word (trim-characters word)))
    (who:with-html-output-to-string (str)
      (cond
	((word-is-tag-p word)
	 (htm (:a :href (format nil "/tags/~a" (subseq trimmed-word 1))
		  (str word))))

	((word-is-mention-p word)
	 (htm (:a :href (format nil "/users/~a" (subseq trimmed-word 1))
		  (str word))))))))

(defun format-chirp-content (chirp)
  (let ((body (content chirp)))
    (with-output-to-string (out)
      (with-input-from-string (in body)
	(let ((word nil)
	      (reading nil))
	  (loop for c = (read-char in nil :eof)
	     until (eq c :eof)
	     do (cond
		  ((member c +char-bag+)

		   (write-string (make-link (coerce (nreverse word) 'string)) out)
		   (write-char c out)
		   (setf reading nil
			 word nil))

		  ((member c '(#\# #\@))
		   (setf reading t)
		   (push c word))

		  (reading
		   (push c word))

		  (t (write-char c out)))))))))
