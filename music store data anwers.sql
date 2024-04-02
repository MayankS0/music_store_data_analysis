--Q1- Who is the senior most employee based on job title?
select first_name, last_name from employee
order by levels desc limit 1

-- Q2 - Which countries have the most Invoices?
select billing_country as country,count(billing_country) as frequencies
from invoice
group by billing_country
order by country

--Q3 -  What are top 3 values of total invoice?
select billing_country, sum(floor(total))
from invoice
group by billing_country 


-- Q4 - Which city has the best customers? We would like to throw a
--     promotional Music Festival in the city we made the most money.
--     Write a query that returns one city that has the highest sum of 
--     invoice totals. Return both the city name & sum of all invoice totals

select billing_city, sum(floor(total)) as total
from invoice
group by billing_city
order by total desc limit 1


-- Q5 - Who is the best customer? The customer who has spent the most
--	money will be declared the best customer. 
--  Write a query that returns the person who has spent the most money

select customer.first_name as First_name,customer.last_name as Last_name, sum(floor(invoice.total)) as total
from customer 
join invoice 
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc limit 1

---------- ********* Intermediate question  ***----------------------------------------------------------------------------


-- Q6 - Write query to return the email, first name, last name, & Genre of
--      all Rock Music listeners. Return your list ordered alphabetically
--      by email starting with A

	

select distinct customer.first_name,customer.last_name, customer.email
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
where track.track_id in ( select track.track_id from track
join genre
	on track.genre_id=genre.genre_id
where genre.name like 'Rock')
order by customer.email


--- Q-7 -Let's invite the artists who have written the most rock music in our dataset. Write a query that 
--- returns the Artist name and total track count of the top 10 rock bands

	
select artist.artist_id,artist.name,count(artist.name)
	from artist
	join album on artist.artist_id=album.artist_id
	join track on album.album_id = track.album_id
	where track.track_id in (
	select track.track_id
	from track
    join genre on track.genre_id = genre.genre_id
    where genre.name like 'Rock')
group by artist.artist_id
order by count(artist.name) desc limit 10


--- Q-8 - Return all the track names that have a song length longer than the average song
--- length. Return the Name and Milliseconds for each track. Order by the song length with
--- the longest songs listed first
	select name, milliseconds as duration from track
where milliseconds > (select avg(milliseconds) from track)
order by duration desc


--- Q9 - Find how much amount spent by each customer on artists? Write a query to return 
---   customer name, artist name and total spent?

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total
	from invoice_line
	join track on invoice_line.track_id = track.track_id
	join album on track.album_id = album.album_id
	join artist on album.artist_id = artist.artist_id
	group by artist.artist_id
	order by total desc limit 1
)
select customer.first_name, customer.last_name, best_selling_artist.artist_name, best_selling_artist.total
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join best_selling_artist on album.artist_id = best_selling_artist.artist_id
group by 1,2,3,4
order by 4 desc


-- Q-12  We want to find out the most popular music Genre for each country. We determine
--       the most popular genre as the genre with the highest amount of purchases. Write
--       a query that returns each country along with the top Genre. For countries 
--       where the maximum number of purchases is shared return all Genres

with popular_genre as(
	select count(invoice_line.quantity) as quantity, customer.country, genre.genre_id, genre.name,
	row_number()  over (partition by customer.country order by count(invoice_line.quantity) desc )
	as row_no
	from invoice_line
	join invoice on invoice_line.invoice_id = invoice.invoice_id
	join customer on invoice.customer_id = customer.customer_id
	join track on invoice_line.track_id =  track.track_id
	join genre on track.genre_id = genre.genre_id
	group by 2, 3, 4
	order by 2,1 desc
)
select * from popular_genre where row_no <= 1



-- Q-11 - Write a query that determines the customer that has spent the most on music
--	     for each country. Write a query that returns the country along with the 
--	     top customer and how much they spent. For countries where the 
--       top amount spent is shared, provide all customers who spent this amount

with customer_with_country as (
	select customer.customer_id,customer.first_name, customer.last_name,invoice.billing_country,
	sum(invoice.total) as total_spending,
	row_number() over (partition by invoice.billing_country order by sum(invoice.total) desc) as row_no
	from invoice 
	join customer on invoice.customer_id = customer.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)
select * from customer_with_country where row_no <=1