


-- Step 1: Customers active in the window 15→3 months ago with 5+ orders
WITH active_window AS (
    SELECT
        customer_id,
        COUNT(order_id) AS orders_in_window
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '15 months'
      AND order_date <  CURRENT_DATE - INTERVAL '3 months'
    GROUP BY customer_id
    HAVING COUNT(order_id) >= 5
),

-- Step 2: Customers who DID order in the last 3 months (to EXCLUDE them)
recent_orders AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '3 months'
),

-- Step 3: Lifetime stats for all customers
lifetime_stats AS (
    SELECT
        customer_id,
        COUNT(order_id)      AS total_orders,
        SUM(order_total)     AS lifetime_spend,
        MAX(order_date)      AS last_order_date
    FROM orders
    GROUP BY customer_id
    HAVING SUM(order_total) >= 500
)

-- Step 4: Combine all conditions
SELECT
    c.customer_id,
    c.customer_name,
    ls.total_orders,
    ls.lifetime_spend,
    ls.last_order_date
FROM customers c
JOIN active_window  aw ON c.customer_id = aw.customer_id
JOIN lifetime_stats ls ON c.customer_id = ls.customer_id
LEFT JOIN recent_orders ro ON c.customer_id = ro.customer_id
WHERE ro.customer_id IS NULL          -- zero orders in last 3 months
ORDER BY ls.lifetime_spend DESC;