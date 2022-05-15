/*
USING CI AND TESTING TO PREVENT DATABASE PROBLEMS

Create a procedure with a security issue. This is a SQL Injection problem (potentially)
*/
CREATE OR ALTER PROCEDURE SearchArticles
	@SearchTerm VARCHAR(100)
AS
BEGIN
  DECLARE @sql VARCHAR(MAX) = 'SELECT ArticlesID FROM dbo.Articles WHERE Article LIKE ''%' + @SearchTerm + '%'''
  EXEC(@sql)
RETURN
END
GO
  