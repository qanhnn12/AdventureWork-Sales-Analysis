/* 
Description: 
- The script updates the date colums for the AdventureWorksDW database with recent dates and it inserts new dates in the date dimension. 
- It uses the current year as the last year for the data in the Adventure Works database. 
- AdventureWorksDW original database contains data from 2010 to 2014, this script will update the data to be (current year - 4 yars) to current year 
- The script deletes leap year records from FactCurrencyRate and FactProductInventory to avoid having constraint issues
- For example: if the current year is 2021, the data after running the script will be from 2017 to 2021. 

Author: David Alzamendi (https://techtalkcorner.com) 
Date: 19/11/2020 

Modified by: Anh Nguyen
Date: 29/12/2022

*/

-- Declare variables
DECLARE @CurrentYear INT
SET @CurrentYear = YEAR(GETDATE())

DECLARE @LastDayCurrentYear DATE
SET @LastDayCurrentYear = GETDATE() - DATEPART(DY, GETDATE())

DECLARE @MaxDateInDW INT
SELECT @MaxDateInDW = MAX(YEAR(orderdate)) FROM [dbo].[FactInternetSales] 

DECLARE @YearsToAdd INT = @CurrentYear - @MaxDateInDW 



IF @YearsToAdd > 0
BEGIN


-- Delete leap year records (February 29th)
DELETE FROM FactCurrencyRate WHERE MONTH([Date]) = 2 AND DAY([Date]) = 29
DELETE FROM FactProductInventory  WHERE MONTH([MovementDate]) = 2 AND DAY([MovementDate]) = 29

-- Drop foreign keys 
ALTER TABLE FactCurrencyRate DROP CONSTRAINT FK_FactCurrencyRate_DimDate 
ALTER TABLE FactFinance DROP CONSTRAINT FK_FactFinance_DimDate 
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate 
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate1 
ALTER TABLE FactInternetSales DROP CONSTRAINT FK_FactInternetSales_DimDate2 
ALTER TABLE FactProductInventory DROP CONSTRAINT FK_FactProductInventory_DimDate 
ALTER TABLE FactResellerSales DROP CONSTRAINT FK_FactResellerSales_DimDate 
ALTER TABLE FactSurveyResponse DROP CONSTRAINT FK_FactSurveyResponse_DateKey 

-- Include more dates in Date dimension, the existing dates are not being replaced 


DECLARE 
	@startdate DATE = '2015-01-01',		--change start date if required
	@enddate DATE = @LastDayCurrentYear	--change end date if required 

DECLARE @datelist TABLE (FullDate DATE);  

-- Recursive date query
WITH dt_cte AS (
	SELECT @startdate AS FullDate  
	UNION ALL  
	SELECT DATEADD(DAY, 1, FullDate) AS FullDate  
	FROM dt_cte  
	WHERE dt_cte.FullDate < @enddate
)

INSERT INTO @datelist 
	SELECT FullDate FROM dt_cte  
	OPTION (MAXRECURSION 0)
	

-- Populates the Date Dimension
SET DATEFIRST 7;	-- Set the first day of the week to Monday 

INSERT INTO [dbo].[DimDate]
( [DateKey] 
  ,[FullDateAlternateKey] 
  ,[DayNumberOfWeek] 
  ,[EnglishDayNameOfWeek] 
  ,[SpanishDayNameOfWeek] 
  ,[FrenchDayNameOfWeek] 
  ,[DayNumberOfMonth] 
  ,[DayNumberOfYear] 
  ,[WeekNumberOfYear] 
  ,[EnglishMonthName] 
  ,[SpanishMonthName] 
  ,[FrenchMonthName] 
  ,[MonthNumberOfYear] 
  ,[CalendarQuarter] 
  ,[CalendarYear] 
  ,[CalendarSemester] 
  ,[FiscalQuarter] 
  ,[FiscalYear] 
  ,[FiscalSemester] 
)

SELECT 
	CONVERT(INT, CONVERT(VARCHAR, dl.FullDate, 112)) AS DateKey
	, dl.FullDate AS FullDateAlternateKey
	, DATEPART(dw,dl.FullDate) AS DayNumberOfWeek
	, DATENAME(weekday,dl.FullDate) AS EnglishDayNameOfWeek
	, CASE DATENAME(weekday, dl.FullDate) 
		WHEN 'Monday' THEN 'Lunes'  
		WHEN 'Tuesday' THEN 'Martes'  
		WHEN 'Wednesday' THEN 'Miércoles'  
		WHEN 'Thursday' THEN 'Jueves'  
		WHEN 'Friday' THEN 'Viernes'  
		WHEN 'Saturday' THEN 'Sábado'  
		WHEN 'Sunday' THEN 'Doming'  
	END AS SpanishDayNameOfWeek
	, CASE DATENAME(weekday, dl.FullDate) 
		WHEN 'Monday' THEN 'Lundi'  
		WHEN 'Tuesday' THEN 'Mardi'  
		WHEN 'Wednesday' THEN 'Mercredi'  
		WHEN 'Thursday' THEN 'Jeudi'  
		WHEN 'Friday' THEN 'Vendredi'  
		WHEN 'Saturday' THEN 'Samedi'  
		WHEN 'Sunday' THEN 'Dimanche' 
	END AS FrenchDayNameOfWeek
	, DATEPART(d, dl.FullDate) AS DayNumberOfMonth
	, DATEPART(dy, dl.FullDate) AS DayNumberOfYear 
	, DATEPART(wk, dl.FullDate) AS WeekNumberOfYear
	, DATENAME(MONTH, dl.FullDate) AS EnglishMonthName
	, CASE DATENAME(weekday, dl.FullDate) 
		WHEN 'January' THEN 'Enero'  
		WHEN 'February' THEN 'Febrero' 
		WHEN 'March' THEN 'Marzo'  
		WHEN 'April' THEN 'Abril'  
		WHEN 'May' THEN 'Mayo' 
		WHEN 'June' THEN 'Junio'  
		WHEN 'July' THEN 'Julio'  
		WHEN 'August' THEN 'Agosto'  
		WHEN 'September' THEN 'Septiembre'  
		WHEN 'October' THEN 'Octubre'  
		WHEN 'November' THEN 'Noviembre'  
		WHEN 'December' THEN 'Diciembre' 
	END AS SpanishMonthName
	, CASE DATENAME(weekday, dl.FullDate) 
		WHEN 'January' THEN 'Janvier'  
		WHEN 'February' THEN 'Février'  
		WHEN 'March' THEN 'Mars'  
		WHEN 'April' THEN 'Avril'  
		WHEN 'May' THEN 'Mai'  
		WHEN 'June' THEN 'Juin'  
		WHEN 'July' THEN 'Juillet'  
		WHEN 'August' THEN 'Août'  
		WHEN 'September' THEN 'Septembre'  
		WHEN 'October' THEN 'Octobre'  
		WHEN 'November' THEN 'Novembre'  
		WHEN 'December' THEN 'Décembre' 
	END AS FrenchMonthName
	, MONTH(dl.FullDate) AS MonthNumberOfYear 
	, DATEPART(qq, dl.FullDate) AS CalendarQuarter 
	, YEAR(dl.FullDate) AS CalendarYear
	, CASE DATEPART(qq, dl.FullDate) 
		WHEN 1 THEN 1  
		WHEN 2 THEN 1  
		WHEN 3 THEN 2  
		WHEN 4 THEN 2  
	END AS CalendarSemester 
	, CASE DATEPART(qq, dl.FullDate)  
		WHEN 1 THEN 3  
		WHEN 2 THEN 4  
		WHEN 3 THEN 1  
		WHEN 4 THEN 2  
	END AS FiscalQuarter
	, CASE DATEPART(qq, dl.FullDate)  
		WHEN 1 THEN YEAR(dl.FullDate) -1 
		WHEN 2 THEN YEAR(dl.FullDate) -1 
		WHEN 3 THEN YEAR(dl.FullDate)  
		WHEN 4 THEN YEAR(dl.FullDate)  
	END AS FiscalYear 
	, CASE DATEPART(qq, dl.FullDate)  
		WHEN 1 THEN 2  
		WHEN 2 THEN 2  
		WHEN 3 THEN 1  
		WHEN 4 THEN 1 
	END AS FiscalSemester 
FROM @datelist dl  
LEFT JOIN [dbo].[dimdate] dt  
	ON dt.FullDateAlternateKey = dl.FullDate 
WHERE  dt.DateKey IS NULL 
ORDER BY DateKey DESC


-- Date (data type: date) 
-- Birth Date and Hire Date are not being updated 

UPDATE DimCustomer SET DateFirstPurchase = CASE WHEN DateFirstPurchase IS NOT NULL THEN DATEADD(year, @YearsToAdd, DateFirstPurchase) END 
UPDATE DimEmployee SET StartDate = CASE WHEN StartDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, StartDate) END 
UPDATE DimEmployee SET EndDate = CASE WHEN EndDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, EndDate) END 
UPDATE DimProduct SET StartDate = CASE WHEN StartDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, StartDate) END 
UPDATE DimProduct SET EndDate = CASE WHEN EndDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, EndDate) END 
UPDATE DimPromotion SET StartDate = CASE WHEN StartDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, StartDate) END 
UPDATE DimPromotion SET EndDate = CASE WHEN EndDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, EndDate) END 
UPDATE FactCallCenter SET Date = CASE WHEN Date IS NOT NULL THEN DATEADD(year, @YearsToAdd, Date) END 
UPDATE FactCurrencyRate SET Date = CASE WHEN Date IS NOT NULL THEN DATEADD(year, @YearsToAdd, Date) END 
UPDATE FactFinance SET Date = CASE WHEN Date IS NOT NULL THEN DATEADD(year, @YearsToAdd, Date) END 
UPDATE FactInternetSales SET OrderDate = CASE WHEN OrderDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, OrderDate) END 
UPDATE FactInternetSales SET DueDate = CASE WHEN DueDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, DueDate) END 
UPDATE FactInternetSales SET ShipDate = CASE WHEN ShipDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, ShipDate) END 
UPDATE FactProductInventory SET MovementDate = CASE WHEN MovementDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, MovementDate) END 
UPDATE FactResellerSales SET OrderDate = CASE WHEN OrderDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, OrderDate) END 
UPDATE FactResellerSales SET DueDate = CASE WHEN DueDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, DueDate) END 
UPDATE FactResellerSales SET ShipDate = CASE WHEN ShipDate IS NOT NULL THEN DATEADD(year, @YearsToAdd, ShipDate) END 
UPDATE FactSalesQuota SET Date = CASE WHEN Date IS NOT NULL THEN DATEADD(year, @YearsToAdd, Date) END 
UPDATE FactSurveyResponse SET Date = CASE WHEN Date IS NOT NULL THEN DATEADD(year, @YearsToAdd, Date) END 


-- DateKey (data type: int) 

UPDATE FactCallCenter SET DateKey = CASE WHEN DateKey IS NOT NULL THEN CAST(CONVERT(varchar, [Date], 112) AS int) END 
UPDATE FactCurrencyRate SET DateKey = CASE WHEN DateKey IS NOT NULL THEN CAST(CONVERT(varchar, 112) AS int) END 
UPDATE FactFinance SET DateKey = CASE WHEN DateKey IS NOT NULL THEN CAST(CONVERT(varchar, [Date], 112) AS int) END 
UPDATE FactInternetSales SET DueDateKey = CASE WHEN DueDateKey IS NOT NULL THEN CAST(CONVERT(varchar,[DueDate], 112) AS int) END 
UPDATE FactInternetSales SET OrderDateKey = CASE WHEN OrderDateKey IS NOT NULL THEN CAST(CONVERT(varchar, [OrderDate], 112) AS int) END 
UPDATE FactInternetSales SET ShipDateKey = CASE WHEN ShipDateKey IS NOT NULL THEN CAST(CONVERT(varchar, [ShipDate], 112) AS int) END 
UPDATE FactProductInventory SET DateKey = CASE WHEN DateKey IS NOT NULL THEN CAST(CONVERT(varchar, [MovementDate], 112) AS int) END 
UPDATE FactResellerSales SET DueDateKey = CASE WHEN DueDateKey IS NOT NULL THEN CAST(CONVERT(varchar, [ShipDate], 112) AS int) END 
UPDATE FactResellerSales SET OrderDateKey = CASE WHEN OrderDateKey IS NOT NULL THEN CAST(CONVERT(varchar, [ShipDate], 112) AS int) END 
UPDATE FactResellerSales SET ShipDateKey = CASE WHEN ShipDateKey IS NOT NULL THEN CAST(CONVERT(varchar, [ShipDate], 112) AS int) END 
UPDATE FactSalesQuota SET DateKey = CASE WHEN DateKey IS NOT NULL THEN CAST(CONVERT(varchar, [Date], 112) AS int) END 
UPDATE FactSurveyResponse SET DateKey = CASE WHEN DateKey IS NOT NULL THEN CAST(CONVERT(varchar, [Date], 112) AS int) END 

 

-- Update tables where year is a number in the format YYYY 

UPDATE FactSalesQuota SET CalendarYear = CASE WHEN CalendarYear IS NOT NULL THEN @YearsToAdd + CalendarYear END 
UPDATE DimReseller SET FirstOrderYear = CASE WHEN FirstOrderYear IS NOT NULL THEN @YearsToAdd + FirstOrderYear END 
UPDATE DimReseller SET LastOrderYear = CASE WHEN LastOrderYear IS NOT NULL THEN @YearsToAdd + LastOrderYear END 
UPDATE DimReseller SET YearOpened = CASE WHEN YearOpened IS NOT NULL THEN @YearsToAdd + YearOpened END 

 
-- Add back CONSTRAINTS

ALTER TABLE [dbo].[FactCurrencyRate] WITH CHECK ADD CONSTRAINT [FK_FactCurrencyRate_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactCurrencyRate] CHECK CONSTRAINT [FK_FactCurrencyRate_DimDate]

ALTER TABLE [dbo].[FactFinance] WITH CHECK ADD  CONSTRAINT [FK_FactFinance_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactFinance] CHECK CONSTRAINT [FK_FactFinance_DimDate]

ALTER TABLE [dbo].[FactInternetSales] WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate] FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate]

ALTER TABLE [dbo].[FactInternetSales] WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate1] FOREIGN KEY([DueDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate1]

ALTER TABLE [dbo].[FactInternetSales] WITH CHECK ADD  CONSTRAINT [FK_FactInternetSales_DimDate2] FOREIGN KEY([ShipDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactInternetSales] CHECK CONSTRAINT [FK_FactInternetSales_DimDate2]

ALTER TABLE [dbo].[FactProductInventory] WITH CHECK ADD CONSTRAINT [FK_FactProductInventory_DimDate] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactProductInventory] CHECK CONSTRAINT [FK_FactProductInventory_DimDate]

ALTER TABLE [dbo].[FactResellerSales]  WITH CHECK ADD CONSTRAINT [FK_FactResellerSales_DimDate] FOREIGN KEY([OrderDateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactResellerSales] CHECK CONSTRAINT [FK_FactResellerSales_DimDate]

ALTER TABLE [dbo].[FactSurveyResponse] WITH CHECK ADD CONSTRAINT [FK_FactSurveyResponse_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

ALTER TABLE [dbo].[FactSurveyResponse] CHECK CONSTRAINT [FK_FactSurveyResponse_DateKey]


END
