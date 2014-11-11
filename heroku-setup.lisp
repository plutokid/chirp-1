(in-package :cl-user)

(print ">>> Building system....")

(load (make-pathname :directory *build-dir* :defaults "chirp.asd"))

(ql:quickload :chirp)
;;; Copy wuwei public files to build

(defun heroku-toplevel ()
  (chirp:start))

;(wu:heroku-install-wupub-files)

(print ">>> Done building system")
