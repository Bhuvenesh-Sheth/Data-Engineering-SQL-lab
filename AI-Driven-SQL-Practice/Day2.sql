
/*
## Day 3: "The Product Cannibalization Check"

### Business Context
An e-commerce company recently launched a **new premium version** of an existing product. The growth team suspects the new product is **cannibalizing sales** of the original rather than bringing in new customers. They want to see, for each month since the new product launched, how many customers bought **only the old product**, **only the new product**, or **both**. This will help decide whether to discontinue the old product or reposition it.

### Schema

**`orders`**
| Column | Type | Description |
|---|---|---|
| order_id | INT | Unique order identifier |
| customer_id | INT | References the customer |
| order_date | DATE | Date the order was placed |

**`order_items`**
| Column | Type | Description |
|---|---|---|
| order_item_id | INT | Unique line item identifier |
| order_id | INT | References the order |
| product_id | INT | References the product |
| quantity | INT | Quantity purchased |

**`products`**
| Column | Type | Description |
|---|---|---|
| product_id | INT | Unique product identifier |
| product_name | VARCHAR | Name of the product |
| category | VARCHAR | Product category |
| launch_date | DATE | Date the product was launched |

### Task
Assume:
- **Old product:** `product_id = 101`
- **New product:** `product_id = 202` (launched `2024-03-01`)

For **each month from March 2024 onwards**, compute how many **distinct customers** fall into each of these three segments:
1. Bought **only product 101**
2. Bought **only product 202**
3. Bought **both products**

### Expected Output

| month | only_old_product | only_new_product | both_products |
|---|---|---|---|
| 2024-03 | ... | ... | ... |
| 2024-04 | ... | ... | ... |

Order by `month` ascending.

### Constraints / Hints
- Use `TO_CHAR(order_date, 'YYYY-MM')` to extract the month
- A customer counts for a month if they placed **any order containing that product** in that month
- Think about **conditional aggregation** — this is the cleanest approach
- Handle the case where a segment may have **zero customers** in a given month gracefully
- PostgreSQL dialect

*/

WITH customer_monthly_purchases AS (
    SELECT
        o.customer_id,
        TO_CHAR(o.order_date, 'YYYY-MM') AS month,
        MAX(CASE WHEN oi.product_id = 101 THEN 1 ELSE 0 END) AS bought_old,
        MAX(CASE WHEN oi.product_id = 202 THEN 1 ELSE 0 END) AS bought_new
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE oi.product_id IN (101, 202)
      AND o.order_date >= '2024-03-01'
    GROUP BY o.customer_id, TO_CHAR(o.order_date, 'YYYY-MM')
)

SELECT
    month,
    COUNT(*) FILTER (WHERE bought_old = 1 AND bought_new = 0) AS only_old_product,
    COUNT(*) FILTER (WHERE bought_old = 0 AND bought_new = 1) AS only_new_product,
    COUNT(*) FILTER (WHERE bought_old = 1 AND bought_new = 1) AS both_products
FROM customer_monthly_purchases
GROUP BY month
ORDER BY month ASC;
 