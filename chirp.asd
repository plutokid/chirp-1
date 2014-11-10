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
;	       #:clsql-postgresql
               #:cl-emb
	       #:envy
	       #:cl-who
               #:clack-middleware-clsql)
  :components ((:file "package")
	       (:file "config")
	       (:file "utils")
	       (:module "classes"
			:components ((:file "base")
				     (:file "user")
				     (:file "session")
				     (:file "tag")
				     (:file "tagging")
				     (:file "mention")
				     (:file "chirp")))
	       (:file "view")
	       (:module "views"
			:components ((:file "chirps")
				     (:file "users")
				     (:file "sessions")
				     (:file "tags")))
	       (:file "db")
	       (:file "chirp")))
