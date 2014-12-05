(in-package #:chirp)

(defparameter *special-function-chars*
  '((#\# make-tagging)
    (#\@ make-mention)))

(clsql:def-view-class chirp (base)
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null :auto-increment)
       :reader id)
   (created-at :type clsql:wall-time
;	       :reader created-at
	       :initform (clsql:get-time)
	       :initarg :created-at )
   (updated-at :type clsql:wall-time
	       ;;	       :accessor updated-at
	       :initform (clsql:get-time)
	       :initarg :updated-at)
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

(defun make-chirp-for-current-user (content env)
  (when-let ((user (current-user env)))
    (let ((chirp (make-instance 'chirp :content content :user-id (id user))))
      (update-records-from-instance chirp)
      (extract-references chirp)
      (notify-followers-for-chirp chirp user)
      chirp)))

(defun extract-references (chirp)
  (let ((body (content chirp)))
    (with-input-from-string (in body)
      (let ((word nil)
	    (reading nil))
	(loop for c = (read-char in nil :eof)
	   until (eq c :eof)
	   do (cond
		((and (member c +char-bag+) word)

		 (let ((reference (coerce (nreverse word) 'string)))
		   (funcall (ecase (char reference 0)
			      (#\# #'make-tagging)
			      (#\@ #'make-mention))
			    (id chirp)
			    (subseq reference 1)))

		 (setf reading nil
		       word nil))

		((member c '(#\# #\@))
		 (setf reading t)
		 (push c word))

		(reading
		 (push c word))))))))

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
  (format-chirp-content (content chirp)))

(defun make-link (word)
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
