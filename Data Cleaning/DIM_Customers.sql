-- Cleaned DIM_Customers Table
SELECT c.[CustomerKey]
      --,[GeographyKey]
      --,[CustomerAlternateKey]
      --,[Title]
      ,c.[FirstName]
      --,[MiddleName]
      ,c.[LastName]
	  ,c.[FirstName] + ' ' + c.[LastName] AS FullName
      --,[NameStyle]
      --,[BirthDate]
      --,[MaritalStatus]
      --,[Suffix]
      ,CASE c.[Gender] WHEN 'M' THEN 'Male' ELSE 'Female' END AS Gender
      --,[EmailAddress]
      --,[YearlyIncome]
      --,[TotalChildren]
      --,[NumberChildrenAtHome]
      --,[EnglishEducation]
      --,[SpanishEducation]
      --,[FrenchEducation]
      --,[EnglishOccupation]
      --,[SpanishOccupation]
      --,[FrenchOccupation]
      --,[HouseOwnerFlag]
      --,[NumberCarsOwned]
      --,[AddressLine1]
      --,[AddressLine2]
      --,[Phone]
      ,c.[DateFirstPurchase]
      --,[CommuteDistance]
	  ,g.City AS [Customer City]
  FROM [AdventureWorksDW2019].[dbo].[DimCustomer] c
  LEFT JOIN [dbo].[DimGeography] g
	ON c.GeographyKey = g.GeographyKey
  ORDER BY c.CustomerKey