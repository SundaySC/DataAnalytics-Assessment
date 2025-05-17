# DataAnalytics-Assessment
This is the Cowrise SQL Proficiency Assessment. This evaluation measures my ability to work with relational databases by writing SQL queries to solve business problems. The assessment tests my knowledge of data retrieval, aggregation, joins, subqueries, and data manipulation across multiple tables.
## Per-Question Explanations and Challenges
# Q1.High-Value Customers with Multiple Products
## My Approach
When tackling this problem, I first needed to understand what defines a "high-value customer" with multiple products. The key requirements were:
1.	Customers must have at least one funded savings plan AND one funded investment plan
2.	Results should be sorted by total deposits to identify the highest-value customers
I built the query by:
1.	Identifying the relevant fields across tables:
-	Using is_regular_savings and is_fixed_investment flags to distinguish plan types
-	Joining plans to customers via owner_id
-	Using savings_savingsaccount to track confirmed deposits
2.	Setting up conditional counting to track different plan types:
-	COUNT(DISTINCT CASE WHEN... to count the unique plans by type
-	This ensured I wasn't double-counting plans or transactions
3.	Formatting the output according to specifications:
-	Combined first_name and last_name fields from users_customuser
-	Used FORMAT function to show 2 decimal places on monetary values
## Challenges I Encountered
1.	Understanding the Database Schema:
-	The multi-table structure required careful analysis to determine how plans related to accounts
-	I needed to understand which fields indicated savings vs. investment plans
-	Solution: Used the is_regular_savings and is_fixed_investment flags to categorize plans
2.	Handling Name Concatenation:
-	Initially used the name field but it displayed null values, but had to switch to combining first_name and last_name
-	This required updating both the SELECT clause AND the GROUP BY clause
-	Solution: Used CONCAT function to properly combine the name fields with appropriate spacing
3.	Ensuring Data Quality:
-	Needed to filter out deleted/archived plans and unsuccessful transactions
-	Added conditions for is_deleted = 0, is_archived = 0, and transaction_status = 'success'
-	Ensured positive deposits with confirmed_amount > 0
4.	Optimizing the Query:
-	The initial query had more columns than needed, which I trimmed to match requirements
-	Focused on retrieving only the essential information while still maintaining the business value
By applying these approaches, I created a solution that directly addresses the business need to identify cross-selling opportunities with high-value customers who trust the institution with multiple types of financial products.
