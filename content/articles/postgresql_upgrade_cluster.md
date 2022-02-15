# Upgrading PostgreSQL Clusters

## Introduction

I own a Debian PC that is used as Network Attached Storage (NAS) and runs
PostgreSQL&#8239;[\[1\]][1] with data files stored on a Btrfs RAID1
filesystem&#8239;[\[2\]][2]. As expected, with every new Debian release comes a
new major version of the PostgreSQL database which is not compatible with the
internal data storage format of the previous one. This requires upgrading the on
disk data files before using the new database server&#8239;[\[3\]][3].

At the time of writing, a new stable release of Debian is available roughly
every two years with the oldstable entering end of life (EOL) one year after 
the latest stable has been released&#8239;[\[4\]][4]. It goes without saying
that, every time I upgrade Debian on such PC, I have to rediscover once again
how to also upgrade PostgreSQL. This guide will hopefully save some time to my
future self by offering a step-by-step summary of some guides available online,
which are incomplete and/or
outdated&#8239;[\[5\]][5]&#8239;[\[6\]][6]&#8239;[\[7\]][7].

## Upgrade Process

The following steps assume a fresh installation of PostgreSQL from the official
Debian packages.

Right after installation, the new version is automatically started alongside
the old one. The command:

	# systemctl | grep postgres

will show the two corresponding unit files as
<tt>postgresql@[version]-[cluster]</tt> both of which should be listed as
running.

The first step is changing the configuration file of the new server to point to
the database directory of the RAID array. To do so, the server must be stopped
and the database reinitialized after changing the <tt>data_directory</tt> option
of <tt>/etc/postgresql/[version]/[cluster]/postgresql.conf</tt>. To make any
future migration or update process easier, it's best to have a different folder
for each postgres version and cluster. Once the configuration file has been
changed, it's time to initialize the new database (as the user postgres):

	# su postgres
	(postgres)# /usr/lib/postgresql/[new version]/bin/initdb \
			-D [mountpoint]/pgsql/[new version]/[cluster]
	(postgres)# exit
	# sudo systemctl restart postgresql@[new version]-[cluster]

The new server should restart smoothly using
<tt>[mountpoint]/pgsql/[new version]/[cluster]</tt> as the data directory. If
not, double check the config file.

If the step above succeeded, it's time to perform the actual migration. To do
so, stop all the services using PostgreSQL and the old and new database servers.

	# sudo systemctl stop postgresql@[old version]-[cluster]
	# sudo systemctl stop postgresql@[new version]-[cluster]  

Before migrating, it's wise to perform a check to verify that the source and
destination clusters are actually compatible. Only if the check succeeds we'll
eventually migrate the data. Please note that the option <tt>--link</tt> of
<tt>pg_upgrade</tt> has not been used on purpose: albeit it makes the migration
process faster, if something goes wrong, the cluster will remain in some
half-backed state requiring unspecified command-line voodoo to restore it. By
not using such option, the old cluster will always be available, the new data
directory can be deleted and the migration process can be restarted.

**NOTE:** With all the services and the database server stopped, performing a
backup of the old cluster is a clever idea. No seriously, do it now before it's
too late.

To start the migration run the following commands as the postgres user and
double check that they are run from postgres' home directory:
	
	# su postgres
	(postgres)# cd ~
	(postgres)# /usr/lib/postgresql/[new version]/bin/pg_upgrade \
			--old-datadir "[mountpoint]/pdsql/[old version]/[cluster]" \
			--new-datadir "[mountpoint]/pdsql/[new version]/[cluster]" \
			--old-bindir "/usr/lib/postgresql/[old version]/bin" \
			--new-bindir "/usr/lib/postgresql/[new version]/bin" \
			--old-options '-c config_file=/etc/postgresql/[old version]/[cluster]/postgresql.conf' \
			--new-options '-c config_file=/etc/postgresql/[new version]/[cluster]/postgresql.conf' \
			--check
	
Inspect carefully the output of the command above for any error. If none, the
<tt>--check</tt> option can be removed to start the actual upgrade:

	(postgres)# /usr/lib/postgresql/[new version]/bin/pg_upgrade \
			--old-datadir "[mountpoint]/pdsql/[old version]/[cluster]" \
			--new-datadir "[mountpoint]/pdsql/[new version]/[cluster]" \
			--old-bindir "/usr/lib/postgresql/[old version]/bin" \
			--new-bindir "/usr/lib/postgresql/[new version]/bin" \
			--old-options '-c config_file=/etc/postgresql/[old version]/[cluster]/postgresql.conf' \
			--new-options '-c config_file=/etc/postgresql/[new version]/[cluster]/postgresql.conf' \
			--jobs [number of cpus]

Wait a few minutes hoping for the best and voilà the new data directory should
contain a migrated copy of the old cluster. If the commands above are run from
ssh, I suggest using <tt>screen</tt> or <tt>tmux</tt> to be able to reconnect to
your session in case ssh hangs for whatever reason.

As a final step, swap the old PostgreSQL server with the new one by setting the
option <tt>port=5232</tt> in
<tt>/etc/postgresql/[new version]/[cluster]/postgresql.conf</tt>, disable the
old server and start the new one.

	# systemctl disable postgresql@[old version]-[cluster]
	# systemctl enable --now postgresql@[new version]-[cluster]

Since optimizer statistics are not transferred by the <tt>pg_upgrade</tt>
command, restore them with:

	# su postgres
	(postgres)# cd ~
	(postgres)# ./analyze_new_cluster.sh

Once finished, the services depending on PostgreSQL can be restarted and should
work as usual. If not, since the old data directory is still available, the new
server can be swapped for the old one to see what went wrong.

The following commands will delete the old cluster's data files:
	
	# su postgres
	(postgres)# cd ~
	(postgres)# ./delete_old_cluster.sh

I usually keep the old data around for a while (until the next migration
actually) so that I always have and old copy laying around. Better be safe than
sorry.

## Further Reading

\[1\] [Start PostgreSQL on Debian 8][1]
[1]: /articles/postgresql_start_debian.html

\[2\] [A Note About Btrfs RAID1 for my Future Self][2]
[2]: /articles/note_btrfs_raid1.html

\[3\] [Upgrading a PostgreSQL Cluster][3]
[3]: https://www.postgresql.org/docs/current/upgrading.html

\[4\] [Production Releases - Debian Wiki][4]
[4]: https://wiki.debian.org/DebianReleases#Production_Releases

\[5\] [PostgreSQL Migration - Debian Wiki][5]
[5]: https://wiki.debian.org/PostgreSql#Migration

\[6\] [Using pg upgrade on Ubuntu/Debian - PostgreSQL Wiki][6]
[6]: https://wiki.postgresql.org/wiki/Using_pg_upgrade_on_Ubuntu/Debian

\[7\] [DebianGis/UpdatingPostGIS - Debian Wiki][7]
[7]: https://wiki.debian.org/DebianGis/UpdatingPostGIS

