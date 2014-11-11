(defpackage #:chirp.config
  (:use :cl
	:envy))

(in-package #:chirp.config)

(setf (config-env-var) "APP_ENV")

(defun db-spec (env)
  (list "localhost" (format nil "chirp_~a" (string-downcase env)) "" ""))


(defconfig :common
    (let ((base-pathname (asdf:component-pathname (asdf:find-system :chirp))))
      `(:application-root ,base-pathname
			  :database-type :postgresql)))

(defun read-secrets ()
  (handler-case
      (read-from-string
       (alexandria:read-file-into-string
	(merge-pathnames ".crypto.sexp"
			 (envy:config :chirp.config :application-root))))
    (error () (list :random-salt (asdf::getenv "RANDOM_SALT")))))

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
	     :connection-spec ,(db-spec :production)
	     :random-salt (asdf::getenv "RANDOM_SALT")))

;; (defconfig :default
;;     `(,@|development|))
