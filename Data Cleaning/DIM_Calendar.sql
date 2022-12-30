-- Cleaned DIM_Date Table
SELECT 
  [DateKey], 
  [FullDateAlternateKey] AS Date,
  --,[DayNumberOfWeek]
  [EnglishDayNameOfWeek] AS Day,
  --,[SpanishDayNameOfWeek]
  --,[FrenchDayNameOfWeek]
  --,[DayNumberOfMonth]
  --,[DayNumberOfYear], 
  [WeekNumberOfYear] AS WeekNo, 
  LEFT([EnglishMonthName], 3) AS MonthShort, 
  --,[SpanishMonthName]
  --,[FrenchMonthName] 
  [MonthNumberOfYear] AS MonthNo, 
  [CalendarQuarter] AS Quarter, 
  [CalendarYear] AS Year
  --,[CalendarSemester]
  --,[FiscalQuarter]
  --,[FiscalYear]
  --,[FiscalSemester]
FROM [AdventureWorksDW2019].[dbo].[DimDate]
WHERE [CalendarYear] >= 2020
