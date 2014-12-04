(in-package #:chirp)

(def-view-class base ()
  (
   ;; (id :type integer
   ;;     :db-kind :key
   ;;     :db-constraints (:not-null :auto-increment)
   ;;     :reader id)
   ;; (created-at :type clsql:wall-time
   ;; 	       :reader created-at
   ;; 	       :initform (clsql:get-time))
   ;; (updated-at :type clsql:wall-time
   ;; 	       :accessor updated-at
   ;; 	       :initform (clsql:get-time))
   ))

;; (defmethod print-object ((object base) stream)
;;   (let ((class (class-of object)))
;;     (print-unreadable-object (object stream :type t :identity t)
;;       (loop
;; 	 for slot in (sb-mop:class-direct-slots class)
;; 	 for slot-name = (sb-mop:slot-definition-name slot)

;; 	 when (slot-boundp object slot-name)
;; 	 do (format stream "~a = ~a"
;; 		    slot-name
;; 		    (sb-mop:slot-value-using-class class object slot))))))

(defmethod clsql:update-records-from-instance :before ((object base) &key database)
  (declare (ignore database))
  (setf (updated-at object) (clsql:get-time)))

(defmethod created-at ((object base))
  (clsql:iso-timestring (slot-value object 'created-at)))

(defmethod (setf created-at) (datetime (object base))
  (setf (slot-value object 'created-at) datetime))


(defmethod updated-at ((object base))
  (clsql:iso-timestring (slot-value object 'updated-at)))

(defmethod (setf updated-at) (datetime (object base))
  (setf (slot-value object 'updated-at) datetime))
