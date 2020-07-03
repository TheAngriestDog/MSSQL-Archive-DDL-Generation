CREATE FUNCTION [dbo].[GenerateHistoryDDLUpdate]
(
	@SchemaName NVARCHAR(MAX),
	@TableName NVARCHAR(MAX),
	@ArchiveSchema NVARCHAR(MAX) = 'Archive'
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE c_Columns CURSOR FOR
		SELECT 
			COLUMN_NAME,
			DATA_TYPE,
			CHARACTER_MAXIMUM_LENGTH
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @TableName
			AND TABLE_SCHEMA = @SchemaName
			AND COLUMN_NAME NOT IN (
				SELECT
					COLUMN_NAME
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = @TableName + 'H'
					AND TABLE_SCHEMA = @ArchiveSchema
			)
		ORDER BY ORDINAL_POSITION
	;
	DECLARE @DDL NVARCHAR(MAX) = '';

	DECLARE @ColumnName NVARCHAR(MAX);
	DECLARE @DataType NVARCHAR(MAX);
	DECLARE @DataLen NVARCHAR(MAX);

	OPEN c_Columns
	FETCH FROM c_Columns INTO @ColumnName, @DataType, @DataLen
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF(UPPER(@DataType) NOT IN (SELECT DataType FROM dbo.GetLengthlessDataTypes()))
		BEGIN
			SET @DDL = @DDL + 'ALTER TABLE ' + @ArchiveSchema + '.' + @TableName + 'H ADD ' + @ColumnName + ' ' + @DataType + ' (' + @DataLen + ');' + CHAR(10) + CHAR(13);
		END
		ELSE
		BEGIN
			SET @DDL = @DDL + 'ALTER TABLE ' + @ArchiveSchema + '.' + @TableName + 'H ADD ' + @ColumnName + ' ' + @DataType + ';' + CHAR(10) + CHAR(13);
		END

		FETCH NEXT FROM c_Columns INTO @ColumnName, @DataType, @DataLen
	END;

	RETURN @DDL;
END;