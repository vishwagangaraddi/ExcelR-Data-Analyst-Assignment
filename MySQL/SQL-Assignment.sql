use classicmodels;

-- Q1 (a)
select * from employees;
select employeeNumber,firstName,lastName from employees 
where jobTitle = "sales REP" and reportsTo = 1102;

-- Q1 (b)
select * from products;
SELECT DISTINCT productline FROM products WHERE productline LIKE "%Cars";

-- Q2 (a)
select * from customers;
select customerNumber, customerName,
case 
when country = 'USA' or country = 'Canada' then "North America"
when country = 'UK' or country = 'France' or country = 'Germany' then "Europe"
else "Others"
end as customersegment from customers;

-- Q3 (a)
select * from OrderDetails;
select productCode, sum(quantityOrdered) as total_ordered from orderdetails 
group by productCode order by total_ordered desc limit 10;
 
-- Q3 (b)
select * from payments;
select monthname(paymentdate) as payment_month, count(*) as number_payments from payments
group by month(paymentdate) having count(*) >20 order by number_payments desc;

-- Q4 (a)
create database customers_orders;
use customers_orders;
create table `Customers` (
`customer_id` int(25) auto_increment,
`first_name` varchar(54),
`last_name` varchar(54),
`email` varchar(300) unique,
`phone_number` varchar(20),
primary key(`customer_id`));

-- Q4 (b)
create table `Orders` (
`order_id` int auto_increment,
`customer_id` int ,
`order_date` date,
`total_amount` decimal(10,4),
primary key(`order_id`),
constraint `order_id_customers` foreign key(`customer_id`) references `Customers`(`customer_id`),
check(`total_amount`>0));

--  Q5
use classicmodels;
select C.country,count(O.ordernumber) as order_count from customers C
join orders O on C.customerNumber = O.customerNumber
group by C.country order by order_count desc limit 5;

-- Q6
CREATE TABLE project (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female'),
    ManagerID INT
);

INSERT INTO project (EmployeeID,FullName, Gender, ManagerID) VALUES
(1,'Pranaya', 'Male', 3),
(2,'Priyanka', 'FeMale',1),
(3,'Preety','Female',null),
(4,'Anurag','Male',1),
(5,'Sambit','Male',1),
(6,'Rajesh','Male',3),
(7,'Hina','Female',3);

select * from project;

SELECT e.FullName AS EmployeeName, m.FullName AS ManagerName
FROM project e LEFT JOIN project m ON e.ManagerID = m.EmployeeID;

-- Q7
CREATE TABLE facility (
Facility_ID INT,
Name VARCHAR(100),
State VARCHAR(100),
Country VARCHAR(100)
);

ALTER TABLE facility
MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE facility
ADD COLUMN city VARCHAR(100) NOT NULL AFTER Name;

DESC facility;
select * from facility;

-- Q8
CREATE VIEW product_category_sales AS
SELECT pl.productLine, SUM(od.quantityOrdered * od.priceEach) AS total_sales,
COUNT(DISTINCT od.orderNumber) AS number_of_orders
FROM productlines pl
JOIN products p ON pl.productLine = p.productLine
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY pl.productLine;

SELECT * FROM product_category_sales;
    DELIMITER $$

-- Q9
CREATE PROCEDURE Get_country_payments ( IN input_year INT, IN input_country VARCHAR(50))
BEGIN
    SELECT YEAR(p.paymentDate) AS Year, c.country AS Country, CONCAT(ROUND(SUM(p.amount) / 1000, 2), 'K') AS Total_Amount_K
    FROM customers c
    JOIN payments p ON c.customerNumber = p.customerNumber
    WHERE YEAR(p.paymentDate) = input_year AND c.country = input_country
    GROUP BY YEAR(p.paymentDate), c.country;
END $$
DELIMITER ;

CALL Get_country_payments(2003, 'France');

-- Q10 (a)
SELECT c.customerName, COUNT(o.orderNumber) AS Order_count,
DENSE_RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY Order_count DESC;

-- Q10 (b)
select 
	year(OrderDate) AS Year,
	monthname(OrderDate) AS Month,
    count(OrderDate) AS Total_Orders,
    
    CONCAT(ROUND(((COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER
    (PARTITION BY MONTH(orderDate)
	ORDER BY YEAR(orderDate)))
    /
    LAG(COUNT(orderNumber)) OVER
		(PARTITION BY MONTH(orderDate)
        ORDER BY YEAR(orderDate))) * 100, 0),'%') AS "%YoY_Change"
        
FROM
	Orders
GROUP BY
	YEAR(OrderDate), MONTH(OrderDate), MONTHNAME(OrderDate)
ORDER BY
	MONTH(OrderDate), YEAR(OrderDate);
        


-- Q11
SELECT p.productLine, COUNT(*) AS product_count
FROM products p
WHERE p.buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY p.productLine;

-- Q12
CREATE TABLE Emp_EH ( EmpID INT PRIMARY KEY, EmpName VARCHAR(100), EmailAddress VARCHAR(100));
DELIMITER $$

CREATE PROCEDURE InsertIntoEmp_EH ( IN p_EmpID INT, IN p_EmpName VARCHAR(100),
IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN SELECT 'Error occurred' AS Message;
    END;

    -- Attempt to insert the values
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    -- If successful
    SELECT 'Record inserted successfully' AS Message;
END$$

DELIMITER ;

CALL InsertIntoEmp_EH(101, 'John Doe', 'john.doe@example.com');

-- Q13
CREATE TABLE Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours INT
);
DELIMITER $$

CREATE TRIGGER trg_before_insert_empbit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END$$
DELIMITER ;

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', -11); 

SELECT * FROM Emp_BIT;
