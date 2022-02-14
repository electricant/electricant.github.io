# LaTeX Templates

I was recently looking for some instructions about templates for a presentation
written using the [Beamer](https://en.wikipedia.org/wiki/Beamer_%28LaTeX%29)
document class in LaTeX.

The aim of this page is to collect some instructions and a few bits I learned
during the process. I also plan to keep this page updated with stuff about LaTeX
in general (hopefully).

## Guides

Firs off some useful guides:

* [Beamer Theme Matrix](https://www.hartwork.org/beamer-theme-matrix/) <br>
	For choosing a base theme and its variant.
* [Better Beamer Themes](http://hamaluik.com/posts/better-beamer-themes/) <br>
	For some basic instructions on creating a theme.

## Boilerplate code

### Presentation

Now some boilerplate code for a presentation:

	\documentclass[a4paper]{beamer}
	\usetheme{%%yourtheme}

	\usepackage{mathtools}
	\usepackage{lmodern}

	\title{The Title}
	\author{Author}
	\date{\today}

	\begin{document}
	%
	%% title frame
	\begin{frame}
		\maketitle
	\end{frame}

	\begin{frame}{Another frame, with title}
		Content
	\end{frame}

	%
	%% The last frame is the same as the first one
	\begin{frame}
		\maketitle
	\end{frame}
	\end{document}

### Article

Also some code for an article:

**NOTE:** This code requires the IEEEtran document class which can be downloaded
from [here](http://www.ctan.org/tex-archive/macros/latex/contrib/IEEEtran/).
On debian-based GNU/linux systems IEEEtran and some other useful packages can be
installed with: <tt>sudo apt-get install texlive-publishers</tt>.

	\documentclass[journal, a4paper, 12pt]{IEEEtran}

	\title{The title}
	\author{The author}
	\markboth{Journal of Something}{Author name and paper title}

	\begin{document}

	\maketitle

	\begin{abstract}
		abstract
	\end{abstract}

	\begin{IEEEkeywords}
		keyword1, keyword2, ...
	\end{IEEEkeywords}

	% Sections and subsections as usual

	\end{document}

Refer to [http://www.texdoc.net/texmf-dist/doc/latex/IEEEtran/IEEEtran_HOWTO.pdf](http://www.texdoc.net/texmf-dist/doc/latex/IEEEtran/IEEEtran_HOWTO.pdf) 
for more details.

## Custom University of Padova Theme

During my PhD at the University of Padova (Department of Information
Engineering) I often need some theme for a presentation.

A good one can be found
[here](https://andrea.burattin.net/stuff/tema-latex-beamer-padova/).
I used this theme as a starting point to create my own variation, adding the
depatment logo and modifying the style a bit. Best results can be obtained using
the presentation template above. The theme assumes that the last frame is the
same as the first one.

Download the theme from
[my github repo](https://github.com/electricant/beamerThemePadovaDEI) and
install it or put the files in the same directory as your presentation. Then use
it with <tt>\usetheme\{PadovaDEI\}</tt>.

