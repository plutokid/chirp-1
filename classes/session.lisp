(in-package #:chirp)

(clsql:def-view-class session ()
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null)
       :reader id)
   (key :type string
	:db-constraints (:not-null)
	:reader key
	:initarg :key)
   (user-id :type integer
	    :db-constraints (:not-null)
	    :reader user-id)
   (user :type user
	 :db-kind :join
	 :db-info (:join-class user
		   :home-key user-id
		   :foreign-key id
		   :set nil)
	 :reader user
	 :initarg :user))
  (:base-table sessions))

(file-enable-sql-reader-syntax)

(defun find-session (id)
  (car (select 'session :where [= [slot-value 'session 'id] id] :flatp t)))

(defun create-session-for-user ())
