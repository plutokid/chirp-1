(in-package #:chirp)

(defparameter +tag-char+ #\#
  "The character that indicates a tag")

(clsql:def-view-class tag (base)
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null :auto-increment)
       :reader id)
   (created-at :type clsql:wall-time
	       :reader created-at
	       :initform (clsql:get-time))
   (updated-at :type clsql:wall-time
	       :accessor updated-at
	       :initform (clsql:get-time))
   (text :type string
	 :db-constraints :not-null
	 :reader text
	 :initarg :text)
   (chirps :type list
	   :reader chirps
	   :db-kind :join
	   :db-info (:join-class tagging
		     :home-key id
		     :foreign-key tag-id
		     :target-slot chirp
		     :set t)))
  (:base-table :tags))

(clsql:file-enable-sql-reader-syntax)

(defun find-tag-by-text (text)
  (first (clsql:select 'tag
		       :where [= [slot-value 'tag 'text] text]
		       :flatp t)))

(defun ensure-find-tag-by-text (text)
  (let ((tag (find-tag-by-text text)))
    (unless tag
      (setf tag (make-instance 'tag :text text))
      (clsql:update-records-from-instance tag))
    tag))

(defun word-is-tag-p (word)
  (starts-with +tag-char+ word))
