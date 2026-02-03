----Q1--Which cities have received the most reviews across all stores?
Select s.city,
	count(r.reviewer_id) as total_reviews
	from store s
	join reviews r
	on s.store_id= r.store_id
	group by s.city
	order by total_reviews desc;

----Q2---Average ratings per type of store-----
Select s.restaurant_type,
	Round(AVG(overall_ratings),2) average_ratings
	From store s
	join reviews r
	on s.store_id= r.store_id
	Group by s.restaurant_type
	order by average_ratings desc;

----Q3---Most active reviewers--Identify the top 10 reviewers who submitted the most reviews.---- Our active reviewers
Select reviewer_id,
	count(*) as each_user_review
	from reviews
	group by  reviewer_id
	order by each_user_review desc
	Limit 10;

---Q4---Which reviews received the most likes?------
Select reviewer_id ,
	review_like_count as total_like
	from reviews 
	order by total_like desc;

---Q5----Find stores with average overall_ratings less than 3.----- which restaurant needs to be replace ?--
Select s.store_id,
		s.store_name,
		Round(AVG(r.overall_ratings),2) as average_ratings
		from store s
		join reviews r
		on s.store_id= r.store_id
		Group by s.store_id, s.store_name
		
		Having AVG(r.overall_ratings) < 3
		order by average_ratings desc;

---Q6----How many reviews are submitted each month?----- which month we got the most reviews ?
	Select 
			Extract (month from review_date) as month,
			To_char(review_date,'Month') as month_name,
			Count(*) as review_count
			from reviews
			group by Extract (month from review_date), To_char(review_date,'Month') 
			order by review_count desc;

-----Q7---Do reviews submitted in the morning have higher ratings than evening?
with time_table as ( 
Select
	reviewer_id,
	overall_ratings,
	Case
		when review_time between '04:00:00' AND '10:59:59' Then 'Morning'
		when review_time between '11:00:00' AND '17:59:59' Then 'Afternoon'
		when review_time between '18:00:00' AND '23:59:59' Then 'Evening'
		else 'Night'
		end as time_period
		from reviews
)
	Select 
	time_period, 
	Round(AVG(overall_ratings),2) as average_ratings,
	Count(*) as total_reviews
	From time_table
	group by time_period
	order by average_ratings desc;

--Q8----Which reviewer reviewed the most number of different stores?
Select reviewer_id,
	Count(Distinct store_id) as total_stores
	from reviews
	group by reviewer_id 
		order by total_stores desc;

---Q9--Identify stores with high ratings but low total reviews (potential hidden gems) ---- which resturants are performing well?
	Select 
		s.store_id,
			s. store_name,
			s.city,
			Round(AVG(r.overall_ratings),2) as overall_ratings,
			Count(*) as total_reviews
From store s
	join reviews r
		on s.store_id= r.store_id
		Group by s.store_id, s.store_name, s.city
		Having AVG(r.overall_ratings) >= 4.50 And Count(*) < 20
		Order by overall_ratings desc, total_reviews asc;

---10--Show how many reviews exist for each rating (1–5).
Select 
	overall_ratings,
	count(*) as ratings_by_review
	from reviews 
	group by overall_ratings
	order by ratings_by_review desc;
	
---- Q11---Which stores have high food ratings but low rider ratings?
Select s.store_id,
		s.store_name,
		Round(AVG(r.food_ratings),2) as average_food_ratings,
		Round(AVG(r.rider_ratings),2) as average_rider_ratings,
		Round(AVG(r.food_ratings),2)- Round(AVG(r.rider_ratings),2) as gaf_between
		From store s
 join reviews r
		on s.store_id= r.store_id
		Group by s.store_id, s.store_name
		Having AVG(r.food_ratings) >=4.50 And AVG(r.rider_ratings) <=3
		Order by average_food_ratings desc, average_rider_ratings asc;

----Q12---Are the most reviewed stores also the highest rated?
		Select s.store_id,
			s.store_name,
				Count(r.reviewer_id) as total_reviews,
				Round(Avg(overall_ratings),2) as avg_ratings,
				Rank () over (order by Count(r.reviewer_id)desc) as review_rank,
				Rank () over (Order by Avg(overall_ratings)desc) as ratings_rank
				from store s 
				Join reviews r
				on s.store_id = r.store_id
				Group by s.store_id, s.store_name
				Order by total_reviews desc, avg_ratings desc;
				
----Q13----Reviewer credibility analysis----Do reviewers who review frequently give lower or higher ratings on average?
Select reviewer_id,
	Count(user_id) as total_review,
	Round(AVG(overall_ratings),2) as average_ratings
	from reviews
	Group by reviewer_id
	Order by total_review desc, average_ratings desc
	Limit 20;
	
----Q14---Are ratings lower during peak hours compared to non-peak hours?
	with time_table as (
	Select 
	overall_ratings,
	Case
		when review_time between '04:00:00' AND '10:59:59' Then 'Morning'
		when review_time between '11:00:00' AND '17:59:59' Then 'Afternoon'
		when review_time between '18:00:00' AND '23:59:59' Then 'Evening'
		else 'Night'
		end as time_period
		from reviews
	)
	Select 
		time_period,
		Count(*) as total_orders,
		Round(Avg(overall_ratings),2) as avg_ratings
		from time_table
		Group by time_period 
		Order by total_orders desc, avg_ratings desc;

---Q15---Which stores have the most stable ratings over time?
Select 
	s.store_name,
		Extract(Year from r.review_date) as review_year,
		Extract(Month from r.review_date) as review_month,
		Round(Avg(r.overall_ratings),2) stable_ratings
		From store s
		join reviews r
		on s.store_id = r.store_id
		Group by s.store_name, Extract(Year from r.review_date),Extract(Month from r.review_date)
		Order by stable_ratings desc;
		
Select 
s.store_name,
Round(Avg(r.overall_ratings),2) stable_ratings,
Round(STDDEV(r.overall_ratings),2) as ratings_stability
From store s 
	join reviews r
	on s.store_id = r.store_id
	Group by s.store_name
	order by ratings_stability asc;
	
--or even using subquerry 
Select store_name,
	Round(STDDEV(monthly_average),2) as stability_score
	From(
		Select 
		s.store_name,
		Round(Avg(r.overall_ratings),2) as monthly_average
		From store s 
		join reviews r 
		on s.store_id = r.store_id
		Group by s.store_name, Extract(Year from r.review_date),Extract(Month from r.review_date)
	) subquerry
			group by store_name
			order by stability_score asc;

-----Q16----Which stores get many likes on reviews but low ratings?
Select s.store_id,
	s.store_name,
	Sum(r.review_like_count) as total_likes,
	Round(Avg(r.overall_ratings),2) as avg_ratings,
	Rank () over (order by Sum(r.review_like_count)desc) as rank_
	From store s 
		join reviews r 
		on s.store_id = r.store_id
		Group by s.store_id, s.store_name
		Having Avg(r.overall_ratings) < 2
		Order by avg_ratings asc;
		
----Q17--Identify reviewers who post many reviews in a very short time span.
Select 
	reviewer_id,
	review_date,
	count(*) as total_review,
Lag (review_date) over (partition by reviewer_id order by review_date) as previous_review
	from reviews 
	group by reviewer_id, review_date
	having  count(*) > 2
	order by reviewer_id, review_date;

--or even with that---
Select 
	reviewer_id,
	count(*) as total_reviews,
	Min(review_date) as first_review,
	Max(review_date) as last_review,
Max(review_date) - Min(review_date) as days_span
from reviews
	group by reviewer_id
	having 	count(*) > 4 and Max(review_date) - Min(review_date) <=60
	order by  total_reviews desc,days_span desc;

----Q18---Which stores depend heavily on a small number of reviewers?
	Select s.store_id,
	s.store_name,
	count(distinct r.reviewer_id) as total_reviewers,
	count(*) as total_reviews,
Round(count(*) / count(distinct r.reviewer_id), 2) as avg_reviews_per_reviewer
	From store s 
		join reviews r 
		on s.store_id = r.store_id
	group by s.store_id, s.store_name
	having count(distinct r.reviewer_id) < 10
	order by avg_reviews_per_reviewer asc;

----Q19--Which high-rated stores receive very low engagement (likes)?
Select 
	s.store_name,
	Round(avg(r.overall_ratings),2) as avg_ratings,
	Sum(r.review_like_count) as total_likes
	From store s
	join reviews r
	on s.store_id = r.store_id 
	Group by s.store_name
	Having avg(r.overall_ratings) >= 4.5 And Sum(r.review_like_count) <= 5
	order by total_likes asc;
	
----Q20---If you had to recommend 3 stores to promote, which would you choose and why?
Select 
	s.store_name,
	Round(avg(r.food_ratings),2) as avg_ratings,
	count(Distinct r.reviewer_id) as total_reviewers
	From store s 
		join reviews r 
		on s.store_id = r.store_id
		Group by s.store_name
		having avg(r.food_ratings) >= 4.50 And count(Distinct r.reviewer_id) <= 3
	order by avg_ratings desc, total_reviewers asc
	Limit 3;
-- I suggested these 3 stores becuse there ratings are above 4.50 and only few reviewers review about them that's mean these are underatted
	