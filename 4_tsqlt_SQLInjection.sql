/*
USING CI AND TESTING TO PREVENT DATABASE PROBLEMS

Create a procedure with a security issue. This is a SQL Injection problem (potentially)
*/
CREATE PROCEDURE SearchArticles
	@SearchTerm VARCHAR(100)
AS
BEGIN
  DECLARE @sql VARCHAR(MAX) = 'SELECT ArticlesID FROM dbo.Articles WHERE Article LIKE ''%' + @SearchTerm + '%'''
  EXEC(@sql)
RETURN
END
GO

-- commit and test
EXEC dbo.SearchArticles 'outage'
go
SELECT top 10
 Article
 FROM dbo.Articles WHERE ArticlesID = 1
go 
-- CI works







-- However, that's an issue

/*-----------------------------------------------------------------------------------

    DO NOT Run

-- EXEC dbo.SearchArticles 'outage; shutdown'
-- EXEC dbo.SearchArticles 'outage; drop table demo'
-----------------------------------------------------------------------------------*/







-- add a test
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SQLCop].[test Procedures using dynamic SQL without sp_executesql]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SQLCop].[test Procedures using dynamic SQL without sp_executesql]
GO

CREATE PROCEDURE [SQLCop].[test Procedures using dynamic SQL without sp_executesql]
AS
BEGIN
    -- Written by George Mastros
    -- February 25, 2012

    SET NOCOUNT ON

    Declare @Output VarChar(max)
    Set @Output = ''

    SELECT  @Output = @Output + SCHEMA_NAME(so.uid) + '.' + so.name + Char(13) + Char(10)
    From    sys.sql_modules sm
            Inner Join sys.sysobjects so
                On  sm.object_id = so.id
                And so.type = 'P'
    Where   so.uid <> Schema_Id('tSQLt')
            And so.uid <> Schema_Id('SQLCop')
            And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%Exec(%'
            And Replace(sm.definition, ' ', '') COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Not Like '%sp_Executesql%'
            And OBJECTPROPERTY(so.id, N'IsMSShipped') = 0
    Order By SCHEMA_NAME(so.uid),so.name

    If @Output > ''
        Begin
            Set @Output = Char(13) + Char(10)
                          + 'For more information:  '
                          + 'https://github.com/red-gate/SQLCop/wiki/Procedures-using-dynamic-SQL-without-sp_executesql'
                          + Char(13) + Char(10)
                          + Char(13) + Char(10)
                          + @Output
            EXEC tSQLt.Fail @Output
        End

END;


/*----------------------------------------------------
Test this code
--------------------------------------------------------
*/
EXEC tsqlt.run '[SQLCop].[test Procedures using dynamic SQL without sp_executesql]'
GO

-- This fails
-- This is vulnerable.
-- If we add this to the CI process now, the build will fail
-- commit and CI

ALTER PROCEDURE SearchArticles
	@SearchTerm NVARCHAR(100)
AS
BEGIN
  EXECUTE sp_executesql  
               N'SELECT *  
                     FROM dbo.Articles
	       WHERE Article LIKE ''%'' + @term + ''%''', -- SQL Statement
              N'@term NVARCHAR(200)',  -- Parameter definition
             @term = @searchterm;  -- Parameter value
 
RETURN
END
GO
EXEC tsqlt.run '[SQLCop].[test Procedures using dynamic SQL without sp_executesql]'
GO
EXEC dbo.SearchArticles 'outage'
GO







