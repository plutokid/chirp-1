(in-package #:chirp)

(clsql:def-view-class tagging ()
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null)
       :reader id)
   (chirp-id :type integer
	     :db-constraints :not-null
	     :reader chirp-id
	     :initarg :chirp-id)
   (tag-id :type integer
	   :db-constraints :not-null
	   :reader tag-id
	   :initarg :tag-id))
  (:base-table taggings))

(defun make-tagging (chirp-id tag)
  (let ((tag-id (id (ensure-find-tag-by-text tag))))
    (clsql:update-records-from-instance
     (make-instance 'tagging
		    :chirp-id chirp-id
		    :tag-id tag-id))))
