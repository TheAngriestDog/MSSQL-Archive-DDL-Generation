--Generates the DDL for a history table based on the table provided to it.
--Plenty of improvements could be made to this, but this provides a quick and dirty way to generate something that I need a lot
--Does not cover all of the datatypes that SQL Server supports. This will be extended as I need it.
CREATE PROCEDURE [dbo].[GenerateHistoryDDL](
	@SchemaName NVARCHAR(MAX),
	@TableName NVARCHAR(MAX),
	@DDL NVARCHAR(MAX) OUTPUT,
	@ArchiveSchema NVARCHAR(MAX) = 'Archive'
)
AS
BEGIN
	DECLARE @c_Columns CURSOR;
	DECLARE @ColumnName NVARCHAR(MAX);
	DECLARE @DataType NVARCHAR(MAX);
	DECLARE @DataLen NVARCHAR(MAX);


	SET @DDL = @DDL 
		+ 'CREATE TABLE ' + @ArchiveSchema + '.' + @TableName + 'H (' + CHAR(10)
		+ '     ' + @ArchiveSchema + 'Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,' + CHAR(10);

	EXEC GetTableColumnData @TableName, @SchemaName, @OutputCursor = @c_Columns OUTPUT;
	FETCH NEXT FROM @c_Columns INTO @ColumnName, @DataType, @DataLen
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @DDL = @DDL + '     ' + @ColumnName + ' ' + @DataType;

		IF(UPPER(@DataType) NOT IN (SELECT DataType FROM dbo.GetLengthlessDataTypes()))
		BEGIN
			SET @DDL = @DDL + '(' + CASE WHEN @DataLen = -1 THEN 'max' ELSE @DataLen END + ')';
		END;

		SET @DDL = @DDL + ',' + CHAR(10);

		FETCH NEXT FROM @c_Columns INTO @ColumnName, @DataType, @DataLen
	END
	CLOSE @c_Columns;
	DEALLOCATE @c_Columns;

	SET @DDL = @DDL
		+ '     Deleted bit not null default(0),' + CHAR(10)
		+ '     ArchiveDate datetime2 not null default(GETDATE())' + CHAR(10)

	SET @DDL = @DDL + ');' + CHAR(10);

END;