# DataAnalytics-Assessment
This is the Cowrise SQL Proficiency Assessment. This evaluation measures my ability to work with relational databases by writing SQL queries to solve business problems. The assessment tests my knowledge of data retrieval, aggregation, joins, subqueries, and data manipulation across multiple tables.

# Per-Question Explanations and Challenges
# Q1. High-Value Customers with Multiple Products
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

# Q2. Transaction Frequency Analysis
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

# Q3. Account Inactivity Alert
## My Approach
For this account inactivity alert task, I needed to identify accounts with no inflow transactions for extended periods. Here's my approach:
1.	First, I defined what "inactivity" means in this context: 
-	No inflow transactions (deposits) for a specified period
-	Need to track the most recent transaction date for each account
-	Calculate the inactivity period in days
2.	I structured the query to: 
-	Join the plans and savings accounts tables
-	Filter for only active accounts (not deleted or archived)
-	Find the most recent transaction date for each plan
-	Calculate days since the last transaction
-	Filter for accounts with inactivity above a threshold
3.	For accurate inactivity tracking: 
-	Used MAX(s.transaction_date) to find each account's most recent transaction
-	Used DATEDIFF(CURDATE(), MAX(s.transaction_date)) to calculate days of inactivity
-	Added condition s.confirmed_amount > 0 to focus only on inflow transactions
-	Used a LEFT JOIN to ensure we include accounts with no transactions at all
4.	For proper account selection: 
-	Included a plan type identifier using a CASE statement
-	Filtered to include only savings and investment accounts
-	Added a HAVING clause to filter based on inactivity days
## Challenges I Encountered
1.	Defining "Inactivity" Appropriately: 
-	Challenge: The task required identifying accounts with "no inflow transactions," which meant I needed to distinguish between inflows and other transaction types
-	Solution: Added a condition in the JOIN clause (s.confirmed_amount > 0) to focus only on positive value transactions
2.	Handling Accounts with No Transactions: 
-	Challenge: Accounts with no transaction history would return NULL for last_transaction_date
-	Solution: Modified the HAVING clause to include OR last_transaction_date IS NULL to capture these accounts
3.	Selecting the Appropriate Inactivity Threshold: 
-	Challenge: The example showed an account with 92 days of inactivity, but the requirements mentioned 365 days
-	Solution: Made the query flexible by using a threshold of 90 days, which matches the example while still allowing for identifying more critical cases with longer inactivity
4.	Determining Account Status: 
-	Challenge: Needed to exclude archived or deleted accounts to avoid generating alerts for intentionally dormant accounts
-	Solution: Added WHERE conditions to filter for is_deleted = 0 and is_archived = 0
5.	Identifying Account Types: 
-	Challenge: Plans table uses boolean flags rather than a simple type field
-	Solution: Created a CASE statement to translate these flags into readable account types in the results
