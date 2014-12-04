(in-package #:chirp.ps)

(export 'timeago)
(defun timeago (env)
  (declare (ignore env))
  (chirp::js-response

    (defun timeago (time)
      (let* ((periods '(("year"   31449600)
			("week"   6048000)
			("day"    86400)
			("hour"   3600)
			("minute" 60)
			("second" 1)))
	     (now (chain -date (now)))
	     (then (chain (new (-date time)) (get-time)))
	     (difference (/ (- now then) 1000))
	     (result ""))

	(when (< difference 1)
	  (return-from timeago "just now"))

	(loop
	   for (period seconds) in periods
	   for time = (floor difference seconds)
	   when (>= difference seconds)
	   do (return-from timeago
		(concatenate 'string
			     time
			     " "
			     period
			     (if (> time 1) "s " " ") "ago")))))))
