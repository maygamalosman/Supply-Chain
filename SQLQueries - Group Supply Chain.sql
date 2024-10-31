use [Supply Chain]
go



----Reports Related to Revenue and Sales -

----- 1. Count of products per each product type ? 

select  distinct(count(sku_id)) as Count_of_Product, p.Product_type
from Operations as o
join Product_Type as p
on o.Product_Type_ID = p.Product_Type_ID
group by Product_type,o.Product_Type_ID,p.Product_type


-----2. How is revenue and sold products Quantity distributed by customer demographics?

select D.Customer_demographics, round(sum(revenue_generated),2) as Total_Revenue , SUM(number_of_products_sold) as Total_Quantity
from operations as o 
join Demographics as d
on o.CustomerDemoID = d.CustomerDemoID
group by D.Customer_demographics
order by Total_Revenue desc

------3. What is the revenue for each supplier?

select  s.supplier_name ,  round(sum(revenue_generated),2) as Total_Revenue
from operations as o 
join Supplier as s 
on o.SupplierID = s.SupplierID
group by Supplier_name
order by Total_Revenue desc

-------4. What is the revenue, total cost, and profit for each product type?
select p.product_type , round(sum(revenue_generated),2) as Total_Revenue, round(sum(costs),2) as Total_Cost, round(sum(revenue_generated - costs ),2) as Total_Profit 
from Operations as o 
join Product_Type as p 
on o.Product_Type_ID = p.Product_Type_ID
group by p.Product_Type
order by Total_Revenue desc

-------5. How is revenue distributed across different location?

select 
 l.location, round(SUM(revenue_generated),2) as Total_Revenue,
 format((sum(o.revenue_generated)/sum(sum(o.revenue_generated)) over()),'P2') as Revenue_Percentage
from Operations as o
join Locations as l 
on o.LoactionID = l.LocationID
group by  l.Location
order by Revenue_Percentage desc 

------- Reports Related to Sales and Quantities.

-----1.	What is the quantity sold for each product compared to its price category?-------

SELECT P.SKU AS product,SUM(O.Number_of_products_sold) AS Sold_Quantity,
    CASE 
        WHEN O.Price < (SELECT (AVG(Price)-10) FROM operations) THEN 'Low price'
        WHEN O.Price >= (SELECT (AVG(Price)+10) FROM operations) THEN 'High price'
        ELSE 'Average price'
    END AS price_category
FROM 
    Product AS P
JOIN 
    Operations AS O ON P.SKUID = O.SKU_ID
GROUP BY 
    P.SKU, O.price
ORDER BY  
	P.sku ;

	---Once we obtained the previous result, we wanted to dive deeper to comprehend the data, thus we posed the following two questions.

/*count of products sold and total quantity sold for each price category */
WITH PriceCategories AS (
    SELECT 
        P.SKU AS product,
        SUM(O.Number_of_products_sold) AS Sold_Quantity,
        CASE 
            WHEN O.Price < (SELECT (AVG(Price) - 10) FROM Operations) THEN 'Low price'
            WHEN O.Price >= (SELECT (AVG(Price) + 10) FROM Operations) THEN 'High price'
            ELSE 'Average price'
        END AS price_category
    FROM 
        Product AS P
    JOIN 
        Operations AS O ON P.SKUID = O.SKU_ID
    GROUP BY 
        P.SKU, O.Price
)

SELECT 
    price_category,
    COUNT(*) AS Count_Of_Products,
    SUM(Sold_Quantity) AS Total_Sold_Quantity
FROM 
    PriceCategories
GROUP BY 
    price_category
ORDER BY 
    price_category;

/*count of products sold and total quantity sold for each product type */

Select 
	pt.Product_type,   
	COUNT(o.SKU_ID) AS Count_Of_Products,
    SUM(o.Number_of_products_sold) AS Total_Sold_Quantity
From 
	Product_Type as pt
join
	Operations AS O ON Pt.Product_Type_ID = O.Product_Type_ID
GROUP BY pt.Product_type ;

/*2. What are the products sold with the highest and lowest defect rates? */

/*lowest_defect_rate */
SELECT 
    TOP 1 p.SKU AS product,
    MIN(o.Defect_rates) AS lowest_defect_rate
FROM 
    Product AS p
JOIN 
    operations AS o ON p.SKUID = o.SKU_ID
GROUP BY 
    p.SKU
ORDER BY 
    lowest_defect_rate ASC


/*Highest_defect_rate*/
SELECT 
    TOP 1 p.SKU AS product,
    max(o.Defect_rates) AS Highest_defect_rate
FROM 
    Product AS p
JOIN 
    operations AS o ON p.SKUID = o.SKU_ID
GROUP BY 
    p.SKU
ORDER BY 
    Highest_defect_rate desc;

/*3. How are shipping times related to quantities sold ?*/

SELECT 
    o.Shipping_times,
    SUM(o.Number_of_products_sold) AS total_quantity_sold
FROM Operations AS o 
GROUP BY 
    o.Shipping_times
ORDER BY 
    o.Shipping_times;

/*4. How is the quantity sold in each product type related to inspection result? */

SELECT 
   i.Inspection_results,
   SUM(o.Number_of_products_sold) AS total_quantity_sold,
   COUNT(o.SKU_ID) AS Count_Of_Products
FROM 
	Operations AS o 
join 
	Inspections as i
	on i.InspectionResultID = o.InspectionResultID
GROUP BY 
	i.Inspection_results
ORDER BY
	SUM(o.Number_of_products_sold);

/*5. How is the quantity sold in each region defected by customer demographics?*/
SELECT 
	d.Customer_demographics,
	SUM(o.Number_of_products_sold) AS total_quantity_sold,
	COUNT(o.SKU_ID) AS Count_Of_Products

FROM 
	Operations AS o 
join 
	demographics as d
on 
	d.CustomerDemoID =o.CustomerDemoID
GROUP BY 
	d.Customer_demographics
ORDER BY 
	SUM(o.Number_of_products_sold);

--Reports Related to Suppliers and Supply Chain 

---1.	analyze the supplier’s performance in terms of efficiency (product sold quantity, stock level, shortest supply time, lowest defect rates, min cost, max profit, and revenue).---
SELECT 
    s.Supplier_name,
    SUM(o.Number_of_products_sold) AS total_products_sold,
    AVG(o.Stock_levels) AS average_stock_level,
    MIN(o.Supplier_Lead_time) AS shortest_supply_time,
    MIN(o.Defect_rates) AS lowest_defect_rate,
    MIN(o.Manufacturing_costs) AS min_cost,
    MAX(o.Revenue_generated - o.Manufacturing_costs) AS max_profit,
    SUM(o.Revenue_generated) AS total_revenue
FROM Supplier s
JOIN Operations o ON s.SupplierID = o.SupplierID
GROUP BY s.Supplier_name
ORDER BY total_products_sold DESC, max_profit DESC;

-----2.	What percentage of products pass inspections based on supplier?
SELECT 
    s.Supplier_name,
    COUNT(CASE WHEN i.Inspection_results = 'Pass' THEN 1 END) * 100.0 / COUNT(*) AS pass_percentage
FROM Supplier s
JOIN Operations o ON s.SupplierID = o.SupplierID
JOIN Inspections i ON o.InspectionResultID = i.InspectionResultID
GROUP BY s.Supplier_name
ORDER BY pass_percentage DESC;

--3.	How do transportation modes and routes affect lead times from each supplier?
SELECT 
    s.Supplier_name,
    t.Transportation_modes,
    r.Routes,
    AVG(o.Supplier_Lead_time) AS average_lead_time
FROM Supplier s
JOIN Operations o ON s.SupplierID = o.SupplierID
JOIN Transportation t ON o.TransportationModeID = t.TransportationModeID
JOIN Routes r ON o.RouteID = r.RouteID
GROUP BY s.Supplier_name, t.Transportation_modes, r.Routes
ORDER BY average_lead_time ASC;

---4.	How does the inspection result impact the total profit by suppliers?
SELECT 
    s.Supplier_name,
    i.Inspection_results,
    SUM(o.Revenue_generated - o.Manufacturing_costs) AS total_profit
FROM Supplier s
JOIN Operations o ON s.SupplierID = o.SupplierID
JOIN Inspections i ON o.InspectionResultID = i.InspectionResultID
GROUP BY s.Supplier_name, i.Inspection_results
ORDER BY total_profit DESC;

----Reports Related to Costs
----1.	What is the relationship between manufacturing costs and revenue for each product type?

SELECT 
    [Product_Type_ID], 
    SUM([Manufacturing_costs]) AS TotalManufacturingCost, 
    SUM([Revenue_generated]) AS TotalRevenue,
    (SUM([Revenue_generated]) - SUM([Manufacturing_costs])) AS ProfitOrLoss
FROM 
    Operations
GROUP BY 
    [Product_Type_ID];

----2.	What are the shipping costs by different shipping companies and location?
SELECT 
    CarrierID, 
    LoactionID, 
    SUM(Shipping_costs) AS TotalShippingCost
FROM 
    Operations
GROUP BY 
    CarrierID, 
    LoactionID
ORDER BY 
    CarrierID, 
    LoactionID;

----3.	How are transportation costs distributed by routes and transportation mode used?
SELECT 
    RouteID, 
    TransportationModeID, 
    SUM(Costs) AS TotalTransportationCost
FROM 
    Operations
GROUP BY 
    RouteID, 
    TransportationModeID
ORDER BY 
    RouteID, 
    TransportationModeID;

----4.	How do shipping costs impact on the total revenue for each shipping company?
SELECT 
    CarrierID, 
    SUM(Shipping_costs) AS TotalShippingCost, 
    SUM(Revenue_generated) AS TotalRevenue,
    (SUM(Revenue_generated) - SUM(Shipping_costs)) AS NetImpact
FROM 
    Operations
GROUP BY 
    CarrierID
ORDER BY 
    CarrierID;

----5.	How do shipping costs affect the number of products sold by location
SELECT 
    LoactionID, 
    SUM(Shipping_costs) AS TotalShippingCost, 
    SUM(Number_of_products_sold) AS TotalProductsSold
FROM 
    Operations
GROUP BY 
    LoactionID
ORDER BY 
    LoactionID;

----Reports Related to Quality 
----1.	Failure rates in product inspection by location.

select count(*) as "Total Products", inspection_results, location
from operations o join Inspections i
on o.InspectionResultID = i.InspectionResultID
join locations l
on o.LoactionID = l.LocationID
where Inspection_results = 'Fail'
group by Inspection_results, location

----2.	What are total costs for defective products for each product type?

select format(sum(costs), 'N2') as "Total Cost", Product_Type
from Operations o join Product_Type p
on o.Product_Type_ID = p.Product_Type_ID
join Inspections i
on o.InspectionResultID = i.InspectionResultID
where Inspection_results = 'Fail'
group by Product_Type

------3.	What percentage of products inspections result based on supplier?

select format(sum(Defect_rates)/227.715799400583, 'P2') as Defect_Rates, Supplier_name
from Operations o join Supplier s
on o.SupplierID = s.SupplierID
group by Supplier_name

------4.	Are the results in inspections result can affect sales volume?

select format(sum(Revenue_generated),'N2') as "Sales Revenue", Inspection_results
from operations o join inspections i
on o.InspectionResultID = i.InspectionResultID
group by Inspection_results

----Reports Related to Location and Shipping companies 

------1.	What is the average shipping cost per product by shipping companies?

SELECT 
    P.SKU AS Product,
    SC.Shipping_carriers AS ShippingCompany,
    ROUND(AVG(O.Shipping_costs), 2) AS AvgShippingCost
FROM 
    Operations O
JOIN 
    Product P ON O.SKU_ID = P.SKUID
JOIN 
    [Shipping Carriers] SC ON O.CarrierID = SC.CarrierID
GROUP BY 
    P.SKU, SC.Shipping_carriers;

------2.	How does revenue vary by rote and transportation mode?

SELECT 
    R.Routes AS Route,
    T.Transportation_modes AS TransportationMode,
    Round(SUM(O.Revenue_generated),2) AS TotalRevenue
FROM 
    Operations O
JOIN 
    Routes R ON O.RouteID = R.RouteID
JOIN 
    Transportation T ON O.TransportationModeID = T.TransportationModeID
GROUP BY 
    R.Routes, T.Transportation_modes;

------3.	What is the most used rote and transportation mode for each company?

WITH RouteTransportationUsage AS (
    SELECT 
        SC.Shipping_carriers AS ShippingCompany,
        R.Routes AS Route,
        T.Transportation_modes AS TransportationMode,
        SUM(O.Order_quantities) AS TotalUsage,
        ROW_NUMBER() OVER (PARTITION BY SC.Shipping_carriers ORDER BY SUM(O.Order_quantities) DESC) AS UsageRank
    FROM 
        Operations O
    JOIN 
        [Shipping Carriers] SC ON O.CarrierID = SC.CarrierID
    JOIN 
        Routes R ON O.RouteID = R.RouteID
    JOIN 
        Transportation T ON O.TransportationModeID = T.TransportationModeID
    GROUP BY 
        SC.Shipping_carriers, R.Routes, T.Transportation_modes
)
SELECT 
    ShippingCompany,
    Route,
    TransportationMode,
    TotalUsage
FROM 
    RouteTransportationUsage
WHERE 
    UsageRank = 1;

------4.	Which shipping company has the highest percentage of best deliveries time (compare to the average value)?
WITH AverageDeliveryTime AS (
    SELECT 
        AVG(O.Shipping_times) AS AvgShippingTime
    FROM 
        Operations O
),
BestDeliveryCount AS (
    SELECT 
        SC.Shipping_carriers AS ShippingCompany,
        COUNT(*) AS TotalDeliveries,
        SUM(CASE WHEN O.Shipping_times < ADT.AvgShippingTime THEN 1 ELSE 0 END) AS BestDeliveries
    FROM 
        Operations O
    JOIN 
        [Shipping Carriers] SC ON O.CarrierID = SC.CarrierID
    CROSS JOIN 
        AverageDeliveryTime ADT
    GROUP BY 
        SC.Shipping_carriers
),
BestDeliveryPercentage AS (
    SELECT 
        ShippingCompany,
        BestDeliveries,
        TotalDeliveries,
        (CAST(BestDeliveries AS FLOAT) / TotalDeliveries) * 100 AS BestDeliveryPercentage
    FROM 
        BestDeliveryCount
)
SELECT 
    TOP 1 ShippingCompany,
    BestDeliveryPercentage
FROM 
    BestDeliveryPercentage
ORDER BY 
    BestDeliveryPercentage DESC;

















