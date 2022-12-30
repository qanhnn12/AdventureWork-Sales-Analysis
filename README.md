# :bar_chart: AdventureWork: Sales Analysis
This repository was inspired by the tutorial of Ali Ahmad - [Data Analyst Portfolio Project (Sales Analysis) with Power BI and SQL](https://www.youtube.com/playlist?list=PLMfXakCUhXsEUtk8c0zWr4whamGxLhAu0). 

The AdventureWork database from 2014 to 2019 can be found [here](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms). To update the database until 2022, follow the SQL Script [here](https://github.com/qanhnn12/AdventureWork-Sales-Analysis/blob/main/update_database.sql).

## Business Request
* We need to improve our Internet sales reports and want to move from static reports to visual dashboard.
* Essentially, we want to focus it on how much we have sold of what products, to which clients and how it has been over time.
* Seeing as each sales person works on different products and customers, it would be benefical to be able to filter them also.
* We measure our numbers against budget so I added that in a spreadsheet and we can compare our values against performance.
* The budget is for 2022 and we ussually look 2 years back in time when we do analysis of sales.

## Business Demand Overview
* Reporter: Sales Manager
* Value of change: Visual dashboard, improve sales reporting and follow up sales force
* Necessary systems: Power BI and CRM System
* Other relevant info: Budgets have been delivered in Excel in 2022

## User Stories
| **No.** | **As a (role)**      | **I want (request / demand)**                      | **So that I (user value)**                                               | **Acceptance criteria**                                               |
|---------|----------------------|----------------------------------------------------|--------------------------------------------------------------------------|-----------------------------------------------------------------------|
| 1       | Sales Manager        | To get a dashboard overview of internet sales      | Can follow better which customers and products sells the best            | A Power BI dashboard which updates data once a day                    |
| 2       | Sales Representative | A detailed overview of internet sales per customer | Can follow up my customers that buy the most and who we can sell one to | A Power BI dashboard which allows me to filter data for each customer |
| 3       | Sales Representative | A detailed overview of internet sales per product  | Can follow up my products that sell the most                            | A Power BI dashboard which allows me to filter data for each product  |
| 4       | Sales Manager        | To get a dashboard overview of internet sales      | Follow sales over time against budget                                    | A Power BI dashboard with graphs and KPIs comparing against budget    |

## Data Cleaning
From the AdventureWork database, we use SQL to generate these tables below:
* DIM_Customers
* DIM_Products
* DIM_Calendar
* FACT_InternetSales

Then, save them as CSV files to import to Power BI later.

*Note: FACT_Budget is generated from a seperated Excel file [here](https://github.com/qanhnn12/AdventureWork-Sales-Analysis/blob/main/Data%20Cleaning/SalesBudget.xlsx).*

### > Table `DIM_Customers`
```TSQL
SELECT 
  c.[CustomerKey]
  ,c.[FirstName] + ' ' + c.[LastName] AS FullName
  ,CASE c.[Gender] WHEN 'M' THEN 'Male' ELSE 'Female' END AS Gender
  ,c.[DateFirstPurchase]
	,g.City AS [Customer City]
FROM [AdventureWorksDW2019].[dbo].[DimCustomer] c
LEFT JOIN [dbo].[DimGeography] g
  ON c.GeographyKey = g.GeographyKey
ORDER BY c.CustomerKey
```
![image](https://user-images.githubusercontent.com/84619797/210081674-04c93ed4-873c-4a88-a8b7-d6bdc86c540d.png)

### > Table `DIM_Products`
```TSQL
SELECT 
  p.[ProductKey]
  ,p.[ProductAlternateKey] AS ProductItemCode
  ,p.[EnglishProductName] AS [Product Name]
  ,ps.[EnglishProductSubcategoryName] AS [Sub Category] --joined with Sub Category Table
  ,pc.[EnglishProductCategoryName] AS [Product Category] --joined with Category Table
  ,p.[Color] AS [Product Color]
  ,p.[Size] AS [Product Size]
  ,p.[ProductLine] AS [Product Line]
  ,p.[ModelName] AS [Product Model Name]
  ,p.[EnglishDescription] AS [Product Description]
  ,ISNULL(p.[Status], 'Outdated') AS [Product Status]
FROM [AdventureWorksDW2019].[dbo].[DimProduct] p
LEFT JOIN [dbo].[DimProductSubcategory] ps ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN [dbo].[DimProductCategory] pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
ORDER BY p.[ProductKey]
```
![image](https://user-images.githubusercontent.com/84619797/210082021-902047a1-4a4c-4655-817a-fc75947606c5.png)

### > Table `DIM_Calendar`
```TSQL
SELECT 
  [DateKey] 
  ,[FullDateAlternateKey] AS Date
  ,[EnglishDayNameOfWeek] AS Day
  ,[WeekNumberOfYear] AS WeekNo
  ,LEFT([EnglishMonthName], 3) AS MonthShort
  ,[MonthNumberOfYear] AS MonthNo
  ,[CalendarQuarter] AS Quarter 
  ,[CalendarYear] AS Year
FROM [AdventureWorksDW2019].[dbo].[DimDate]
WHERE [CalendarYear] >= 2020	--2 years back in time
```
![image](https://user-images.githubusercontent.com/84619797/210082248-3880cb1f-18d0-4010-950b-f46906f8a37b.png)

### > Table `FACT_InternetSales`
```TSQL
SELECT [ProductKey]
      ,[OrderDateKey]
      ,[DueDateKey]
      ,[ShipDateKey]
      ,[CustomerKey]
      ,[SalesOrderNumber]
      ,[SalesAmount]
FROM [AdventureWorksDW2019].[dbo].[FactInternetSales]
WHERE LEFT(OrderDateKey, 4) >= YEAR(GETDATE()) - 2 --ensures that we only bring 2 years of date from extraction
ORDER BY OrderDateKey
```
![image](https://user-images.githubusercontent.com/84619797/210082437-28e7a939-ccf1-466e-8269-6fb412035ace.png)

## Entity Relationship Diagram
After importing all CSV files to Power BI, the data model will look like this:
<img src="https://user-images.githubusercontent.com/84619797/210082856-5ac6a1c8-b7f1-4b8b-a02c-9884b371e391.png" width="900" height="500" >

## Dashboard

View the Power BI file [here](https://github.com/qanhnn12/AdventureWork-Sales-Analysis/blob/main/Dashboard%20AdventureWork.pbix).

View the PDF file [here](https://github.com/qanhnn12/AdventureWork-Sales-Analysis/blob/main/PDF%20Adventurework.pdf).

<img src="https://user-images.githubusercontent.com/84619797/210082886-1d08b8f4-478c-469e-8cd4-e5e6058ce447.png" width="900" height="550" >

<img src="https://user-images.githubusercontent.com/84619797/210083133-e5c7cf45-6956-4cc7-be54-2871e1d1f63e.png" width="900" height="550" >

<img src="https://user-images.githubusercontent.com/84619797/210083139-75de78ca-08ba-4d32-805c-0a84716462e3.png" width="900" height="550" >

---
## 👏 Support
Please give me a ⭐️ if you like this project!

---
© 2022 Anh Nguyen
