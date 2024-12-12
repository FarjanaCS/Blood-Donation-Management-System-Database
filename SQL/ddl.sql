if db_id('blooddonors') is null
create database blooddonors
go
use blooddonors
go

create table donors
(
	donorID int primary key,
	donorName varchar(50) not null,
	donorAddress varchar(70) not null
)
go

create table hospitals
(
	hospitalID int primary key,
	hospitalName varchar(50) not null
)
go
create table patients
(
	patiantID int primary key,
	patiantName varchar(50) not null,
	bloodGroup varchar(20) not null,
	patiantAddress varchar(70) not null,
	payment money not null,
	hospitalID int not null references hospitals(hospitalID)
)
go

create table patiantDonors
(
	donationID int primary key,
	donorID int not null references donors(donorID),
	patiantID int not null references patients(patiantID),
	timeOfDonation date not null
)
go
--donors table

--Insert Donors Procedure

create proc spInsertDonors 
		@name varchar(50), 
		@address varchar(70),
		@id INT OUTPUT
as

select @id = isnull(MAX(donorID), 0)+1 from donors
begin try
	insert into donors (donorID, donorName, donorAddress)
	values (@id, @name, @address)
	return 0
end try
begin catch
	; 
	throw 50001, 'Faild to insert the entity', 1
	return 50001
end catch
go

--Update Donors Procedure

create proc spUpdateDonors 
	@id int, 
	@name varchar(30), 
	@address varchar(70)
as
begin try
	update donors 
	set donorName = @name, donorAddress = @address
	where donorID = @id
end try
begin catch
	declare @em varchar(500)
	set @em = ERROR_MESSAGE()
	raiserror( @em, 16, 1)
	return
end catch
go

--Delete Donors Procedure

create proc spDeleteDonors @id int
as
begin try
	delete donors
	where donorID = @id
end try
begin catch
	;
	throw 50002, 'Faild to delete', 1
end catch
go


--Hospitals 

--Insert Hospital Procedure


create proc spInsertHospitals
	@name varchar(30), @id INT OUTPUT
as
select @id = isnull(MAX(hospitalID), 0)+1 from hospitals
begin try
	insert into hospitals(hospitalID, hospitalName)
	values (@id, @name)
	return 0
end try
begin catch
	declare @em varchar(500), @n INT
	SELECT @em = ERROR_MESSAGE(), @n=ERROR_NUMBER()
	raiserror( @em, 16, 1)
	return @n
end catch
go

--Update Hospital Procedure

create proc spUpdateHospitals @id int, @name VARCHAR(30)
as
begin try
	update hospitals 
	set hospitalName = @name
	where hospitalID = @id
end try
begin catch
	;
	throw 50001, 'Faild to update', 1
end catch
go

--Delete Hospitals Procedure


create proc spDeleteHospitals @id INT
as
begin try
	delete hospitals
	where hospitalID = @id
end try
begin catch
 	declare @em varchar(500)
	set @em = ERROR_MESSAGE()
	raiserror( @em, 16, 1)
	return 
end catch
GO

--patients 

--Insert patients Procedure

CREATE proc spInsertpatients
	@name varchar(50),
	@BGroup varchar(20),
	@address varchar(100),
	@payment MONEY,
	@hospitalID int,
	@id INT OUTPUT
as

select @id = ISNULL(MAX(patiantID), 0)+1 from patients
begin try
	INSERT INTO patients(patiantID, patiantName, bloodGroup, patiantAddress, payment, hospitalID)
	VALUES (@id, @name, @BGroup, @address, @payment, @hospitalID)
	RETURN 0
end try
begin catch
	declare @em varchar(500), @n INT
	SELECT @em = ERROR_MESSAGE(), @n=ERROR_NUMBER()
	raiserror( @em, 16, 1)
	return @n
end catch
GO

--Update Patiant Procedure

create proc spUpdatepatients 
	@id int, 
	@name varchar(50),
	@BGroup varchar(20),
	@address varchar(100),
	@payment money,
	@hospitalID INT

as
begin try
	update patients 
	set patiantName = @name,
		bloodGroup = @BGroup,
		patiantAddress = @address,
		payment = @payment,
		hospitalID = @hospitalID
	where patiantID = @id
end try
begin catch
	;
	throw 50001, 'Faild to update', 1
end catch
GO

--Delete Patiant Procedure

create proc spDeletepatients @id int
as
begin try
	delete patients
	where patiantID = @id
end try
begin catch
	declare @em varchar(500)
	set @em = ERROR_MESSAGE()
	raiserror( @em, 16, 1)
	return
end catch
GO


--PatiantDonors
--Insert Procedure

create proc spInsertPatiantDonors
	@donorID INT,
	@patiantID INT,
	@timeOfDonation DATETIME,
	@id INT OUTPUT
as
	
	select @id = isnull(MAX(donationID), 0)+1 from patiantDonors
begin try
	insert into patiantDonors (donationID, donorID, patiantID, timeOfDonation)
	values (@id, @donorID, @patiantID, @timeOfDonation)
	return 0
end try
begin catch
	declare @em varchar(500), @n INT
	SELECT @em = ERROR_MESSAGE(), @n=ERROR_NUMBER()
	raiserror( @em, 16, 1)
	return @n
end catch
GO

--Update PatiantDonors Procedure

create proc spUpdatePatiantDonors
	@id int, 
	@donorID int,
	@patiantID int,
	@timeOfDonation datetime

as
begin try
	update patiantDonors
	set donorID = @donorID,
		patiantID = @patiantID,
		timeOfDonation = @timeOfDonation
	where donationID = @id
end try
begin catch
	declare @em varchar(500)
	set @em = ERROR_MESSAGE()
	raiserror( @em, 16, 1)
	return
end catch
GO

--DELETE PatiantDonors Procedure

create proc spDeletePatiantDonors @id int
as
begin try
	delete patiantDonors
	where donationID = @id
end try
begin catch
	;
	throw 50002, 'Faild to delete', 1
end catch
GO

--VIEW for patiant with details

create view vPatiantDetails
with encryption
as
SELECT H.hospitalName, P.patiantName, P.patiantAddress, D.donorName, D.donorAddress, PD.timeOfDonation
FROM patients P
INNER JOIN hospitals H on H.hospitalID = P.hospitalID
INNER JOIN patiantDonors PD on P.patiantID = PD.patiantID
INNER JOIN donors D on D.donorID = PD.donorID
go
create view vPatientsONeg
as
select d.donorName, d.donorAddress, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM donors d
inner join patiantDonors pd ON d.donorID = pd.donorID 
inner join patients p ON pd.patiantID = p.patiantID 
inner join  hospitals h ON p.hospitalID = h.hospitalID
WHERE p.bloodGroup = 'O-'
go
--VIEW for Donors with details

create view vAvailableDonors
with encryption
as
(
	select D.donorName, cast(PD.timeOfDonation as date) as 'donation date', D.donorAddress
	from donors D
	inner join patiantDonors PD on PD.donorID = D.donorID
	where datediff(month, PD.timeOfDonation, getdate()) > 3
)
go
-- View donors no donation
create view vDonorZeeoCount
as
select  d.donorName, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM   patients AS p 
inner join patiantDonors AS pd ON p.patiantID = pd.patiantID 
inner join hospitals AS h ON p.hospitalID = h.hospitalID 
right outer join donors AS d ON pd.donorID = d.donorID
WHERE d.donorID NOT IN (select donorID FROM patiantDonors)
go

--udf

create function fnDonationDetails (@month int) returns table
as
return
(
	select D.donorName, cast(PD.timeOfDonation as date) as 'donationDate', P.patiantName, P.payment
	from donors d
	inner join patiantDonors PD on PD.donorID = D.donorID
	inner join patients P on P.patiantID = PD.patiantID
	where @month = month(PD.timeOfDonation) and year(PD.timeOfDonation) = year(getdate())
)
GO

--Scalar

create function fnpatients (@bloodGroup varchar(15)) returns int
as
begin
	declare @total int
	select @total = count(*) from patients
	where @bloodGroup = bloodGroup
	return @total
END
GO

-----Trigger------

create trigger trDonorDelete
on donors
after delete
AS
begin
	 declare @id int
	 select @id = donorID from deleted
	 delete from patiantDonors 
	 where @id = donorID
end
go

----Instead of Trigger

create trigger trInsertDonation
ON patiantDonors
INSTEAD OF INSERT
AS
begin
	DECLARE @d_id int , @cd DATE, @ld DATE
	select @d_id = donorID, @cd = timeOfDonation from inserted
	select @ld=max(timeOfDonation) from patiantDonors where donorID=@d_id
	select @d_id, @cd, DATEDIFF(day, @ld, @cd)
	IF DATEDIFF(day, @ld, @cd) < 90
	begin
		raiserror('Cannot donate in 90 days', 16, 1)
		return
	end
	INSERT INTO patiantDonors
	select * from inserted
end
GO
