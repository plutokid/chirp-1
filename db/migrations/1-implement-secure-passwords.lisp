;; 1-implement-secure-passwords.lisp
(:UP (("ALTER TABLE users ADD password_digest STRING")
      ("ALTER TABLE users DROP COLUMN password"))
 :DOWN (("ALTER TABLE users ADD password STRING")
	("ALTER TABLE users DROP COLUMN password_digest")))
