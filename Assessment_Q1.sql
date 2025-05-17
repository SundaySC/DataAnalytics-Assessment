/**
 * Query to identify customers with both savings and investment plans
 * Matches specified output format with owner_id, name, savings_count, investment_count, and total_deposits
 * Name is combined from first_name and last_name fields
 */

-- Find customers with at least one funded savings plan AND one funded investment plan
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Count distinct plans by type
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_fixed_investment = 1 THEN p.id END) AS investment_count,
    -- Calculate total deposits and convert to naira
    FORMAT(SUM(s.confirmed_amount)/100, 2) AS total_deposits
FROM 
    users_customuser u
    -- Join to plans owned by the user
    INNER JOIN plans_plan p ON u.id = p.owner_id 
    -- Join to savings accounts to get deposit amounts
    INNER JOIN savings_savingsaccount s ON p.id = s.plan_id
WHERE 
    -- Only include active plans
    p.is_deleted = 0 
    AND p.is_archived = 0
    -- Only include confirmed transactions
    AND s.transaction_status = 'success'
    -- Only include positive deposits
    AND s.confirmed_amount > 0
GROUP BY 
    u.id, u.first_name, u.last_name
-- Use HAVING to filter for customers with both types of plans
HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) > 0
    AND 
    COUNT(DISTINCT CASE WHEN p.is_fixed_investment = 1 THEN p.id END) > 0
-- Sort by total deposits descending to find highest value customers first
ORDER BY 
    SUM(s.confirmed_amount) DESC;