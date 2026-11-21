# Sales Analysis: SQL Project (Lite+)

A single-file MySQL 8 project on a small sales database (customers, products, orders) covering the SQL functions and concepts used most in analyst and developer work.

## Topics covered
| Area | Functions / concepts |
|------|----------------------|
| Setup | `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `DEFAULT`, indexes, views |
| Aggregates | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`, `GROUP_CONCAT`, `ROLLUP` |
| Strings | `UPPER`, `LOWER`, `LENGTH`, `CONCAT`, `CONCAT_WS`, `TRIM`, `REPLACE`, `LEFT`, `RIGHT`, `LPAD`, `REVERSE`, `LOCATE`, `SUBSTRING_INDEX`, `FORMAT` |
| Dates | `YEAR`, `QUARTER`, `MONTHNAME`, `DAYNAME`, `DATE_FORMAT`, `DATE_ADD`, `LAST_DAY`, `DATEDIFF`, `TIMESTAMPDIFF`, `STR_TO_DATE` |
| Numeric / conditional | `ROUND`, `CEIL`, `FLOOR`, `MOD`, `POW`, `GREATEST`, `CASE`, `IF` |
| NULL handling / casting | `IFNULL`, `COALESCE`, `NULLIF`, `CAST` |
| Joins | `INNER`, `LEFT`, `RIGHT`, `SELF`, `CROSS` |
| Pattern matching | `LIKE`, `REGEXP`, `IN`, `BETWEEN` |
| Subqueries / CTEs | scalar, `EXISTS`, correlated, `WITH`, `WITH RECURSIVE` |
| Set operations | `UNION`, `UNION ALL` |
| Window functions | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `LAG`, `LEAD`, `FIRST_VALUE`, running total, moving average |
| Programmability | user-defined function, stored procedure, trigger, transaction, `SAVEPOINT`, `SIGNAL`, `EXPLAIN` |

## How to run
Requires MySQL 8.0 or newer.

```bash
mysql -u root -p < sales_analysis.sql
```

Or open `sales_analysis.sql` in MySQL Workbench and run it (lightning bolt button). Section 12 uses `DELIMITER`, so use the MySQL CLI or Workbench, not a web-based SQL editor.
