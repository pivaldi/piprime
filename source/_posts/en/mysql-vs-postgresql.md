title: Why use _PostgreSQL_ instead of _MySQL/MariaDB_ ?
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
Others storage engines should have other behaviors, certainly more
lax, which is not expected to my mind by a _RDBM_.
{% endadmonition %}

If _MySQL/MariaDB_ had a really good storage engine, why they implement so much storage engines ?

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
whereas _MySQL/MariaDB_ did not have or have implemented badly.


# Factual Pros and Cons

You will find [in this article](https://www.2ndquadrant.com/en/postgresql/postgresql-vs-mysql/)
and in [this one](http://www.postgresqltutorial.com/postgresql-vs-mysql/) a full comparison
of _MySQL/MariaDB_ with _PostgreSQL_.
Here a summary of the main differences.

## _PostgreSQL_ pros, _MySQL/MariaDB_ cons

- _PostgreSQL_ is largely _SQL_ compliant, _MySQL/MariaDB_ is partially compliant on some of the versions ;
- `CASCADE` in the `DROP TABLE` command is not supported in _MySQL/MariaDB_ ;
- _PostgreSQL_ supports `CASCADE`, `RESTART IDENTITY`, `CONTINUE IDENTITY` in the `TRUNCATE TABLE` command, _MySQL/MariaDB_ don't ;
- `TRUNCATE TABLE` (similar to the `DELETE` statement with no `WHERE`
  clause and without loggin the individual row deletions) is
  **transaction-safe** in _PostgreSQL_, not in _MySQL/MariaDB_ ;
- All schema changes are **transaction-safe** in _PostgreSQL_, not in _MySQL/MariaDB_ (👎 boooo !) :
  > MariaDB (and most other DBMSs) supports rollback of SQL-data
  > change statements, but not of SQL-Schema statements. This means that
  > if you use any of CREATE, ALTER, DROP, GRANT, REVOKE, you are
  > implicitly committing at execution time.
  >> [Source mariadb.com](https://mariadb.com/kb/en/library/rollback/)
- ["Analytic functions"/"Window Functions"](https://www.postgresql.org/docs/9.1/static/tutorial-window.HTML) (see examples [here](http://www.postgresqltutorial.com/postgresql-window-function/))
  does not exist in _MySQL/MariaDB_ ;
- Many advanced types such as
  **[json with NoSQL functionalities](https://www.postgresql.org/docs/9.3/static/datatype-json.html)**,
  _array_, _hstore_, **[user-defined types](https://www.postgresql.org/docs/current/static/xtypes.html)**, _IP_ address data type, [UID](https://www.postgresql.org/docs/current/static/datatype-uuid.html), etc are not available in _MySQL/MariaDB_ ;
- _PostgreSQL_ has a real boolean type (true/false) whereas _MySQL/MariaDB_ use `TINYINT(1)` to mimic boolean type ;
- In _PostgreSQL_ the default column value can be both constant or function call. In _MySQL/MariaDB_
  the default column value must be a constant or `CURRENT_TIMESTAMP` or
  `TIMESTAMP` or `DATETIME` ;
- _PostgreSQL_ implements the _SQL standard [Common Table Expressions](https://www.postgresql.org/docs/current/static/queries-with.html)
  (`WITH` queries), _MySQL/MariaDB_ does not ;
- _PostgreSQL_ support useful [Materialized views](https://www.postgresql.org/docs/current/static/sql-creatematerializedview.html),
  _MySQL/MariaDB_ implements the `CHECK` constraint but ignore it (wath the fuck !)
  > From MariaDB 10.2.1 (stable in 2017-05-23 [Ed]), constraints are enforced. Before MariaDB
  > 10.2.1 constraint expressions were accepted in the syntax but
  > ignored.
  >> [Source mariadb.com](https://mariadb.com/kb/en/library/constraint/)
- _PostgreSQL_ supports the _SQL_ standard [CHECK constraint](https://www.postgresql.org/docs/current/static/ddl-constraints.html), _MySQL/MariaDB_ does not ;
- _PostgreSQL_ implements [table inheritance](https://www.postgresql.org/docs/current/static/tutorial-inheritance.html), _MySQL/MariaDB_ does not ;
- _PostgreSQL_ handles programming languages for stored procedures (Ruby, Perl, Python, TCL, PL/pgSQL, SQL, JavaScript, etc)
  whereas _MySQL/MariaDB_ use only _SQL_ langage with [Compound Statements](https://mariadb.com/kb/en/library/programmatic-compound-statements/) ;
- _PostgreSQL_ implements the _SQL_ standard `FULL OUTER JOIN` (combines the results of both `LEFT JOIN` and `RIGHT JOIN`), _MySQL/MariaDB_ does not ;
- _PostgreSQL_ implements the _SQL_ standard `INTERSECT` and `EXCEPT`, _MySQL/MariaDB_ does not ;
- _PostgreSQL_ implements [Partial indexes](https://www.postgresql.org/docs/8.0/static/indexes-partial.html),
  [Bitmap indexes](https://wiki.postgresql.org/wiki/Bitmap_Indexes) and
  [Indexes on Expressions](https://www.postgresql.org/docs/current/static/indexes-expressional.html), _MySQL/MariaDB_ does not ;
- _PostgreSQL_ has full support of [triggers](https://www.postgresql.org/docs/current/static/plpgsql-trigger.html)
  whereas _MySQL/MariaDB_ has triggers limited to some commands only and `TRUNCATE TABLE` does not activate any triggers ;
- _PostgreSQL_'s `INSERT ON CONFLICT` ([doc here](https://www.postgresql.org/docs/9.5/static/sql-insert.html))
  clause is much sophisticated than the only on statement
  _MySQL/MariaDB_ `INSERT ON DUPLICATE KEY UPDATE` ([doc here](https://mariadb.com/kb/en/library/insert-on-duplicate-key-update/)).

## _PostgreSQL_ cons, _MySQL/MariaDB_ pros

- _MySQL/MariaDB_ has unsigned integer type, _PostgreSQL_ does not ;
- _MySQL/MariaDB_ has `RANGE`, `LIST`, `HASH`, `KEY`, and composite partitioning
  table whereas _PostgreSQL_ has only `RANGE`, `LIST` partitioning table ;

# Administrative command lines

Both _PostgreSQL_ and _MySQL/MariaDB_ have administrative command lines but _PostgreSQL_'s are better designed
and documented. It is only a subjective opinion that depends only on
my experience…

For _MySQL/MariaDB_ theses commands are custom SQL-like statement whereas _PostgreSQL_ have special
meta-commands :

> Anything you enter in psql that begins with an unquoted backslash is a psql
> meta-command that is processed by psql itself. These commands make psql more
> useful for administration or scripting.

# Documentation overview

For example, [The Administrative Statements Documentation of MySQL/MariaDB](https://mariadb.com/kb/en/library/administrative-sql-statements/)
is displayed as a directories tree which is really painful to explore compared to the one page
[PostgreSQL Client Applications Documentation](https://www.postgresql.org/docs/10/static/app-psql.html).

All features are describe in the same way so the documentation of _PostgreSQL_ is much better designed and thought.

## Case studies

{% admonition info Make MySQL/MariaDB Less Fancy / More Strict %}
You can manage how _Mariadb_ handles notes, warning and errors by setting the variable `SQL_MODE`.
The documentation is
[here](https://mariadb.com/kb/en/library/sql-mode/) and show how
implement a really complex (so bad) warning/error manager system.
You can even make division by zero returns `NULL` !
We'll use in this article the default setting for `SQL_MODE`.

_PostgreSQL_ is **always** very strict about data integrity and validity when
inserting or updating it. With _MySQL/MariaDB_, you need to set the
server to a strict SQL mode (`STRICT_ALL_TABLES` or `STRICT_TRANS_TABLES`).
{% endadmonition %}

## Data type handling

As describe [in this article](https://www.cybertec-postgresql.com/en/why-favor-postgresql-over-mariadb-mysql/),
the data type handling in _MySQL/MariaDB_ is not at all clever.
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

**We insert the number 1234.5678 and _MySQL/MariaDB_ records 99.99 !** What is this shit ?

Look at this with _PostgreSQL_ :

```text
postgres=# CREATE TABLE data (id integer NOT NULL, data numeric(4, 2));
> CREATE TABLE

postgres=# INSERT INTO data VALUES (1, 1234.5678);
> ERROR:  numeric field overflow
> DETAIL:  A field with precision 4, scale 2 must round to an absolute value less than 10^2.
```

The comportment of _PostgreSQL_ is more sensible and reliable ; storing data is
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

Hohooo ! 99.99 becomes 9.99. Let do it with _PostgreSQL_ :

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

_PostgreSQL_ refuses to change the data type because some data does not conform
to the new asked data type. If you ever want the data in the table to
be changed **in case the new rules are violated**, you have to tell
_PostgreSQL_ explicitly what you want :

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

## Data Constraint Handling

### General `NOT NULL` Constraint

In the previous example we created a table where the field _id_ must
be `NOT NULL`, let see how this constraint is handled by _MySQL/MariaDB_ :

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
Let see what appends with _PostgreSQL_ :

```text
postgres=# UPDATE data SET id = NULL WHERE id = 1;
> ERROR:  null value in column "id" violates not-null constraint
> DETAIL:  Failing row contains (null, 5.61).
```

### Case of `DATE` Type

```text
MariaDB [test]> ALTER TABLE data ADD COLUMN a_date DATE NOT NULL;
> Query OK, 0 rows affected (0.47 sec)
> Records: 0  Duplicates: 0  Warnings: 0
```

Hohooo, what are the values for `a_date` of the previous records ?

```
MariaDB [test]> SELECT * FROM data;
> +-----+------+------------+
> | id  | data | a_date     |
> +-----+------+------------+
> |   0 | 9.99 | 0000-00-00 |
> |   1 | 0.00 | 0000-00-00 |
> +-----+------+------------+
```

See it with _PostgreSQL_ :

```
postgres=# ALTER TABLE DATA ADD COLUMN a_date DATE NOT NULL;
> ERROR:  column "a_date" contains null values

postgres=# ALTER TABLE DATA ADD COLUMN a_date DATE NOT NULL DEFAULT NOW();
> ALTER TABLE

postgres=# ALTER TABLE DATA ALTER COLUMN a_date DROP DEFAULT;
> ALTER TABLE
postgres=# \d data
>         Table "public.data"
>  Column |     Type     | Modifiers
> --------+--------------+-----------
>  id     | integer      | not null
>  data   | numeric(3,2) |
>  a_date | date         | not null

postgres=# SELECT * FROM data;
>  id | data |   a_date
> ----+------+------------
>   1 | 5.61 | 2018-05-10
```

All is right with _PostgreSQL_ !
One more time _MySQL/MariaDB_ tends to be fancy but fails on data integrity and coherence !
However, testing the insertion of `NULL` values with _MySQL/MariaDB_, we have a good surprise :

```
MariaDB [test]> INSERT INTO data VALUES (1, 0, NULL);
> ERROR 1048 (23000): Column 'a_date' cannot be null
```

Correct `DATE NOT NULL` handling seems a good news. Note that _MySQL/MariaDB_ inserts
`0000-00-00` when `a_date` is null with the _Myisam_ storage engine…
Wait, see this one…

```
MariaDB [test]> INSERT INTO data VALUES (-1, 0, '2018-02-25');
> Query OK, 1 row affected (0.15 sec)

MariaDB [test]> UPDATE data SET a_date=null WHERE id=-1;
> Query OK, 1 row affected, 1 warning (0.06 sec)
> Rows matched: 1  Changed: 1  Warnings: 1

MariaDB [test]> SELECT * FROM data WHERE id=-1;
> +----+------+------------+
> | id | data | a_date     |
> +----+------+------------+
> | -1 | 0.00 | 0000-00-00 |
> +----+------+------------+
```

Wouhahahaaa, `0000-00-00` is a date in a calendar of the space cake.
_MySQL/MariaDB_ handles correctly the `NOT NULL` constraints when inserting, not when updating ! (WTF ?).
Let's see for wrong dates handling…

```
MariaDB [test]> INSERT INTO data VALUES (99, 0, '');
> Query OK, 1 row affected, 1 warning (0.04 sec)

MariaDB [test]> SELECT * FROM data WHERE id=99;
> +----+------+------------+
> | id | data | a_date     |
> +----+------+------------+
> | 99 | 0.00 | 0000-00-00 |
> +----+------+------------+
```

An over one ?

```
MariaDB [test]> INSERT INTO data VALUES (999, 0, '2018-50-80');
> Query OK, 1 row affected, 1 warning (0.05 sec)

MariaDB [test]> INSERT INTO data VALUES (999, 0, '2018-02-29');
> Query OK, 1 row affected, 1 warning (0.05 sec)

MariaDB [test]> SELECT * FROM data WHERE id=999;
> +-----+------+------------+
> | id  | data | a_date     |
> +-----+------+------------+
> | 999 | 0.00 | 0000-00-00 |
> | 999 | 0.00 | 0000-00-00 |
> +-----+------+------------+
```

**What** ?
We can insert a wrong date but the data recorded will be reset to `0000-00-00`
In this case, we absolutely can not be sure of the values recorded in
the database and eventually post correct then.
How _PostgreSQL_ handle this data ?

```
postgres=# INSERT INTO data VALUES (99, 0, '');
> ERROR:  invalid input syntax for type date: ""
> LINE 1: INSERT INTO data VALUES (99, 0, '');
>                                         ^

postgres=# INSERT INTO data VALUES (999, 0, '2018-50-80');
> ERROR:  date/time field value out of range: "2018-50-80"
> LINE 1: INSERT INTO data VALUES (999, 0, '2018-50-80');
>                                          ^
> HINT:  Perhaps you need a different "datestyle" setting.

postgres=# INSERT INTO data VALUES (999, 0, '2018-02-29');
> ERROR:  date/time field value out of range: "2018-02-29"
> LINE 1: INSERT INTO data VALUES (999, 0, '2018-02-29');
```

The behaviour is clear, clean, precise and unambiguous.

# Time and Interval Computation

_PostgreSQL_ computation with time have natural writing whereas _MySQL/MariaDB_ use poor
functional design. For example, to subtract date _MySQL/MariaDB_ provides the
functions `TIMESTAMPDIFF`, `DATEDIFF` or `DATE_SUB` or `SUBTIME` etc whereas
_PostgreSQL_ use natural subtraction writing with hard typing via
casting, no need to remember tone of functions.
Also, _PostgreSQL_ has a real `INTERVAL` type which allow use to work very
efficiently with time operation :

 - `DATE - DATE` returns an integer, the number of days between the two dates ;
 - `DATE - INTERVAL` returns a `TIMESTAMP`;
 - `TIMESTAMP - TIMESTAMP` return an interval of time (type `INTERVAL`) ;
 - `INTERVAL - INTERVAL` returns an `INTERVAL` ;
 - etc, operations are natural so easy to remember.

Let's the how the syntax and behaviors diverge…

## Subtracting Time Interval

With _PostgreSQL_ is very easy to subtract a time interval to a given date :

```text
postgress=# SELECT '2017-06-15 23:30'::timestamp
           - interval '1 year 3 months 1 day 2 hours 25 seconds' AS result;
>        result
> ---------------------
>  2016-03-14 21:29:35
```

I do not know how to just do the same thing with _MySQL/MariaDB_, leave a comment if you know how…

## Subtracting Dates

```text
postgres=# SELECT '2017-06-15 23:30'::timestamp - '2015-02-19 12:25:19'::timestamp AS result;
      result
-------------------
 847 days 11:04:41
```

With _MySQL/MariaDB_, `TIME` values may range from '-838:59:59' to
'838:59:59'. WTF ? It's not serious !

```text
MariaDB [(none)]> SELECT TIMEDIFF('2017-06-15 23:30:00', '2015-02-19 12:25:19') AS result;
+-----------+
| result    |
+-----------+
| 838:59:59 |
+-----------+
1 row in set, 1 warning (0.00 sec)

MariaDB [(none)]> SHOW WARNINGS;
+---------+------+-----------------------------------------------+
| Level   | Code | Message                                       |
+---------+------+-----------------------------------------------+
| Warning | 1292 | Truncated incorrect time value: '20339:04:41' |
+---------+------+-----------------------------------------------+
1 row in set (0.00 sec)
```

## Is this a Bug ?

```text
MariaDB [(none)]> SELECT SUBTIME('2017-06-15 23:30:0.0', '1-0-1 2:0:25') AS result;
> +--------+
> | result |
> +--------+
> | NULL   |
> +--------+
> 1 row in set (0.00 sec)
```

No warnings ! All is right for _MySQL/MariaDB_…

# Conclusion

We have showed in this article that _PostgreSQL_ has much more features than _MySQL/MariaDB_,
a better documentation and a better functional design in many ways.
We have also showed that _PostgreSQL_ is always very strict for the data
integrity whereas _MySQL/MariaDB_ with the default `SQL_MODE` setting has critical
faults. Whereas, we can raise the rigor of _MySQL/MariaDB_ *near but
under* what _PostgreSQL_ has by setting `SQL_MODE` to
`STRICT_ALL_TABLES` or `STRICT_TRANS_TABLES`.
