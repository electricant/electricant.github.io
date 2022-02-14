;;;;
;;;; Source file that compiles the ipol.gq website. It starts from a theme and
;;;; a bunch of markdown files to build up the static webiste.
;;;;
;;;; USAGE:
;;;; Load this file into your lisp interpreter of choice and issue the command
;;;; (make-website)
;;;;
;;;; (c) 2017 Paolo Scaramuzza
;;;;
;;;; This program is free software: you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation, either version 3 of the License, or
;;;; (at your option) any later version.
;;;;
;;;; This program is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;; GNU General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU General Public License
;;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;;

;;; Load required packages. Adjust quicklisp location if needed
(load "~/.quicklisp/setup.lisp")
(ql:quickload "cl-markdown" :silent T)
(ql:quickload "local-time" :silent T)
(ql::quickload "cl-ppcre" :silent T)

;;;
;;; Global configuration variables
;;;

;;; Directory where the result is stored
(defparameter *target-dir* "websites/")

;;; Directory containing the pages to be compiled and their extension
(defparameter *pages-dir* "content/pages/*.md")

;;; Drectory containing the articles to be compiled and their extension
(defparameter *articles-dir* "content/articles/*.md")

;;; Character encoding to be used when reading and writing files
(defparameter *char-enc* :utf-8)

;;;
;;; Various functions and code
;;;
(load "theme/header.lisp") ; load theme header

;;; Return the article title contained in the line passed as parameter.
;;; NIL if no title is found. The title is identified by the string "# " at the
;;; beginning. A regex is used to identify and remove such string to put the
;;; title in the header.
(defun title-from-line (line)
	(multiple-value-bind (title matched) (cl-ppcre:regex-replace "# " line "")
	(if matched title)))

;;; Convert a markdown file to html and return the content as a string.
;;; The title of the article is assumed to be witin the first line, with a '#'
;;; before the actual string.
;;; It returns a list where the first element is the title (or nil if no title)
;;; and the rendered markdown
(defun render-file (filename)
  (with-open-file (in filename)
  	(let ((data (make-string (file-length in))))
  	  (read-sequence data in)
  	  (list (title-from-line (read-line (make-string-input-stream data)))
  	        (cl-markdown:render-to-stream (cl-markdown:markdown data
										      :stream nil)
  	  						  :html nil)))))

;;; Render footer from the theme. TODO: make it dynamic like the header 
(defun render-footer ()
    (with-open-file (in "theme/footer.html")
          (let ((data (make-string (file-length in))))
          	      (read-sequence data in)
          	            data)))

;;; Render the current unix timestamp as a comment. Useful to force github pages
;;; to update the website content, even if no actual change was made
(defun render-timestamp ()
	(concatenate 'string "<!-- Build timestamp: "
		(local-time:format-timestring nil (local-time:now)) " -->"))
          	            
;;; Scan the sources directories and build a list of paths as strings
(defun get-sources ()
  (append (mapcar #'namestring (directory *pages-dir*))
  		  (mapcar #'namestring (directory *articles-dir*))))

;;; Scan the sources directories and build a list of paths for compiled html
;;; targets
(defun get-destinations ()
  (append (mapcar 
  			#'(lambda (p) (concatenate 'string "website/"
  									   (pathname-name p) ".html"))
  			(directory *pages-dir*))
  		  (mapcar
  		  	#'(lambda (p) (concatenate 'string "website/articles/"
  		  							   (pathname-name p) ".html"))
  		  	(directory *articles-dir*))))

;;; Build an association list containing the path of each file and its
;;; destination file where the compiled result will be stored
(defun sources-alist ()
  (pairlis (get-sources) (get-destinations)))

;;; Compile the provided source and put the result in dest
(defun build-file (source dest)
  (let ((ostream (open dest :direction :output
  					   :if-exists :supersede
  					   :if-does-not-exist :create
  					   :external-format *char-enc*))
  		(content_html (render-file source))			   )
  	(format ostream "~a~&~a~&~a~&~a" (header-str (car content_html))
	                                 (cadr content_html)
	                                 (render-footer)
	                                 (render-timestamp))
  	(close ostream)))

;;; Make the website using the functions above
(defun make-website ()
	(mapc #'(lambda(fl) (build-file (car fl) (cdr fl))) (sources-alist)))
