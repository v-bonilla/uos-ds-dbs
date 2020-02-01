use mumsnet;
select * from [order] where o_number = 'o_aaa'
select * from order_item where oi_number = 'oi_aaa'
select * from customer where cus_id = 111111
select * from item where i_variant_code = '00028142'

-- prCreateOrderGroup tests
-- Customer doesn't exist -> ERROR
declare @time datetime
set @time = (select CURRENT_TIMESTAMP)
exec dbo.prCreateOrderGroup 'o_aaa', @time, 111111
-- Customer and order already exists -> ERROR
declare @time datetime
set @time = (select CURRENT_TIMESTAMP)
exec dbo.prCreateOrderGroup 'OR\01012005\01', @time, 1
-- Customer already exists but order doesn't -> SUCCESS
declare @time datetime
set @time = (select CURRENT_TIMESTAMP)
exec dbo.prCreateOrderGroup 'o_aaa', @time, 1

select * from [order] where o_number = 'o_aaa'

-- prCreateOrderItem tests
declare @time datetime
set @time = (select CURRENT_TIMESTAMP)
exec dbo.prCreateOrderGroup 'o_aaa', @time, 1
-- Item doesn't exist -> ERROR
exec dbo.prCreateOrderItem 'o_aaa', 'oi_aaa', 'Li', '00022', 2, 3
-- Item and order item already exists -> ERROR
exec dbo.prCreateOrderItem 'o_aaa', 'OR\01012005\01\1', 'Lingerie', '00028142', 2, 3
-- Customer already exists but product doesn't -> SUCCESS
exec dbo.prCreateOrderItem 'o_aaa', 'oi_aaa', 'Lingerie', '00028142', 2, 3
exec dbo.prCreateOrderItem 'o_aaa', 'oi_aaaa', 'Lingerie', '00028142', 2, 3

select * from [order] where o_number = 'o_aaa'
select * from order_item where oi_order_number = 'o_aaa'

-- 1st create order 2nd create order item -> SUCCESS
declare @time datetime
set @time = (select CURRENT_TIMESTAMP)
exec dbo.prCreateOrderGroup 'o_aaa', @time, 1
exec dbo.prCreateOrderItem 'o_aaa', 'oi_aaa', 'Lingerie', '00028142', 2, 3

select * from [order] where o_number = 'o_aaa'
select * from order_item where oi_number = 'oi_aaa'

-- 1st create order item 2nd create order -> ERROR
declare @time datetime
set @time = (select CURRENT_TIMESTAMP)
exec dbo.prCreateOrderItem 'o_bbb', 'oi_bbb', 'Lingerie', '00028142', 3, 4.5
exec dbo.prCreateOrderGroup 'o_bbb', @time, 1

select * from [order] where o_number = 'o_bbb'
select * from order_item where oi_number = 'oi_bbb'

-- Clean
DELETE FROM [dbo].[order_item] WHERE oi_order_number = 'o_aaa'
DELETE FROM [dbo].[order] WHERE o_number = 'o_aaa'
