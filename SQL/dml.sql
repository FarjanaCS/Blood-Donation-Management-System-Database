use blooddonors
go

insert into donors
values (1, 'Amin', 'Dhaka')
GO
insert [dbo].[donors] ([donorID], [donorName], [donorAddress]) 
values (2, 'Rasel', 'Faridpur')
GO
insert [dbo].[donors] ([donorID], [donorName], [donorAddress])
values (3, 'Ripon', 'Jamalpur'),
	   (4, 'Himel', 'Rajshahi'),
	   (5, 'Mahmud', 'Comilla')


insert into [dbo].[hospitals] ([hospitalID], [hospitalName])
values (1, 'National Heart Foundation'),
		(2, 'P. G. Hospital'),
		(3, 'Kidney Foundation'),
		(4, 'CMS Hospital Bangladesh'),
		(5, 'Green Life Hospital')
GO

insert [dbo].[patients] ([patiantID], [patiantName], [bloodGroup], [patiantAddress], [payment], [hospitalID])
values (1, 'Rajib', 'B+', 'Mirpur, Dhaka', 1000.0000, 1),
		(2, 'Rajab', 'A+', 'Uttara, Dhaka', 15000.0000, 2),
		(3, 'Sakib', 'O-', 'Mohammadpur, Dhaka', 20000.0000, 3),
		(4, 'Mamun', 'AB+', 'Farmgate, Dhaka', 2500.0000, 4)
GO

USE [blooddonors]
GO
insert [dbo].[patiantDonors] ([donationID], [donorID], [patiantID], [timeOfDonation]) 
values (1, 1, 1, cast('2022-08-01 12:00:00.000' AS DateTime)),
		(2, 2, 3, cast('2022-05-01 22:00:00.000' AS DateTime)),
		(3, 3, 4, cast('2022-09-02 18:00:00.000' AS DateTime)),
		(4, 4, 2, cast('2022-010-01 11:00:00.000' AS DateTime))
GO

--procedure
DECLARE @id INT
exec spInsertDonors  'Amirul', 'Keranigonj', @id OUTPUT
SELECT @id
 GO
select * FROM donors
GO
EXEC spUpdateDonors 6, 'Amirul Islam', 'Keranigonj, Dhaka'
 GO
select * FROM donors
GO
EXEC  spDeleteDonors 6
GO
select * FROM donors
GO
DECLARE @id INT
EXEC spInsertHospitals 'Medicare', @id OUTPUT
SELECT @id
GO
select * FROM hospitals
GO
EXEC spUpdateHospitals 6, 'Medicare Hospital'
GO
select * FROM hospitals
GO
EXEC spDeleteHospitals 6
GO
select * FROM hospitals
GO
DECLARE @id INT
EXEC spInsertpatients 'Abdul Alim', 'A+','Mirpur, Dhaka',21000,5, @id OUTPUT
SELECT @id
GO
select * FROM patients
GO
EXEC spUpdatepatients 5, 'Abdul Alim', 'AB+','Mirpur-1, Dhaka',21000,5
GO
select * FROM patients
GO
EXEC spDeletepatients 5
GO
select * FROM patients
GO
DECLARE @id INT
EXEC spInsertPatiantDonors 5 ,4, '2022-03-14', @id OUTPUT
SELECT @id
GO
select * FROM patiantDonors
GO
EXEC spDeletePatiantDonors 5
GO
select * FROM patiantDonors
GO

--views
select * FROM vPatiantDetails
GO
select * FROM vAvailableDonors
GO
select * from vPatientsONeg
go
select * from vDonorZeeoCount
go
--udf
select * FROM fnDonationDetails(1)
GO


--trigger
EXEC spInsertDonors  'Amirul', 'Keranigonj'
 GO
 DECLARE @id INT
EXEC spInsertPatiantDonors 5 ,4, '2022-03-1', @id OUTPUT	
GO
select * FROM donors
GO
select * FROM patiantDonors
GO
insert [dbo].[patiantDonors] ([donationID], [donorID], [patiantID], [timeOfDonation]) values (6, 5, 1, '2022-03-14') --cannot donate in 90 days
go
select * FROM patiantDonors
GO

---1 Join Inner

select d.donorName, d.donorAddress, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM donors d
inner join patiantDonors pd ON d.donorID = pd.donorID 
inner join patients p ON pd.patiantID = p.patiantID 
inner join  hospitals h ON p.hospitalID = h.hospitalID
GO

---2 filter blod grpup

select d.donorName, d.donorAddress, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM donors d
inner join patiantDonors pd ON d.donorID = pd.donorID 
inner join patients p ON pd.patiantID = p.patiantID 
inner join  hospitals h ON p.hospitalID = h.hospitalID
WHERE p.bloodGroup = 'O-'
GO

--- 3 filter hosptal	

select d.donorName, d.donorAddress, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM donors d
inner join patiantDonors pd ON d.donorID = pd.donorID 
inner join patients p ON pd.patiantID = p.patiantID 
inner join  hospitals h ON p.hospitalID = h.hospitalID
WHERE h. hospitalName = 'National Heart Foundation'
GO

--	 4 outer (right)	

select d.donorName, d.donorAddress, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM   patients AS p 
inner join patiantDonors AS pd ON p.patiantID = pd.patiantID 
inner join hospitals AS h ON p.hospitalID = h.hospitalID 
right outer join donors AS d ON pd.donorID = d.donorID
GO

--	 5 rewrite 4 with cte	
 
WITH cteall AS
(

select  pd.donorID, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM   patients AS p 
inner join patiantDonors AS pd ON p.patiantID = pd.patiantID 
inner join hospitals AS h ON p.hospitalID = h.hospitalID 
)
select d.donorName, c.patiantName, c.bloodGroup, c.patiantAddress, c.hospitalName, c.timeOfDonation
FROM cteall c
right outer join donors d ON c.donorID=d.donorID
GO

--	6 outer (right) not matched		
 
select  d.donorName, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM   patients AS p 
inner join patiantDonors AS pd ON p.patiantID = pd.patiantID 
inner join hospitals AS h ON p.hospitalID = h.hospitalID 
right outer join donors AS d ON pd.donorID = d.donorID
WHERE pd.donorID IS NULL
GO

---	 7 sme 6 with sub-query		
 
select  d.donorName, p.patiantName, p.bloodGroup, p.patiantAddress, h.hospitalName, pd.timeOfDonation
FROM   patients AS p 
inner join patiantDonors AS pd ON p.patiantID = pd.patiantID 
inner join hospitals AS h ON p.hospitalID = h.hospitalID 
right outer join donors AS d ON pd.donorID = d.donorID
WHERE d.donorID NOT IN (select donorID FROM patiantDonors)
GO

--	 8 aggregate	
 
select d.donorName, count(pd.donorID)
FROM donors d
inner join patiantDonors pd ON d.donorID = pd.donorID 
inner join patients p ON pd.patiantID = p.patiantID 
inner join  hospitals h ON p.hospitalID = h.hospitalID
GROUP BY d.donorName
GO

select d.donorName, p.bloodGroup, count(pd.donorID)
FROM donors d
inner join patiantDonors pd ON d.donorID = pd.donorID 
inner join patients p ON pd.patiantID = p.patiantID 
inner join  hospitals h ON p.hospitalID = h.hospitalID
GROUP BY d.donorName,  p.bloodGroup
GO

--	 9 aggregate+having		
 
select d.donorName, count(pd.donorID)
FROM donors d
inner join patiantDonors pd on d.donorID = pd.donorID 
inner join patients p on pd.patiantID = p.patiantID 
inner join  hospitals h on p.hospitalID = h.hospitalID
GROUP BY d.donorName,  p.bloodGroup
having p.bloodGroup = 'AB+'
GO

--	10 windowing function	
 
select d.donorName, 
 count(pd.donorID) OVER(ORDER BY d.donorID) 'count',
 ROW_NUMBER() OVER(ORDER BY d.donorID) 'number',
 RANK() OVER(ORDER BY d.donorID) 'rank',
 DENSE_RANK() OVER(ORDER BY d.donorID) 'denserank',
 NTILE(3) OVER(ORDER BY d.donorID) 'ntile(3)'
FROM donors d
inner join patiantDonors pd ON d.donorID = pd.donorID 
inner join patients p ON pd.patiantID = p.patiantID 
inner join  hospitals h ON p.hospitalID = h.hospitalID
GO

--	11 CASE .. WHEN...END	
 
select
	case when p.patiantName is null then 'nil'
	else p.patiantName
end AS 'patiantName'
from   patients AS p 
inner join patiantDonors AS pd ON p.patiantID = pd.patiantID 
inner join hospitals AS h ON p.hospitalID = h.hospitalID 
right outer join donors AS d ON pd.donorID = d.donorID