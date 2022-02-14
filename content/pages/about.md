# About this Website

This website was hosted on a VPS of mine and used to have a backend written in
[lisp](http://lispers.org/) using the
[hunchentoot](http://weitz.de/hunchentoot/) web server to serve the content.
The backend converted a bunch of markdown files on the fly when requested by
some javascript on the page.

After a while I realized that the content was mostly static and I converted the
backend into a static website generator. So here it is: a fast static website
that works without javascript. The source code is available on
[github](https://github.com/electricant/ipol.gq).

You may ask: "Why roll your own solution when there's plenty of blogging
platform and static site generators?". The answer is because I can.
<center>
	<img src="/res/img/made-with-lisp-logo.jpg" width="300" height="100"/>
</center>
