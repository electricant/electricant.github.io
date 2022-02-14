# Start PostgreSQL on Debian 8

I run a small NAS computer at home for network file sharing and RSS feed
fetching through
[Tiny Tiny RSS](https://tt-rss.org/gitlab/fox/tt-rss/wikis/home).

The hardware is a regular low-power computer running Debian 8. Overall this
setup is running fine, requiring moderate amount of mantainance.

Recently, after an update, PostgreSQL stopped working and I was unable to access
to my beloved RSS feeds. Apparently something was changed in the way Debian
starts Postgres via systemd. Now to start and or enable it the version you want
to run has to be specified.

For example the command to start the service is:

`systemctl start postgresql@9.4-main`

Whereas to enable it:

`systemctl enable postgresql@9.4-main`

If there is more than one version of the software installed that has to be run,
then such version has to be specified after the <tt>@</tt> symbol.

For more details see [this mailing-list entry](http://www.postgresql.org/message-id/CAFyxdeSZh=Fv6nikh1_WqAtyKc0nmKTdTvj8-+JzYw-GobZnzw@mail.gmail.com)
which states the problem but does not give a complete solution.
