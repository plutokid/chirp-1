(in-package #:chirp)


(export 'user)
(defun json-show-user (user env &optional (stream *standard-output*))
  (json:with-object (stream)
    (json:encode-object-member "username" (username user) stream)
    (json:encode-object-member "followers_number" 0 stream)
    (json:encode-object-member "following_number" 0 stream)
    (json:encode-object-member "user_avatar" "/static/gusty.jpg" stream)
    (json:encode-object-member "current_user" (current-user-p env user) stream)))
