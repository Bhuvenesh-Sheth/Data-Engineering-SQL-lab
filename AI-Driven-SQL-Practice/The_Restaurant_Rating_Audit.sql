/*
Business Context
A food delivery platform wants a simple health-check on restaurant quality. The operations team wants to flag restaurants whose average rating dropped below 3.5 in their most recent set of reviews, so they can be reviewed for removal from the app. This is a routine weekly report — nothing fancy, just clean aggregation.
Schema
restaurants
ColumnTypeDescriptionrestaurant_idINTUnique restaurant identifierrestaurant_nameVARCHARName of the restaurantcityVARCHARCity the restaurant operates in
reviews
ColumnTypeDescriptionreview_idINTUnique review identifierrestaurant_idINTReferences the restaurantratingINTRating from 1 to 5review_dateDATEDate the review was posted
Task
For each restaurant, calculate:

The total number of reviews
The average rating (rounded to 2 decimal places)

Then return only restaurants that have:

At least 10 reviews (so we don't flag restaurants with too little data)
An average rating below 3.5

Expected Output
restaurant_idrestaurant_namecitytotal_reviewsavg_rating...............
Order by avg_rating ascending (worst first).
Constraints / Hints

This only needs: JOIN, GROUP BY, HAVING, ROUND, AVG, COUNT
No window functions needed
No CTEs required (though you can use one if it helps you think)
Think about why HAVING is used instead of WHERE here
*/



SELECT
    rt.restaurant_id,
    rt.restaurant_name,
    rt.city,
    COUNT(re.review_id)        AS total_reviews,
    ROUND(AVG(re.rating), 2)   AS avg_rating
FROM restaurants rt
JOIN reviews re ON rt.restaurant_id = re.restaurant_id
GROUP BY rt.restaurant_id, rt.restaurant_name, rt.city
HAVING COUNT(re.review_id) >= 10
   AND AVG(re.rating) < 3.5
ORDER BY avg_rating ASC;
