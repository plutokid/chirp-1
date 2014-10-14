(in-package #:chirp)

(def-view-class user ()
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null)
       :reader id)
   (username :type string
	     :db-constraints :not-null
	     :accessor username
	     :initarg :username)
   (email :type string
	  :db-constraints :not-null
	  :accessor email
	  :initarg :email)
   (password :type string
	     :db-constraints :not-null
	     :accessor password
	     :initarg :password)
   (chirps :type chirp
	   :db-kind :join
	   :db-info (:join-class chirp
		     :foreign-key user-id
		     :home-key id)
	   :accessor chirps))
  (:base-table users))

;(clsql:locally-enable-sql-reader-syntax)
(file-enable-sql-reader-syntax)

(defun user-url (user)
  (format nil "/user/~d"
	  (typecase user
	    (user (id user))
	    (number user))))

(defun find-user-by-username (username)
  (first (select 'user
		 :where [= [slot-value 'user 'username] username]
		 :flatp t)))

(defun find-chirps-by-username (username)
  (chirps (find-user-by-username username)))
