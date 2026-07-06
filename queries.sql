-- =====================================================
-- Task 1.3 – Data Manipulation
-- =====================================================

-- ---------------------------------------------------------
-- a. INSERT Statements
-- ---------------------------------------------------------

-- Insert Advisors

INSERT INTO Advisors (advisor_name, advisor_email)
VALUES
('Dr. Mehta', 'mehta@university.edu'),
('Dr. Sharma', 'sharma@university.edu');

-- ---------------------------------------------------------

-- Insert Instructors

INSERT INTO Instructors (instructor_name, instructor_email)
VALUES
('Prof. Kumar', 'kumar@university.edu'),
('Prof. Singh', 'singh@university.edu');

-- ---------------------------------------------------------

-- Insert Students

INSERT INTO Students (student_id, student_name, department, advisor_name)
VALUES
(101, 'Aman Verma', 'Computer Science', 'Dr. Mehta'),
(102, 'Priya Sharma', 'Information Technology', 'Dr. Sharma'),
(103, 'Rahul Gupta', 'Computer Science', 'Dr. Mehta');

-- ---------------------------------------------------------

-- Insert Courses

INSERT INTO Courses (course_code, course_name, instructor_name)
VALUES
('CS101', 'Database Systems', 'Prof. Kumar'),
('CS202', 'Operating Systems', 'Prof. Singh');

-- ---------------------------------------------------------

-- Insert Enrollments

INSERT INTO Enrollments
(student_id, course_code, enrollment_year, marks_obtained)
VALUES
(101, 'CS101', 2024, 82),
(102, 'CS202', 2025, 74),
(103, 'CS101', 2025, 28);

-- ---------------------------------------------------------
-- b. Update instructor email using PRIMARY KEY
-- ---------------------------------------------------------

UPDATE Instructors
SET instructor_email = 'newkumar@university.edu'
WHERE instructor_name = 'Prof. Kumar';

-- ---------------------------------------------------------
-- c. Delete enrollment records where marks < 35
-- ---------------------------------------------------------

DELETE FROM Enrollments
WHERE marks_obtained < 35;

-- ---------------------------------------------------------
-- d. Delete all rows from old StudentRecords table
-- ---------------------------------------------------------

-/*
DELETE is preferred instead of TRUNCATE because:

- DELETE is a DML statement.
- DELETE works safely with BEGIN TRANSACTION and ROLLBACK
  across major database systems.

TRUNCATE behaves differently across database engines.

In MySQL:
- TRUNCATE is treated as DDL.
- It performs an implicit COMMIT.
- Changes cannot be rolled back.

In PostgreSQL:
- TRUNCATE is transactional and can be rolled back.

Therefore DELETE is the safest cross-database choice for
transaction-controlled bulk removal.
*/

DELETE FROM StudentRecords;

-- =====================================================
-- Task 1.4 – Advanced Queries
-- =====================================================

-- ---------------------------------------------------------
-- a. Students enrolled in CS101, CS202 or CS303
-- ---------------------------------------------------------

SELECT
    s.student_name,
    c.course_name
FROM Students s
JOIN Enrollments e
    ON s.student_id = e.student_id
JOIN Courses c
    ON e.course_code = c.course_code
WHERE e.course_code IN ('CS101','CS202','CS303');

-- ---------------------------------------------------------
-- b. Students with marks between 60 and 85
--    and advisor email not NULL
-- ---------------------------------------------------------

SELECT
    s.student_name,
    e.marks_obtained,
    a.advisor_email
FROM Students s
JOIN Advisors a
    ON s.advisor_name = a.advisor_name
JOIN Enrollments e
    ON s.student_id = e.student_id
WHERE e.marks_obtained
      BETWEEN 60 AND 85
AND a.advisor_email IS NOT NULL;

-- ---------------------------------------------------------
-- c. Department-wise Average, Minimum and Maximum Marks
-- ---------------------------------------------------------

SELECT
    s.department,
    AVG(e.marks_obtained) AS average_marks,
    MIN(e.marks_obtained) AS minimum_marks,
    MAX(e.marks_obtained) AS maximum_marks
FROM Students s
JOIN Enrollments e
    ON s.student_id = e.student_id
GROUP BY s.department
HAVING AVG(e.marks_obtained) > 55;

-- ---------------------------------------------------------
-- d(i). INNER JOIN
-- ---------------------------------------------------------

SELECT
    s.student_name,
    c.course_name,
    e.marks_obtained
FROM Students s
INNER JOIN Enrollments e
    ON s.student_id = e.student_id
INNER JOIN Courses c
    ON e.course_code = c.course_code;

-- ---------------------------------------------------------
-- d(ii). LEFT JOIN
-- ---------------------------------------------------------

SELECT
    s.student_name,
    c.course_name,
    e.marks_obtained
FROM Students s
LEFT JOIN Enrollments e
    ON s.student_id = e.student_id
LEFT JOIN Courses c
    ON e.course_code = c.course_code;

-- ---------------------------------------------------------
-- e. Students scoring above department average
-- ---------------------------------------------------------

SELECT
    s.student_name,
    e.marks_obtained
FROM Students s
JOIN Enrollments e
ON s.student_id = e.student_id
WHERE e.marks_obtained >
(
    SELECT AVG(e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2
    ON s2.student_id = e2.student_id
    WHERE s2.department = s.department
);

-- ---------------------------------------------------------
-- f. Students enrolled in 2024 but not in 2025
-- ---------------------------------------------------------

SELECT student_id
FROM Enrollments
WHERE enrollment_year = 2024

EXCEPT

SELECT student_id
FROM Enrollments
WHERE enrollment_year = 2025;

-- ---------------------------------------------------------
-- g. Second highest marks in each department
-- ---------------------------------------------------------

SELECT
    s.student_name,
    s.department,
    e.marks_obtained
FROM Students s
JOIN Enrollments e
ON s.student_id = e.student_id
WHERE 1 =
(
    SELECT COUNT(DISTINCT e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2
    ON s2.student_id = e2.student_id
    WHERE s2.department = s.department
    AND e2.marks_obtained > e.marks_obtained
);

-- ---------------------------------------------------------
-- h. ROW_NUMBER(), RANK(), DENSE_RANK()
-- ---------------------------------------------------------

SELECT
    s.student_name,
    s.department,
    e.marks_obtained,

    ROW_NUMBER() OVER
    (
        PARTITION BY s.department
        ORDER BY e.marks_obtained DESC
    ) AS row_number,

    RANK() OVER
    (
        PARTITION BY s.department
        ORDER BY e.marks_obtained DESC
    ) AS rank_value,

    DENSE_RANK() OVER
    (
        PARTITION BY s.department
        ORDER BY e.marks_obtained DESC
    ) AS dense_rank_value

FROM Students s
JOIN Enrollments e
ON s.student_id = e.student_id;