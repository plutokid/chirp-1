(in-package #:chirp)

(def-view-class follow (base)
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
   (follower-id :type integer
		:initarg :follower-id
		:accessor follower-id)
   (follower :type user
	     :db-kind :join
	     :db-info (:join-class user
		       :foreign-key id
		       :home-key follower-id
		       :set nil)
	     :accessor follower)
   (followee-id :type integer
		:initarg :followee-id
		:accessor followee-id)
   (followee :type user
	     :db-kind :join
	     :db-info (:join-class user
		       :foreign-key id
		       :home-key followee-id
		       :set nil)
	     :accessor followee))
  (:base-table follows))
