# LibrarySync SQL Database Management System

**LibrarySync** is my SQL-powered library management system, designed to streamline the operations of a modern library. From managing books, members, and employees to generating insightful reports, this project showcases my skills in database design, CRUD operations, advanced querying, and automation through stored procedures. I built this system to feel dynamic and practical, like a real library bustling with activity. The database is structured for data integrity, and the queries provide actionable insights into library performance.

![Library Image](https://github.com/jimi121/DATABASE-MANAGEMENT-SYSTEM/blob/main/LibrarySync%20SQL%20Database%20Management%20System/Library%20Image.jpeg)

## Objectives

1. **Database Setup**: Create and populate a relational database to manage branches, employees, members, books, issued books, and returns.  
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations for efficient data management.  
3. **CTAS Queries**: Use Create Table As Select (CTAS) to generate summary tables for quick analysis.  
4. **Advanced Analysis**: Develop complex queries and stored procedures to automate tasks and uncover trends like overdue books and branch performance.

## Project Structure

### 1. Database Setup

The `library_sync_db` database comprises six core tables, designed with primary and foreign keys to ensure data integrity. The schema links books to issuance records, employees to branches, and members to issued books, capturing the essence of library operations. Below is the Entity-Relationship Diagram (ERD) and a sample of the schema:

![Library ERD](https://github.com/jimi121/DATABASE-MANAGEMENT-SYSTEM/blob/main/LibrarySync%20SQL%20Database%20Management%20System/ERR%20Diagram.png)

```sql
CREATE DATABASE library_sync_db;
CREATE SCHEMA "LibrarySync";

CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    positions VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- Additional tables: members, books, issued_status, return_status (see SQL SCHEMA.sql)
```

**Explanation**: The schema defines tables for branches, employees, members, books, issued books, and returns. Foreign keys ensure referential integrity, e.g., `issued_status` links to `members`, `employees`, and `books`. The `return_status` table was modified to include a `book_quality` column to track the condition of returned books.

### 2. CRUD Operations

This section covers the Create, Read, Update, and Delete operations to manage library data effectively.

#### Task 1: Create a New Book Record
**Objective**: Add *To Kill a Mockingbird* to the books table.  
**Code**:
```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES 
    ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Explanation**: This query inserts a new book record with details like ISBN, title, category, rental price, availability status, author, and publisher. The `SELECT` statement verifies the insertion by displaying all books.

#### Task 2: Update an Existing Member’s Address
**Objective**: Update the address of member `C101` (Alice Johnson).  
**Code**:
```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;
```
**Explanation**: The `UPDATE` statement changes the address for member `C101`, ensuring accurate member records. The `SELECT` statement confirms the update.

#### Task 3: Delete a Record from the Issued Status Table
**Objective**: Delete the issuance record with `issued_id = 'IS121'`.  
**Code**:
```sql
DELETE FROM issued_status 
WHERE issued_id = 'IS121';
SELECT * FROM issued_status;
```
**Explanation**: This query removes the specified issuance record to maintain data accuracy. The `SELECT` statement verifies the deletion.

#### Task 4: Retrieve All Books Issued by a Specific Employee
**Objective**: List all books issued by employee `E101`.  
**Code**:
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```
**Explanation**: This query retrieves all issuance records for employee `E101`, helping track their activity in the library system.

### 3. Data Analysis & Insights

This section includes queries to analyze library operations and uncover trends.

#### Task 1: List Members Who Have Issued More Than One Book
**Objective**: Identify members who have issued multiple books.  
**Code**:
```sql
SELECT
    member_name,
    COUNT(i.issued_id) AS no_of_book_issued
FROM issued_status i
JOIN members m 
ON i.issued_member_id = m.member_id
GROUP BY member_name
HAVING COUNT(i.issued_id) > 1
ORDER BY no_of_book_issued DESC;
```
**Explanation**: This query joins `issued_status` and `members` tables to count book issuances per member, filtering for those with more than one issuance. Results are sorted to highlight the most active members.

#### Task 2: Retrieve All Books in a Specific Category
**Objective**: List all books in the "Classic" category.  
**Code**:
```sql
SELECT * FROM books
WHERE category = 'Classic';
```
**Explanation**: This query filters the `books` table to display all books categorized as "Classic," aiding users in finding genre-specific titles.

#### Task 3: Find Total Rental Income by Category
**Objective**: Calculate the total rental income for each book category.  
**Code**:
```sql
SELECT 
    category,
    SUM(rental_price) AS total_rental_income
FROM books b
GROUP BY category
ORDER BY total_rental_income DESC;
```
**Explanation**: This query groups books by category and sums their rental prices to estimate potential rental income, sorted to highlight the most lucrative categories.

#### Task 4: List Members Who Registered in the Last Year
**Objective**: Identify members who joined in the last 12 months.  
**Code**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '1 year';
```
**Explanation**: This query filters the `members` table for those with a registration date within the last year, useful for targeting new members for engagement.

#### Task 5: List Employees with Their Branch Manager’s Name and Branch Details
**Objective**: Display employee details alongside their branch manager and branch information.  
**Code**:
```sql
SELECT
    e1.*,
    b.manager_id,
    e2.emp_name AS manager_name,
    b.branch_address,
    b.contact_no
FROM branch b
JOIN employees e1 
ON b.branch_id = e1.branch_id
JOIN employees e2 
ON b.manager_id = e2.emp_id;
```
**Explanation**: This query joins the `branch` and `employees` tables twice to link each employee with their branch and manager, providing a comprehensive view of the organizational structure.

#### Task 6: Retrieve the List of Books Not Yet Returned
**Objective**: Identify books that have not been returned.  
**Code**:
```sql
SELECT 
    DISTINCT issued_book_name,
    return_book_isbn
FROM issued_status i
LEFT JOIN return_status r
ON i.issued_id = r.issued_id
WHERE return_book_isbn IS NULL;
```
**Explanation**: This query uses a `LEFT JOIN` to find issuance records without corresponding return records, indicating books still on loan.

#### Task 7: Identify Members with Overdue Books
**Objective**: List members with books overdue by more than 30 days, including member name, book title, issue date, and days overdue.  
**Code**:
```sql
SELECT 
    member_name,
    i.issued_book_name,
    r.return_date,
    (CURRENT_DATE - i.issued_date) AS overdue_date
FROM members m 
JOIN issued_status i
ON m.member_id = i.issued_member_id
LEFT JOIN return_status r
ON r.issued_id = i.issued_id
WHERE (CURRENT_DATE - i.issued_date) >= 30
AND r.return_date IS NULL;
```
**Explanation**: This query joins `members`, `issued_status`, and `return_status` to identify books not returned within 30 days, calculating the overdue period and ensuring no return date exists.

#### Task 8: Find Employees with the Most Book Issues Processed
**Objective**: Identify the top 3 employees who processed the most book issues, including their name, branch, and issuance count.  
**Code**:
```sql
SELECT 
    *
FROM (
    SELECT 
        e.emp_name,
        b.*,
        COUNT(issued_id) AS no_book_issued,
        DENSE_RANK() OVER (ORDER BY COUNT(issued_id) DESC) AS rnk
    FROM employees e
    JOIN branch b
    ON e.branch_id = b.branch_id
    JOIN issued_status i
    ON e.emp_id = i.issued_emp_id
    GROUP BY 1, 2
    ORDER BY no_book_issued DESC) x 
WHERE x.rnk <= 3;
```
**Explanation**: This query uses a window function (`DENSE_RANK`) to rank employees by the number of books issued, joining `employees`, `branch`, and `issued_status` tables. It filters for the top 3 ranks.

#### Task 9: Identify Members Issuing High-Risk Books
**Objective**: Find members who returned books marked as "damaged" more than twice.  
**Code**:
```sql
SELECT 
    m.member_name,
    i.issued_book_name,
    COUNT(*) AS number_of_issued_books
FROM issued_status i
JOIN members m 
ON i.issued_member_id = m.member_id
JOIN return_status r
ON i.issued_id = r.issued_id 
WHERE LOWER(r.book_quality) = 'damaged'
GROUP BY 1, 2;
```
**Explanation**: This query joins `issued_status`, `members`, and `return_status` to count instances where books were returned damaged, grouping by member and book to identify high-risk borrowers.

### 4. CTAS (Create Table As Select)

This section covers tasks that use CTAS to create summary tables for efficient analysis.

#### Task 1: Create Summary Table for Book Issuance Counts
**Objective**: Create a table to track how often each book has been issued.  
**Code**:
```sql
CREATE TABLE book_cnts AS 
SELECT 
    issued_book_name,
    COUNT(issued_id) AS total_book_issued
FROM issued_status AS i
JOIN books b
ON i.issued_book_isbn = b.isbn
GROUP BY issued_book_name
ORDER BY total_book_issued DESC;
SELECT * FROM book_cnts;
```
**Explanation**: This CTAS query creates a table summarizing the number of times each book has been issued, joining `issued_status` and `books` to ensure accurate book titles.

#### Task 2: Create a Table of Books with Rental Price Above $7
**Objective**: Create a table of books with rental prices exceeding $7.  
**Code**:
```sql
CREATE TABLE books_price_greater_than_seven AS 
SELECT * FROM books
WHERE rental_price > 7;
SELECT * FROM books_price_greater_than_seven;
```
**Explanation**: This CTAS query creates a table of high-value books, filtering for those with rental prices above $7, useful for inventory analysis.

#### Task 3: Create a Table of Active Members
**Objective**: Create a table of members who issued at least one book in the last 13 months.  
**Code**:
```sql
CREATE TABLE active_members AS 
SELECT 
    DISTINCT m.member_id,
    m.member_name,
    m.member_address,
    m.reg_date
FROM issued_status i
JOIN members m 
ON i.issued_member_id = m.member_id
WHERE i.issued_date > CURRENT_DATE - INTERVAL '13 month';
SELECT * FROM active_members;
```
**Explanation**: This CTAS query creates a table of active members based on issuance activity within the last 13 months, using `DISTINCT` to avoid duplicates.

#### Task 4: Create a Table for Overdue Books and Fines
**Objective**: Create a table listing members with books overdue by more than 50 days, including fines at $0.50 per day.  
**Code**:
```sql
CREATE TABLE overdue_book AS
WITH book_return AS (
    SELECT 
        DISTINCT i.issued_member_id AS member_id,
        (r.return_date - i.issued_date) AS no_of_days,
        i.issued_book_name
    FROM issued_status i
    JOIN return_status r 
    ON i.issued_id = r.issued_id
)
SELECT 
    member_id,
    SUM(no_of_days * 0.50) AS total_fine,
    COUNT(issued_book_name) AS total_overdue_book
FROM book_return
WHERE no_of_days > 50
GROUP BY 1;
```
**Explanation**: This CTAS query uses a CTE to calculate the number of days between issuance and return, then creates a table summarizing fines and overdue book counts for loans exceeding 50 days.

### 5. Advanced SQL Features

This section covers stored procedures to automate key library operations.

#### Task 1: Update Book Status on Return
**Objective**: Create a procedure to update a book’s status to 'yes' when returned.  
**Code**:
```sql
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE 
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN 
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
    SELECT issued_book_isbn, issued_book_name INTO v_isbn, v_book_name
    FROM issued_status WHERE issued_id = p_issued_id;
    UPDATE books SET status = 'yes' WHERE isbn = v_isbn;
    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;
CALL add_return_records('RS138', 'IS135', 'Good');
```
**Explanation**: This procedure inserts a return record, retrieves the ISBN and book name from `issued_status`, updates the book’s status to 'yes' in the `books` table, and notifies the user of the successful return.

#### Task 2: Stored Procedure for Book Issuance
**Objective**: Create a procedure to issue a book, checking its availability first.  
**Code**:
```sql
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE 
    v_status VARCHAR(10);
BEGIN 
    SELECT status INTO v_status FROM books WHERE isbn = p_issued_book_isbn;
    IF v_status = 'yes' THEN 
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
        UPDATE books SET status = 'no' WHERE isbn = p_issued_book_isbn;
        RAISE NOTICE 'Book records added successfully for book isbn: %', p_issued_book_isbn;
    ELSE 
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$;
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
```
**Explanation**: This procedure checks if a book is available (`status = 'yes'`). If available, it inserts an issuance record and updates the book’s status to 'no'; otherwise, it notifies the user of unavailability.

### 6. Branch Performance Report

#### Task 1: Branch Performance Report
**Objective**: Generate a report showing the number of books issued, returned, and revenue generated per branch.  
**Code**:
```sql
CREATE TABLE branch_reports AS 
SELECT 
    b.branch_id,
    COUNT(i.issued_id) AS total_book_issued,
    COUNT(r.return_id) AS total_book_returned,
    SUM(b2.rental_price) AS revenue_generated
FROM branch b 
JOIN employees e ON b.branch_id = e.branch_id
LEFT JOIN issued_status i ON i.issued_emp_id = e.emp_id
LEFT JOIN return_status r ON r.issued_id = i.issued_id 
LEFT JOIN books b2 ON i.issued_book_isbn = b2.isbn
GROUP BY b.branch_id;
SELECT * FROM branch_reports;
```
**Explanation**: This CTAS query joins `branch`, `employees`, `issued_status`, `return_status`, and `books` to create a table summarizing each branch’s issuance count, return count, and total rental revenue.

## Reports & Insights

- **Schema Design**: The relational structure uses primary and foreign keys to ensure data consistency across tables.  
- **Key Findings**: Classics and History books generate significant rental income; some branches show higher issuance activity, indicating operational efficiency.  
- **Operational Insights**: Overdue books and damaged returns are flagged to maintain library standards and improve user accountability.

## How to Run This Project

1. **Clone the Repository**: Download the project files.
   ```sh
   git clone https://github.com/jimi121/LibrarySync-SQL-Project.git
   ```
2. **Set Up the Database**: Execute `SQL SCHEMA.sql` and `INSERT DATA.sql` to create and populate the database.
3. **Run Queries**: Use `SQL QUERY.sql` to perform the tasks and explore results.
4. **Customize**: Modify queries or add new ones to dive deeper into the data.

## About Me

I’m Olajimi Adeleke, a data enthusiast passionate about crafting efficient databases and uncovering insights through SQL. LibrarySync reflects my love for solving real-world problems with structured data. Building this system was a rewarding challenge, and I hope it inspires you to explore SQL’s potential!

## Follow me on:
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](www.linkedin.com/in/olajimi-adeleke)  
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/jimi121?tab=repositories)   
📧 Email me at: [adelekejimi@gmail.com](mailto:adelekejimi@gmail.com)

Thanks for exploring LibrarySync! I enjoyed building this system, and I’d love to hear your thoughts or suggestions for improvements. Let’s keep the data flowing! 🚀
