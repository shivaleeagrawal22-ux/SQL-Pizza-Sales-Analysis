create database pizza_sales_analysis

select top 1 * from order_details
select top 1 * from orders 
select top 1 * from pizza_types 
select top 1 * from pizzas 

-- BASIC:

--Q1 Retrieve the total number of orders placed.
   select count(*) as total_orders from orders as a

--Q2 Calculate the total revenue generated from pizza sales.
   select sum(t.total_sales) as total_revenue 
   from ( 
          select a.pizza_id, sum(b.quantity * a.price) as total_sales from pizzas as a
          right join order_details as b
          on a.pizza_id = b.pizza_id 
          group by a.pizza_id
        ) as t

--Q3 Identify the highest-priced pizza.
   select top 1 pizza_id from pizzas
   order by price desc

--Q4 Identify the most common pizza size ordered.
   select top 1 a.size from pizzas as a
   right join order_details as b
   on a.pizza_id = b.pizza_id 
   group by a.size
   order by count(*) desc

--Q5 List the top 5 most ordered pizza types along with their quantities.
   select top 5 c.name, sum(a.quantity) as quantity_ from order_details as a
   left join pizzas as b
   on a.pizza_id = b.pizza_id 
   inner join pizza_types as c
   on b.pizza_type_id = c.pizza_type_id
   group by c.name
   order by quantity_ desc
   
-- INTERMEDIATE:

--Q6 Join the necessary tables to find the total quantity of each pizza category ordered.
   select c.category, sum(a.quantity) as total_quantity from order_details as a
   left join pizzas as b
   on a.pizza_id = b.pizza_id 
   inner join pizza_types as c
   on b.pizza_type_id = c.pizza_type_id
   group by c.category

--Q7 Determine the distribution of orders by hour of the day.
   select datepart(hour,a.time) as hour_, count(distinct b.order_id) from orders as a
   inner join order_details as b
   on a.order_id = b.order_id
   group by datepart(hour,a.time)
   order by hour_

--Q8 Join relevant tables to find the category-wise distribution of pizzas.
   select c.category, sum(a.quantity) as total_quantity from order_details as a
   left join pizzas as b
   on a.pizza_id = b.pizza_id 
   inner join pizza_types as c
   on b.pizza_type_id = c.pizza_type_id
   group by c.category

--Q9 Group the orders by date and calculate the average number of pizzas ordered per day.
  select avg(t.quantity_sold) as avg_pizza_perday
  from (
         select a.date, sum(b.quantity) as quantity_sold
         from orders as a
         inner join order_details as b
         on a.order_id = b.order_id
         group by a.date 
       ) as t
                                        
--Q10 Determine the top 3 most ordered pizza types based on revenue.
   select top 3 c.name from order_details as a
   left join pizzas as b
   on a.pizza_id = b.pizza_id
   inner join pizza_types as c
   on b.pizza_type_id = c.pizza_type_id
   group by c.name
   order by sum(a.quantity * b.price) desc

-- ADVANCED:

--Q11 Calculate the percentage contribution of each pizza type to total revenue.
   WITH revenue_cte AS (
                        select c.pizza_type_id, SUM(a.quantity) * b.price as revenue_
                        from order_details as a
                        left join pizzas as b
                        on a.pizza_id = b.pizza_id
                        inner join pizza_types as c
                        on b.pizza_type_id = c.pizza_type_id
                        group by c.pizza_type_id, b.price
   )

  SELECT t.pizza_type_id,
       round((t.revenue_ / (SELECT SUM(revenue_) FROM revenue_cte)) * 100,2) AS pct_contribution
  FROM revenue_cte as t
  
--Q12 Analyze the cumulative revenue generated over time.
   select t.date, sum(t.revenue_generated) over(order by t.date) as cumulative_revenue
   from (
          select b.date, round(sum(a.quantity * c.price),2) as revenue_generated
          from order_details as a
          inner join orders as b
          on a.order_id = b.order_id
          inner join pizzas as c
          on a.pizza_id = c.pizza_id
          group by b.date
        ) as t

--Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
   select t.category, t.name
   from (
          select c.category, c.name, sum(a.quantity) * b.price as revenue_, 
          rank() over (partition by c.category order by sum(a.quantity) * b.price desc) 
          as rank_ from order_details as a
          left join pizzas as b
          on a.pizza_id = b.pizza_id
          inner join pizza_types as c
          on b.pizza_type_id = c.pizza_type_id
          group by c.category, c.name, b.price
        ) as t

   where t.rank_ in (1,2,3)
   
   
   