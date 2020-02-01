USE AssignmentPart1;

SELECT * FROM Product;

-- Exploration of Features
SELECT [ProductGroup], [ProductCode], [VariantCode], [Name], Cup, Size, [LegLength], [Colour], [Features]
FROM Product
WHERE [Features] LIKE '%age%';

SELECT [ProductGroup], [ProductCode], [VariantCode], Cup, Size, [LegLength], [Colour], [Features]
FROM Product
WHERE [Features] NOT LIKE '%Leg%'
AND [Features] NOT LIKE '% Length%'
AND [Features] LIKE '%Length%';

SELECT [ProductGroup], [ProductCode], [VariantCode], Cup, Size, [LegLength], [Colour], [Features]
FROM Product
WHERE [Features] NOT LIKE '%Colour%';

SELECT [ProductGroup], [ProductCode], [VariantCode], Cup, Size, [LegLength], [Colour], [Features]
FROM Product
WHERE [Features] NOT LIKE '%Colour%'
AND [Features] NOT LIKE '%Length%';

SELECT [ProductGroup], [ProductCode], [VariantCode], Cup, Size, [LegLength], [Colour], [Features]
FROM Product
WHERE [Features] NOT LIKE '%Colour%'
AND [Features] NOT LIKE '%Length%'
AND [Features] NOT LIKE '%[0-9][%]%';

SELECT [ProductGroup], [ProductCode], [VariantCode], Cup, Size, [LegLength], [Colour], [Features]
FROM Product
WHERE [Features] NOT LIKE '%Colour%'
AND [Features] NOT LIKE '%Length%'
AND [Features] NOT LIKE '%[0-9][%]%'
AND [Features] NOT LIKE '%Size%';

SELECT [ProductGroup], [ProductCode], [VariantCode], Cup, Size, [LegLength], [Colour], [Features]
FROM Product
WHERE [Features] NOT LIKE '%Colour%'
AND [Features] NOT LIKE '%Length%'
AND [Features] NOT LIKE '%[0-9][%]%'
AND [Features] NOT LIKE '%Size%'
AND [Features] NOT LIKE '%Measure%'
AND [Features] NOT LIKE '%Age%';

SELECT distinct [ProductGroup]
FROM Product
WHERE [Features] LIKE '%age%';

-- Try to automate for different features. Better to do it one by one
DECLARE @norm VARCHAR(MAX) = (
	SELECT 
		' WITH split([ProductGroup], [ProductCode], [VariantCode], feature) AS'
		+ ' ('
		+ ' SELECT [ProductGroup], [ProductCode], [VariantCode], value as feature'
		+ ' FROM Product'
		+ ' CROSS APPLY STRING_SPLIT([Features], ''|'')'
		+ ' )'
		+ ' update Product set ' + f + ' = substring(feature, CHARINDEX('':'',feature) + 2, LEN(feature))'
		+ ' from split'
		+ ' where Product.[ProductGroup] = split.[ProductGroup]'
		+ ' and Product.[ProductCode] = split.[ProductCode]'
		+ ' and Product.[VariantCode] = split.[VariantCode]'
		+ ' and feature LIKE ''%' + f + '%'';'
	FROM 
		(
		SELECT value AS f
		FROM STRING_SPLIT('Colour,Length',',')
		) list
    FOR XML PATH('')
)
EXEC(@norm)


-- Normalisation of Features
-- Create new columns
ALTER TABLE Product ADD 
					[Length] nvarchar(255),
					[Material] nvarchar(255),
					[Washing] nvarchar(255),
					[Lining] nvarchar(255),
					[Age] nvarchar(255),
					[Measures] nvarchar(255);

SELECT * FROM Product;

-- Colour column
-- Exploration
SELECT [ProductGroup], [ProductCode], [VariantCode], [Colour], [Features]
FROM Product
where [Features] like '%Colour%'
and [Features] not like '%Colour%:%';

-- We actually don't want the set of rows the previous query return. Pattern: '%Colour%:%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Colour] = substring(feature, CHARINDEX(':',feature) + 2, LEN(feature))
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (Product.[Colour] IS NULL OR Product.[Colour] = '')
and split.feature LIKE '%Colour%:%';

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%Colour%:%';

SELECT [ProductGroup], [ProductCode], [VariantCode], [Colour], [Features]
FROM Product;

-- Trying to check if value from Colour is different to the colour in Features. The query doen't work but I've seen values confirming the hypothesis
WITH split([ProductGroup], [ProductCode], [VariantCode], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
select Product.[ProductGroup], Product.[ProductCode], Product.[VariantCode], Product.[Colour], Product.Colour_proc, Product.[Features], Product.Features_proc
from Product
inner join split on Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
where ltrim([Colour]) <> ltrim(substring(feature, CHARINDEX(':',feature) + 2, LEN(feature)))
and split.feature LIKE '%Colour%';
-----------------------------------------------------------------------------------------------------------------------

-- Leg length column
-- Exploration
SELECT [ProductGroup], [ProductCode], [VariantCode], [LegLength], [Features]
FROM Product
where ([Features] like '%Leg Length%' or [Features] like '%LegLength%')
and [Features] not like '%Leg Length%:%';

-- We actually don't want the set of rows the previous query return. Pattern: '%Leg Length%:%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [LegLength] = substring(feature, CHARINDEX(':',feature) + 2, LEN(feature))
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (Product.[LegLength] IS NULL OR Product.[LegLength] = '')
and split.feature LIKE '%Leg Length%:%';

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%Leg Length%:%';

SELECT [ProductGroup], [ProductCode], [VariantCode], [LegLength], [Features]
FROM Product;
-----------------------------------------------------------------------------------------------------------------------

-- Length column
-- Exploration
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%Length%'
and ([Features] not like '%Length%:%' and [Features] not like '%Length.%'); 
-- We actually don't want the set of rows the previous query return. Pattern: '%Length%:%' OR '%Length.%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Length] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%Length%:%' OR split.feature LIKE '%Length.%');

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%Length%:%' OR split.feature LIKE '%Length.%');

-- Solo height values to Length
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%Height%' and [Features] not like '%Height%:%' and [Features] not like '%Height [0-9]%'; 
-- We actually don't want the set of rows the previous query return. Pattern: '%Height%:%' OR '%Height [0-9]%'
-- Check if there are Lenght_proc values with this pattern. No, so NOT NEED TO CONCAT, just using update
SELECT [ProductGroup], [ProductCode], [VariantCode], [Length], [Features]
FROM Product
where [Length] is not null
and ([Features] like '%Height%:%' or [Features] like '%Height [0-9]%'); 

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Length] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%Height%:%' OR split.feature LIKE '%Height [0-9]%');

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%Height%:%' OR split.feature LIKE '%Height [0-9]%');

SELECT [ProductGroup], [ProductCode], [VariantCode], [LegLength], [Length], [Features]
FROM Product;
-----------------------------------------------------------------------------------------------------------------------

-- Material and lining special cases. This values go to both columns. EXECUTE BEFORE MATERIAL AND LINING COLUMNS
-- Exploration
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%fabric and lining%';

-- Pattern: '%fabric and lining%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product 
set [Material] = feature,
	[Lining] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%fabric and lining%';

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%fabric and lining%';
-----------------------------------------------------------------------------------------------------------------------

-- Material column
-- Exploration
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%Composition%';
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%[0-9][%]%'
and [Features] not like '%[0-9][%]%'; 
-- We actually don't want the set of rows the previous query return. Pattern: '%[0-9][%]%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Material] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (Product.[Material] IS NULL OR Product.[Material] = '')
and split.feature LIKE '%[0-9][%]%';

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%[0-9][%]%';

SELECT [ProductGroup], [ProductCode], [VariantCode], [Material], [Features]
FROM Product

-----------------------------------------------------------------------------------------------------------------------

-- Age column
-- Exploration
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%Age%'
and ([Features] not like '%Age:%' and [Features] not like '%Age f%'); 
-- We actually don't want the set of rows the previous query return. Pattern: '%Age:%' OR '%Age f%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Age] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%Age:%' or split.feature LIKE '%Age f%');

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%Age:%' or split.feature LIKE '%Age f%');

--update Product set Product.[Age] = REPLACE(Product.[Age], 'Age ', '');

SELECT [ProductGroup], [ProductCode], [VariantCode], [Age], [Features]
FROM Product where [Age] is not null;
-----------------------------------------------------------------------------------------------------------------------

-- Size column
-- Exploration of size
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%Size%'
and ([Features] not like '%Size%:%' and [Features] not like '%one size%' and ([Features] not like '%only%size%' and [Features] not like '%size%only%')); 
-- We actually don't want the set of rows the previous query return. Pattern: '%Size%:%' OR '%one size%' OR '%only%size%' OR '%size%only%'

-- First features values to Size. Second merge Cup into Size
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Size] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (Product.Size is null or Product.Size = '')
and (split.feature LIKE '%Size%:%'
	OR split.feature LIKE '%one size%'
	OR split.feature LIKE '%only%size%'
	OR split.feature LIKE '%size%only%');

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%Size%:%'
	OR split.feature LIKE '%one size%'
	OR split.feature LIKE '%only%size%'
	OR split.feature LIKE '%size%only%');

SELECT [ProductGroup], [ProductCode], [VariantCode], [Size], [Features]
FROM Product where [Size] is null;

-- Exploration of cup
SELECT distinct [Cup]
FROM Product;
-- Any null size when cup is filled? YES
select [ProductGroup], [ProductCode], [VariantCode], [Size], [Cup], [Features]
FROM Product where [Cup] is not null and [Cup] <> '' and [Size] is null;

select count([Size]), count([Cup])
FROM Product where [Cup] is not null and [Cup] <> '';

-- Merge Size and Cup into Size_proc
update Product set [Size] = CONCAT_WS(' ', [Size], [Cup])
where [Cup] is not null
and [Cup] <> ''
and [Size] is not null
and [Size] <> '';

ALTER TABLE Product DROP COLUMN [Cup];

SELECT [ProductGroup], [ProductCode], [VariantCode], [Size], [Features]
FROM Product where [Cup] is not null and [Cup] <> '';
-----------------------------------------------------------------------------------------------------------------------

-- Lining column
-- Exploration of size
SELECT [ProductGroup], [ProductCode], [VariantCode], [Lining], [Features]
FROM Product
where [Features] like '%Lining%'
and [Features] not like '%lined%'; 
-- First update values with pattern: '%lined%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Lining] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (Product.[Lining] IS NULL OR Product.[Lining] = '')
and split.feature LIKE '%lined%';

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%lined%';

--  Second concatenate values with pattern '%lining%' into Lining
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Lining] = concat_ws(' - ', [Lining], feature)
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%lining%';

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and split.feature LIKE '%lining%';

-----------------------------------------------------------------------------------------------------------------------

-- Washing column
-- Exploration
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%wash%' or [Features] like '%clean%'; 
-- We actually don't want the set of rows the previous query return. Pattern: '%wash%' OR '%clean%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Washing] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%wash%' or split.feature LIKE '%clean%');

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%wash%' or split.feature LIKE '%clean%');

SELECT [ProductGroup], [ProductCode], [VariantCode], [Washing], [Features]
FROM Product where [Washing] is not null;
-----------------------------------------------------------------------------------------------------------------------

-- Measures column
-- Exploration.... Check: (Practical Products & Storage-5222-00153551) after processing
SELECT [ProductGroup], [ProductCode], [VariantCode], [Features]
FROM Product
where [Features] like '%measure%'; 
SELECT [ProductGroup], [ProductCode], [VariantCode], [LegLength], LegLength_proc, [Length], [Features]
FROM Product
where [Features] like '%measure%' or [Features] like '%[0-9][ ]x[ ][0-9]%' or [Features] like '%[0-9]x[0-9]%';
-- We actually don't want the set of rows the previous query return. Pattern: '%measure%' OR '%[0-9][ ]x[ ][0-9]%' OR '%[0-9]x[0-9]%'
WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set [Measures] = feature
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%measure%' or split.feature LIKE '%[0-9][ ]x[ ][0-9]%' or split.feature LIKE '%[0-9]x[0-9]%');

WITH split([ProductGroup], [ProductCode], [VariantCode], [Features], feature)
AS
(
	SELECT [ProductGroup], [ProductCode], [VariantCode], [Features], value as feature
	FROM Product  
		CROSS APPLY STRING_SPLIT([Features], '|')
)
update Product set Product.[Features] = REPLACE(Product.[Features], feature, '')
from split
where Product.[ProductGroup] = split.[ProductGroup]
and Product.[ProductCode] = split.[ProductCode]
and Product.[VariantCode] = split.[VariantCode]
and (split.feature LIKE '%measure%' or split.feature LIKE '%[0-9][ ]x[ ][0-9]%' or split.feature LIKE '%[0-9]x[0-9]%');

SELECT [ProductGroup], [ProductCode], [VariantCode], [Measures], [Features]
FROM Product;
-----------------------------------------------------------------------------------------------------------------------

-- Conservative clean of '|' character 
update Product set [Features] = REPLACE([Features], '|', '')
where len([Features]) <= 3;
-- Conservative clean of middle '|' characters
update Product set [Features] = REPLACE([Features], '||||', '|');
update Product set [Features] = REPLACE([Features], '|||', '|');
update Product set [Features] = REPLACE([Features], '||', '|');
-- Remove character '|' if at the beginning or end
update Product set [Features] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Features],' ','~'),'|',' ')),' ','|'),'~',' ');

-- Trim and lowcase all processed columns
update Product set [Features] = TRIM(LOWER([Features])),
	[Colour] = TRIM(LOWER([Colour])),
	[LegLength] = TRIM(LOWER([LegLength])),
	[Length] = TRIM(LOWER([Length])),
	[Material] = TRIM(LOWER([Material])),
	[Washing] = TRIM(LOWER([Washing])),
	[Size] = TRIM(LOWER([Size])),
	[Lining] = TRIM(LOWER([Lining])),
	[Age] = TRIM(LOWER([Age])),
	[Measures] = TRIM(LOWER([Measures]));

-- Remove dots: trim all columns
update Product set [Features] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Features],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Colour] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Colour],' ','~'),'.',' ')),' ','.'),'~',' '),
	[LegLength] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([LegLength],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Length] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Length],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Material] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Material],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Washing] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Washing],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Size] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Size],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Lining] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Lining],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Age] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Age],' ','~'),'.',' ')),' ','.'),'~',' '),
	[Measures] = REPLACE(REPLACE(TRIM(REPLACE(REPLACE([Measures],' ','~'),'.',' ')),' ','.'),'~',' ');

-- Remove dots: trim all columns and replace '. |' by ' |' only Features column
update Product set [Features] = REPLACE([Features], '. |', ' |');

select distinct [Features] from Product; -- There are many features different just by capital letters or dots or spaces.

-- Check normalisation result
SELECT  [ProductCode],[Features]
FROM Product 
where [Features] <> '' and [Features] is not null
group by [ProductCode], [Features];

-- Check '|' characters in any processed column <> Features_proc
select [Features],
	[Colour],
	[LegLength],
	[Length],
	[Material],
	[Washing],
	[Size],
	[Lining],
	[Age],
	[Measures]
from Product
where [Colour] like '%|%' or
	[LegLength] like '%|%' or
	[Length] like '%|%' or
	[Material] like '%|%' or
	[Washing] like '%|%' or
	[Size] like '%|%' or
	[Lining] like '%|%' or
	[Age] like '%|%' or
	[Measures] like '%|%';
-- None, all good

SELECT COUNT([Features])
FROM Product
WHERE [Features] IS NOT NULL AND [Features] <> '';

-- Afer splitting features, there are still 612 values which are too characteristic to find a pattern

SELECT * FROM Product;