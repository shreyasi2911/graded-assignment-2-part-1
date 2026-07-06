# Student Records Database Normalization and SQL Queries

## Project Overview

This project demonstrates the process of transforming a spreadsheet-based student records system into a well-designed relational database that satisfies Boyce-Codd Normal Form (BCNF). The project also includes SQL scripts for schema creation, data manipulation, advanced querying, and transaction management.

The original dataset stores all information in a single table:

```
StudentRecords(
    student_id,
    student_name,
    department,
    advisor_name,
    advisor_email,
    course_code,
    course_name,
    instructor_name,
    instructor_email,
    enrollment_year,
    marks_obtained
)
```

The existing design suffers from update, insertion, and deletion anomalies because multiple entities are stored together in a single relation.

---

# Task 1.1 – Normalization

## Candidate Key

The given composite key is:

```
(student_id, course_code)
```

A student can enroll in multiple courses, and each course can have multiple students.

---

## Functional Dependencies

The following functional dependencies are provided:

```
student_id → student_name, department, advisor_name

advisor_name → advisor_email

course_code → course_name, instructor_name, instructor_email

instructor_name → instructor_email

(student_id, course_code) → enrollment_year, marks_obtained
```

---

## Partial Dependencies

A partial dependency occurs when a non-key attribute depends on only part of the composite primary key.

### 1.

```
student_id → student_name
```

Reason:

Student name depends only on the student ID and not on the entire composite key.

---

### 2.

```
student_id → department
```

Reason:

A student's department is determined by the student, regardless of the course.

---

### 3.

```
student_id → advisor_name
```

Reason:

Each student has one advisor.

---

### 4.

```
course_code → course_name
```

Reason:

Course name depends only on course code.

---

### 5.

```
course_code → instructor_name
```

Reason:

Each course has one instructor.

---

### 6.

```
course_code → instructor_email
```

Reason:

Instructor information depends on the course alone.

---

## Transitive Dependencies

A transitive dependency exists when a non-key attribute depends on another non-key attribute.

### 1.

```
student_id
        ↓
advisor_name
        ↓
advisor_email
```

Therefore,

```
student_id → advisor_email
```

is transitive.

---

### 2.

```
course_code
        ↓
instructor_name
        ↓
instructor_email
```

Therefore,

```
course_code → instructor_email
```

is also transitive.

---

## Problems in the Original Table

### Update Anomaly

Updating an advisor's email requires modifying multiple rows because every student advised by that advisor stores the same email.

Example:

```
Advisor A changes email.
```

Every row containing Advisor A must be updated.

---

### Insertion Anomaly

A new course cannot be inserted unless at least one student is enrolled.

Example:

```
CS404
```

cannot exist without a student record.

---

### Deletion Anomaly

Deleting the final student enrolled in a course removes all information about that course and its instructor.

---

# BCNF Decomposition

The relation is decomposed into the following tables.

---

## Students

Stores student information.

```
Students
---------
student_id (PK)
student_name
department
advisor_name (FK)
```

Primary Key

```
student_id
```

Foreign Key

```
advisor_name → Advisors(advisor_name)
```

Resolves

- Student redundancy
- Update anomaly

---

## Advisors

Stores advisor information.

```
Advisors
---------
advisor_name (PK)
advisor_email
```

Primary Key

```
advisor_name
```

Resolves

- Advisor email duplication
- Update anomaly

---

## Instructors

Stores instructor information.

```
Instructors
------------
instructor_name (PK)
instructor_email
```

Primary Key

```
instructor_name
```

Resolves

- Instructor email duplication

---

## Courses

Stores course information.

```
Courses
---------
course_code (PK)
course_name
instructor_name (FK)
```

Primary Key

```
course_code
```

Foreign Key

```
instructor_name → Instructors(instructor_name)
```

Resolves

- Course redundancy
- Instructor redundancy

---

## Enrollments

Stores student enrollments.

```
Enrollments
------------
student_id (FK)
course_code (FK)
enrollment_year
marks_obtained
```

Primary Key

```
(student_id, course_code)
```

Foreign Keys

```
student_id → Students(student_id)

course_code → Courses(course_code)
```

Resolves

- Enrollment redundancy
- Deletion anomaly
- Insertion anomaly

---

# BCNF Verification

### Students

```
student_id → student_name, department, advisor_name
```

The determinant is a candidate key.

BCNF satisfied.

---

### Advisors

```
advisor_name → advisor_email
```

Determinant is the primary key.

BCNF satisfied.

---

### Instructors

```
instructor_name → instructor_email
```

Determinant is the primary key.

BCNF satisfied.

---

### Courses

```
course_code → course_name, instructor_name
```

Determinant is the primary key.

BCNF satisfied.

---

### Enrollments

```
(student_id, course_code)
→
enrollment_year, marks_obtained
```

Determinant is the composite primary key.

BCNF satisfied.

---

# Integrity Constraints

## 1. Entity Integrity

**Satisfied**

Every table has a primary key.

Examples

```
Students.student_id

Courses.course_code

Advisors.advisor_name

Instructors.instructor_name

(student_id, course_code)
```

No primary key value can be NULL.

---

## 2. Referential Integrity

**Satisfied**

Foreign keys enforce valid references.

Examples

```
Students.advisor_name
        references
Advisors.advisor_name
```

```
Courses.instructor_name
        references
Instructors.instructor_name
```

```
Enrollments.student_id
        references
Students.student_id
```

```
Enrollments.course_code
        references
Courses.course_code
```

This prevents orphan records.

---

## 3. Domain Integrity

**Satisfied**

Appropriate data types and constraints are used.

Examples

```
student_id INT

course_code VARCHAR(10)

marks_obtained DECIMAL(5,2)

advisor_email VARCHAR(100)
```

Marks should be between 0 and 100 using a CHECK constraint.

---

## 4. User-Defined Integrity

**Satisfied**

Business rules include:

- Every student must have a valid advisor.
- Every course must have a valid instructor.
- Marks cannot be negative.
- Enrollment year has a default value.
- Duplicate enrollments are not allowed because of the composite primary key.

---

# Design Decisions

The database was decomposed into BCNF to eliminate redundancy and remove update, insertion, and deletion anomalies.

The normalization separates independent entities such as Students, Advisors, Courses, Instructors, and Enrollments into individual relations while maintaining relationships using foreign keys.

The design improves data consistency, minimizes duplication, and simplifies maintenance.

---

# Transaction and Isolation Analysis (Task 1.5)

## Task 1.5(a)

A transaction transfers a student from one course to another by deleting the old enrollment and inserting the new enrollment.

The transaction uses:

- BEGIN
- COMMIT
- ROLLBACK

If the insertion fails, the transaction rolls back so that the student remains enrolled in the original course.

---

## Task 1.5(b)

Scenario:

One transaction reads a student's marks.

Another transaction updates the marks and commits.

The first transaction reads the marks again and gets a different value.

### Concurrency Anomaly

**Non-Repeatable Read**

### Minimum Isolation Level

```
REPEATABLE READ
```

This guarantees that repeated reads within the same transaction return the same value.

---

## Task 1.5(c)

Scenario:

Two transactions simultaneously observe that a course has available seats and both insert a new enrollment.

### Concurrency Anomaly

**Write Skew / Lost Capacity Check**

### Minimum Isolation Level

```
SERIALIZABLE
```

Serializable execution prevents concurrent transactions from violating capacity constraints.

---

## Task 1.5(d)

The database uses Multi-Version Concurrency Control (MVCC).

A reporting transaction begins and reads a student's marks.

Another transaction updates the marks and commits.

If the reporting transaction reads the row again, it still sees the original value because MVCC provides a consistent snapshot of the database taken when the transaction started.

### Isolation Level

```
REPEATABLE READ
```

(or SERIALIZABLE depending on the database system)

### Trade-off

Advantages

- Consistent reports
- No non-repeatable reads
- Stable query results

Disadvantages

- Higher storage usage for row versions.
- Long-running transactions delay cleanup of old row versions.
- Slightly lower concurrency compared to READ COMMITTED.

---

# Files Included

```
README.md
schema.sql
queries.sql
```

- **README.md** – Normalization analysis, BCNF decomposition, integrity constraints, and transaction discussion.
- **schema.sql** – SQL schema with tables, primary keys, foreign keys, constraints, and default values.
- **queries.sql** – Data manipulation, advanced SQL queries, correlated subqueries, window functions, and transaction examples.
