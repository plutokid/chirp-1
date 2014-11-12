(in-package #:chirp)

(def-view-class user (base)
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
   (username :type string
	     :db-constraints (:not-null :unique)
	     :accessor username
	     :initarg :username)
   (email :type string
	  :db-constraints :not-null
	  :accessor email
	  :initarg :email)
   (password-digest :type string
		    :db-constraints :not-null
		    :accessor password-digest
		    :initarg :password-digest)
   (chirps :type chirp
	   :db-kind :join
	   :db-info (:join-class chirp
		     :foreign-key user-id
		     :home-key id)
	   :accessor chirps))
  (:base-table users)
  (:extra-initargs '(:password)))

(export '(username id email chirps user-url))

;(clsql:locally-enable-sql-reader-syntax)
(file-enable-sql-reader-syntax)

(defmethod print-object ((user user) stream)
  (print-unreadable-object (user stream :type t)
    (format stream "id: ~d username: ~a" (id user) (username user))))

;; (defmethod initialize-instance :after ((user user) &rest initargs &key password &allow-other-keys)
;;   (declare (ignore initargs))
;;   (unless (slot-boundp user 'id)
;;     (setf (password user) password)))

(defmethod (setf password) (password (user user))
  (setf (password-digest user) (hash-password password)))

(defun user-url (user)
  (format nil "/users/~d" (username user)))

(defun find-user-by-username (username)
  (first (select 'user
		 :where [= [slot-value 'user 'username] username]
		 :flatp t)))

(defun find-user-by-credentials (username password)
  (let ((user (find-user-by-username username)))
    (when (check-password password (password-digest user))
      user)))

(defun find-chirps-by-username (username)
  (chirps (find-user-by-username username)))
