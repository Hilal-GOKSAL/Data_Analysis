
--////////////////////////////////////////

--UNIVERSITY DATABASE PROJECT 

--///////////////////////////////////////

---------- CREATE DATABASE

CREATE DATABASE UNIVERSITY;

USE UNIVERSITY
---------- CREATE TABLES 

-- Student Table

CREATE TABLE Student (
    Student_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
    student_first_Name NVARCHAR(50) NOT NULL,
    student_last_name NVARCHAR(50) NOT NULL,
    Registration_date DATE NOT NULL,
    Region NVARCHAR(20) NOT NULL
);
---------------------------------

SELECT		*
FROM		Student


--DROP TABLE  Student
---------------------------------

-- Staff Table

CREATE TABLE Staff (
    Staff_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
    Staff_first_name NVARCHAR(50) NOT NULL,
    Staff_last_name NVARCHAR(50) NOT NULL,
    Region NVARCHAR(20) NOT NULL
);

--DROP TABLE Staff
----------------------------------
-- Course Table

USE UNIVERSITY
GO

CREATE FUNCTION dbo.fn_check_credit (
    @course_title NVARCHAR(50),
    @course_credit TINYINT
)
RETURNS VARCHAR(10)
AS 
BEGIN
    DECLARE @credit_real TINYINT
    DECLARE @credit_result VARCHAR(10)
    IF @course_title IN ('Fine Arts', 'German', 'Biology')
        SET @credit_real = 15
    ELSE 
        SET @credit_real = 30 
    IF @course_credit = @credit_real 
        SET @credit_result = 'True'
    ELSE 
        SET @credit_result = 'False'
    RETURN @credit_result
END;

CREATE TABLE Course (
    course_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
    course_title NVARCHAR(50) NOT NULL,
    course_credit TINYINT NOT NULL,
    CONSTRAINT credit_check
    CHECK (dbo.fn_check_credit(course_title, course_credit) = 'True')
);

---------------------------------------
-- Duty Table

CREATE TABLE Duty (
    duty_id TINYINT NOT NULL,
    staff_id INT NOT NULL, 
    duty_name NVARCHAR(20) NOT NULL,
    CONSTRAINT fk_staffid FOREIGN KEY (staff_id) 
	REFERENCES Staff (staff_id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE, 
    CONSTRAINT pk_duty PRIMARY KEY (duty_id, staff_id)
);



-----------------------------------------
-- Student_Staff Table

USE UNIVERSITY
GO 

CREATE FUNCTION dbo.fn_check_region 
(
    @student_id INT,
    @staff_id INT
)
RETURNS VARCHAR(10)
AS 
BEGIN 
    DECLARE @result VARCHAR(20)
    DECLARE @student_result VARCHAR(20) 
    DECLARE @staff_result VARCHAR(10)
		SELECT @student_result = Region 
		FROM student 
		WHERE student_id = @student_id
    
		SELECT @staff_result = Region 
		FROM staff 
		WHERE staff_id = @staff_id
    IF @student_result = @staff_result
        SET @result = 'True'
    ELSE 
        SET @result = 'False'
    RETURN @result 
END;



CREATE TABLE Student_staff (
    student_id INT NOT NULL,
    staff_id INT NOT NULL, 
    duty_id TINYINT NOT NULL,
    
	CONSTRAINT fk_student FOREIGN KEY (student_id) 
	REFERENCES Student (student_id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    CONSTRAINT fk_duty FOREIGN KEY (duty_id, staff_id) 
	REFERENCES Duty (duty_id, staff_id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    CONSTRAINT sstaff_pk PRIMARY KEY (student_id, staff_id, duty_id),
    CONSTRAINT region_control2
    CHECK (dbo.fn_check_region(student_id, staff_id) = 'True')
);



---------------------------------------
-- Staff_Course Table

CREATE TABLE Staff_Course (
    staff_id INT NOT NULL,
    course_id INT NOT NULL, 
    CONSTRAINT fk_staff3 FOREIGN KEY (staff_id) 
	REFERENCES Staff (staff_id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    CONSTRAINT fk_course2 FOREIGN KEY (course_id) 
	REFERENCES Course (course_id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    CONSTRAINT sstaff_pk3 PRIMARY KEY (staff_id, course_id)
);



----------------------------------

-- Student_Course Table

--////////////////////////////////////

--FUNCTION 1

--///////////////////////////////////

CREATE FUNCTION dbo.fn_course_constraint_1 
(
    @student_id INT
)
RETURNS VARCHAR(10)
AS 
BEGIN 
    DECLARE @total_credit INT 
    DECLARE @result VARCHAR(10)
    SELECT @total_credit = SUM(c.course_credit) 
	FROM Course c 
	JOIN Student_Course sc ON c.course_id=sc.course_id 
	WHERE sc.student_id = @student_id
    
	IF @total_credit <= 100
        SET @result = 'True'
    
	ELSE 
        SET @result = 'False'
    
	RETURN @result
END;

-----
--////////////////////////////////////

--FUNCTION 2

--///////////////////////////////////

CREATE FUNCTION dbo.fn_course_region 
(
    @student_id INT,
    @course_id INT
)
RETURNS VARCHAR(10)
AS 
BEGIN 
    DECLARE @result VARCHAR(20)
    DECLARE @student_result VARCHAR(20) 
    DECLARE @course_result VARCHAR(10)
    SELECT @student_result = Region 
	FROM Student 
	WHERE student_id = @student_id
    
	SELECT @course_result = st.Region 
	FROM Course c 
	JOIN Staff_Course sc ON c.course_id=sc.course_id 
    JOIN Staff st ON sc.staff_id=st.staff_id 
    WHERE c.course_id = @course_id
    
	IF @student_result = @course_result
        SET @result = 'True'
    
	ELSE 
        SET @result = 'False'
    
	RETURN @result 
END;

-----------------------------------
--////////////////////////////////////

--Table Construction -  Student_Course

--///////////////////////////////////

CREATE TABLE Student_Course (
    student_id INT NOT NULL,
    course_id INT NOT NULL, 
    CONSTRAINT fk_student2 FOREIGN KEY (student_id) 
	REFERENCES Student (student_id)
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    CONSTRAINT fk_course FOREIGN KEY (course_id) 
	REFERENCES Course (course_id)
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    CONSTRAINT sstaff_pk2 PRIMARY KEY (student_id, course_id),
    CONSTRAINT course_control
    CHECK (dbo.fn_course_constraint_1(student_id) = 'True'),
    CONSTRAINT region_control
    CHECK (dbo.fn_course_region(student_id, course_id) = 'True')
);


--DROP TABLE Student_Course

--////////////////////////////////////////////////////////


---------- INSERTING THE VALUES INTO THE TABLES

--//////////////////////////////////////////////////////


-- Student Table

INSERT INTO Student VALUES ('Alec', 'Hunter', '2020-05-12', 'Wales'),
                ('Browning', 'Blueberry', '2020-05-12', 'Scotland'),
                ('Charlie', 'Apricot', '2020-05-12', 'England'), 
                ('Ursula', 'Douglas', '2020-05-12', 'Scotland'),
                ('Zorro', 'Apple', '2020-05-12', 'England'),
                ('Debbie', 'Orange', '2020-05-12', 'Wales')

----------

SELECT	*
FROM	Student

-----------------------------------------------------------------


-- Staff Table 

INSERT INTO Staff VALUES ('October', 'Lime', 'Wales'),
                ('Ross', 'Island', 'Scotland'),
                ('Harry', 'Smith', 'England'), 
                ('Neil', 'Mango', 'Scotland'),
                ('Kellie', 'Pear', 'England'),
                ('Victor', 'Fig', 'Wales'),
                ('Margeret', 'Nolan', 'England'),
                ('Yavette', 'Berry', 'Northern Ireland'),
                ('Tom', 'Garden', 'Northern Ireland')

------------------

SELECT	*
FROM	Staff

-----------------------------------------------------------------

-- Course Table

INSERT INTO Course VALUES ('Fine Arts', 15),
                     ('German', 15),
                     ('Chemistry', 30),
                     ('French', 30),
                     ('Physics', 30),
                     ('History', 30),
                     ('Music', 30),
                     ('Psychology', 30),
                     ('Biology', 15)

--------------------

SELECT	*
FROM	Course

-----------------------------------------------------


-- Duty Table

insert duty values (1, 1, 'counsel'),
                   (1, 2, 'counsel'),
                   (1, 3, 'counsel'),
                   (1, 4, 'counsel'),
                   (1, 5, 'counsel'),
                   (1, 6, 'counsel'),
                   (2, 4, 'tutor'),
                   (2, 3, 'tutor'),
                   (2, 7, 'tutor'),
                   (2, 8, 'tutor'),
                   (2, 9, 'tutor')

-----------------------

SELECT	*
FROM	Duty

-----------------------------------------------------


-- Student_Staff Table

--Insertion gives an error: 
--the error message: 
	--[The INSERT statement conflicted with the CHECK constraint "region_control2". 
	--The conflict occurred in database "UNIVERSITY", table "dbo.Student_staff"."]

--**There is a mismatch between students's region_id and staff's region_id

INSERT INTO Student_staff VALUES (1, 1, 1),
                            (2, 2, 1),
                            (3, 3, 1),
                            (4, 4, 1),
                            (5, 5, 1),
                            (6, 6, 1),
                            (1, 4, 2),
                            (1, 3, 2),
                            (2, 4, 2),
                            (2, 3, 2),
                            (3, 4, 2),
                            (3, 3, 2),
                            (4, 4, 2),
                            (4, 3, 2)

-------------------
-- we cannot assign any value inside the Student_staff table.
SELECT	*
FROM	Student_staff

------------------------------------------------------------------


-- Staff_Course Table

--(Table explains which tutor enters to which course.)

INSERT INTO Staff_Course VALUES (4, 1),
                           (3, 2),
                           (7, 3),
                           (5, 4),
                           (7, 4),
                           (3, 5),
                           (5, 5),
                           (8, 9)

----------------------------

SELECT	*
FROM	Staff_Course

------------------------------------------------------


-- Student_Course Table

-- Same error was recieved as we saw in the Student_Staff table value insertion.
--The error message: 
	--The INSERT statement conflicted with the CHECK constraint "region_control". 
	--The conflict occurred in database "UNIVERSITY", table "dbo.Student_Course".

INSERT INTO Student_Course VALUES (1, 1),
                             (1, 2),
                             (2, 1),
                             (2, 2),
                             (3, 1),
                             (3, 2),
                             (4, 1),
                             (4, 2)



----------------------------------------------------------------------------------------
---------- CONSTRAINTS

-- 1. Students are constrained in the number of courses they can be enrolled in at any one time. 
--	  They may not take courses simultaneously if their combined points total exceeds 180 points.

-- You can see this constraints inside the execution of Student_Course table at the very beginning of this page.

-- Now, none of the students were enrolled in courses. The query down below showed that some of the students cannot be enrolled in several courses due to check
--constraint that we set before. As there is a rule of amount of course_credit that each student can get throuoght the year.


INSERT INTO Student_Course VALUES (3, 2),
                             (3, 4),
                             (3, 5),
                             (3, 2)
                             

-- The current status can be seen through the below query:

SELECT st.student_id, st.course_id, c.course_title, c.course_credit
FROM Student_Course st 
JOIN Course c ON st.course_id=c.course_id



--------------------------------------------------------------------------------------------
-- 2. The student's region and the counselor's region must be the same.

--The below function showed this constraint for region restriction for both students as well as staff.
-----
--////////////////////////////////////

--FUNCTION 2

--///////////////////////////////////
/*
CREATE FUNCTION dbo.fn_course_region 
(
    @student_id INT,
    @course_id INT
)
RETURNS VARCHAR(10)
AS 
BEGIN 
    DECLARE @result VARCHAR(20)
    DECLARE @student_result VARCHAR(20) 
    DECLARE @course_result VARCHAR(10)
    SELECT @student_result = Region 
	FROM Student 
	WHERE student_id = @student_id
    
	SELECT @course_result = st.Region 
	FROM Course c 
	JOIN Staff_Course sc ON c.course_id=sc.course_id 
    JOIN Staff st ON sc.staff_id=st.staff_id 
    WHERE c.course_id = @course_id
    
	IF @student_result = @course_result
        SET @result = 'True'
    
	ELSE 
        SET @result = 'False'
    
	RETURN @result 
END;

*/


/* As, the student_staff table is empty we can only insert values for whom located in the same region. Therefore, the below 
query will be running successfully.*/

INSERT INTO Student_staff VALUES (1, 1, 1),
                            (2, 2, 1),
                            (3, 3, 1),
                            (4, 4, 1),
                            (5, 5, 1),
                            (6, 6, 1)

--To  check the insertion of the values inside the Student_staff table and related information we can run the below query;

------------------
SELECT		s.student_id, 
			s.student_first_Name, 
			s.student_last_name, 
			s.region, 
			st.staff_id, 
			st.Staff_first_name, 
			st.Staff_last_name, 
			d.duty_name, 
			st.Region
FROM Student s 
JOIN Student_staff ss ON s.student_id=ss.student_id 
JOIN duty d ON (ss.duty_id=d.duty_id AND ss.staff_id=d.staff_id)
JOIN staff st ON d.staff_id=st.staff_id;

-----------------


/*
To check whether we successfully insert our values based on Constraint; we will try to insert a  tutor_id who is located in different
region than his student. 
*/

-- For example, if I try to insert Neil Mango as the Fine Arts tutor of Alec Hunter, the query will not work.

INSERT INTO Student_staff VALUES (1, 4, 2)



--The Error message will be showed:
	/*
	The INSERT statement conflicted with the CHECK constraint "region_control2". The conflict occurred in database "UNIVERSITY", table "dbo.Student_staff".
The statement has been terminated.

	*/











---------- ADDITIONALLY TASKS

-- 1. Test the credit limit constraint.

-- Done

-- 2. Test that you have correctly defined the constraint for the student counsel's region. 

-- Done

-- 3. Try to set the credits of the History course to 20. (You should get an error.)

-- Done
--The check constraint for this;

/*
CREATE FUNCTION dbo.fn_check_credit (
    @course_title NVARCHAR(50),
    @course_credit TINYINT
)
RETURNS VARCHAR(10)
AS 
BEGIN
    DECLARE @credit_real TINYINT
    DECLARE @credit_result VARCHAR(10)
    IF @course_title IN ('Fine Arts', 'German', 'Biology')
        SET @credit_real = 15
    ELSE 
        SET @credit_real = 30 
    IF @course_credit = @credit_real 
        SET @credit_result = 'True'
    ELSE 
        SET @credit_result = 'False'
    RETURN @credit_result
END;

*/

-- The below query will return an error message.

INSERT INTO Course VALUES ('History', 20)

--The error message: 
	/* 
	The INSERT statement conflicted with the CHECK constraint "credit_check". The conflict occurred in database "UNIVERSITY", table "dbo.Course".
The statement has been terminated.
	*/
	

-- 4. Try to set the credits of the Fine Arts course to 30. (You should get an error.)

INSERT INTO Course VALUES ('Fine Arts', 30)

-- 5. Debbie Orange wants to enroll in Chemistry instead of German. (You should get an error.)

SELECT * FROM Student;
SELECT * FROM Course;

-- Using the above queries we can see that Debbie Orange's student_id is 6 and the course_id of Chemistry is 3.
-- Since Debbie is from Wales and the tutor of the Chemistry class is from England, the below query will not run successfully.

INSERT INTO Student_Course VALUES (6, 4)

-- 6. Try to set Tom Garden as counsel of Alec Hunter (You should get an error.)

-- Using the below query, we can get the current counsels of student.

SELECT		s.student_id, 
			s.student_first_Name, 
			s.student_last_name, 
			s.Region, 
			st.staff_id, 
			st.Staff_first_name, 
			st.Staff_last_name, 
			d.duty_name
FROM		Student s 
JOIN		Student_staff ss ON s.student_id=ss.student_id 
JOIN		duty d ON (ss.staff_id=d.staff_id and ss.duty_id=d.duty_id) 
JOIN		staff st ON d.staff_id=st.staff_id;

SELECT * FROM Student_staff

-- Using the below query, we can see the region of Tom Garden.

SELECT *
FROM Staff 
WHERE Staff_first_name = 'Tom'

-- If I try to set Tom Garden (staff_id = 9) as counsel (duty_id = 1) of Alec Hunter (student_id = 1),
-- the query will return an error message and will not run.

INSERT INTO Student_staff VALUES (1, 9, 1)

-- 7. Swap counselors of Ursula Douglas and Bronwin Blueberry.

UPDATE student_staff
SET staff_id = 4
WHERE student_id = 2;

UPDATE student_staff
SET staff_id = 2 
WHERE student_id = 4;

-- 8. Remove a staff member from the staff table.
--	  If you get an error, read the error and update the reference rules for the relevant foreign key.

SELECT * FROM Staff

DELETE FROM Staff WHERE staff_id = 1

--////////////////////////////////////////////////////////////////////
