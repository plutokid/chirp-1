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
			  :database-type :postgresql
			  ,@(read-from-string
			     (alexandria:read-file-into-string
			      (merge-pathnames ".crypto.sexp"
					       base-pathname))))))

(defconfig |development|
    `(:debug t
	     :connection-spec ,(db-spec :dev)))

(defconfig |test|
    `(:debug t
	     :connection-spec ,(db-spec :test)))

;; (defconfig :default
;;     `(,@|development|))
