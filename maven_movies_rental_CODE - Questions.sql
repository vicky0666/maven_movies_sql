-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

USE MAVENMOVIES;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA --

SELECT * FROM RENTAL;

SELECT CUSTOMER_ID, RENTAL_DATE
FROM RENTAL;

SELECT * FROM INVENTORY;

SELECT * FROM FILM;

SELECT * FROM CUSTOMER;

-- You need to provide customer firstname, lastname and email id to the marketing team --

select first_name , last_name , email from customer;


-- How many movies are with rental rate of $0.99? --

select count(*) as no_of_Movies 
from film 
where rental_rate = 0.99;

-- We want to see rental rate and how many movies are in each rental category --

select rental_rate, count(*) as no_of_Movies from film 
group by rental_rate;

-- Which rating has the most films? --

select rating ,count(*)as most_rating from film
group by rating 
order by most_rating DESC 
limit 1;

-- Which rating is most prevalant in each store? --

select f.rating , i.store_id ,count(*) as no_of_film 
from film f
join inventory i 
on f.film_id = i.film_id
group by f.rating , i.store_id
order by no_of_film desc;

-- List of films by Film Name, Category, Language --

select f.title as Film_name , l.name as Language , ca.name as Category
from film f 
join language l 
on f.language_id = l.language_id 
join film_category c
on c.film_id = f.film_id 
join category ca
on c.category_id = ca.category_id;

-- How many times each movie has been rented out?

select i.film_id , count(r.inventory_id) as No_of_Count
from inventory i 
join rental r 
on i.inventory_id = r.inventory_id 
group by i.film_id
order by No_of_count desc;


-- REVENUE PER FILM (TOP 10 GROSSERS)
select i.film_id , sum(p.amount) as total_revenue 
from inventory i 
join rental r 
on i.inventory_id = r.inventory_id 
join payment p 
on r.rental_id = p.rental_id
group by i.film_id 
order by total_revenue desc
limit 10;

            
-- Most Spending Customer so that we can send him/her rewards or debate points

select c.customer_id ,c.first_name ,c.last_name , sum(p.amount) as Highest_spending
from payment p 
join customer c 
on c.customer_id = p.customer_id
group by c.customer_id ,c.first_name ,c.last_name 
order by Highest_spending
limit 1;

-- Which Store has historically brought the most revenue?
select i.store_id , sum(p.amount) as Revenue
from inventory i 
join rental r 
on r.inventory_id  = i.inventory_id
join payment p 
on r.customer_id = p.customer_id 
group by i.store_id 
order by Revenue desc
limit 1;

-- How many rentals we have for each month

select year(rental_date) as Years ,monthname(rental_date) as Month , count(*) as No_of_Rental
from rental
group by year(rental_date) ,monthname(rental_date);

-- Reward users who have rented at least 30 times (with details of customers)

select c.customer_id , c.first_name,c.last_name ,count(r.customer_id) as No_of_time
from customer c
left join rental r 
on c.customer_id = r.customer_id
group by c.customer_id , c.first_name,c.last_name
having  count(r.customer_id) >=30
order by No_of_time DESC;


-- Could you pull all payments from our first 100 customers (based on customer ID)

select customer_id , payment_date ,amount
from payment
where customer_id < 101;

-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006

select customer_id , payment_date , amount
from payment 
where customer_id <= 100 and amount > 5 and payment_date >= '2006-01-01'; 

-- Now, could you please write a query to pull all payments from those specific customers, along
-- with payments over $5, from any customer?

select customer_id , payment_date , amount 
from payment 
where amount > 5  and customer_id in (5,9,100,95,320);


-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

select * 
from film 
where special_features like  '%Behind the Scenes%'; 


-- unique movie ratings and number of movies

select rating , count(*) as No_of_monvies
from film
group by rating;

-- Could you please pull a count of titles sliced by rental duration?

select rental_duration , count(title)  as no_of_movies
 from film
 group by rental_duration;

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION


select rating,  avg(length) as Avg_length ,
 avg(rental_duration) 
as Avg_duration , count(film_id) as No_of_Movies 
from film
group by rating
order by Avg_duration;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?

select replacement_cost , count(film_id) as No_of_Movies , round(avg(rental_rate),2) as Avg_rate , 
min(rental_rate) as Min_rate , max(rental_rate) as Max_rate
from film 
group by replacement_cost;


-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

select customer_id , count(rental_id) as No_of_times
from rental
group by customer_id
having count(rental_id) < 15 ; 


-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

select title , length , rental_rate
from film 
order by length desc , rental_rate desc;

-- CATEGORIZE MOVIES AS PER LENGTH
select film_id , title , length , 
case 
  when length < 50 then 'Short Movies' 
  when length < 100 then 'Avg Length Movies'
  when length < 150 then 'Bit Long Movies'
  else 'Too long Movies' 
  end as Length_categorize
  from film
  order by length desc;
  

-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC
  select  TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'Duration short'
        WHEN RENTAL_RATE >= 3.99 THEN 'Cost High'
        WHEN RATING IN ('NC-17','R') THEN 'For Adults'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'Short or Longer'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'For Children'
	END AS Recommendation
FROM film;

-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”

select first_name , last_name , 
       case when store_id = 1 and active = 1 then 'Store 1 active' 
       when store_id = 1 and active = 0 then 'Store 1 inactive' 
       when store_id = 2 and active = 1 then 'Store 2 active'
       when store_id = 2 and active = 0 then 'Store 2 inactive'
       end as Store_Label
       from customer;

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

select  f.title , f.description , i.store_id , i.inventory_id
from inventory i 
left join film f 
on i.film_id = f.film_id;

-- Actor first_name, last_name and number of movies

select a.first_name , a.last_name ,
 count(fa.film_id) as No_of_movies
from actor a 
 join film_actor fa 
on a.actor_id = fa.actor_id
group by a.first_name , a.last_name
order by No_of_movies desc;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

select f.title, count(fa.actor_id) as No_of_actors
from film f 
left join film_actor fa 
on f.film_id = fa.film_id
group by f.title;

-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
    
select a.first_name , a.last_name , f.title 
from actor a 
join film_actor fa
on a.actor_id = fa.actor_id 
join film f 
on fa.film_id = f.film_id;

-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”

select distinct(f.title) , f.description 
from film f 
join inventory i 
on f.film_id = i.film_id 
where i.store_id = 2;

-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

(select first_name , last_name , 'Staff Member' as Designation  from staff
union
select  first_name , last_name , 'Advisors' as Designation from advisor);
