(in-package #:chirp)

(clsql:def-view-class tagging (base)
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null :auto-increment)
       :reader id)
   (created-at :type clsql:wall-time
;	       :reader created-at
	       :initform (clsql:get-time))
   (updated-at :type clsql:wall-time
;	       :accessor updated-at
	       :initform (clsql:get-time))
   (chirp-id :type integer
	     :db-constraints :not-null
	     :reader chirp-id
	     :initarg :chirp-id)
   (chirp :type chirp
	  :db-kind :join
	  :db-info (:join-class chirp
		    :foreign-key chirp-id
		    :home-key id
		    :set nil))
   (tag-id :type integer
	   :db-constraints :not-null
	   :reader tag-id
	   :initarg :tag-id)
   (tag :type tag
	:db-kind :join
	:db-info (:join-class tag
		  :home-key id
		  :foreign-key tag-id
		  :set nil)))
  (:base-table taggings))

(defun make-tagging (chirp-id tag)
  (let ((tag-id (id (ensure-find-tag-by-text tag))))
    (clsql:update-records-from-instance
     (make-instance 'tagging
		    :chirp-id chirp-id
		    :tag-id tag-id))))
