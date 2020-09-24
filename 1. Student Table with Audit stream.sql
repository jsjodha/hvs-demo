
/*
1) Create a table Student with following columns and proper primary key and indexes
• Student Id
• Student Name
• Student Class
• Interests
• Subjects
a) Make this table timeseries and audit enabled
b) Prepare scripts to maintain the timeseries and audit on the table
*/

--Many Databases to choose from  for timeseries and history using default to SQL server . 
--default using to MS SQL 
--
-- SQL Server newer versions do have inbuild audit /timeseries thru history tables. 
-- but keep thing old school we can make use of another audit table and push data when changed in orignal table thru Triggers. although this is not eficient with bulk data

IF (OBJECT_ID('PK_Student') IS NOT NULL)
BEGIN
    ALTER TABLE [dbo].[Student]
    DROP CONSTRAINT PK_Student
END
GO
drop table if exists dbo.Student;
go

CREATE TABLE [dbo].[Student](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Class] [nvarchar](50) NOT NULL,
	[Interests] [nvarchar](100) NULL,
	[Subjects] [nvarchar](100) NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
) )


go 
IF (OBJECT_ID('IX_UniqueStudents') IS NOT NULL)
BEGIN
    ALTER TABLE [dbo].[Students]
    DROP CONSTRAINT IX_UniqueStudents
END
 
GO

Create Unique Index IX_UniqueStudents
on dbo.Student(Name)
Include(Class,Interests,Subjects)

GO
 

 
GO

drop table if exists dbo.Student_audit;
go

CREATE TABLE [dbo].[Student_audit](
	InsertDate DateTime Not NUll default(getdate()),
	State varchar(10) not null ,
	ChangedBy varchar(50) not null default(user_name()),
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Class] [nvarchar](50) NOT NULL,
	[Interests] [nvarchar](100) NULL,
	[Subjects] [nvarchar](100) NULL,
 CONSTRAINT [PK_Student_audit] PRIMARY KEY CLUSTERED 
(
	InsertDate ASC, State ASC, ChangedBy ASC
) )

GO
CREATE TRIGGER [dbo].[Student_Auditor]
ON [dbo].[Student]
AFTER INSERT,UPDATE
AS
  BEGIN
    --INSERT
    IF NOT EXISTS (SELECT *
                   FROM   deleted)
      BEGIN
        INSERT INTO dbo.Student_audit
        SELECT getdate(),
	'ADDED' ,
	SUSER_SNAME(),
	[Id] ,
	[Name],
	[Class] ,
	[Interests] ,
	[Subjects]
        FROM   inserted
      END
    

    --UPDATE
    IF EXISTS (SELECT *
               FROM   inserted)
       AND EXISTS (SELECT *
                   FROM   deleted)
      BEGIN
         INSERT INTO dbo.Student_audit
        SELECT getdate(),
	'UPDATED' ,
	SUSER_SNAME(),
	i.Id ,
	i.Name,
	i.Class ,
	i.Interests ,
	i.Subjects
        FROM   dbo.Student_audit o,
               inserted i
        WHERE  o.Id = i.Id
               
      END
  END


GO

Insert into dbo.Student values ('JS Jodha','X','Technology','Computer Science')
Insert into dbo.Student values ('Jhoonjhar Jodha','XI','Technology','Computer Science')

update dbo.Student 
set Name = 'J S Jodha' where class='X'
update dbo.Student 
set Interests ='RPG Games' where Name ='Jhoonjhar Jodha'
 
select * from dbo.Student_audit order by InsertDate desc 