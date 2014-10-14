(in-package #:chirp)

(defparameter +mention-char+ #\@
  "The character that indicates someone mentions another user")

(defun show-user (params)
  (let* ((user   (find-user-by-username (getf params :user)))
	 
	 (chirps (when user
		   (chirps user))))
    
    (with-html-output-to-string (string)
      (:html
       (:body
	(:h1 (str (username user)))

	(:ul
	 (when chirps
	   (format t "~a" chirps)
	   (loop for chirp in chirps
		 do (htm
		     (:li (str (render chirp :html))))))))))))

(defun word-is-mention-p (word)
  (starts-with +mention-char+ word))
