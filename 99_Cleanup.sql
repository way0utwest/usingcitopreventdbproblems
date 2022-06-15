/*
USING CI AND TESTING TO PREVENT DATABASE PROBLEMS

Cleanup
*/

DROP FUNCTION dbo.UF_CalcBonusForArticles
GO
DROP PROCEDURE [tSalesOrderDetail].[test Check Bonus Calculation for qty rules]
GO
DROP SCHEMA tSalesOrderDetail
GO
DROP TABLE [dbo].[ContentItems_Staging]
GO
DROP PROCEDURE dbo.SearchArticles
GO
DROP PROC [SQLCop].[test Procedures using dynamic SQL without sp_executesql]
GO
DROP PROCEDURE [tMetaDataChecks].[test dbo.Files should not be altered without discussion]
GO
DROP SCHEMA tMetaDataChecks
GO
DROP TABLE dbo.Files
GO


