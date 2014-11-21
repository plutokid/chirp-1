(in-package #:chirp)

(defparameter +view-classes+ '(user chirp tag tagging mention session))

(defun create-tables ()
  ;; Only try to create the database if we're in debug (local computer) mode
  (if (envy:config :chirp.config :debug)
      (unless (clsql-sys:probe-database (envy:config :chirp.config :connection-spec))
	(clsql-sys:create-database
	 (envy:config :chirp.config :connection-spec)
	 :database-type (envy:config :chirp.config :database-type))))

  (clsql:with-database
      (db (envy:config :chirp.config :connection-spec)
	  :database-type (envy:config :chirp.config :database-type))

    (dolist (class +view-classes+)
      (unless (clsql:table-exists-p (clsql:sql-view-class class) :database db)
	(clsql:create-view-from-class class :database db)))))

(defun drop-tables ()
    (unless (clsql-sys:probe-database (envy:config :chirp.config :connection-spec))
    (clsql-sys:create-database
     (envy:config :chirp.config :connection-spec)
     :database-type (envy:config :chirp.config :database-type)))

  (clsql:with-database
      (db (envy:config :chirp.config :connection-spec)
	  :database-type (envy:config :chirp.config :database-type))

    (dolist (class +view-classes+)
      (if (clsql:table-exists-p (clsql:sql-view-class class) :database db)
	(clsql:drop-view-from-class class :database db)))))

(defun ensure-environment ()
  (unless (sb-posix:getenv "APP_ENV")
    (sb-posix:setenv "APP_ENV" "development" 0))

  ;; (load (merge-pathnames "config.lisp"
  ;; 			 (envy:config :chirp.config :application-root)))
  )

(defun connect-to-db ()
  (clsql:connect (envy:config :chirp.config :connection-spec) :database-type (envy:config :chirp.config :database-type) ))
