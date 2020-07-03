CREATE PROCEDURE [dbo].[GenerateHistoryTriggerDDL]
	@SchemaName NVARCHAR(MAX),
	@TableName NVARCHAR(MAX),
	@DDL NVARCHAR(MAX) OUTPUT,
	@ArchiveSchema NVARCHAR(MAX) = 'Archive'
AS
BEGIN
	DECLARE @c_Columns CURSOR;
	DECLARE @ColumnName NVARCHAR(MAX);
	DECLARE @DataType NVARCHAR(MAX);
	DECLARE @DataLen NVARCHAR(MAX);
	DECLARE @ColumnsToPopulate NVARCHAR(MAX) = '';
	
	EXEC GetTableColumnData @TableName, @SchemaName, @OutputCursor = @c_Columns OUTPUT;
	FETCH NEXT FROM @c_Columns INTO @ColumnName, @DataType, @DataLen;
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @ColumnsToPopulate = @ColumnsToPopulate + @ColumnName + ', ';


		FETCH NEXT FROM @c_Columns INTO @ColumnName, @DataType, @DataLen;
	END;
	CLOSE @c_Columns;
	DEALLOCATE @c_Columns;

	SET @ColumnsToPopulate = @ColumnsToPopulate + 'Deleted, ArchiveDate';

	SET @DDL = @DDL 
		+ 'CREATE TRIGGER ' + @SchemaName + '.Archive' + @TableName + CHAR(10)
		+ 'ON ' + @SchemaName + '.' + @TableName + CHAR(10)
		+ 'FOR INSERT, UPDATE, DELETE' + CHAR(10)
		+ 'AS' + CHAR(10)
		+ 'BEGIN' + CHAR(10)
	;

	SET @DDL = @DDL 
		+ '     SET NOCOUNT ON' + CHAR(10) + CHAR(10)
		+ '     IF (NOT EXISTS(SELECT 1 FROM deleted))' + CHAR(10)
		+ '     BEGIN' + CHAR(10)
		+ '          INSERT INTO ' + @ArchiveSchema + '.' + @TableName + 'H (' + @ColumnsToPopulate + ')' + CHAR(10)
		+ '               SELECT *, 0, GETDATE() FROM inserted' + CHAR(10)
		+ '     END' + CHAR(10)
		+ '     ELSE IF(NOT EXISTS(SELECT 1 FROM inserted))' + CHAR(10)
		+ '     BEGIN' + CHAR(10)
		+ '          INSERT INTO ' + @ArchiveSchema + '.' + @TableName + 'H (' + @ColumnsToPopulate + ')' + CHAR(10) 
		+ '               SELECT *, 1, GETDATE() FROM deleted' + CHAR(10)
		+ '     END' + CHAR(10)
		+ '     ELSE' + CHAR(10)
		+ '     BEGIN' + CHAR(10)
		+ '          INSERT INTO ' + @ArchiveSchema + '.' + @TableName + 'H (' + @ColumnsToPopulate + ')' + CHAR(10)
		+ '               SELECT *, 0, GETDATE() FROM deleted' + CHAR(10)
		+ '     END' + CHAR(10)
	;

	SET @DDL = @DDL + 'END;' + CHAR(10);

END
