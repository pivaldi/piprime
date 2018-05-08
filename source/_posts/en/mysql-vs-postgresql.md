title: How PostgreSQL is better than MariaDB (MySQL) ?
date: 2018-05-07 15:39:30
id: cqqw2cq47idtd7i
categories:
- [Tech, Programming, Database, MySQL/MariaDB]
- [Tech, Programming, Database, PostgreSQL]
tags:
- Versus

---

# Abstract

In this post, I will expose some useful features that *PostgreSQL* has
while *MySQL/MariaDB* did not have or have implemented badly.

So you will don't find here a real comparison of *MySQL/MariaDB* with *PostgreSQL*, this is already well done
[in this article](https://www.2ndquadrant.com/en/postgresql/postgresql-vs-mysql/).

# Administrative command lines

Both PG and MM have administrative command lines but PG's are better designed and documented.

Here a screen

# Data type handling

As describe [in this article](https://www.cybertec-postgresql.com/en/why-favor-postgresql-over-mariadb-mysql/),
the data type handling in MMDB is not at all clever.  
Here some examples :

```text
[root@t520 local ]$ mariadb
> […]

MariaDB [(none)]> create database test;
> Query OK, 1 row affected (0.00 sec)
MariaDB [(none)]> use test
> Database changed
```



