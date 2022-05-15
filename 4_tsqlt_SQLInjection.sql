CREATE PROCEDURE SearchArticles
	@SearchTerm VARCHAR(100)
AS
BEGIN
  DECLARE @sql VARCHAR(MAX) = 'SELECT ArticlesID FROM dbo.Articles WHERE Article LIKE ''%' + @SearchTerm + '%'''
  EXEC @sql
RETURN
END
GO
  