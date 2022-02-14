# Directory Alias in Bash

Frequently I work with long paths from the terminal and typing them is tiresome
and time-consuming. So I started to search for a solution to this problem.
I thought that if I could create an alias for the path I could just type
<tt>$cd path_alias</tt> instead of the tiring and error-prone
<tt>$cd /a/very/long/path/to/write/</tt>.

After a trip to the usual search engine [this is what I found](http://stackoverflow.com/questions/17958567/how-to-make-an-alias-for-a-long-path).

The guy that asked the question was trying to make an alias for a path by
assigning it to a variable and then *cd-ing* to such variable, this way:

	myFold="~/Files/Scripts/Main"
	cd myFold

This fails because by default <tt>cd</tt> thinks that <tt>myFold</tt> is a 
folder, not a variable to be expanded. The correct command to run is:

	cd $myFold

But what if we want to get rid of the annoying <tt>$</tt>?

## Enter Shell Options

There is a [shell option](http://wiki.bash-hackers.org/internals/shell_options)
called <tt>cdable_vars</tt>. When it is set *"an argument to the cd builtin
command that is not a directory is assumed to be the name of a variable whose
value is the directory to change to"*.

As a result to make an alias to your favourite directory and make it permanent
you could add the following lines to your <tt>.bashrc</tt>:

	shopt -s cdable_vars # enable cdable_vars
	export myFold="/a/very/long/path/to/write/"

After reloading your <tt>.bashrc</tt> either by closing and reopening the
terminal or by entering the command <tt>. ~/.bashrc</tt>  no <tt>$</tt> is
required any more.

You can issue <tt>cd myFold</tt> and you will be redirected automagically to the
directory of choice.

## Caveat

The only caveat is that subdirectories within the alias do not work. For
example the following command will result in:

	cd myFold/subfolder
	bash: cd: myFold/subfolder: No such file or directory

Whereas <tt>cd $myFold/subfolder</tt> works as expected.
