# MySQL Assignment – Classic Models Database

This repository contains solutions for MySQL assignment questions using the **Classic Models Database**.  
All queries are organized topic-wise and written in a single SQL file.  

---

## Q1. SELECT Clause with WHERE, AND, DISTINCT, Wild Card (LIKE)

**a. Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102**

```sql
SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep' AND reportsTo = 1102;
```

**b. Show the unique productline values containing the word cars at the end from the products table**

```sql
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';
```

---

## Q2. CASE Statements for Segmentation

**Segment customers into regions based on country**

```sql
SELECT customerNumber, customerName,
CASE
    WHEN country IN ('USA', 'Canada') THEN 'North America'
    WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
    ELSE 'Other'
END AS CustomerSegment
FROM customers;
```

---

## Q3. Group By with Aggregation, Having, Date & Time

**a. Top 10 products by total order quantity**

```sql
SELECT productCode, SUM(quantityOrdered) AS total_quantity
FROM orderdetails
GROUP BY productCode
ORDER BY total_quantity DESC
LIMIT 10;
```

**b. Payment frequency by month (only months with count > 20)**

```sql
SELECT MONTHNAME(paymentDate) AS MonthName, COUNT(*) AS TotalPayments
FROM payments
GROUP BY MonthName
HAVING COUNT(*) > 20
ORDER BY TotalPayments DESC;
```

---

## Q4. Constraints

**a. Customers Table**

```sql
CREATE DATABASE Customers_Orders;
USE Customers_Orders;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);
```

**b. Orders Table**

```sql
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT chk_total CHECK (total_amount > 0)
);
```

---

## Q5. Joins

**Top 5 countries by order count**

```sql
SELECT c.country, COUNT(o.orderNumber) AS total_orders
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY total_orders DESC
LIMIT 5;
```

---

## Q6. Self Join

**Project Table and Employee-Manager Relation**

```sql
CREATE TABLE project (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male','Female'),
    ManagerID INT
);

-- Find employees with their managers
SELECT e.FullName AS Employee, m.FullName AS Manager
FROM project e
LEFT JOIN project m ON e.ManagerID = m.EmployeeID;
```

---

## Q7. DDL Commands

```sql
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);

ALTER TABLE facility 
MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE facility
ADD city VARCHAR(50) NOT NULL AFTER Name;
```

---

## Q8. Views

```sql
CREATE VIEW product_category_sales AS
SELECT pl.productLine,
       SUM(od.quantityOrdered * od.priceEach) AS total_sales,
       COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM products p
JOIN productlines pl ON p.productLine = pl.productLine
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY pl.productLine;
```

---

## Q9. Stored Procedures

```sql
DELIMITER //
CREATE PROCEDURE Get_country_payments(IN input_year INT, IN input_country VARCHAR(50))
BEGIN
  SELECT YEAR(p.paymentDate) AS Year, c.country,
         CONCAT(FORMAT(SUM(p.amount)/1000,0), 'K') AS TotalAmount
  FROM payments p
  JOIN customers c ON p.customerNumber = c.customerNumber
  WHERE YEAR(p.paymentDate) = input_year AND c.country = input_country
  GROUP BY YEAR(p.paymentDate), c.country;
END //
DELIMITER ;
```

---

## Q10. Window Functions

**a. Rank customers based on order frequency**

```sql
SELECT c.customerNumber, c.customerName,
       COUNT(o.orderNumber) AS order_count,
       RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS rank_order
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName;
```

**b. Year-wise, month-wise order count with YoY% change**

```sql
SELECT YEAR(orderDate) AS Year,
       MONTHNAME(orderDate) AS Month,
       COUNT(orderNumber) AS order_count,
       CONCAT(ROUND(
            (COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)))
            / LAG(COUNT(orderNumber)) OVER (PARTITION BY MONTH(orderDate) ORDER BY YEAR(orderDate)) * 100,0
       ), '%') AS YoY_Percentage
FROM orders
GROUP BY YEAR(orderDate), MONTH(orderDate);
```

---

## Q11. Subqueries

```sql
SELECT productLine, COUNT(*) AS ProductCount
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine;
```

---

## Q12. Error Handling

```sql
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    EmailAddress VARCHAR(100)
);

DELIMITER //
CREATE PROCEDURE insert_emp(IN p_id INT, IN p_name VARCHAR(50), IN p_email VARCHAR(100))
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT 'Error occurred' AS Message;
  END;

  INSERT INTO Emp_EH VALUES (p_id, p_name, p_email);
END //
DELIMITER ;
```

---

## Q13. Triggers

```sql
CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

DELIMITER //
CREATE TRIGGER before_insert_empbit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
   IF NEW.Working_hours < 0 THEN
      SET NEW.Working_hours = ABS(NEW.Working_hours);
   END IF;
END //
DELIMITER ;

-- Sample Data
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);
```

---

✅ All solutions are tested with the **Classic Models Database**.
