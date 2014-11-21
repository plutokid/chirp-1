;;;; chirp.asd

(asdf:defsystem #:chirp
  :serial t
  :description "Microblah blah blah"
  :author "Matt Novenstern <fisxoj@gmail.com>"
  :license "LLGPLv3"
  :depends-on (#:clack
	       #:clack-app-route ;#:ningle
	       #:clack-middleware-csrf
               #:clsql-helper
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
	       (:module "classes"
			:components ((:file "base")
				     (:file "user")
				     (:file "session")
				     (:file "tag")
				     (:file "tagging")
				     (:file "mention")
				     (:file "chirp")
				     (:file "follow")))
	       (:file "view")
	       (:module "views"
			:components ((:file "chirps")
				     (:file "users")
				     (:file "sessions")
				     (:file "tags")
				     (:module "api"
					      :components ((:file "chirps")
							   (:file "users")))))
	       (:module "parenscript"
			:components ((:file "package")
				     (:file "birder")
				     (:file "timeago")))
	       (:file "helpers")
	       (:file "chirp")))
