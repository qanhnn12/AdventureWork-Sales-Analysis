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

Save those table as CSV files to import to Power BI later.

Note: FACT_Budget is generated from a seperated Excel file [here](https://github.com/qanhnn12/AdventureWork-Sales-Analysis/blob/main/Data%20Cleaning/SalesBudget.xlsx).

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
## Dashboard
