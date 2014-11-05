(in-package #:chirp)

(defparameter +mention-char+ #\@
  "The character that indicates someone mentions another user")

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
		    :foreign-key id
		    :set nil))
   (user-id :type integer
	    :db-constraints :not-null
	    :reader user-id
	    :initarg :user-id)
   (user :type user
	 :db-class :db-join
	 :db-info (:join-class user
		   :home-key user-id
		   :foreign-key id
		   :set nil)))
  (:base-table mentions))

(defun make-mention (chirp-id username)
  (let* ((user (find-user-by-username username))
	 (mention (make-instance 'mention
				 :user-id (id user)
				 :chirp-id chirp-id)))
    (clsql:update-records-from-instance mention)))

(defun word-is-mention-p (word)
  (starts-with +mention-char+ word))
