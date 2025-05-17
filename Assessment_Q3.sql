/**
 * Account Inactivity Alert
 * Identifies accounts with no inflow transactions for extended periods
 * Shows plan details and days since last transaction
 */

-- Find active accounts with their last transaction date and inactivity period
SELECT 
    p.id AS plan_id,
    p.owner_id,
    -- Determine plan type
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_fixed_investment = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    -- Get the last transaction date
    MAX(DATE(s.transaction_date)) AS last_transaction_date,
    -- Calculate days of inactivity
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days
FROM 
    plans_plan p
    -- Left join to include all plans, even those with no recent transactions
    LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id AND s.confirmed_amount > 0  -- Only inflow transactions
WHERE 
    -- Only include active plans (not archived or deleted)
    p.is_deleted = 0
    AND p.is_archived = 0
    -- Look at either savings or investment plans
    AND (p.is_regular_savings = 1 OR p.is_fixed_investment = 1)
GROUP BY 
    p.id, p.owner_id, type
HAVING 
    -- Include plans with no recent activity
    (inactivity_days >= 90 OR last_transaction_date IS NULL)
ORDER BY 
    inactivity_days DESC;