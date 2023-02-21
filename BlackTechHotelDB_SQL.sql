--#region CREATING DATABASE FOR PROJECT
--CREATE DATABASE BlackTechHotelDB;
--#endregion


--#region IMPORT CSV FILES
--csv files for the project is imported using the import wizard (ctrl+i)
--#endregion


--#region INTEROGATING THE IMPORTED DATA

SELECT *
FROM dbo.Bookings -- 10,346 rows

SELECT *
FROM Requests -- 5,000 rows

SELECT *
FROM dbo.FoodOrders -- 2,965 rows

SELECT *
FROM dbo.Rooms -- 5 rows

SELECT *
FROM dbo.Menu -- 16 rows

SELECT TOP (5) *
FROM Bookings

SELECT TOP (5) *
FROM FoodOrders

SELECT TOP (5) *
FROM Menu

SELECT TOP (5) *
FROM Requests

SELECT TOP (5) *
FROM Rooms

--#endregion


--#region CREATING TABLE RELATIONSHIPS
-- Create request_id as a foreign key on the Bookings table
/* ALTER TABLE [dbo].[Bookings]
ADD FOREIGN KEY (request_id) REFERENCES Requests(request_id); */

-- Create menu_id as a foreign key on the FoodOrders table
/* ALTER TABLE [dbo].[FoodOrders]
ADD FOREIGN KEY (menu_id) REFERENCES Menu(menu_id); */
--#endregion


--#region UNDERSTANDING NUMBERS ON OUR DATA

--1. identity the number of clients that made room request
SELECT COUNT (DISTINCT client_name)
FROM dbo.Requests -- 4,998 

--2. identity the number of confirmed booking
-- using CTE to identify the missing records (not confirmed or cancelled bookings) between Request table and Booking table
-- This query shows us that 281 records were the requested that were not 'confirmed booking'
WITH REBK AS (
SELECT Requests.request_id FROM Requests
EXCEPT
SELECT Bookings.request_id FROM Bookings
)
SELECT * 
FROM REBK
INNER JOIN
Requests ON
rebk.request_id = Requests.request_id --281

--3. we know there are 10,346 bookings that were made from the 4,998 clients
SELECT COUNT(DISTINCT booking_id)
FROM dbo.Bookings -- 10,346

--4. identify the transaction period (2016-01-01 to 2016-04-13)
SELECT top (1) start_date
FROM Bookings
ORDER BY start_date asc 
--
SELECT top (1) end_date
FROM Bookings
ORDER BY end_date DESC 

/* Repeating same query on Request and FoodOders tables to verify the result is accurate
--Request table
SELECT top (1) start_date
FROM Requests
ORDER BY start_date asc 
--
SELECT top (1) end_date
FROM Requests
ORDER BY end_date DESC 

--FoodOders table
SELECT top (1) order_date
FROM FoodOrders
ORDER BY order_date asc 
--
SELECT top (1) order_date
FROM FoodOrders
ORDER BY order_date DESC */

--5. we know there are 2,965 food orders records/entry, and 8,714 total number of food ordered
SELECT COUNT(num_of_orders)
FROM dbo.FoodOrders

SELECT sum(num_of_orders)
FROM dbo.FoodOrders -- 8,714

--6. Segmenting rooms to verify the prefix on the Room table is accurate with room type column on the Request table
SELECT *,
CASE WHEN room_type = 'conference_room_large' then 'L'
        WHEN room_type = 'normal_room' then 'N'
        WHEN room_type = 'conference_room_small' then 'S'
        WHEN room_type = 'double_room' then 'D'
        WHEN room_type = 'deluxe_room' then 'X'
        end as room        
FROM dbo.Requests
JOIN Rooms
ON Requests.room_type = Rooms.[type]

-- having identified these numbers, we then proceed with our joins
--#endregion


--#region INTEROGATING TABLE JOINS - (NOT WORKING/UNSTABLE JOINS)
--TEST JOIN 1
-- Too many null values were returned
SELECT *
FROM dbo.Requests
LEFT JOIN Bookings
ON Requests.request_id = Bookings.request_id
ORDER by Bookings.booking_id  -- 10,627 rows

-- out of the 10,346 records on the Bookings table, and 5,000 on Request table, there were 4,719 matches (the number of confirmed booking)
SELECT Requests.request_id FROM Requests
INTERSECT
SELECT Bookings.request_id FROM Bookings

-- However, 281 records did not match.
-- In a hotel setup, it is normal to have request/reservation that are not confirmed or cancelled bookings.
-- It therefore fair to assume that these 281 records were not confirmed or cancelled bookings.
SELECT Requests.request_id FROM Requests
EXCEPT
SELECT Bookings.request_id FROM Bookings

--TEST JOIN 2
-- Join FoodOrder and the Booking tables (There were too many repitition of food orders)
-- Example on row 1, an order on 2016-04-07 for room N14 cannot be for a client who booked/requsted a room between 2016-01-26 to 2016-01-29
SELECT * 
FROM dbo.FoodOrders
JOIN Bookings
ON Bookings.room = FoodOrders.bill_room 
ORDER BY order_date DESC -- 55,333 rows

--However, out of the 10,346 records on the Bookings table, and 2,965 on FoodOrder table, only 425 records matched
SELECT Bookings.room FROM Bookings
INTERSECT
SELECT FoodOrders.bill_room FROM FoodOrders 

-- and 259 did not match so it will be advisable to aviod this join
SELECT Bookings.room FROM Bookings
EXCEPT
SELECT FoodOrders.bill_room FROM FoodOrders


--TEST JOIN 3
-- Join Request and the FoodOrders tables 
SELECT *
FROM dbo.Requests
INNER JOIN FoodOrders
ON Requests.start_date = FoodOrders.order_date 
ORDER BY Requests.start_date DESC  -- 159,600 rows

-- out of the 5,000 records on the Requests table, and 2,965 on FoodOrder table, only 90 matches
-- 90 matches represent 3% matches of FoodOders records, this join will give us a very poor representation of our data.
SELECT Requests.start_date FROM Requests
INTERSECT
SELECT FoodOrders.order_date FROM FoodOrders 

-- 0 did not match. Seeing that only 90 matches from 5,000 and 2,965 records it will be advisable to aviod this join
SELECT Requests.start_date FROM Requests
EXCEPT
SELECT FoodOrders.order_date FROM FoodOrders 


--TEST JOIN 4
-- Join Booking, Requests and FoodOrders tables (There were too many repitition of food orders)
-- Example on row 1, an order on 2016-01-01 for room S62 cannot be for a client, Le O'Kon who booked/requsted a party between 2016-03-02 to 2016-03-06
-- It has also been established earlier that the FoodOrder table join with Request table will throw a very poor representation of our data.
SELECT *
FROM dbo.Bookings
JOIN Requests
ON Bookings.request_id = Requests.request_id
JOIN FoodOrders
ON Bookings.room = FoodOrders.bill_room  
ORDER BY order_date ASC -- 55,333 rows

--TEST JOIN 5
-- (There were too many repitition of food orders, and too many null values)
SELECT * 
FROM dbo.Bookings
FULL OUTER JOIN FoodOrders
ON Bookings.room = FoodOrders.bill_room
FULL OUTER JOIN Requests
ON Bookings.request_id = Requests.request_id  
ORDER BY order_date ASC -- 58,937 rows

-- It is therefore safe to separate joining FoodOders table with either Request or Booking table
--#endregion


--#region INTEROGATING TABLE JOINS - (WORKING JOINS)

--TEST JOIN 6
-- Join Booking and Request tables
select *
FROM Bookings
JOIN Requests
ON Requests.request_id = Bookings.request_id -- 10,346 rows

-- out of the 10,346 records on the Bookings table, and 4,719 (5,000 - 281) on Request table, there were 4,719 matches.
-- 100% matches on the Request table (100% confirmed booking)
SELECT Bookings.request_id FROM Bookings
INTERSECT
SELECT Requests.request_id FROM Requests

-- 0 did not match, this is will be a good join with 100% quality data
SELECT Bookings.request_id FROM Bookings
EXCEPT
SELECT Requests.request_id FROM Requests

--TEST JOIN 7
-- Join Request and the Rooms tables
SELECT *
FROM dbo.Requests
JOIN Rooms
ON Requests.room_type = Rooms.[type] -- 5,000 rows

-- out of the 5,000 records on the Requests table, and 5 on Room table, there were 5 matches
-- 100% matches on the Room table
SELECT Requests.room_type FROM Requests
INTERSECT
SELECT Rooms.[type] FROM Rooms

-- 0 did not match, this is will be a good join with 100% quality data
SELECT Requests.room_type FROM Requests
EXCEPT
SELECT Rooms.[type] FROM Rooms

--TEST JOIN 8
-- therefore we can proceed with joining Booking, Request, and Rooms tables
SELECT *
FROM dbo.Bookings
JOIN Requests
ON Bookings.request_id = Requests.request_id
JOIN Rooms
ON Requests.room_type = Rooms.[type] -- 10,346

--TEST JOIN 9
-- Join FoodOrders and the Menu tables
SELECT *
FROM FoodOrders
JOIN Menu
ON FoodOrders.menu_id = Menu.menu_id -- 2,965

-- out of the FoodOrders 2,965 records and 16 records on Menu table, there were 16 matches
-- 100% matches on the Menu table
SELECT FoodOrders.menu_id FROM FoodOrders
INTERSECT
SELECT Menu.menu_id FROM Menu

-- 0 did not match, this is will be a good join with 100% quality data
SELECT FoodOrders.menu_id FROM FoodOrders
EXCEPT
SELECT Menu.menu_id FROM Menu
-- The FoodOders and Menu table is a good join with 100% quality data

-- We have therefore, succeeded with our joins and separated our joins into two separate table
--#endregion


--#region DROPPING, ADDING AND CALCULATING DERIVED COLUMNS 
--JOIN 8 with all the needed columns
SELECT bk.booking_id as BookingID, Re.request_id as RequestID, re.client_name as Client_Name, bk.room as Room_#, 
        re.request_type as Room_Request_Type, re.room_type as Room_Type, re.start_date as Check_In_Date, re.end_date as Check_Out_Date, 
        (DATEDIFF(DAY,re.start_date,re.end_date)) as Duration_of_Stay, rm.price_day as Room_Rate,
        (DATEDIFF(DAY,re.start_date,re.end_date)*rm.price_day) AS Occupancy_Cost, rm.capacity as Room_Capacity,
        re.adults as Guest_Adults, re.children as Guest_Children
FROM Bookings AS bk 
JOIN Requests AS re 
ON re.request_id = bk.request_id
JOIN Rooms AS rm
ON re.room_type = rm.type
ORDER BY bk.start_date

--JOIN 9 with all the needed columns
SELECT  fo.dest_room as Order_Destination, fo.bill_room as Bill_Room, mn.category as Menu_Category, mn.menu_name as Menu_Name, 
        fo.order_date as Order_Date, fo.time_of_order as Time_of_Order, fo.num_of_orders as Number_of_Orders, mn.price as Menu_Price, 
        (fo.num_of_orders * mn.price) as Order_Cost
FROM dbo.FoodOrders as fo
JOIN Menu as mn
ON mn.menu_id = fo.menu_id
ORDER BY fo.order_date

--#endregion


--#region CREATING TWO VIEWS USING JOIN 8 AND 9 FOR VISUALISATION

--View 1
-- Using Join 8 to create a view, called view_reservation for the confirmed bookings transactions
CREATE VIEW view_reservation AS (SELECT bk.booking_id as BookingID, Re.request_id as RequestID, re.client_name as Client_Name, bk.room as Room_#, 
        re.request_type as Room_Request_Type, re.room_type as Room_Type, re.start_date as Check_In_Date, re.end_date as Check_Out_Date, 
        (DATEDIFF(DAY,re.start_date,re.end_date)) as Duration_of_Stay, rm.price_day as Room_Rate,
        (DATEDIFF(DAY,re.start_date,re.end_date)*rm.price_day) AS Occupancy_Cost, rm.capacity as Room_Capacity,
        re.adults as Guest_Adults, re.children as Guest_Children
FROM Bookings AS bk 
JOIN Requests AS re 
ON re.request_id = bk.request_id
JOIN Rooms AS rm
ON re.room_type = rm.type)

--View 2
-- Using Join 9 to Create a view, view_restuarant for the food orders transaction
CREATE VIEW view_restuarant AS (SELECT  fo.dest_room as Order_Destination, fo.bill_room as Bill_Room, mn.category as Menu_Category, mn.menu_name as Menu_Name, 
        fo.order_date as Order_Date, fo.time_of_order as Time_of_Order, fo.num_of_orders as Number_of_Orders, mn.price as Menu_Price, 
        (fo.num_of_orders * mn.price) as Order_Cost
FROM dbo.FoodOrders as fo
JOIN Menu as mn
ON mn.menu_id = fo.menu_id)

--#endregion


--#region MOVE DATA FROM VIEW INTO A NEW TABLE
--View 1
SELECT *
FROM view_reservation

-- Move data into a new table named Reservation

select * into Reservation FROM view_reservation

-- After moving data use the below query to drop the view
--DROP VIEW view_reservation;

SELECT *
from Reservation

--If not statisfied with the table drop table with the query below
-- DROP TABLE Reservation;

--View 2
SELECT *
FROM view_restuarant

-- Move data into a new table named Restaurant

select * into Restaurant FROM view_restuarant

-- After moving data use the below query to drop the view
-- DROP VIEW view_restuarant;

SELECT *
from Restaurant

--If not statisfied with the table drop table with the query below
-- DROP TABLE Restaurant;

--#endregion

--This concludes the data manipulation and wrangling process. 
--Therefore, our data is ready for ETL by PowerBI.