Use classicmodels;
#Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
 
 #A. Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table) 
 #Solution A
    select distinct employeeNumber,firstName,LastName from employees where jobTitle="Sales Rep" and reportsTo=1102;
 #B. show the unique productline values containing the word cars at the end from the products table. 
 #solution B
  select distinct productline from products where productline like "%cars";
 
#Q2. CASE STATEMENTS for Segmentation
 
 #  a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
 #                         "North America" for customers from USA or Canada
 #                        "Europe" for customers from UK, France, or Germany
 #                        "Other" for all remaining countries
 #     Select the customerNumber, customerName, and the assigned region as "CustomerSegment".
 
 # Solution Q.2 (a)
 select customerNumber,customerName ,
   Case
    when country in ("USA","Canada") then "North America"
    when country in("UK", "France","Germany") then  "Europe"
    else "Other"
    end as "CustomerSegment"
    from customers;
    
    
# Q3. Group By with Aggregation functions and Having clause, Date and Time functions
 # a.	Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders
  #solution :- Q3(a) 
   
    select productcode,sum(quantityordered) total_order from orderdetails group by 1 order by  2 desc limit 10;
 
 # b. Company wants to analyse payment frequency by month. Extract the month name from the 
   #payment date to count the total number of payments for each month and include only those months 
   # with a payment count exceeding 20. Sort the results by total number of payments in descending order.  (Refer Payments table). 

#solution Q.3(B)
  
  select date_format(paymentdate,"%M") payment_month, count(*) num_payment from  payments group by 1 having num_payment>20 order by 2 desc;

#Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
 #solution Q4
   create database Customers_Orders;
   use Customers_orders;
   
   #Solution Q4(A)
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

#Solution Q4(B)

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT chk_total_amount
        CHECK (total_amount > 0)
);



# Q5. JOINS
  #Solution Q5 A
  select a.country,count(b.orderNumber) order_count from customers a inner join  orders as b on a.customerNumber=b.customerNumber group by a.country order by order_count desc limit 5;


#Q6. SELF JOIN  
   #solution Q6 A 
    create table project(
    EmployeeID int primary key auto_increment,
    FullName varchar(50) not null,
    Gender ENUM('Male','Female') Not Null,
    ManagerID int
    );
    
    
  INSERT INTO project (FullName, Gender, ManagerID) VALUES
('Pranaya', 'Male', 3),
('Priyanka', 'Female', 1),
('Preety', 'Female', NULL),
('Anurag', 'Male', 1),
('Sambit', 'Male', 1),
('Rajesh', 'Male', 3),
('Hina', 'Female', 3);

select * from project;

select a.FullName as Manger_name,b.FullName as Emp_Name from project b  join project a on b.ManagerID=a.EmployeeID;


#Q7 Views in SQL
#solution Q7 a
create table facility (
    Facility_ID int,
    Name varchar(100),
    State varchar(50),
    Country varchar(50)
);
desc facility;

Alter table facility
modify facility_id int primary key auto_increment;

desc facility;

alter table facility
add column city varchar(50) not null after name;

desc facility;


#Q8 Views in sql
create view product_category_sales 
as
select 
    pl.productLine,
    sum(od.quantityOrdered * od.priceEach) as total_sales,
    count(DISTINCT o.orderNumber) as number_of_orders
from 
    productlines as pl
join
    products as p 
    on pl.productLine = p.productLine
join 
    orderdetails as od 
    on p.productCode = od.productCode
join 
    orders as o 
    on od.orderNumber = o.orderNumber
group by 
    pl.productLine;
        
select * from product_category_Sales;


# Q9. Stored Procedures in SQL with parameters
delimiter $$

create procedure get_country_payments (
    in p_year int,
    in p_country varchar(50)
)
begin
    select 
        year(p.paymentdate) as payment_year,
        c.country,
        concat(round(sum(p.amount) / 1000, 0), 'k') as total_amount
    from 
        customers as c
    join 
        payments as p 
        on c.customernumber = p.customernumber
    where 
        year(p.paymentdate) = p_year
        and c.country = p_country
    group by 
        year(p.paymentdate), c.country;
end $$

delimiter ;

call get_country_payments(2003, 'france');

# Q10. Window functions - Rank, dense_rank, lead and lag
#solution A
 select 
    c.customerNumber,
    c.customerName,
    count(o.orderNumber) as order_count,
    rank() over (order by count(o.orderNumber) desc) as rank_no
from 
    customers as c
join 
    orders as o 
    on c.customerNumber = o.customerNumber
group by 
    c.customerNumber, c.customerName
order by 
    rank_no;
#solution b
select 
    year(orderdate) as order_year,
    monthname(orderdate) as order_month,
    count(orderNumber) as total_orders,
    case 
        when lag(count(orderNumber)) over (order by year(orderdate), month(orderdate)) is null 
            then null
        else concat(
            round(
                (
                    (count(orderNumber) - lag(count(orderNumber)) over (order by year(orderdate), month(orderdate)))
                    / lag(count(orderNumber)) over (order by year(orderdate), month(orderdate))
                ) * 100
            , 0), '%'
        )
    end as yoy_change
from 
    orders
group by 
    year(orderdate), month(orderdate), monthname(orderdate)
order by 
    order_year, month(orderdate);
    
    
#Q12. ERROR HANDLING in SQL
#solution
create table emp_eh (
    empid int primary key,
    empname varchar(50),
    emailaddress varchar(100)
);

delimiter $$

create procedure insert_emp_eh(
    in p_empid int,
    in p_empname varchar(50),
    in p_emailaddress varchar(100)
)
begin
    declare exit handler for sqlexception
    begin
        select 'error occurred' as message;
    end;

    insert into emp_eh(empid, empname, emailaddress)
    values(p_empid, p_empname, p_emailaddress);
end$$

delimiter ;

call insert_emp_eh(1, 'Akhilesh Nishad', 'akhil@example.com');


#Q13. TRIGGERS
create table emp_bit (
    name varchar(50),
    occupation varchar(50),
    working_date date,
    working_hours int
);


drop trigger if exists trg_before_update_empbit;

delimiter $$

create trigger trg_before_update_empbit
before update on emp_bit
for each row
begin
    if new.working_hours < 0 then
        set new.working_hours = abs(new.working_hours);
    end if;
end$$

delimiter ;








insert into emp_bit values
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', -11); 

select * from emp_bit;

