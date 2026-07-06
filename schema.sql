-- ------------------------------------
-- Students Record Database (BCNF)
-- ------------------------------------

-- DROP TABLE IF THEY ALREADY EXITS 
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Instructors;
DROP TABLE IF EXISTS Advisors;

-- ------------------------------
-- Advisors
-- ------------------------------

CREATE TABLE Advisors ( advisor_name varchar(100) primary key, advisor_email varchar(100) not null unique);

-- -----------------------------
-- Instructors
-- -----------------------------

CREATE TABLE Instructors (instructor_name varchar(100) primary key, instructor_email varchar(100) not null unique);

-- -----------------------------
-- Students
-- -----------------------------

CREATE TABLE Students( 
student_id int primary key,
student_name varchar(100) not null, 
department varchar(100) not null, 
advisor_name varchar(100) not null, 
foreign key (advisor_name)
references Advisors(advisor_name)
);

-- --------------------------------
-- Courses 
-- --------------------------------

CREATE TABLE Courses (
course_code varchar(10) primary key, 
course_name varchar(100) not null, 
instructor_name varchar(100) not null,
foreign key (instructor_name)
references Instructors(instructor_name)
);

-- -------------------------------
-- Enrollments
-- -------------------------------

CREATE TABLE Enrollments( 
student_id int,
course_code varchar(10),
enrollment_year int default 2025,
marks_obatined decimal(5,2)
CHECK (marks_obtained >=0 and marks_obtained <=100),
primary key (student_id, course_code),
foreign key (student_id)
references Students(student_id),
foreign key (course_code)
references Courses (course_code)
);

