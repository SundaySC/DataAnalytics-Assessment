/**
 * Customer Lifetime Value (CLV) Estimation
 * Calculates CLV based on account tenure and transaction volume
 * Formula: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
 * Assumes profit_per_transaction is 0.1% of transaction value
 * Note: Transaction amounts are in kobo (1/100 of the currency unit)
 */

-- Calculate CLV metrics for each customer
SELECT 
    u.id AS customer_id,
    -- Format name from first and last name
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Calculate tenure in months since signup
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    -- Count total number of transactions
    COUNT(s.id) AS total_transactions,
    -- Calculate estimated CLV and format to 2 decimal places
    FORMAT(
        -- Formula: (total_transactions / tenure) * 12 * avg_profit_per_transaction
        (COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * 
        -- Calculate average profit per transaction (0.1% of transaction value)
        -- Convert kobo to currency units by dividing by 100
        (SUM(s.confirmed_amount) / 100 * 0.001 / COUNT(s.id)),
        2
    ) AS estimated_clv
FROM 
    users_customuser u
    -- Join to get all successful transactions
    JOIN savings_savingsaccount s ON u.id = s.owner_id
WHERE 
    -- Only include successful transactions
    s.transaction_status = 'success'
    -- Only include positive transactions
    AND s.confirmed_amount > 0
    -- Ensure tenure is at least 1 month to avoid division by zero
    AND TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) >= 1
GROUP BY 
    u.id, 
    u.first_name, 
    u.last_name, 
    u.date_joined
-- Order by CLV from highest to lowest
ORDER BY 
    -- Remove formatting for correct numeric sorting
    (COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * 
    (SUM(s.confirmed_amount) / 100 * 0.001 / COUNT(s.id)) DESC;