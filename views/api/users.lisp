(in-package #:chirp)

;; Renders users to JSON

(defun json-show-user (user env &optional (stream *standard-output*))
  (json:with-object (stream)
    (json:encode-object-member "username" (username user) stream)
    (json:encode-object-member "followers_number" (followers-count user) stream)
    (json:encode-object-member "following_number" (follows-count user) stream)
    (json:encode-object-member "user_avatar" "/static/gusty.jpg" stream)
    (json:encode-object-member "current_user" (current-user-p env user) stream)
    (json:encode-object-member "followingp" (user-following-p (current-user env) user) stream)))
