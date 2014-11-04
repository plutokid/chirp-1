(in-package #:chirp)

(defvar *layout-directory* #P"templates/")
(defvar *default-layout-path* #P"default.html.emb")
(defvar +static-file-path+ "static/")
(defvar *static-files* nil)

(defmacro html-response (&body body)
  ``(200
     (:content-type "text/html")
     ,,@body))

(defmacro redirect-to (url &body body)
  ``(302
    (:location ,,url)
    ,,@body))

(defmacro find-static-files ()
  (let ((scanner (ppcre:create-scanner +static-file-path+)))
    (setf *static-files*
	  (mapcar (lambda (path)
		    (ppcre:scan-to-strings scanner (format nil "~a" path)))
		  (fad:list-directory +static-file-path+)))))

(defun render-emb (template-path &optional env)
  (let ((emb:*escape-type* :html)
        (emb:*case-sensitivity* nil)
	(template-path (if (ends-with template-path ".html.emb" :test #'string=)
			   template-path
			   (concatenate 'string template-path ".html.emb"))))
    (emb:execute-emb
     (merge-pathnames template-path
                      *layout-directory*)
     :env env)))

(defmacro with-layout ((&rest env-for-layout) &body body)
  (let ((layout-path (merge-pathnames *default-layout-path*
                                      *layout-directory*)))
    (when (pathnamep (car env-for-layout))
      (setf layout-path (pop env-for-layout)))

    `(let ((emb:*escape-type* :html)
           (emb:*case-sensitivity* nil))
       (emb:execute-emb ,layout-path
        :env (list :_content (progn ,@body)
                   ,@env-for-layout)))))

(defun emb-helper (symbol)
  "Imports a symbol into the cl-emb-intern package, where it will be available for use at template time."
  (let ((symbols (if (listp symbol) symbol (list symbol))))
    (print symbols)
    (shadowing-import symbols cl-emb:*function-package*)))
