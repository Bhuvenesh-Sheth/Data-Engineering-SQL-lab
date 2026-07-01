/*
Business Context
A logistics company operates deliveries across multiple cities. The operations manager wants a monthly performance report to track how well deliveries are meeting their promised delivery dates. Late deliveries hurt customer satisfaction scores and trigger penalty clauses with enterprise clients. This report will be reviewed every Monday morning by the leadership team.
Schema
deliveries
ColumnTypeDescriptiondelivery_idINTUnique delivery identifierdriver_idINTReferences the drivercityVARCHARCity where delivery was madescheduled_dateDATEPromised delivery dateactual_dateDATEActual delivery datedelivery_statusVARCHAR'completed', 'cancelled', 'pending'
drivers
ColumnTypeDescriptiondriver_idINTUnique driver identifierdriver_nameVARCHARFull name of the drivercityVARCHARCity the driver is based in
Task
For each city and month, calculate:

Total deliveries (only completed ones)
On-time deliveries (completed and actual_date <= scheduled_date)
Late deliveries (completed and actual_date > scheduled_date)
On-time delivery rate — as a percentage, rounded to 1 decimal place

Return only city-months that had at least 5 completed deliveries.
Expected Output
citymonthtotal_deliverieson_timelateon_time_rate..................
Order by month ascending, then on_time_rate ascending (worst performers first within each month).
Constraints / Hints

Use TO_CHAR(actual_date, 'YYYY-MM') for the month
Use conditional aggregation for on_time and late counts — the same pattern from Day 3 (COUNT(*) FILTER (WHERE ...) or SUM(CASE WHEN ...))
No joins are strictly necessary — think about whether you actually need the drivers table for this task
Handle the percentage calculation carefully — think about integer division
*/

SELECT
    city,
    TO_CHAR(actual_date, 'YYYY-MM')                    AS month,
    COUNT(*) FILTER (
        WHERE delivery_status = 'completed'
    )                                                   AS total_deliveries,
    COUNT(*) FILTER (
        WHERE delivery_status = 'completed'
        AND actual_date <= scheduled_date
    )                                                   AS on_time,
    COUNT(*) FILTER (
        WHERE delivery_status = 'completed'
        AND actual_date > scheduled_date
    )                                                   AS late,
    ROUND(
        COUNT(*) FILTER (
            WHERE delivery_status = 'completed'
            AND actual_date <= scheduled_date
        ) * 100.0
        / NULLIF(COUNT(*) FILTER (
            WHERE delivery_status = 'completed'
        ), 0)
    , 1)                                                AS on_time_rate
FROM deliveries
GROUP BY city, TO_CHAR(actual_date, 'YYYY-MM')
HAVING COUNT(*) FILTER (
    WHERE delivery_status = 'completed'
) >= 5
ORDER BY month ASC, on_time_rate ASC;
