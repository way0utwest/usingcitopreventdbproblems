/*
USING CI AND TESTING TO PREVENT DATABASE PROBLEMS

Hueristics Checking
*/
CREATE FUNCTION dbo.UF_CalcBonusForArticles ( @Qty INT )
RETURNS NUMERIC(10 ,3)
AS
    BEGIN
        DECLARE @i NUMERIC(10,3);

        SELECT  @i = CASE WHEN ( @Qty > 5 ) THEN 0.1
                          WHEN ( @Qty > 10 ) AND (@Qty < 20)
                               THEN 0.20
                          ELSE 0.0
                     END

        RETURN @i
    END

GO


-- We have a function for bonuses, UF_CalcBonusForArticles
-- Right now we have bonuses of 5% and 10% based on quantity. However no one has ever written > 100.
-- Management wants to boost writing with new bonuses. The rules are:
--    Qty more than 5 and less than 10 = 10% bonus
--    Qty more than 10 = 20%
--    Qty more than 20 = 30%



-- examine the function.
SELECT dbo.UF_CalcBonusForArticles(7);
go

EXEC tsqlt.NewTestClass
  @ClassName = N'tSalesOrderDetail';
  GO


-- we could do this. Look at these 3 tests.
CREATE PROCEDURE [tSalesOrderDetail].[test Check Bonus Calculation for qty 4 = 0%]
AS
    BEGIN
  -- Assemble
        DECLARE @expected NUMERIC(10 ,3) = 0.00
          , @actual NUMERIC(10 ,3);

  -- act
        SELECT  @actual = dbo.UF_CalcBonusForArticles(4);
  -- assert    
        EXEC tSQLt.AssertEquals @Expected = @expected ,@Actual = @actual ,
            @Message = N'An incorrect discount calculation occurred.';
  
    END;
GO

CREATE PROCEDURE [tSalesOrderDetail].[test Check Bonus Calculation for qty 5 = 10%]
AS
    BEGIN
  -- Assemble
        DECLARE @expected NUMERIC(10 ,3) = 0.1
          , @actual NUMERIC(10 ,3);

  -- act
        SELECT  @actual = dbo.UF_CalcBonusForArticles(4);
  -- assert    
        EXEC tSQLt.AssertEquals @Expected = @expected ,@Actual = @actual ,
            @Message = N'An incorrect discount calculation occurred.'
  
    END
GO

CREATE PROCEDURE [tSalesOrderDetail].[test Check Bonus Calculation for qty 10 = 20%]
AS
    BEGIN
  -- Assemble
        DECLARE @expected NUMERIC(10 ,3) = 0.2
          , @actual NUMERIC(10 ,3);

  -- act
        SELECT  @actual = dbo.UF_CalcBonusForArticles(10);
  -- assert    
        EXEC tSQLt.AssertEquals @Expected = @expected ,@Actual = @actual ,
            @Message = N'An incorrect discount calculation occurred.'
  
    END
GO


-- We could continue to write other tests for different values and boudaries.
-- However that's confusing and it results in a lot of tests for simple rules. 
-- Let's simplify.
CREATE PROCEDURE [tSalesOrderDetail].[test Check Bonus Calculation for qty rules]
AS
    BEGIN
  -- Assemble
  CREATE table #expected (qty INT, discount NUMERIC(10 ,3));

  INSERT #expected
          ( qty ,discount )
  VALUES  ( 4 ,0.0 )
        , ( 5 ,0.1 )
        , ( 9 ,0.1 )
        , ( 10 ,0.2 )
        , ( 19 ,0.2 )
        , ( 20 ,0.3 )

  SELECT TOP(0) *
   INTO #actual
   FROM #expected

  -- act
  INSERT #actual SELECT 4, dbo.UF_CalcBonusForArticles(4);
  INSERT #actual SELECT 5, dbo.UF_CalcBonusForArticles(5);
  INSERT #actual SELECT 9, dbo.UF_CalcBonusForArticles(9);
  INSERT #actual SELECT 10, dbo.UF_CalcBonusForArticles(10);
  INSERT #actual SELECT 19, dbo.UF_CalcBonusForArticles(19);
  INSERT #actual SELECT 20, dbo.UF_CalcBonusForArticles(20);

 -- assert    
        EXEC tSQLt.AssertEqualsTable @Expected = N'#expected' ,@Actual = N'#actual' ,@FailMsg = N'The discount calculations are incorrect'
  
    END
GO


EXEC tsqlt.run '[tSalesOrderDetail].[test Check Bonus Calculation for qty rules]';
GO










-- Let's refactor the procedure
-- Set the boundaries carefully
-- look at results
ALTER FUNCTION dbo.UF_CalcBonusForArticles ( @Qty INT )
RETURNS NUMERIC(10 ,3)
/*
-- Test Code
EXEC tsqlt.run '[tSalesOrderDetail].[test Check Bonus Calculation for qty rules]';

*/
AS
    BEGIN
        DECLARE @i NUMERIC(10,3);

        SELECT  @i = CASE WHEN ( @Qty >= 5 ) AND (@Qty < 10)
								THEN 0.1
                          WHEN ( @Qty >= 10 ) AND (@Qty < 20)
                               THEN 0.2
                          WHEN ( @Qty >= 20 ) 
                               THEN 0.3
                          ELSE 0.0
                     END

        RETURN @i
    END

GO


-- retest
EXEC tsqlt.run '[tSalesOrderDetail].[test Check Bonus Calculation for qty rules]';
GO


-- We want CI to catch the issues
-- Let's refactor and see if CI catches this.
ALTER FUNCTION dbo.UF_CalcBonusForArticles ( @Qty INT )
RETURNS NUMERIC(10 ,3)
/*
-- Test Code
EXEC tsqlt.run '[tSalesOrderDetail].[test Check Bonus Calculation for qty rules]';

*/
AS
    BEGIN
        DECLARE @i NUMERIC(10,3);

        SELECT  @i = CASE WHEN ( @Qty >= 5 ) AND (@Qty < 10)
								THEN 0.1
                          WHEN ( @Qty >= 10 ) AND (@Qty < 20)
                               THEN 0.2
                          WHEN ( @Qty >= 20 ) AND (@Qty < 50)
                               THEN 0.3
                          WHEN ( @Qty >= 50 ) 
                               THEN 0.40
                          ELSE 0.0
                     END

        RETURN @i
    END

GO
select dbo.UF_CalcBonusForArticles(51) AS Bonus
GO

-- commit to CI

-- run this in integration
-- select dbo.UF_CalcBonusForArticles(51)
-- isn't correct


-- need to update test

ALTER PROCEDURE [tSalesOrderDetail].[test Check Bonus Calculation for qty rules]
AS
    BEGIN
  -- Assemble
  CREATE table #expected (qty INT, discount NUMERIC(10 ,3));

  INSERT #expected
          ( qty ,discount )
  VALUES  ( 4 ,0.0 )
        , ( 5 ,0.1 )
        , ( 9 ,0.1 )
        , ( 10 ,0.2 )
        , ( 19 ,0.2 )
        , ( 20 ,0.3 )
        , ( 50 ,0.4 )

  SELECT TOP(0) *
   INTO #actual
   FROM #expected

  -- act
  INSERT #actual SELECT 4, dbo.UF_CalcBonusForArticles(4);
  INSERT #actual SELECT 5, dbo.UF_CalcBonusForArticles(5);
  INSERT #actual SELECT 9, dbo.UF_CalcBonusForArticles(9);
  INSERT #actual SELECT 10, dbo.UF_CalcBonusForArticles(10);
  INSERT #actual SELECT 19, dbo.UF_CalcBonusForArticles(19);
  INSERT #actual SELECT 20, dbo.UF_CalcBonusForArticles(20);
  INSERT #actual SELECT 50, dbo.UF_CalcBonusForArticles(50);

 -- assert    
        EXEC tSQLt.AssertEqualsTable @Expected = N'#expected' ,@Actual = N'#actual' ,@FailMsg = N'The discount calculations are incorrect'
  
    END
GO
