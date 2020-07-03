CREATE PROCEDURE [dbo].[GenerateTableType](
	@SchemaName NVARCHAR(MAX),
	@TableName NVARCHAR(MAX),
	@DDL NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	DECLARE @c_Columns CURSOR;
	DECLARE @ColumnName NVARCHAR(MAX);
	DECLARE @DataType NVARCHAR(MAX);
	DECLARE @DataLen NVARCHAR(MAX);


	SET @DDL = @DDL + 'CREATE TYPE ' + @SchemaName + '.' + @TableName + 'Type AS TABLE(' + CHAR(10);

	EXEC GetTableColumnData @TableName, @SchemaName, @OutputCursor = @c_Columns OUTPUT;
	FETCH NEXT FROM @c_Columns INTO @ColumnName, @DataType, @DataLen
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		SET @DDL = @DDL + '     ' + @ColumnName + ' ' + @DataType;

		IF(UPPER(@DataType) NOT IN (SELECT DataType FROM dbo.GetLengthlessDataTypes()))
		BEGIN
			SET @DDL = @DDL + '(' + CASE WHEN @DataLen = -1 THEN 'max' ELSE @DataLen END + ')';
		END;

		FETCH NEXT FROM @c_Columns INTO @ColumnName, @DataType, @DataLen
		IF(@@FETCH_STATUS = 0)
			SET @DDL = @DDL + ',';

		SET @DDL = @DDL + CHAR(10);
	END;
	CLOSE @c_Columns;
	DEALLOCATE @c_Columns;

	SET @DDL = @DDL + ');' + CHAR(10)

END;
