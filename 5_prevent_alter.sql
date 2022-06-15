/*
Using CI To Prevent Database Problems


Preventing Alters of Important Tables
*/
-- We have an important table that exists in our system
-- We do not want developers to alter this table without a discussion
CREATE TABLE dbo.Files
(
[FileID] [int] NOT NULL,
[FileName] [varchar] (250) NOT NULL,
[FileExtension] [varchar] (50) NOT NULL,
[SizeInBytes] [bigint] NOT NULL,
[CreatedDate] [datetime] NOT NULL
)
GO

-- Since we know this table is important and linked to other processes
-- Let's write a test
-- Let's use a Test to notify us that this is an issue
EXEC tsqlt.NewTestClass
  @ClassName = N'tMetaDataChecks' -- nvarchar(max)
GO
CREATE PROCEDURE [tMetaDataChecks].[test dbo.Files should not be altered without discussion]
AS
BEGIN
-- Assemble
CREATE TABLE dbo.ExpectedFiles
(
[FileID] [int] NOT NULL,
[FileName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileExtension] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SizeInBytes] [bigint] NOT NULL,
[CreatedDate] [datetime] NOT NULL
)


-- Act


-- Assert
EXEC tsqlt.AssertResultSetsHaveSameMetaData
  @expectedCommand = N'select * from dbo.ExpectedFiles'
, @actualCommand = N'select * from dbo.Files'

END
GO

-- test the test
EXEC tsqlt.run '[tMetaDataChecks].[test dbo.Files should not be altered without discussion]'
GO



-- Here is our code
-- This will take a long time in production because the table is large.
-- A developer wrote this, and in their testing it worked fine.
-- The dev database only had 100 rows
/*
ALTER TABLE dbo.Files
 ADD FileSummary VARCHAR(1000) NULL
GO
UPDATE dbo.Files
 set FileSummary = a.MetaData
 from Files f
  CROSS APPLY dbo.clrLoadFileMetadata(f.FileID) a
GO
ALTER TABLE dbo.Files
 ALTER COLUMN FileSummary varchar(1000) NOT NULL
*/

-- The developer runs this
ALTER TABLE dbo.Files
 ADD FileSummary VARCHAR(1000) NULL
GO

-- and commits the code.
-- Let's commit and see what happens in CI




-- CI Fails
-- Now what?
-- schedule meeting
-- discuss strategies (maintenance window, time required for deployment)


-- We DO NOT want an exception here. We want this test to fail.
-- IF the change is approved, the test is altered to allow
-- this change, but prevent future ones.

