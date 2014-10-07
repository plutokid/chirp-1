;;;; chirp.asd

(asdf:defsystem #:chirp
  :serial t
  :description "Microblah blah blah"
  :author "Matt Novenstern <fisxoj@gmail.com>"
  :license "LLGPLv3"
  :depends-on (#:ningle
	       #:clack-middleware-csrf
               #:clsql
;	       #:clsql-postgresql
               #:cl-emb
	       #:cl-who
               #:clack-middleware-clsql)
  :components ((:file "package")
	       (:file "utils")
	       (:module "classes"
		:components ((:file "user")
			     (:file "tag")
			     (:file "tagging")
			     (:file "mention")
			     (:file "chirp")))
	       (:file "user")
	       (:file "db")
	       (:file "chirp")))
