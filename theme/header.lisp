(defun header-str (extratitle)
(concatenate 'string "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<meta charset=\"utf-8\">
<meta name=\"HandheldFriendly\" content=\"True\">
<meta name=\"MobileOptimized\" content=\"320\">
<meta name=\"description\" content=\"Pol's website. " extratitle "\"/>

<link rel=\"icon\" type=\"image/png\" sizes=\"192x192\" href=\"/res/img/favicon192.png\">
<link rel=\"icon\" type=\"image/png\" sizes=\"128x128\" href=\"/res/img/favicon128.png\">
<link rel=\"icon\" type=\"image/png\" sizes=\"64x64\" href=\"/res/img/favicon64.png\">
<link rel=\"shortcut-icon\" type=\"image/png\" href=\"/res/img/favicon64.png\">

<link rel=\"stylesheet\" href=\"/res/css/style.css\">
<link rel=\"styleshet\" href=\"/res/css/foundation-icons.css\">

<title>Paolo Scaramuzza" (if extratitle (concatenate 'string " | " extratitle))
"</title>
</head>
<body>
<div class=\"header\">
	<div class=\"headerdata\">
		<h1><a class=\"homelink\" href=\"/\">Paolo Scaramuzza</a></h1>
	</div>
	<div class=\"navbar\">
		<a href=\"/\">HOME</a> |
		<a href=\"/article-index.html\">ARTICLES</a> |
		<a href=\"/random.html\">RANDOM STUFF</a> |
		<a href=\"/now.html\">NOW</a> |
		<a href=\"/about.html\">ABOUT</a>
	</div>
</div>

<div id=\"content\" class=\"content\">
	<div id=\"text\" class=\"tile text\">
	<!-- Article text -->
"))
