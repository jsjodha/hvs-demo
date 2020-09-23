/*
2) Consider Following table. Write a procedure which accepts Date and Depth as parameter and returns the expiring contract.
Depth = ordering of tickers sorted by LastTrade
ContractCode Ticker LastTrade
ES	ESU0	9/15/2020
	ESZ0 12/15/2020
	ESH1 3/15/2021
	ESM1 6/15/2021
	ESU1 9/15/2021
NK NK1 9/15/2020
	NK2 10/15/2020
	NK3 11/15/2020
	NK4 12/15/2020
	NK5 1/15/2021
*/
 
IF (OBJECT_ID('FK_Trade_ContractID') IS NOT NULL)
BEGIN
    ALTER TABLE [dbo].[Trades]
    DROP CONSTRAINT FK_Trade_ContractID
END
go
drop table if Exists dbo.Contracts
go 
drop index if exists dbo.Contracts.pk_Contracts
Go
CREATE TABLE [dbo].[Contracts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL Unique,
	 
 CONSTRAINT [PK_Contracts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC  
) )



GO
IF (OBJECT_ID('FK_Trade_ContractID') IS NOT NULL)
BEGIN
    ALTER TABLE [dbo].[Trades]
    DROP CONSTRAINT FK_Trade_ContractID
END
go

Drop Table if Exists dbo.Trades
go
drop index if exists [dbo].[Trades].pk_Trades
GO 
CREATE TABLE [dbo].[Trades](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ContractId] [int] NOT NULL  ,
	[Name] varchar(50) not null ,
	[TradeDate] [date] not null,
 CONSTRAINT [PK_Trades] PRIMARY KEY CLUSTERED 
(
	Id ASC , ContractId Asc , TradeDate Asc
) )

ALTER TABLE dbo.Trades
ADD CONSTRAINT FK_Trade_ContractID
FOREIGN KEY (ContractId) REFERENCES dbo.Contracts(ID);


Insert into dbo.Contracts values ('ES')
Insert Into dbo.Contracts values('NK')



--Insert Sample records
Declare @Id int
Set @Id = 1

While @Id <= 20
Begin 
 
DECLARE @start DATE ;
select @Start = DateADd(Day,-100 , getdate()) 
DECLARE @end DATE  =getdate() 

Declare @NextDate Date=  DATEADD(DAY,ABS(CHECKSUM(NEWID())) % ( 1 + DATEDIFF(DAY,@start,@end)),@start)
   Insert Into [Trades] values (
								1,
							    'ES-' +cast(@Id as varchar(10)),
								 @NextDate)
	 Insert Into [Trades] values (
								2,
								 'NK-' +cast(@Id as varchar(10)),
								 @NextDate)
   Print @Id
   Set @Id = @Id + 1
End



Drop procedure if exists  dbo.GetExpiringContracts
go 
Create proc dbo.GetExpiringContracts(
@date Date, @depth int =5)
as 
begin
 select * from ( select c.Name as ContractName,
  ROW_NUMBER() over(partition by c.Name order by t.TradeDate desc) as RowNum,
  t.Name as TradeName, t.TradeDate from dbo.Trades t left join 
  dbo.Contracts c on c.Id = t.ContractId
  ) as t where t.RowNum   <=@depth
  order by ContractName, TradeDate desc
end 

GO

Exec dbo.GetExpiringContracts 
@date= '2020-09-23', 
 @depth= 5