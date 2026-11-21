# Sales Analysis: Lite SQL Project

A small, single-file MySQL 8 project that covers the core SQL skills on a 3-table sales database (customers, products, orders).

## Topics covered
- Table creation, constraints, foreign keys, views
- Aggregates: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`
- String functions: `UPPER`, `SUBSTRING_INDEX`, `LENGTH`, `COALESCE`, `CONCAT`, `LPAD`
- Date functions: `YEAR`, `MONTHNAME`, `DATE_FORMAT`, `DATEDIFF`
- Numeric and conditional: `ROUND`, `CEIL`, `CASE`
- Joins (`INNER`, `LEFT`), subqueries, CTEs
- Window functions: `RANK`, `ROW_NUMBER`, `LAG`, running totals

## Run it
```bash
mysql -u root -p < sales_analysis.sql
```
Or open `sales_analysis.sql` in MySQL Workbench and run it.
