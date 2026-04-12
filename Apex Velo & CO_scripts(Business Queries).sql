-- Revenue Analysis 

-- Finding top customers 
-- Basis = Customer,territory
select c.customerid,
	st.name,
	round(sum(linetotal),2) as total_revenue,
count(distinct soh.SalesOrderID) as order_count,
	round(round(sum(linetotal),2)/count(distinct soh.SalesOrderID),2) as avgs 
from customer c 
	join salesorderheader soh 
on c.CustomerID = soh.CustomerID
	join salesorderdetail sod
on sod.SalesOrderID = soh.SalesOrderID
	join salesterritory st 
on c.TerritoryID = st.TerritoryID
group by c.CustomerID
order by round(sum(linetotal),2) desc;

-- Product basis revenue generation 
-- basis = products 
select p.ProductID,p.name,
	round(sum(linetotal),2) as total_revenue
from product p 
	join salesorderdetail sod 
on p.ProductID = sod.ProductID 
	group by p.name ,p.productid
order by round(sum(linetotal),2) desc;

-- Average On Product basis 
with Averages as (
select p.name as productname ,avg(linetotal) as Average_revenue
from product p 
join salesorderdetail sod 
on p.ProductID = sod.ProductID
group by p.name
)
select productname,round(Average_revenue,2) as Average_revenue ,
round(avg(average_revenue) over(),2) as Abs_average,
case when round(Average_revenue,2) >= round(avg(average_revenue) over(),2) then 'Above Average'
when round(Average_revenue,2) < round(avg(average_revenue) over(),2) then 'Below Average'
Else 'Average'
end as Analsysis
from averages;


-- Ranking on the basis of product  
 select p.name,round(sum(linetotal),2) as total_revenue ,
	dense_rank() over(order by sum(linetotal) desc) as Ranks
from salesorderdetail sod 
	join salesorderheader soh 
 on sod.SalesOrderID = soh.SalesOrderID
	join product p 
 on p.ProductID = sod.ProductID
	group by p.name 
		limit 10 ;


-- revenue distribution on  territory basis
with location_rev_percent as (
select st.name as location,
round(sum(linetotal),2) as location_revenue
FROM salesorderdetail sod
    JOIN salesorderheader soh
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN salesterritory st
        ON soh.TerritoryID = st.TerritoryID
    GROUP BY st.Name),
    	total_revenue as (select round(sum(location_revenue),2) as total_revenue from location_rev_percent )
    select location,location_revenue,total_revenue,
		round((location_revenue/total_revenue)*100,2) as margin
    from 
		location_rev_percent
    cross join total_revenue
	order by margin desc ;
    
 
  
  -- Ranking on the basis of territory 
 Select st.name location,
	round(sum(linetotal),2) as total_revenue ,
 dense_rank() over(order by sum(linetotal) desc ) as Ranks
	from salesorderdetail sod 
 join salesorderheader soh 
	on sod.SalesOrderID = soh.SalesOrderID
 join salesterritory st 
	on st.TerritoryID = soh.TerritoryID
 group by st.name 
 limit 10;
  
    
    
    
    -- productcategory and subcategory revenue distribution 
    with product_revenue as(
		select pc.name as category,ps.name as subcategory,
    round(sum(linetotal),2) as product_revenue
		from productcategory pc 
    join productsubcategory ps 
		on pc.ProductCategoryID = ps.ProductCategoryID
    join product p 
		on p.ProductSubcategoryID = ps.ProductSubcategoryID 
    join salesorderdetail sod 
		on p.ProductID = sod.ProductID
    group by pc.name,ps.name
    ),
		total_revenue as (select round(sum(product_revenue),2) as total_revenue from product_revenue)
    select category,subcategory,product_revenue,total_revenue,
		round((product_revenue/total_revenue)*100,2) as distribution 
    from product_revenue	
		cross join total_revenue
    order by distribution desc;
    
   
   -- Ranking ON the basis of Categories and subcategories 
 select pc.name as category,ps.name subcategory ,round(sum(linetotal),2) as total_revenue ,
	dense_rank() over(order by sum(linetotal) desc) as Ranks
 from salesorderdetail sod 
	join salesorderheader soh 
 on sod.SalesOrderID = soh.SalesOrderID
	join product p 
 on p.ProductID = sod.ProductID
	join productsubcategory ps
 on ps.ProductSubcategoryID = p.ProductSubcategoryID
	join productcategory pc
 on pc.ProductCategoryID = ps.ProductcategoryID
	group by pc.name,ps.name 
 limit 10 ;
   
   
   -- Time based Analysis 
    -- Monthy And Yearly trends 
    with Monthly_revenue as (
		select round(sum(totaldue),2) as Total_revenue,
    date_format(orderdate,'%Y-%m-01') as date
		from salesorderheader 
    group by date_format(orderdate,'%Y-%m-01')
    ) 
		select date,total_revenue,
    lag(total_revenue) over(order by date) as prev_month_rev,
		total_revenue - lag(total_revenue) over(order by date) as Revenue_chg_in_absolute,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY date))
        * 100.0 / LAG(total_revenue) OVER (ORDER BY date),
        2) as '%_change_in_revenue',
        CASE 
			WHEN total_revenue > LAG(total_revenue) OVER (ORDER BY date) THEN 'Growth'
        WHEN total_revenue < LAG(total_revenue) OVER (ORDER BY date) THEN 'Decrease'
			ELSE 'Stagnation'
    END AS business_condition
		from monthly_revenue;
    
   -- tracking growth or stagnation on monthly basis 
    with monthly_analysis as (
		select month(orderdate) as month,
    round(sum(totaldue),2) as revenue
		from salesorderheader 
    group by month(orderdate) )
		select month,revenue,
    lag(revenue) over(order by month) as prev_month,
		revenue - lag(revenue) over(order by month) as chg_in_revenue,
    (lag(revenue) over(order by month)/revenue)*100 as '%_chg_in_rev',
		case when revenue > lag(revenue) over(order by month) then 'Growth'
		when revenue < lag(revenue) over(order by month) then 'Decrease'
			Else 'stagnation'
    end as business_condition 
		from monthly_analysis;
        
	-- pattern seasonality analysis
	WITH revenue_basis AS (
SELECT 
        YEAR(OrderDate) AS year,
	MONTH(OrderDate) AS month,
        SUM(TotalDue) AS revenue
FROM SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
seasonality_test AS (
    SELECT 
	year,
	month,
	revenue,
        AVG(revenue) OVER (PARTITION BY year) AS yearly_avg
FROM revenue_basis
)
SELECT 
    year,
    month,
    ROUND(revenue,2) AS revenue,
    ROUND(yearly_avg,2) AS yearly_avg,
    ROUND(revenue / yearly_avg,2) AS avg_ratio,
    CASE 
	WHEN revenue > yearly_avg * 1.10 THEN 'Strong Above Average'
	WHEN revenue > yearly_avg THEN 'Above Average'
	WHEN revenue < yearly_avg * 0.90 THEN 'Way Below Average'
        ELSE 'Below Average'
    END AS classification
FROM seasonality_test
	ORDER BY year, month;

-- Efficiency checks on employees 
-- Reveneue distribution 
-- Basis = Employees 
WITH emp_revenue_distribution AS (
    SELECT 
        soh.SalesPersonID AS employeeid,
        SUM(sod.LineTotal) AS total_revenue
    FROM SalesOrderHeader soh
    JOIN SalesOrderDetail sod 
        ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.SalesPersonID IS NOT NULL
    GROUP BY soh.SalesPersonID
),
absolute_revenue AS (
    SELECT SUM(total_revenue) AS absolute_revenue 
    FROM emp_revenue_distribution
)
SELECT 
    e.employeeid,
    ROUND(e.total_revenue,2) AS total_revenue,
    ROUND(a.absolute_revenue,2) AS absolute_revenue,
    ROUND((e.total_revenue / a.absolute_revenue) * 100,2) AS contribution_pct,
    CASE 
        WHEN (e.total_revenue / a.absolute_revenue) * 100 > 10 THEN 'Top Performer'
        WHEN (e.total_revenue / a.absolute_revenue) * 100 BETWEEN 5 AND 10 THEN 'Average'
        ELSE 'Below Average'
    END AS performance_category
FROM emp_revenue_distribution e
CROSS JOIN absolute_revenue a;

-- Efficiency on the basis of store 
	 with store_performance as (
		select s.customerid,s.name as name ,sum(linetotal) as total_revenue 
     from store s 
		join salesorderheader soh 
     on s.CustomerID = soh.CustomerID 
		join salesorderdetail sod 
     on sod.SalesOrderID = soh.SalesOrderID
		group by s.CustomerID,name  ),
     Absolute_revenue as (select sum(total_revenue) as Absolute_revenue from store_performance)
		select name,round(total_revenue,2),round(absolute_revenue,2),
     round((total_revenue/absolute_revenue)*100,2) 
		as Percent_contributions 
     from store_performance 
		cross join absolute_revenue ;

 -- Ranking on the basis of stores 
 select s.name ,round(sum(linetotal),2) as total_revenue ,
	dense_rank() over(order by sum(linetotal) desc) as Ranks
 from salesorderdetail sod 
	join salesorderheader soh 
 on sod.SalesOrderID = soh.SalesOrderID
join store s 
 on s.CustomerID = soh.CustomerID
	group by s.name 
 limit 10;



-- Profit margin on the basis of category and subcategory
-- categorising profits and losses 
with revenue as ( 
	select poh.ProductID,pc.name as productcategory,ps.name as productsubcategory,sum(linetotal) as total_revenue,
 sum(poh.standardcost* OrderQty) as total_cost,
	sum(linetotal)- sum(poh.standardcost* OrderQty) as 'profit_or_loss'
 from productcosthistory poh 
	left join salesorderdetail sod 
 on sod.ProductID = poh.ProductID 
	join product p 
 on p.ProductID = poh.ProductID
	join productsubcategory ps
 on p.productsubcategoryid = ps.productsubcategoryid
	left join productcategory pc 
 on pc.ProductCategoryID = ps.ProductCategoryID
	group by poh.ProductID,pc.name,ps.name
 )
 select productid,productcategory,productsubcategory,round(total_revenue,2)as total_revenue
	,round(total_cost,2) as total_cost
 ,round(profit_or_loss,2) as profit_or_loss  ,
	round((profit_or_loss /total_revenue)*100,2) as margins from revenue
where total_revenue and total_cost is not null 
;
 

-- Products with lead revenue generation but low margins 
with performance as (
	select p.name,round(sum(linetotal),2) as total_revenue,
 round(sum(poh.standardcost),2) as total_cost,
	round(sum(linetotal)-sum(poh.standardcost* OrderQty),2) as 'profit_or_loss'
 from product p 
	join salesorderdetail sod
 on p.ProductID = sod.ProductID
	join productcosthistory poh
 on poh.ProductID = p.ProductID
group by p.name )
 select name,round(sum(total_revenue),2) as revenue,
	round((profit_or_loss /total_revenue)*100,2) as margins,
 case when 
	sum(total_revenue) > (select avg(total_revenue) from performance) and
  profit_or_loss < (select avg(profit_or_loss) from performance) then 'High revenue low margins' 
	when  sum(total_revenue) < (select avg(total_revenue) from performance) and  
 profit_or_loss > (select avg(profit_or_loss) from performance) then 'Low revenue high margins' 
	else 'Balanced '	
 end as classification_by_performance from performance
	group by name ;
 
 
 -- Customers that never purchased 
 select c.customerid
 from customer c 
 left join salesorderheader soh 
 on c.CustomerID = soh.CustomerID
 where soh.SalesOrderID is null ;
 
-- Discount Impact Analysis 
with Discount_impact as (
select p.name as productname,pc.name as category,ps.name as subcategory ,
case when unitpricediscount = 0 then "No Cost Borne"
when unitpricediscount between 0.02 and 0.05 then "Low Cost Borne"
when unitpricediscount between 0.06 and 0.15 then "High Cost Borne"
when unitpricediscount > 0.35 then "Very High Cost Borne"
End as Discount_Buckets,
sum(orderqty*unitprice) as Potential_revenue,
sum(linetotal) as Actual_Revenue,
sum(Orderqty*standardcost) as total_cost,
round(sum(orderqty*unitprice) - sum(linetotal)),2 as Discount_cost
from salesorderdetail sod 
join product p
on p.ProductID = sod.ProductID
join productsubcategory ps 
on ps.ProductSubcategoryID = p.ProductSubcategoryID
join productcategory pc 
on pc.ProductCategoryID = ps.ProductCategoryID
group by p.name,pc.name,ps.name,unitpricediscount
)
select productname,category,subcategory,round((Actual_Revenue - total_cost)) as Profit,
round((Actual_Revenue - total_cost) / (round(Discount_cost,2)) ,2) as performance,
case when round((Actual_Revenue - total_cost) / (round(Discount_cost,2)) ,2) > 0 then "Adding to profits"
when round((Actual_Revenue - total_cost) / (round(Discount_cost,2)) ,2) < 0 then "Eating Profits"
Else "NO contribution"
End as Impact_on_Business 
from Discount_impact
order by profit desc;
