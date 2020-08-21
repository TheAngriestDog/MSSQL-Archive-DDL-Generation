CREATE PROCEDURE [dbo].[BigPrint]
	@Varchar		NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Count INT = 0;
	DECLARE @TotalPrints INT = CEILING(LEN(@varchar) / 4000) + 1;
	DECLARE @Pos INT = 0;
	DECLARE @SubStringLen INT;

	WHILE @Count < @TotalPrints
	BEGIN
		SET @SubStringLen = 4000 - CHARINDEX(CHAR(10), REVERSE(SUBSTRING(@Varchar, @Pos, 4000)));
		PRINT SUBSTRING(@Varchar, @Pos, @SubStringLen);
		SET @Count = @Count + 1;
		SET @Pos = @Pos + @SubStringLen + 2;
	END;
END
