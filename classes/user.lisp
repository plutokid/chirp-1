(in-package #:chirp)

(def-view-class user (base)
  ((id :type integer
       :db-kind :key
       :db-constraints (:not-null :auto-increment)
       :reader id)
   (created-at :type clsql:wall-time
;	       :reader created-at
	       :initform (clsql:get-time)
	       :initarg :created-at)
   (updated-at :type clsql:wall-time
;	       :accessor updated-at
	       :initform (clsql:get-time)
	       :initarg :updated-at)
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
		     :home-key id
		     :set t)
	   :accessor chirps)
   (sessions :type sessions
	     :db-kind :join
	     :db-info (:join-class session
		       :foreign-key user-id
		       :home-key id
		       :set t)))
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
  (format nil "/#/users/~d" (username user)))

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

;; FIXME: This is really hacky and maybe injection-unsafe
;; there's not much else I can do with clsql, though
(defun find-chirps-for-user-and-follows (user)
  (when-let ((user (find-user user)))
    (clsql-helper:db-objs
     'chirp
     (format nil
	     "SELECT chirps.content,  chirps.user_id,  chirps.created_at,  chirps.updated_at,  chirps.id
  FROM chirps
  LEFT OUTER JOIN follows ON follows.follower_id = ~d
  WHERE chirps.user_id = ~d OR chirps.user_id = follows.followee_id" (id user) (id user)))))

(defgeneric followers-count (user)
  (:method  ((user user))
    (car (format-query "SELECT COUNT(follows.*)
 FROM follows
 WHERE follows.followee_id = ~d" (id user)))))

(defgeneric follows-count (user)
  (:method ((user user))
    (car (format-query "SELECT COUNT(follows.*)
 FROM follows
 WHERE follows.follower_id = ~d" (id user)))))

(defun follow-information-for-user (user)
  (let* ((user (find-user user))
	 (follows (car (format-query "SELECT COUNT(follows.*) FROM follows WHERE follows.follower_id = ~d" (id user))))
	 (followers (car (format-query "SELECT COUNT(follows.*) FROM follows WHERE follows.followee_id = ~d" (id user)))))))

(defun user-following-p (follower followee)
  (when (and follower followee)
    (not (string= "f" (car (format-query "SELECT COUNT(follows.id) > 0
FROM follows
WHERE follows.follower_id = ~d AND follows.followee_id = ~d" (id follower) (id followee)))))))
