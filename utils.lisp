(in-package #:chirp)

(defparameter +char-bag+
  '(#\, #\. #\: #\; #\! #\" #\' #\Space))

(defun trim-characters (string)
  (string-right-trim +char-bag+ string))

;; (params env '(:user (:username :password :email)))

(defun keywordify-plist (plist)
  (loop
     for val in plist
     for i from 0 by 1
     if (evenp i)
     collect (make-keyword val)
     else
     collect val))

(defun params (env &optional require permits)
  (let* ((request (clack.request:make-request env))
	 (body-params (slot-value request 'clack.request::body-parameters))
	 (all-parameters (append
			  (remove-from-plist body-params :json)
			  (slot-value request 'clack.request::query-parameters)
			  (keywordify-plist (hash-table-plist (getf body-params :json (make-hash-table)))))))

    ;; Route parameters don't get whitelisted
    (append
     (when (and require permits)
       (loop
	  for key in permits
	  for value = (getf all-parameters (make-keyword (string-downcase (format-param (list require key)))))
	  append (list (keywordify key) value)))
     (getf env :route.parameters))))

(defun format-param (keys)
  (format nil "~{~a~@{[~a]~}~}" keys))

(defun keywordify (string)
  (make-keyword (string-upcase string)))

(defun check-password (password digest)
  (let ((password-vector (ironclad:ascii-string-to-byte-array password)))

    (ironclad:pbkdf2-check-password password-vector digest)))

(defun hash-password (string)
  "Creates a hex string of an ascii password combined with the random-salt"

  (let ((salt (ironclad:hex-string-to-byte-array
	       (getf (envy:config :chirp.config) :random-salt)))
	(password-bytes (ironclad:ascii-string-to-byte-array string)))

    (ironclad:pbkdf2-hash-password-to-combined-string password-bytes :salt salt)))

(defun random-hex-string ()
  (ironclad:byte-array-to-hex-string (ironclad:make-random-salt)))

(defun format-query (query &rest args)
  "Works like #'format but tastes like SQL"
  (clsql:query (apply #'format nil query args) :flatp t :field-names nil))
