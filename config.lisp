(defpackage #:chirp.config
  (:use :cl
	:envy)
  (:export #:configure))

(in-package #:chirp.config)

(setf (config-env-var) "APP_ENV")

(defun db-spec (env &optional (host "localhost"))
  (list host (format nil "chirp_~a" (string-downcase env)) "" ""))

(defun production-db-spec ()
  "Heroku database url format is postgres://username:password@host:port/database_name.
TODO: cleanup code."
  (let* ((url (second (cl-ppcre:split "//" (asdf::getenv "DATABASE_URL"))))
	 (user (first (cl-ppcre:split ":" (first (cl-ppcre:split "@" url)))))
	 (password (second (cl-ppcre:split ":" (first (cl-ppcre:split "@" url)))))
	 (host (first (cl-ppcre:split ":" (first (cl-ppcre:split "/" (second (cl-ppcre:split "@" url)))))))
	 (database (second (cl-ppcre:split "/" (second (cl-ppcre:split "@" url))))))
    (list database user password host)))


(defun read-secrets ()
  (let ((base-pathname (asdf:component-pathname (asdf:find-system :chirp))))
    (handler-case
	(read-from-string
	 (alexandria:read-file-into-string
	  (merge-pathnames ".crypto.sexp"
			   base-pathname)))
      (error () (list :random-salt (asdf::getenv "RANDOM_SALT"))))))

(defun configure ()


  (defconfig :common
      (let ((base-pathname (asdf:component-pathname (asdf:find-system :chirp))))
	`(:application-root ,base-pathname
			    :database-type :postgresql)))

  (defconfig |development|
      `(:debug t
	       :connection-spec ,(db-spec :dev)
	       ,@(read-secrets)))

  (defconfig |test|
      `(:debug t
	       :connection-spec ,(db-spec :test)
	       ,@(read-secrets)))

  (defconfig |production|
      `(:debug nil
	       :connection-spec ,(production-db-spec)
	       :random-salt ,(asdf::getenv "RANDOM_SALT"))))

;; (defconfig :default
;;     `(,@|development|))
