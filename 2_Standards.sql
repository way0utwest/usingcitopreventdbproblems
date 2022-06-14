/*
USING CI AND TESTING TO PREVENT DATABASE PROBLEMS

Standards Testing
*/

-- We want to add a new table.
-- let's build a new table.
CREATE TABLE [dbo].[ContentItems_Staging]
(
[ContentItemID] [INT] NOT NULL IDENTITY(1, 1),
[PrimaryTagID] [INT] NULL,
[Title] [VARCHAR] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShortTitle] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (3500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Text] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternalURL] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimateofReadingTime] [time] NOT NULL
)
GO

SELECT * FROM dbo.ContentItems_Staging
-- insert data
-- merge with main ContentItems


-- commit and CI
-- save, run

















-- Now we re-run our standards tests.
-- We only want to run the minimal test here. We'll add more later.
EXEC tsqlt.run '[SQLCop]'
GO



-- We have a failure.


-- Solutions
-- 1. Add a PK
-- alter table contentitems_staging add constraint ContentItems_StagingPK primary key ([ContentItemID])
--
-- DO THIS 99.99999% of the TIME
--
-- ALWAYS HAVE A PRIMARY KEY
--
--
--
-- 2. However, we don't want a primary key here. This is a staging table that we want to load
--    as quickly as possible.
-- Let's add an exception.

EXEC sys.sp_addextendedproperty 
  @name = 'PKException',
  @value = 1, -- sql_variant
  @level0type = 'schema', -- varchar(128)
  @level0name = 'dbo', -- sysname
  @level1type = 'table', -- varchar(128)
  @level1name = 'ContentItems_Staging' -- sysname
  ;
GO






-- Alter the test to allow the exception
ALTER PROCEDURE [SQLCop].[test Tables without a primary key]
AS
BEGIN

-- Assemble
DECLARE @output nvarchar(max)

-- act
SELECT AllTables.name
 INTO #actual
  FROM    ( SELECT    o.name ,
                    o.object_id AS id ,
                    COALESCE( e. value, 0) AS 'PKException'
          FROM      sys.objects o
                    INNER JOIN sys.schemas s ON s. schema_id = o.schema_id
                    LEFT OUTER JOIN sys.extended_properties e ON o.object_id = e .major_id
                                                              AND e.value = 1
                                                              AND e.class_desc = 'OBJECT_OR_COLUMN'
                                                              AND e.name = 'PKException'
          WHERE     o.type = 'U'
                    AND s.name <> 'tsqlt'
        ) AS AllTables
        LEFT JOIN ( SELECT  parent_object_id
                    FROM    sys. objects
                    WHERE   type = 'PK'
                  ) AS PrimaryKeys ON AllTables .id = PrimaryKeys. parent_object_id
WHERE    PrimaryKeys. parent_object_id IS NULL
        AND AllTables .PKException = 0
ORDER BY AllTables. name;

-- assert
EXEC tsqlt.AssertEmptyTable @TableName = N'#actual', -- nvarchar(max)
  @Message = N'There are tables without a primary key.' -- nvarchar(max)
END


GO







-- now re-test
EXEC tsqlt.run '[SQLCop]'
GO




-- If we change our mind....
EXEC sys.sp_updateextendedproperty
  @name = 'PKException'
, @value = 0
, @level0type = 'schema'
, @level0name = 'dbo'
, @level1type = 'table'
, @level1name = 'ContentItems_Staging' -- sysname
  ;
GO



-- now re-test
EXEC tsqlt.run '[SQLCop]'
GO



/*
-- change again if wanted
EXEC sys.sp_updateextendedproperty
  @name = 'PKException'
, @value = 1
, -- sql_variant
  @level0type = 'schema'
, -- varchar(128)
  @level0name = 'dbo'
, -- sysname
  @level1type = 'table'
, -- varchar(128)
  @level1name = 'ContentItems_Staging' -- sysname
  ;
GO

*/














-- test
EXEC tsqlt.run '[SQLCop]';
GO




-- fix
EXEC sys.sp_rename
  @objname = N'sp_test'
, -- nvarchar(1035)
  @newname = 'prcTest';
GO







-- test
EXEC tsqlt.run '[SQLCop]';
GO








--break
EXEC sys.sp_rename
  @objname = N'prctest'
, -- nvarchar(1035)
  @newname = 'sp_Test';
GO









-- test
EXEC tsqlt.run '[SQLCop]';
GO











-- allow an exclusion
EXEC sys.sp_addextendedproperty
  @name = 'sp_Exception'
, -- sysname
  @value = 1
, -- sql_variant
  @level0type = 'schema'
, -- varchar(128)
  @level0name = 'dbo'
, -- sysname
  @level1type = 'procedure'
, -- varchar(128)
  @level1name = 'sp_Test'
;
GO



-- test
EXEC tsqlt.run '[SQLCop]';
GO


/*******************************************************************************
*                                                                              *
*                            END DEMO                                          *
*                                                                              *
********************************************************************************/
