-- Deliverable 1: Implement Order Group (in our tables is 'order') and the stored procedures
-- Execute with database mumsnet_no_OG_vX restored or after executing 3NF_vX script
USE mumsnet;
GO

-- Create Order Group entity modifying 'order' table. It will be our Order Group entity
-- We just have to add the new columns: TotalLineItems and SavedTotal
ALTER TABLE [order] ADD
	o_total_line_items INT NOT NULL DEFAULT 0,
	o_saved_total MONEY NOT NULL DEFAULT 0;
GO

WITH new_cols(oi_order_number, total_line_items, saved_total)
AS
(
	SELECT
		oi_order_number,
		sum(oi_quantity) as total_line_items, 
		sum(oi_line_item_total) as saved_total
	FROM order_item
	GROUP BY oi_order_number
)
UPDATE [order] SET 
	o_total_line_items = total_line_items,
	o_saved_total = saved_total
FROM new_cols
WHERE new_cols.oi_order_number = [order].o_number;
GO


-- Stored procedures -------------------------------------------------------------------------------

CREATE PROCEDURE prCreateOrderGroup
	@order_number NVARCHAR(50),
	@order_create_date DATETIME,
	@order_customer_id BIGINT
	AS

	DECLARE @ErrorNumber INT;
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorState INT;

	BEGIN TRY
		BEGIN TRANSACTION t_prCreateOrderGroup WITH MARK N'Transaction from the stored procedure prCreateOrderGroup
		to create an OrderGroup in table order';

		IF EXISTS (
			SELECT cus_id
			FROM customer 
			WHERE cus_id = @order_customer_id
		)
		BEGIN
			IF NOT EXISTS (
				SELECT o_number
				FROM [order] 
				WHERE o_number = @order_number
			)
			BEGIN
				INSERT INTO [order]
				(o_number, o_create_date, o_status_code, o_customer_id, o_billing_currency)
				VALUES (@order_number, @order_create_date, 0, @order_customer_id, 'GBP');
			END;
			-- No update o_total_line_item or o_saved_total because to create an order item 
			-- there must be an order group created to satisfy fk_order_item_to_order
			ELSE
			BEGIN
				SET @ErrorNumber = 50002;
				SET @ErrorMessage = N'The order ' + @order_number + N' already exists in the system.';
				SET @ErrorState = 1;
				THROW @ErrorNumber, @ErrorMessage, @ErrorState;
			END;
		END;
		ELSE
		BEGIN
			SET @ErrorNumber = 50001;
			SET @ErrorMessage = N'The customer ' + CAST(@order_customer_id AS VARCHAR(10)) + N' does not exist in the system.';
			SET @ErrorState = 1;
			THROW @ErrorNumber, @ErrorMessage, @ErrorState;
		END;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;  
		THROW; 
	END CATCH;
GO

CREATE PROCEDURE prCreateOrderItem
	@order_number nvarchar(50),
	@order_item_number nvarchar(32),
	@product_group nvarchar(128),
	@variant_code nvarchar(255),
	@quantity int,
	@unit_price money
	AS

	DECLARE @ErrorNumber INT;
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorState INT;

	BEGIN TRY
		BEGIN TRANSACTION t_prCreateOrderItem WITH MARK N'Transaction from the stored procedure prCreateOrderItem
		to create an OrderItem in table order_item and to update the related OrderGroup in the table order';

		IF EXISTS (
			SELECT i_variant_code, i_product_group
			FROM item
			WHERE i_variant_code = @variant_code AND i_product_group = @product_group
		)
		BEGIN
			IF NOT EXISTS (
				SELECT oi_number
				FROM order_item
				WHERE oi_number = @order_item_number
			)
			BEGIN
				INSERT INTO order_item
				(oi_number, oi_variant_code, oi_product_group, oi_quantity, oi_line_item_total, oi_order_number)
				VALUES (@order_item_number, @variant_code, @product_group, @quantity, @quantity * @unit_price, @order_number);
				-- No check if exists o_number in table order because to create an order item 
				-- there must be an order group created to satisfy fk_order_item_to_order
				UPDATE [order] SET
					o_total_line_items = o_total_line_items + @quantity,
					o_saved_total = o_saved_total + (@quantity * @unit_price)
				WHERE o_number = @order_number;
			END;
			ELSE
			BEGIN
				SET @ErrorNumber = 50004;
				SET @ErrorMessage = N'The order item ' + @order_item_number + N' already exists in the system.';
				SET @ErrorState = 1;
				THROW @ErrorNumber, @ErrorMessage, @ErrorState;
			END;
		END;
		ELSE
		BEGIN
			SET @ErrorNumber = 50003;
			SET @ErrorMessage = N'The item with VC: ' + @variant_code + N' and PG: ' + @product_group + N' does not exist in the system.';
			SET @ErrorState = 1;
			THROW @ErrorNumber, @ErrorMessage, @ErrorState;
		END;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;  
		THROW;
	END CATCH;
GO
