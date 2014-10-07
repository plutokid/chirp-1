(in-package #:chirp)

(defparameter +char-bag+
  '(#\, #\. #\: #\; #\! #\" #\'))

(defun trim-characters (string)
  (string-right-trim +char-bag+ string))
