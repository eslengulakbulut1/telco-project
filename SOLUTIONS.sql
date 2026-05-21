/*
Question 1.1:
This query lists the customers who are subscribed to the 'Kobiye Destek' tariff.
The CUSTOMERS table is joined with the TARIFFS table by using the TARIFF_ID column.
The WHERE condition filters only the tariff records whose name is 'Kobiye Destek'.
*/
SELECT 
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';


/*
Question 1.2:
This query finds the newest customer who subscribed to the 'Kobiye Destek' tariff.
The customers are filtered by tariff name and then ordered by SIGNUP_DATE in descending order.
The FETCH FIRST 1 ROW ONLY clause returns only the most recent customer.
*/
SELECT 
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROW ONLY;


/*
Question 2.1:
This query finds the distribution of tariffs among all customers.
The CUSTOMERS table is joined with the TARIFFS table to display tariff names instead of only tariff IDs.
The GROUP BY clause groups customers by tariff and COUNT calculates the number of customers in each tariff.
*/
SELECT 
    t.NAME AS TARIFF_NAME,
    COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME
ORDER BY CUSTOMER_COUNT DESC;


/*
Question 3.1:
This query identifies the earliest customers to sign up.
The earliest customers are determined by the minimum SIGNUP_DATE value, not by the lowest customer ID.
The subquery finds the earliest signup date and the main query lists all customers with that date.
*/
SELECT 
    CUSTOMER_ID,
    NAME,
    CITY,
    SIGNUP_DATE,
    TARIFF_ID
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
);


/*
Question 3.2:
This query finds the city distribution of the earliest customers.
First, it filters customers whose SIGNUP_DATE equals the minimum signup date in the dataset.
Then it groups these earliest customers by city and counts how many of them are in each city.
*/
SELECT 
    CITY,
    COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
GROUP BY CITY
ORDER BY CUSTOMER_COUNT DESC;


/*
Question 4.1:
This query identifies customers whose monthly usage records are missing.
A LEFT JOIN is used to keep all customers even if they do not have a matching record in MONTHLY_STATS.
The WHERE condition selects only the customers whose monthly statistics record does not exist.
*/
SELECT 
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    c.SIGNUP_DATE
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL;


/*
Question 4.2:
This query finds the city distribution of customers with missing monthly records.
The LEFT JOIN detects customers who do not have matching records in MONTHLY_STATS.
After filtering missing records, the query groups the result by city and counts customers in each city.
*/
SELECT 
    c.CITY,
    COUNT(*) AS MISSING_CUSTOMER_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
GROUP BY c.CITY
ORDER BY MISSING_CUSTOMER_COUNT DESC;


/*
Question 5.1:
This query finds customers who have used at least 75% of their data limit.
The query joins CUSTOMERS, TARIFFS, and MONTHLY_STATS to compare customer usage with tariff limits.
Tariffs with zero data limit are excluded to avoid invalid percentage comparisons.
*/
SELECT 
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.DATA_LIMIT,
    ms.DATA_USAGE,
    ROUND((ms.DATA_USAGE / t.DATA_LIMIT) * 100, 2) AS DATA_USAGE_PERCENTAGE
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE t.DATA_LIMIT > 0
  AND ms.DATA_USAGE >= t.DATA_LIMIT * 0.75
ORDER BY DATA_USAGE_PERCENTAGE DESC;


/*
Question 5.2:
This query identifies customers who have completely exhausted all available package limits.
The usage values from MONTHLY_STATS are compared with the package limits stored in TARIFFS.
If a package limit is zero, that limit is ignored because the tariff does not include that service.
*/
SELECT 
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    ms.DATA_USAGE,
    ms.MINUTE_USAGE,
    ms.SMS_USAGE
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE (t.DATA_LIMIT = 0 OR ms.DATA_USAGE >= t.DATA_LIMIT)
  AND (t.MINUTE_LIMIT = 0 OR ms.MINUTE_USAGE >= t.MINUTE_LIMIT)
  AND (t.SMS_LIMIT = 0 OR ms.SMS_USAGE >= t.SMS_LIMIT);


/*
Question 6.1:
This query finds customers who have unpaid fees.
The PAYMENT_STATUS column in MONTHLY_STATS is used to determine whether a customer has paid or not.
The query joins customer, tariff, and monthly statistics data to show customer and tariff information together.
*/
SELECT 
    c.CUSTOMER_ID,
    c.NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.MONTHLY_FEE,
    ms.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE UPPER(ms.PAYMENT_STATUS) <> 'PAID';


/*
Question 6.2:
This query finds the distribution of payment statuses across different tariffs.
The query joins all three tables so that payment statuses can be grouped by tariff name.
The GROUP BY clause groups records by tariff and payment status, while COUNT shows the number of customers in each group.
*/
SELECT 
    t.NAME AS TARIFF_NAME,
    ms.PAYMENT_STATUS,
    COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
GROUP BY t.NAME, ms.PAYMENT_STATUS
ORDER BY t.NAME, ms.PAYMENT_STATUS;