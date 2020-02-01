create database Test;
go
use Test;
go

drop table if exists test1;
create table test1 (id int, a int, b int, c varchar(255));
go
insert into test1 values 
(1,1,2,'80% polyamide, 20% Lycra.'), 
(2,1,2,'Colours: Black, Red. | 100% cotton.'), 
(3,1,2,'Colour: 3 | 90% cotton, 10% silk'), 
(4,3,4,'Length: 35&quot;/89cm. | Colour: Khaki. | 100% polyester.'), 
(5,3,4,'Colour: 5 | 5 x 25 | Pack of two'), 
(6,1,2,'Colour: 6 | 15 x 5 cm | Navy only 19.99!'), 
(7,1,2,'Colour: 7 | Lining: good shit | 45 x 335 | Partial lined'), 
(8,5,6,'Length: 35&quot;/89cm. | Colour: Grey/Pale Blue. | 92% polyamide, 8% elastane.'), 
(9,7,6,'Colour: Chocolate. | Dry clean.');
go

select * from test1;
go

-- Check partial or transitive dependency
with groups(a,b)
as 
(select a,b from test1 group by a,b)
select 
	case 
		when count(a) = count(distinct a) then 'Dependent'
		else 'Not dependent'
	end
from groups;
go

DECLARE @sql VARCHAR(MAX) = (
	SELECT 'select ' 
		+ QUOTENAME(c.name) 
		+ ' from [test1] group by ' 
		+ QUOTENAME(c.name)
	FROM sys.columns c
	WHERE c.object_id = OBJECT_ID('dbo.test1')
    FOR XML PATH('')
)
EXEC(@sql);

SELECT name as col1, col2
from sys.columns c
cross apply
	(SELECT c.name as col2
	FROM sys.columns c
	WHERE c.object_id = OBJECT_ID('dbo.test1')
	) cols
WHERE c.object_id = OBJECT_ID('dbo.test1') and name <> col2;


DECLARE @dep VARCHAR(MAX) = (
	SELECT 
		' with groups(a,b) as '
			+ '(select ' + QUOTENAME(col1) + ' as a,' + QUOTENAME(col2) + ' as b from test1 group by ' + QUOTENAME(col1) + ',' + QUOTENAME(col2) + ')'
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
			WHERE c.object_id = OBJECT_ID('dbo.test1')
			) cols
		WHERE c.object_id = OBJECT_ID('dbo.test1') and name <> col2
		) tuples
    FOR XML PATH('')
)
EXEC(@dep)

-- Normalise column c
ALTER TABLE test1 ADD colour varchar(255), length varchar(255), material varchar(255);
select * from test1;

WITH split(id, c,feature)
AS
(
	SELECT id, c, value as feature
	FROM test1  
		CROSS APPLY STRING_SPLIT(c, '|')
)
update test1 set colour = substring(feature, CHARINDEX(':',feature) + 2, LEN(feature)) 
from split
where test1.id = split.id
and feature LIKE '%Colour%';
