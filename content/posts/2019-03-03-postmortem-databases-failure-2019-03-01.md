---
title: Postmortem of databases failure on 2019-03-01
tags:
  - postgresql
  - mysql
categories:
  - postmortem
date: 2019-03-03T16:26:00-0800
---

> #### Note to the reader
>
> This article was written a long ago and thus: it isn't up-to-date with my
> current policy for upgrades and migrations, it isn't a good postmortem,
> you probably shouldn't be reading this. I decided to publish it anyway because
> I think it can help newcomers to the world of self-hosting to see that
> everyone makes mistakes.

Sometime around 2019-03-01 02:22:11 UTC
[Mattermost](https://chat.lama-corp.space) stopped working because it couldn't
communicate with its database (PostgreSQL).

## Some duck RDBM context

Before the incident, there were two databases installed at their default
locations: MariaDB and PostgreSQL. An maintenance operation was to be performed
on both of them, in order to move their data folder to an external disk
connected to the VPS in order to facilitate backup and migration of data.
During this migration, all services relying on those databases (MariaDB:
[PrivateBin](https://bin.risson.space), [Polr](https://u.risson.me),
[42over2/CatCatch](https://42over2.ovh), [Zabbix](https://bird.risson.space) ;
PostgreSQL: [Mattermost](https://chat.lama-corp.space)) would be down as it
required to shutdown MariaDB and PostgreSQL, but it wasn't considered a problem
as it was night time in France.

## duck databases death

The process was simple: shutdown the RDBM, copy the data folder to the new
location, move the original one to a backup location, change the configuration
of the RDBM and restart the RDBM. The plan was to start with PostgreSQL as the
most important service ([Mattermost](https://chat.lama-corp.space)) is relying
on it. Everything went smoothly until the last step. PostgreSQL wasn't
restarted and therefore let [Mattermost](https://chat.lama-corp.space) without
its data. The issue wasn't noticed due to the way
[Mattermost](https://chat.lama-corp.space) manages its frontend and backend. It
wasn't obvious [Mattermost](https://chat.lama-corp.space) wasn't working.
Therefore, the migration went on with MariaDB. This one failed at the
configuration step, but was left dead because it wasn't an important service.

The sysadmin then went away from his computer for his nocturnal activities and
did not notice something was wrong until 2019-03-01 20:37:.. UTC. By the time
the Mattermost logs were checked and PostgreSQL was restarted, it was
2019-03-01 20:47:33 UTC, which implies 18 hours and 25 minutes of downtime.
**No data loss was endured.**

Then it was time to fix MariaDB as the migration did not succeed. The problem
was with the MariaDB socket, which wasn't in the default place anymore and
could not be found by `php-fpm`. Re-configuring all of it took a while. Somehow
the users permissions were messed up and had to be reconfigured too. This
situation was resolved at 2019-03-01 21:52:13 UTC.

### Impact on [Mattermost](https://chat.lama-corp.spae)

[Mattermost](https://chat.lama-corp.space) web interface was accessible during
the whole incident but nothing was usable. Not data dating prior 2019-03-01
02:22:11 UTC was lost. All data input in
[Mattermost](https://chat.lama-corp.space) between 2019-03-01 02:22:11 UTC and
2019-03-01 20:47:33 UTC was lost as it wasn't recorded in the database.

### Impact on other services

The other services impacted were those running on MariaDB:

* [PrivateBin](https://bin.risson.space): still accessible, however `Send`
  wasn't working anymore.
* [Polr](https://u.risson.me): not accessible
* [42over2.ovh/CatCatch](https://42over2.ovh): not accessible
* [Zabbix](https://bird.risson.space): backend not logging anymore but sending
  alerts saying the database was down. Web interface wasn't accessible anymore.

## Why did this happen?

* **PostgreSQL**: The root cause of this is clearly human error. The migration
  process went on smoothly. The problem isn't that the error was made, but that
  it was not detected.
* **MariaDB**: The migration was a complete mess.  There was no real
  documentation on how to move the databases without data loss. Hopefully
  everything was recovered.

### Why wasn't it detected earlier?

The monitoring system in place (Zabbix) was not configured to monitor
PostgreSQL, neither MariaDB. The MariaDB fail was discovered because Zabbix
relied on it, but the PostgreSQL fail wasn't.

## How can we prevent this from happening again?

First, by putting a strong monitoring system in place.
[Netdata](https://bird.risson.space) has been set up in order to keep track of
everything that could go wrong with `duck` systems. Notifications in Mattermost
have been set up. Email notifications are still a TODO. Then, we need an
external monitor checking that the websites are still accessible. Also,
considering migrating away from MariaDB to PostgreSQL, easier to
maintain and backup.

## In retrospect

This incident took down almost all systems running on `duck`. It lasted for
more than 18 hours, but no data loss was endured. It showed a lack of
monitoring of the services in place. For a first major incident for a young
sysadmin, I would say it wasn't that bad.

Finally, I want to apologize to the users of the services I provide. It only is
a beginning for me in the sysadmin world and I still have a lot to learn, but
providing a working system with minimal downtime is a priority and I failed.
Sorry :/
