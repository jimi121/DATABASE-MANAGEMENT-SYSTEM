-- Project Task

-- Task 1. Create a New Book Record -- "('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES 
	('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status 
WHERE issued_id = 'IS121';
SELECT * FROM issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: find members who have issued more than one book.
SELECT
	member_name,
	count(i.issued_id ) AS No_of_book_issued
FROM issued_status i
JOIN members m 
ON i.issued_member_id = m.member_id
GROUP BY member_name
HAVING count(i.issued_id) > 1
ORDER BY No_of_book_issued DESC;


-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_cnts AS 
SELECT 
	issued_book_name,
	count(issued_id) AS total_book_issused
FROM issued_status AS i
JOIN books b
ON i.issued_book_isbn = b.isbn
GROUP BY issued_book_name
ORDER BY total_book_issused DESC;

SELECT * FROM book_cnts

-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:
SELECT 
	category,
	sum(rental_price) AS total_rental_income
FROM books b
GROUP BY category
ORDER BY total_rental_income DESC;

--Task 9: List Members Who Registered in the Last 1 year:
SELECT * FROM members
WHERE reg_date >= current_date - INTERVAL '1 year';

-- task 10 List Employees with Their Branch Manager's Name and their branch details:
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

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
CREATE TABLE books_price_greater_than_seven AS 
SELECT * FROM books
WHERE rental_price > 7;

SELECT * FROM 
books_price_greater_than_seven;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
	DISTINCT issued_book_name,
	return_book_isbn
FROM issued_status i
LEFT JOIN return_status r
ON i.issued_id = r.issued_id
WHERE return_book_isbn IS NULL;

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
SELECT 
	member_name,
	i.issued_book_name,
	r.return_date,
	(current_date - i.issued_date) AS overdue_date
FROM members m 
JOIN issued_status i
ON m.member_id = i.issued_member_id
LEFT JOIN return_status r
ON r.issued_id = i.issued_id
WHERE (current_date - i.issued_date) >= 30
AND r.return_date IS NULL;

/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned 
(based on entries in the return_status table).
*/
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(10), p_issued_id varchar(10), p_book_quality varchar(10))
LANGUAGE plpgsql
AS $$
DECLARE 
	v_isbn varchar(50);
	v_book_name varchar(80);
BEGIN 
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES 
		(p_return_id, p_issued_id, current_date, p_book_quality);

	SELECT 
		issued_book_isbn,
		issued_book_name
	INTO 
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;
	
	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

CREATE TABLE branch_reports AS 
SELECT 
	b.branch_id,
	count(i.issued_id) AS total_book_issued,
	count(r.return_id) AS total_book_returned,
	sum(b2.rental_price) AS Revenue_generated
FROM branch b 
JOIN employees e 
ON b.branch_id = e.branch_id
LEFT JOIN issued_status i
ON i.issued_emp_id = e.emp_id
LEFT JOIN return_status r
ON r.issued_id = i.issued_id 
LEFT JOIN books b2
ON i.issued_book_isbn  = b2.isbn
GROUP BY b.branch_id;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued 
-- at least one book in the last 13 months.

CREATE TABLE active_members AS 
SELECT 
	DISTINCT m.member_id,
	m.member_name,
	m.member_address,
	m.reg_date
FROM issued_status i
JOIN members m 
ON i.issued_member_id = m.member_id
WHERE i.issued_date > current_date - INTERVAL '13 month';

SELECT * FROM active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, 
-- number of books processed, and their branch.

SELECT 
	*
FROM (
	SELECT 
		e.emp_name,
		b.*,
		COUNT(issued_id) AS no_book_issued,
		dense_rank() OVER (ORDER BY COUNT(issued_id) DESC) AS rnk
	FROM employees e
	JOIN branch b
	ON e.branch_id  = b.branch_id
	JOIN issued_status i
	ON e.emp_id = i.issued_emp_id
	GROUP BY 1, 2
	ORDER BY no_book_issued DESC) x 
WHERE x.rnk <= 3

/* Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books. */

SELECT 
	m.member_name,
	i.issued_book_name,
	count(*) AS number_of_issued_books
FROM issued_status i
JOIN members m 
ON i.issued_member_id = m.member_id
JOIN return_status r
ON i.issued_id = r.issued_id 
WHERE LOWER(r.book_quality) = 'damaged'
GROUP BY 1,2;


/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id varchar(10), p_issued_member_id varchar(10), p_issued_book_isbn varchar(30), p_issued_emp_id varchar(10))
LANGUAGE plpgsql
AS $$
DECLARE 
	v_status varchar(10);
BEGIN 
	SELECT 
		status 
	INTO 
		v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN 
		INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES 
			(p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id);
		
		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;
		
		RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;
	
	ELSE 
		RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
	
	END IF;
	
END;
$$

/* Task 20: Create Table As Select (CTAS) 
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued 
but not returned within 50 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines */

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
	sum(no_of_days * 0.50) AS total_fine,
	count(issued_book_name) AS total_overdue_book
FROM book_return
WHERE no_of_days > 50
GROUP BY 1;












