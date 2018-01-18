
/*
SELECT dbo.ufnCalcularMora(7,5)
*/

CREATE FUNCTION [dbo].[ufnCalcularMora] ( @ImporteMoratorio DECIMAL(16,4) , @DiasAtrazo INT, @DiasGracia INT)
RETURNS DECIMAL(16,2)
AS 
    BEGIN
	    IF @DiasAtrazo <=0
			RETURN 0
        IF @DiasAtrazo <=@DiasGracia
			RETURN 0
        
		RETURN @ImporteMoratorio * @DiasAtrazo
    END
