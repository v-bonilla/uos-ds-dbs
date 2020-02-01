-- Normalising to 1NF
USE [AssignmentPart1];

--Check for nulls -----------------------------------------------------------
DECLARE @null_CustomerCity VARCHAR(MAX) = (
	SELECT 
		' SELECT COUNT(*) - COUNT(' + QUOTENAME(col) + ') AS count_' + col
		+ ' FROM CustomerCity'
	FROM 
		(SELECT name as col
		from sys.columns c
		WHERE c.object_id = OBJECT_ID('dbo.CustomerCity')
		) cols
    FOR XML PATH('')
);
EXEC(@null_CustomerCity);
GO

DECLARE @null_OrderItem VARCHAR(MAX) = (
	SELECT 
		' SELECT COUNT(*) - COUNT(' + QUOTENAME(col) + ') AS count_' + col
		+ ' FROM OrderItem'
	FROM 
		(SELECT name as col
		from sys.columns c
		WHERE c.object_id = OBJECT_ID('dbo.OrderItem')
		) cols
    FOR XML PATH('')
);
EXEC(@null_OrderItem);
GO

DECLARE @null_Product VARCHAR(MAX) = (
	SELECT 
		' SELECT COUNT(*) - COUNT(' + QUOTENAME(col) + ') AS count_' + col
		+ ' FROM Product'
	FROM 
		(SELECT name as col
		from sys.columns c
		WHERE c.object_id = OBJECT_ID('dbo.Product')
		) cols
    FOR XML PATH('')
);
EXEC(@null_Product);
GO

-- Null values in Product:
-- Cup: 603
-- Size: 458
-- LegLength: 597
-- Colour: 454
-- Features: 160
-- Description: 141
-- Length: 4153
-- Material: 756
-- Washing: 4330
-- Lining: 4503
-- Age: 4466
-- Measures: 4467


-- 1NF table Product

DECLARE @blank_Product VARCHAR(MAX) = (
	SELECT 
		' UPDATE Product SET ' + QUOTENAME(col) + ' = '''''
		+ ' WHERE ' + QUOTENAME(col) + ' IS NULL'
	FROM 
		(SELECT name as col
		from sys.columns c
		WHERE c.object_id = OBJECT_ID('dbo.Product')
		) cols
    FOR XML PATH('')
);
EXEC(@blank_Product);
GO

-- Check duplicates ------------------------------------------------------------------
-- Table CustomerCity
SELECT [Id], [Gender], [FirstName], [LastName], [DateRegistered], [City], [County], [Region], [Country], COUNT(*) AS Number_of_duplicates
FROM CustomerCity
GROUP BY [Id], [Gender], [FirstName], [LastName], [DateRegistered], [City], [County], [Region], [Country]
HAVING COUNT(*) > 1;

-- Table OrderItem
SELECT [OrderItemNumber], [OrderNumber], [OrderCreateDate], [OrderStatusCode], [CustomerCityId], [BillingCurrency], [ProductGroup], [ProductCode], [VariantCode], [Quantity], [UnitPrice], [LineItemTotal], COUNT(*) AS Number_of_duplicates
FROM OrderItem
GROUP BY [OrderItemNumber], [OrderNumber], [OrderCreateDate], [OrderStatusCode], [CustomerCityId], [BillingCurrency], [ProductGroup], [ProductCode], [VariantCode], [Quantity], [UnitPrice], [LineItemTotal]
HAVING COUNT(*) > 1;

-- Table Product
SELECT [ProductGroup], [ProductCode], [VariantCode], [Name], [Cup], [Size], [LegLength], [Colour], [Price], [Features],[Description], [Length], [Material], [Washing], [Lining], [Age], [Measures], COUNT(*) AS Number_of_duplicates
FROM Product
GROUP BY [ProductGroup], [ProductCode], [VariantCode], [Name], [Cup], [Size], [LegLength], [Colour], [Price], [Features],[Description], [Length], [Material], [Washing], [Lining], [Age], [Measures]
HAVING COUNT(*) > 1;

-- Delete duplicates (There are no duplicates) ---------------------------------------------------------------------
-- Table CustomerCity
WITH duplicates AS(
   SELECT [Id], [Gender], [FirstName], [LastName], [DateRegistered], [City], [County], [Region], [Country],
       RN = ROW_NUMBER()OVER(PARTITION BY [Id], [Gender], [FirstName], [LastName], [DateRegistered], [City], [County], [Region], [Country] ORDER BY [Gender])
   FROM CustomerCity
)
select * FROM duplicates WHERE RN > 1;

-- Table OrderItem
WITH duplicates AS(
   SELECT [OrderItemNumber], [OrderNumber], [OrderCreateDate], [OrderStatusCode], [CustomerCityId], [BillingCurrency], [ProductGroup], [ProductCode], [VariantCode], [Quantity], [UnitPrice], [LineItemTotal],
       RN = ROW_NUMBER()OVER(PARTITION BY [OrderItemNumber], [OrderNumber], [OrderCreateDate], [OrderStatusCode], [CustomerCityId], [BillingCurrency], [ProductGroup], [ProductCode], [VariantCode], [Quantity], [UnitPrice], [LineItemTotal] ORDER BY [OrderNumber])
   FROM OrderItem
)
select * FROM duplicates WHERE RN > 1;

-- Table Product
WITH duplicates AS(
   SELECT [ProductGroup], [ProductCode], [VariantCode], [Name], [Cup], [Size], [LegLength], [Colour], [Price], [Features],[Description], [Length], [Material], [Washing], [Lining], [Age], [Measures],
       RN = ROW_NUMBER()OVER(PARTITION BY [ProductGroup], [ProductCode], [VariantCode], [Name], [Cup], [Size], [LegLength], [Colour], [Price], [Features],[Description], [Length], [Material], [Washing], [Lining], [Age], [Measures] ORDER BY [Name])
   FROM Product
)
select * FROM duplicates WHERE RN > 1;

-- Primary keys --------------------------------------------------------------
-- CustomerCity: Id
-- OrderItem: OrderItemNumber
-- Product: ProductGroup+VariantCode

SELECT [ProductGroup], [VariantCode], COUNT(*) AS Number_of_duplicates
FROM Product
GROUP BY [ProductGroup], [VariantCode]
HAVING COUNT(*) > 1;

-- Functional dependencies ---------------------------------------------------

DECLARE @dep_CustomerCity VARCHAR(MAX) = (
	SELECT 
		' with groups(a,b) as '
			+ '(select ' + QUOTENAME(col1) + ' as a,' + QUOTENAME(col2) + ' as b from CustomerCity group by ' + QUOTENAME(col1) + ',' + QUOTENAME(col2) + ')'
		+ ' select'
			+ ' case'
				+ ' when count(a) = count(distinct a) then ''Dependent'''
				+ ' else ''0'''
			+ ' end as ' + col1 + '_to_' + col2
		+ ' from groups;'
	FROM 
		(SELECT name as col1, col2
		from sys.columns c
		cross apply
			(SELECT c.name as col2
			FROM sys.columns c
			WHERE c.object_id = OBJECT_ID('dbo.CustomerCity')
			) cols
		WHERE c.object_id = OBJECT_ID('dbo.CustomerCity') and name <> col2
		) tuples
    FOR XML PATH('')
);
EXEC(@dep_CustomerCity);
GO

DECLARE @dep_OrderItem VARCHAR(MAX) = (
	SELECT 
		' with groups(a,b) as '
			+ '(select ' + QUOTENAME(col1) + ' as a,' + QUOTENAME(col2) + ' as b from OrderItem group by ' + QUOTENAME(col1) + ',' + QUOTENAME(col2) + ')'
		+ ' select'
			+ ' case'
				+ ' when count(a) = count(distinct a) then ''Dependent'''
				+ ' else ''0'''
			+ ' end as ' + col1 + '_to_' + col2
		+ ' from groups;'
	FROM 
		(SELECT name as col1, col2
		from sys.columns c
		cross apply
			(SELECT c.name as col2
			FROM sys.columns c
			WHERE c.object_id = OBJECT_ID('dbo.OrderItem')
			) cols
		WHERE c.object_id = OBJECT_ID('dbo.OrderItem') and name <> col2
		) tuples
    FOR XML PATH('')
);
EXEC(@dep_OrderItem);
GO

DECLARE @dep_Product VARCHAR(MAX) = (
	SELECT 
		' with groups(a,b) as '
			+ '(select ' + QUOTENAME(col1) + ' as a,' + QUOTENAME(col2) + ' as b from Product group by ' + QUOTENAME(col1) + ',' + QUOTENAME(col2) + ')'
		+ ' select'
			+ ' case'
				+ ' when count(a) = count(distinct a) then ''Dependent'''
				+ ' else ''0'''
			+ ' end as ' + col1 + '_to_' + col2
		+ ' from groups;'
	FROM 
		(SELECT name as col1, col2
		from sys.columns c
		cross apply
			(SELECT c.name as col2
			FROM sys.columns c
			WHERE c.object_id = OBJECT_ID('dbo.Product')
			) cols
		WHERE c.object_id = OBJECT_ID('dbo.Product') and name <> col2
		) tuples
    FOR XML PATH('')
);
EXEC(@dep_Product);
GO