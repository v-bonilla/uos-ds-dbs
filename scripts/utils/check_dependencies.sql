use AssignmentPart1;

DECLARE @dep_CustomerCity VARCHAR(MAX) = (
	SELECT 
		' with groups(a,b) as '
			+ '(select ' + QUOTENAME(col1) + ' as a,' + QUOTENAME(col2) + ' as b from CustomerCity group by ' + QUOTENAME(col1) + ',' + QUOTENAME(col2) + ')'
		+ ' select'
			+ ' case'
				+ ' when count(a) = count(distinct a) then ''Dependent'''
				+ ' else ''Not dependent'''
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
GO;

DECLARE @dep_OrderItem VARCHAR(MAX) = (
	SELECT 
		' with groups(a,b) as '
			+ '(select ' + QUOTENAME(col1) + ' as a,' + QUOTENAME(col2) + ' as b from OrderItem group by ' + QUOTENAME(col1) + ',' + QUOTENAME(col2) + ')'
		+ ' select'
			+ ' case'
				+ ' when count(a) = count(distinct a) then ''Dependent'''
				+ ' else ''Not dependent'''
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
GO;

DECLARE @dep_Product VARCHAR(MAX) = (
	SELECT 
		' with groups(a,b) as '
			+ '(select ' + QUOTENAME(col1) + ' as a,' + QUOTENAME(col2) + ' as b from Product group by ' + QUOTENAME(col1) + ',' + QUOTENAME(col2) + ')'
		+ ' select'
			+ ' case'
				+ ' when count(a) = count(distinct a) then ''Dependent'''
				+ ' else ''Not dependent'''
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
GO;