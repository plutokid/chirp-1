(in-package #:chirp)

(clsql:def-view-class mention ()
  ((id :type integer
       :db-type :key
       :reader id)
   (chirp-id :type integer
	     :db-constraints :not-null
	     :reader chirp-id
	     :initarg :chirp-id)
   (chirp :type chirp
	  :db-kind :join
	  :db-info (:join-class chirp
		    :home-key chirp-id
		    :foreign-key id))
   (user-id :type integer
	    :db-constraints :not-null
	    :reader user-id
	    :initarg :user-id))
  (:base-table mentions))

(defun make-mention (chirp-id username)
  (let* ((user-id (find-user-by-username username))
	 (mention (make-instance 'mention
				 :user-id user-id
				 :chirp-id chirp-id)))
    (clsql:update-records-from-instance mention)))
