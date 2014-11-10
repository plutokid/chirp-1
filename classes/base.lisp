(in-package #:chirp)

(def-view-class base ()
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null)
       :reader id)
   (created-at :type clsql:wall-time
	       :reader created-at
	       :initform (clsql:get-time))
   (updated-at :type clsql:wall-time
	       :accessor updated-at
	       :initform (clsql:get-time))))

(defmethod clsql:update-records-from-instance :before ((object base) &key database)
  (declare (ignore database))
  (setf (updated-at object) (clsql:get-time)))

(defmethod created-at ((object base))
  (clsql:iso-timestring (slot-value object 'created-at)))

(defmethod updated-at ((object base))
  (clsql:iso-timestring (slot-value object 'updated-at)))
