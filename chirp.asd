;;;; chirp.asd

(asdf:defsystem #:chirp
  :serial t
  :description "Microblah blah blah"
  :author "Matt Novenstern <fisxoj@gmail.com>"
  :license "LLGPLv3"
  :depends-on (#:clack
	       #:clack-app-route ;#:ningle
	       #:clack-middleware-csrf
               #:clsql
               #:clsql-helper
	       #:clsql-helper-slot-coercer
	       #:clsql-postgresql
               #:cl-emb
	       #:cl-json
	       #:envy
	       #:cl-who
	       #:parenscript
	       #:clack.handler.hunchensocket
	       #:sb-posix
               #:clack-middleware-clsql)
  :components ((:file "package")
	       (:file "config")
	       (:file "utils")

	       ;; Things that live in the database
	       (:module "classes"
			:components ((:file "base")
				     (:file "user")
				     (:file "session")
				     (:file "tag")
				     (:file "tagging")
				     (:file "mention")
<<<<<<< HEAD
				     (:file "chirp")))
=======
				     (:file "chirp")
				     (:file "follow")))
	       ;; Code that helps render content
>>>>>>> angularize
	       (:file "view")
	       (:module "views"
			:components ((:file "users")
				     (:file "sessions")
				     (:module "api"
<<<<<<< HEAD
					      :components ((:file "chirps")))))
=======
					      :components ((:file "chirps")
							   (:file "users")))))

	       ;; Because writing javascript was too easy
>>>>>>> angularize
	       (:module "parenscript"
			:components ((:file "package")
				     (:file "birder")
				     (:file "timeago")))

	       ;; Handling real-time notificatons
	       (:file "notifications")
	       (:file "helpers")
	       (:file "chirp")))
