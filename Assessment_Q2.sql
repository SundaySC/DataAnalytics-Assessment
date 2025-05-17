/**
 * Transaction Frequency Analysis
 * Categorizes customers based on monthly transaction frequency and provides counts and averages
 * Categories: High Frequency (≥10 txns/month), Medium Frequency (3-9 txns/month), Low Frequency (≤2 txns/month)
 */

-- Calculate average transactions per customer per month and categorize them
WITH customer_transaction_stats AS (
    SELECT
        u.id AS customer_id,
        -- Count transactions for each customer
        COUNT(s.id) AS total_transactions,
        -- Calculate the number of distinct months the customer has been active
        COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')) AS active_months,
        -- Calculate average transactions per month
        COUNT(s.id) / COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')) AS avg_transactions_per_month
    FROM
        users_customuser u
        JOIN savings_savingsaccount s ON u.id = s.owner_id
    WHERE
        -- Only include successful transactions
        s.transaction_status = 'success'
        -- Only include positive transactions
        AND s.confirmed_amount > 0
        -- Only consider transactions in the last 12 months for a reasonable timeframe
        AND s.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY
        u.id
    HAVING
        -- Ensure we have enough data for meaningful averages (at least 1 month of activity)
        active_months > 0
)

-- Summarize by frequency category
SELECT
    CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month >= 3 AND avg_transactions_per_month < 10 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    -- Count of customers in each category
    COUNT(*) AS customer_count,
    -- Average transactions per month across customers in this category (rounded to 1 decimal place)
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM
    customer_transaction_stats
GROUP BY
    CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month >= 3 AND avg_transactions_per_month < 10 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END
ORDER BY
    -- Sort by frequency category (high to low)
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
