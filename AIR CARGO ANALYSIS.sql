create database air_cargo;
use air_cargo;
show tables;

CREATE TABLE CUSTOMER (
	customer_id INT PRIMARY KEY NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	date_of_birth TEXT,
	gender CHAR(1), CHECK (GENDER IN('M' , 'F'))
);
SELECT * FROM CUSTOMER;

CREATE TABLE PASSENGERS_ON_FLIGHTS (
	customer_id INT,
    aircraft_id	VARCHAR(25),
    route_id INT,
	depart CHAR(3),
    arrival	CHAR(3),
    seat_num VARCHAR(10),
	class_id VARCHAR(50), CHECK (CLASS_ID IN('Bussiness','Economy','Economy Plus','First Class')),
	travel_date	TEXT,
    flight_num INT);
SELECT * FROM passengers_on_flights;

CREATE TABLE TICKET_DETAILS (
	p_date TEXT NOT NULL,
	customer_id INT NOT NULL,
	aircraft_id VARCHAR(25),
	class_id VARCHAR(50), CHECK (CLASS_ID IN('Bussiness','Economy','Economy Plus','First Class')),
	no_of_tickets INT,
	a_code CHAR(3),
	Price_per_ticket INT,
	brand VARCHAR(50));
SELECT * FROM ticket_details;

CREATE TABLE ROUTES (
	route_id INT PRIMARY KEY,
	flight_num INT UNIQUE NOT NULL,
	origin_airport	CHAR(3),
    destination_airport	CHAR(3),
    aircraft_id VARCHAR(25),
	distance_miles INT, CHECK (distance_miles>0)
);
SELECT * FROM ROUTES;

/* 	Write a query to display all the passengers (customers) who have
	travelled in routes 01 to 25. Take data  from the passengers_on_flights table. */
    
SELECT DISTINCT * FROM CUSTOMER WHERE customer_id IN( SELECT customer_id FROM 
passengers_on_flights WHERE ROUTE_ID BETWEEN 1 AND 25) ORDER BY customer_id;

/*	Write a query to identify the number of passengers and total revenue 
	in business class from the ticket_details table. */
    
SELECT SUM(no_of_tickets) NO_OF_PASSENGERS, sum(no_of_tickets*Price_per_ticket) TOTAL_REVENUE FROM ticket_details WHERE class_id ='BUSSINESS';

/*	Write a query to display the full name of the customer by 
	extracting the first name and last name from the customer table. */
    
SELECT CONCAT(first_name,' ',last_name) FULL_NAME FROM CUSTOMER;

/*	Write a query to extract the customers who have registered and 
	booked a ticket. Use data from the customer and ticket_details tables.*/

SELECT distinct C.customer_id, concat(first_name,' ',last_name) FULL_NAME,gender,
 count(*) over(PARTITION BY T.customer_id) NO_OF_TICKET_BOOKINGS FROM CUSTOMER C 
 JOIN ticket_details T ON C.customer_id=T.customer_id ORDER BY C.CUSTOMER_ID;
 
 /*	Write a query to identify the customer’s first name and last name based on 
	their customer ID and brand (Emirates) from the ticket_details table. */
 
 SELECT first_name,last_name FROM CUSTOMER WHERE customer_id IN (SELECT customer_id FROM ticket_details WHERE brand ='EMIRATES');
 
 /*	Write a query to identify the customers who have travelled by Economy Plus class 
	using Group By and Having clause on the passengers_on_flights table. */
    
SELECT customer_id,first_name,last_name FROM CUSTOMER WHERE customer_id IN(
WITH SS AS(SELECT customer_id,class_id,count(class_id) FROM passengers_on_flights 
GROUP BY customer_id,class_id HAVING class_id= 'ECONOMY PLUS')SELECT customer_ID FROM SS);

/*	Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table. */

SELECT SUM(no_of_tickets*Price_per_ticket) REVENUE,IF(SUM(no_of_tickets*Price_per_ticket)>
10000,'REVENUE CROSSED 10000','REVENUE IS BELOW 10000') REVENUE_STATUS FROM ticket_details;

/*	Write a query to create and grant access to a new user to perform operations on a database. */

CREATE USER IF NOT EXISTS `ALPHA`@`911` IDENTIFIED BY 'PASSWORD123';
GRANT ALL PRIVILEGES ON AIR_CARGO TO `ALPHA`@`911`;

/*	Write a query to find the maximum ticket price for each class using window functions on the ticket_details table. */

SELECT class_id,MAX(Price_per_ticket) FROM ticket_details GROUP BY class_id;

/*	Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table. */

CREATE INDEX INDDEX_ROUTE_ID ON passengers_on_flights(route_id);
SELECT P.customer_id,concat(FIRST_NAME,' ',LAST_NAME) NAME,route_id FROM passengers_on_flights P 
JOIN CUSTOMER C ON P.customer_id=C.customer_id WHERE route_id=4;

/*	 For the route ID 4, write a query to view the execution plan of the passengers_on_flights table. */

EXPLAIN SELECT * FROM passengers_on_flights WHERE route_id=4;

/*	Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function. */

SELECT customer_id,aircraft_id,sum(no_of_tickets*Price_per_ticket) TOTAL_PRICE FROM ticket_details group by customer_id,aircraft_id WITH ROLLUP;

/*	Write a query to create a view with only business class customers along with the brand of airlines. */

CREATE VIEW BUSINESS_CLASS_CUSTOMERS AS(SELECT T.customer_id, FIRST_NAME,LAST_NAME,class_id,brand FROM 
ticket_details T JOIN CUSTOMER C ON T.customer_id=C.customer_id WHERE class_id ='BUSSINESS');

SELECT * FROM BUSINESS_CLASS_CUSTOMERS order by BRAND,customer_id;

/*	Write a query to create a stored procedure to get the details of all passengers flying between
	a range of routes defined in run time. */

DELIMITER $$
USE `air_cargo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ROUTE_DETAILS`(RID1 INT, RID2 INT)
BEGIN
	select C.CUSTOMER_ID, concat(FIRST_NAME,' ',LAST_NAME) CUSTOMER_NAME,GENDER,ROUTE_ID FROM 
    CUSTOMER C JOIN PASSENGERS_ON_FLIGHTS P ON C.CUSTOMER_ID = P.CUSTOMER_ID WHERE ROUTE_ID BETWEEN RID1 AND RID2 order by C.CUSTOMER_ID;
END$$

DELIMITER ;
;    
CALL ROUTE_DETAILS(5,10);

/*	Write a query to create a stored procedure that extracts all the details from the routes
	table where the travelled distance is more than 2000 miles. */

DELIMITER $$
USE `air_cargo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ROUTES_ABOVE`(DISTANCE INT)
BEGIN
	SELECT * FROM ROUTES WHERE DISTANCE_MILES > DISTANCE ORDER BY DISTANCE_MILES;
END$$

DELIMITER ;
;
CALL ROUTES_ABOVE(2000);

/*	Write a query to create a stored procedure that groups the distance travelled by each flight 
    into three categories. The categories are, short distance travel (SDT) for >=0 AND <= 2000 
    miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500. */

DELIMITER $$
USE `air_cargo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DISTANCE_STATUS`()
BEGIN
    SELECT ROUTE_ID,FLIGHT_NUM,DISTANCE_MILES,IF(DISTANCE_MILES >= 6500,'LDT',
    IF(DISTANCE_MILES >= 2000,'IDT','SDT')) STATUS FROM ROUTES ORDER BY STATUS;
END$$

DELIMITER ;
;
CALL DISTANCE_STATUS();

/* 	Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services
    are provided for the specific class using a stored function in stored procedure on the ticket_details table.
	Condition:
	If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No  */
    
DELIMITER $$
USE `air_cargo`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `service`(class varchar(40)) RETURNS varchar(5) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	declare service_status varchar(5);
	if class in ('bussiness','economy plus') then
		set service_status = 'yes';
	else
		set service_status ='no';
	end if;
RETURN service_status;
END$$

DELIMITER ;
;

DELIMITER $$
USE `air_cargo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `service_details`()
BEGIN
	select p_date,customer_id,class_id,service(class_id) from ticket_details;
END$$

DELIMITER ;
;

call service_details;