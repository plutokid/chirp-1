(in-package #:chirp)

(defun create-tables ()
  (unless (clsql-sys:probe-database (envy:config :chirp.config :connection-spec))
    (clsql-sys:create-database (envy:config :chirp.config :connection-spec)))

  (clsql:with-database (db (envy:config :chirp.config :connection-spec)
			   :database-type (envy:config :chirp.config :database-type))

    (dolist (class '(user chirp tag tagging mention session))
      (unless (clsql:table-exists-p class)
	(clsql:create-view-from-class class)))))

(defun ensure-environment ()
  (unless (sb-posix:getenv "APP_ENV")
    (sb-posix:setenv "APP_ENV" "development" 0)))
