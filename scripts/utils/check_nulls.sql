USE AssignmentPart1;

-- Check for null or blank (empty string) values in a column
SELECT COUNT(Id)
FROM CustomerCity
WHERE Id IS NULL or Id = '';

DECLARE @null_CustomerCity VARCHAR(MAX) = (
	SELECT 
		' SELECT COUNT(' + QUOTENAME(col) + ') AS count_' + col
		+ ' FROM CustomerCity'
		+ ' WHERE ' + QUOTENAME(col) + ' IS NULL'
	FROM 
		(SELECT name as col
		from sys.columns c
		WHERE c.object_id = OBJECT_ID('dbo.CustomerCity')
		) cols
    FOR XML PATH('')
);
EXEC(@null_CustomerCity);
GO;

DECLARE @null_OrderItem VARCHAR(MAX) = (
	SELECT 
		' SELECT COUNT(' + QUOTENAME(col) + ') AS count_' + col
		+ ' FROM OrderItem'
		+ ' WHERE ' + QUOTENAME(col) + ' IS NULL'
	FROM 
		(SELECT name as col
		from sys.columns c
		WHERE c.object_id = OBJECT_ID('dbo.OrderItem')
		) cols
    FOR XML PATH('')
);
EXEC(@null_OrderItem);
GO;

DECLARE @null_Product VARCHAR(MAX) = (
	SELECT 
		' SELECT COUNT(' + QUOTENAME(col) + ') AS count_' + col
		+ ' FROM Product'
		+ ' WHERE ' + QUOTENAME(col) + ' IS NULL'
	FROM 
		(SELECT name as col
		from sys.columns c
		WHERE c.object_id = OBJECT_ID('dbo.Product')
		) cols
    FOR XML PATH('')
);
EXEC(@null_Product);
GO;