# DataAnalytics-Assessment
This is the Cowrise SQL Proficiency Assessment. This evaluation measures my ability to work with relational databases by writing SQL queries to solve business problems. The assessment tests my knowledge of data retrieval, aggregation, joins, subqueries, and data manipulation across multiple tables.

# Per-Question Explanations and Challenges
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
By applying these approaches, I created a solution that directly addresses the business need to identify cross-selling opportunities with high-value customers who trust the institution 

# Q2.Transaction Frequency Analysis - Approach and Challenges
## My Approach
For this transaction frequency analysis task, I needed to categorize customers based on their monthly transaction patterns. Here's how I approached it:
1.	First, I identified the core requirements:
-	Calculate average transactions per customer per month
-	Segment customers into three frequency categories (High: ≥10, Medium: 3-9, Low: ≤2)
-	Produce a summary showing customer count and average transactions per category
2.	I structured the query in two logical parts:
-	A CTE (Common Table Expression) to calculate individual customer metrics
-	A main query to categorize and aggregate results
3.	For monthly transaction calculation:
-	Used COUNT(s.id) to get total transactions per customer
-	Used COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')) to count active months
-	Divided these values to get the average transactions per month
4.	For category assignment:
-	Applied the CASE statement twice - once in the main query and once in the ORDER BY clause
-	This allowed me to both categorize customers and sort results appropriately
5.	For aggregation:
-	Grouped by frequency category
-	Used COUNT(*) for customer counts
-	Used ROUND(AVG(...), 1) to match the expected single decimal place format
## Challenges I Encountered
1.	Handling Inactive Months:
-	Challenge: If I simply divided by total months in the system, it would understate activity for customers who weren't active every month
-	Solution: Counted only distinct months where transactions actually occurred using DATE_FORMAT to create month identifiers
2.	Ensuring Data Quality:
-	Challenge: Raw transaction data might include failed transactions, refunds, or test data
-	Solution: Added filters for successful transactions and positive amounts to ensure reliable frequency metrics
3.	Handling Edge Cases:
-	Challenge: Customers with very short history might have skewed averages
-	Solution: Added a HAVING clause to ensure we only included customers with at least one month of activity
4.	Category Order in Results:
-	Challenge: SQL would naturally order alphabetically, placing "High" between "Low" and "Medium"
-	Solution: Created a custom sort using a CASE statement in the ORDER BY clause to ensure High → Medium → Low ordering
5.	Time Period Consideration:
-	Challenge: Using all historical data could skew results with inactive customers
-	Solution: Added a 12-month lookback window to focus on recent activity patterns
This approach allowed me to create a clean segmentation that accurately reflects customer transaction behavior in a format that's immediately useful for business analysis and strategic planning.
