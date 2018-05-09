title: How PostgreSQL is better than MariaDB (MySQL) ?
date: 2018-05-07 15:39:30
id: cqqw2cq47idtd7i
categories:
- [Tech, Programming, Database, MySQL/MariaDB]
- [Tech, Programming, Database, PostgreSQL]
- tags:
    Versus
---

{% admonition info Note %}
In this article the storage engine considered is _InnoDB_ ; It is the
only one that supports transactions and foreign keys.  
Others storage engines should have other behaviors but, if MM had a
really good storage engine, why they implement so much storage engines ?
{% endadmonition %}

```
MariaDB []> SHOW ENGINES;
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                                          | Transactions | XA   | Savepoints |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                                            | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                                                               | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                                        | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                                                            | NO           | NO   | NO         |
| SEQUENCE           | YES     | Generated tables filled with sequential values                                                   | YES          | NO   | YES        |
| Aria               | YES     | Crash-safe tables with MyISAM heritage                                                           | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                                               | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
```

# Abstract

The development of _MySQL_ began the 1995-11 under the _GNU GPL_ license and was
acquired by _Oracle Corporation_ in 2010.  
Due to its acquisition by _Oracle Corporation_, _MariaDB_ was born as a fork of
_MySQL_ in 2010-02-01.

In this post, I will expose some useful features that _PostgreSQL_ has
while _MySQL/MariaDB_ did not have or have implemented badly.


# Features

You will find [in this article](https://www.2ndquadrant.com/en/postgresql/postgresql-vs-mysql/)
and in [this one](http://www.postgresqltutorial.com/postgresql-vs-mysql/) a full comparison
of _MySQL/MariaDB_ with _PostgreSQL_.

## PG features that MM does not have

- `CASCADE` in the `DROP TABLE` command ;
- `TRUNCATE TABLE` supports `CASCADE`, `RESTART IDENTITY`, `CONTINUE IDENTITY` and is **transaction-safe** ;
- ["Analytic functions"/"Window Functions"](https://www.postgresql.org/docs/9.1/static/tutorial-window.HTML) ([Examples](http://www.postgresqltutorial.com/postgresql-window-function/)) ;
- Many advanced types such as
  **[json](https://www.postgresql.org/docs/9.3/static/datatype-json.html)**,
  _array_, _hstore_, **[user-defined types](https://www.postgresql.org/docs/current/static/xtypes.html)**, _IP_ address data type, [UID](https://www.postgresql.org/docs/current/static/datatype-uuid.html), etc ;
- Real boolean type (true/false) instead a `TINYINT(1)` in MM ;
- Default column value can be both constant or function call. MM
  default column value must be a constant or `CURRENT_TIMESTAMP` or
  `TIMESTAMP` or `DATETIME` ;
- [Common Table Expressions](https://www.postgresql.org/docs/current/static/queries-with.html)
  (`WITH` queries) ;
- [Materialized views](https://www.postgresql.org/docs/current/static/sql-creatematerializedview.html) ;
- [CHECK constraint](https://www.postgresql.org/docs/current/static/ddl-constraints.html) ;
- [Table inheritance](https://www.postgresql.org/docs/current/static/tutorial-inheritance.html) ;
- Programming languages for stored procedures (Ruby, Perl, Python, TCL, PL/pgSQL, SQL, JavaScript, etc) ;
- `FULL OUTER JOIN` (combines the results of both `LEFT JOIN` and `RIGHT JOIN`) ;
- `INTERSECT` and `EXCEPT` ;
- [Partial indexes](https://www.postgresql.org/docs/8.0/static/indexes-partial.html),
  [Bitmap indexes](https://wiki.postgresql.org/wiki/Bitmap_Indexes) and
  [Indexes on Expressions](https://www.postgresql.org/docs/current/static/indexes-expressional.html) ;
- Triggers (MM triggers is limited to some commands) ;

## MM features that PG does not have


# Administrative command lines

Both PG and MM have administrative command lines but PG's are better designed
and documented.

For MM theses commands are custom SQL-like statement however PG have special
meta-commands :

> Anything you enter in psql that begins with an unquoted backslash is a psql
> meta-command that is processed by psql itself. These commands make psql more
> useful for administration or scripting.

[The documentation of administrative command of MM](https://mariadb.com/kb/en/library/administrative-sql-statements/)
is really painful to explore compared to the one page
[PostgreSQL Client Applications Documentation](https://www.postgresql.org/docs/10/static/app-psql.html).

This being said, it is only a subjective opinion that depends only on my experience…

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

MariaDB [test]> CREATE TABLE data (id integer NOT NULL, data numeric(4, 2));
Query OK, 0 rows affected (0.31 sec)

MariaDB [test]> INSERT INTO data VALUES (1, 1234.5678);
Query OK, 1 row affected, 1 warning (0.08 sec)

MariaDB [test]> SELECT * FROM data;
+----+-------+
| id | data  |
+----+-------+
|  1 | 99.99 |
+----+-------+
```

**We insert the number 1234.5678 and MM records 99.99 !** What is this shit ?

Look at this with PG :

```text
postgres=# CREATE TABLE data (id integer NOT NULL, data numeric(4, 2));
> CREATE TABLE

postgres=# INSERT INTO data VALUES (1, 1234.5678);
> ERROR:  numeric field overflow
> DETAIL:  A field with precision 4, scale 2 must round to an absolute value less than 10^2.
```

The comportment of PG is more sensible and reliable ; storing data is
not about “tolerance” , it is about correctness.

What about modifying the data structure ?

```text
MariaDB [test]> ALTER TABLE data MODIFY data numeric(3, 2);
> Query OK, 1 row affected, 1 warning (0.99 sec)
> Records: 1  Duplicates: 0  Warnings: 1

MariaDB [test]> SELECT * FROM data;
> +----+------+
> | id | data |
> +----+------+
> |  1 | 9.99 |
> +----+------+
```

Hohooo ! 99.99 becomes 9.99. Let do it with PG :

```text
postgres=# INSERT INTO data VALUES (1, 99.1234);
> INSERT 0 1

postgres=# INSERT INTO data VALUES (1, 56.1234);
> INSERT 0 1

postgres=# SELECT * FROM data ;
>  id | data
> ----+-------
>   1 | 56.12

postgres=# ALTER TABLE data ALTER COLUMN data TYPE numeric(3, 2);
> ERROR:  numeric field overflow
> DETAIL:  A field with precision 3, scale 2 must round to an absolute value less than 10^1.
```

PG refuses to change the data type because some data does not conform
to the new asked data type. If you ever want the data in the table to
be changed **in case the new rules are violated**, you have to tell
PG explicitly what you want :

```txt
postgres=# ALTER TABLE data ALTER COLUMN data TYPE numeric(3, 2) USING (data / 10);
> ALTER TABLE

postgres=# SELECT * FROM data ;
>  id | data
> ----+------
>   1 | 5.61
```

As it is said in [this article](https://www.cybertec-postgresql.com/en/why-favor-postgresql-over-mariadb-mysql/) :

> _PostgreSQL_ does not try to be smart like _MySQL/MariaDB_ which
> finally fails, it does not try to do something fancy – it simply
> does what _you_ want and what is good for your data.

# Data constraint handling

In the previous example we created a table where the field _id_ must
be `NOT NULL`, let see how this constraint is handled by MM :

```txt
MariaDB [test]> UPDATE data SET id = NULL WHERE id = 1;
> Query OK, 1 row affected, 1 warning (0.09 sec)
> Rows matched: 1  Changed: 1  Warnings: 1

MariaDB [test]> SELECT * FROM data;
> +----+------+
> | id | data |
> +----+------+
> |  0 | 9.99 |
> +----+------+
```

Null value becomes 0…  
Let see what appends with PG :

```text
postgres=# UPDATE data SET id = NULL WHERE id = 1;
> ERROR:  null value in column "id" violates not-null constraint
> DETAIL:  Failing row contains (null, 5.61).
```

