use NorthwindDB


--1--
create function AgeChecker(@date datetime, @age int)
returns nvarchar(max)
begin
	declare @returnVal nvarchar(max);
	declare @check int = 0;
	if(year(@date) + @age < year(getDate())) 
		set @check = @check + 1;
		set @returnVal = 'In that age';
	if(@check = 0 and year(@date) + @age = year(getDate()) and month(@date) < month(getDate()))
		set @check = @check + 1;
		set @returnVal = 'In that age';
	if(@check = 0 and year(@date) + @age = year(getDate()) and month(@date) = month(getDate()) and day(@date) < day(getDate()))
		set @check = @check + 1;
		set @returnVal = 'In that age';

	if(@check = 0)
		set @returnVal = 'Not in age';

	return @returnVal
end;

drop function dbo.AgeChecker;

select dbo.agechecker(cast('2003-01-27' as datetime), 19);

--2--
create database Odev

use Odev;

create table Countries(
	CountryId int primary key identity(1,1) not null,
	CountryName nvarchar(40) not null,
	Code int not null
);

create table Cities(
	CityId int primary key identity(1,1) not null,
	CityName nvarchar(40) not null,
	Code int not null,

	CountryId int foreign key references Countries(CountryId)
);

create table Districts(
	DistrictId int primary key identity(1,1) not null,
	DistrictName nvarchar(40) not null,
	Code int not null,

	CountryId int foreign key references Countries(CountryId),
	CityId int foreign key references Cities(CityId)
);

create table Town(
	TownId int primary key identity(1,1) not null,
	TownName nvarchar(40) not null,
	Code int not null,

	CountryId int foreign key references Countries(CountryId),
	CityId int foreign key references Cities(CityId),
	DistrictId int foreign key references Districts(DistrictId)
);

create procedure CountryUpdater (@countryName nvarchar(max), @cityName nvarchar(max), @districtName nvarchar(max), @townName nvarchar(max))
as
begin
	declare @messages nvarchar(max);

	if(lower(@countryName) in (select lower(CountryName) from Countries))
		begin
		print('Given country already exists');

		declare @countryId int = (select CountryId
								  from (select CountryId, lower(CountryName) as CountryName from Countries) tbl
								  where CountryName = @countryName);

		if(lower(@cityName) in (select lower(CityName) from Cities where CountryId = @countryId))
			begin
			print('Given city already exists');

			declare @cityId int = (select CityId
								   from (select CityId, lower(CityName) as CityName from Cities) tbl
								   where CityName = @cityName);

			if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId = @countryId and CityId = @cityId))
				begin
				print('Given district already exists');

				declare @districtId int = (select DistrictId
										   from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								           where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId and DistrictId = @districtId))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId or DistrictId != @districtId))
					begin
					update Town set CountryId = @countryId, CityId = @cityId, @districtId = @districtId where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId, @districtId)
					end;
				end;
			else if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId != @countryId or CityId != @cityId))
				begin
				update Districts set CountryId = @countryId, CityId = @cityId where DistrictName = @districtName;

				declare @districtId2 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId and DistrictId = @districtId2))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId or DistrictId != @districtId2))
					begin
					update Town set CountryId = @countryId, CityId = @cityId, @districtId = @districtId2 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId, @districtId2)
					end;
				end;
			else
				begin
				insert into Districts(DistrictName, CountryId, CityId) values (@districtName, @countryId, @cityId);

				declare @districtId3 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId and DistrictId = @districtId3))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId or DistrictId != @districtId3))
					begin
					update Town set CountryId = @countryId, CityId = @cityId, @districtId = @districtId3 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId, @districtId3)
					end;
				end;

			end;
		else if(lower(@cityName) in (select lower(CityName) from Cities where CountryId != @countryId))
			begin
			update Cities set CountryId = @countryId where CityName = @cityName

			declare @cityId2 int = (select CityId
								    from (select CityId, lower(CityName) as CityName from Cities) tbl
								    where CityName = @cityName);

			if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId = @countryId and CityId = @cityId2))
				begin
				print('Given district already exists');

				declare @districtId4 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId2 and DistrictId = @districtId4))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId2 or DistrictId != @districtId4))
					begin
					update Town set CountryId = @countryId, CityId = @cityId2, @districtId = @districtId4 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId2, @districtId4)
					end;
				end;
			else if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId != @countryId or CityId != @cityId2))
				begin
				update Districts set CountryId = @countryId, CityId = @cityId2 where DistrictName = @districtName;

				declare @districtId5 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId2 and DistrictId = @districtId5))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId2 or DistrictId != @districtId5))
					begin
					update Town set CountryId = @countryId, CityId = @cityId2, @districtId = @districtId5 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId2, @districtId5)
					end;
				end;
			else
				begin
				insert into Districts(DistrictName, CountryId, CityId) values (@districtName, @countryId, @cityId2);

				declare @districtId6 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId2 and DistrictId = @districtId6))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId or DistrictId != @districtId6))
					begin
					update Town set CountryId = @countryId, CityId = @cityId2, @districtId = @districtId6 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId2, @districtId6)
					end;
				end;
			end;
		else
			begin
			insert into Cities(CityName, CountryId) values (@cityName, @countryId);

			declare @cityId3 int = (select CityId
								    from (select CityId, lower(CityName) as CityName from Cities) tbl
								    where CityName = @cityName);

			if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId != @countryId or CityId != @cityId3))
				begin
				update Districts set CountryId = @countryId, CityId = @cityId3 where DistrictName = @districtName;

				declare @districtId7 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId3 and DistrictId = @districtId7))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId3 or DistrictId != @districtId7))
					begin
					update Town set CountryId = @countryId, CityId = @cityId3, @districtId = @districtId7 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId3, @districtId7)
					end;
				end;
			else
				begin
				insert into Districts(DistrictName, CountryId, CityId) values (@districtName, @countryId, @cityId3);

				declare @districtId8 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId and CityId = @cityId3 and DistrictId = @districtId8))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId or CityId != @cityId3 or DistrictId != @districtId8))
					begin
					update Town set CountryId = @countryId, CityId = @cityId3, @districtId = @districtId8 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId, @cityId3, @districtId8)
					end;
				end;
			end;
		end;
	else
		begin
		insert into Countries(CountryName) values (@countryName);

		declare @countryId2 int = (select CountryId
								  from (select CountryId, lower(CountryName) as CountryName from Countries) tbl
								  where CountryName = @countryName);

		if(lower(@cityName) in (select lower(CityName) from Cities where CountryId != @countryId2))
			begin
			update Cities set CountryId = @countryId2 where CityName = @cityName

			declare @cityId4 int = (select CityId
								    from (select CityId, lower(CityName) as CityName from Cities) tbl
								    where CityName = @cityName);

			if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId = @countryId2 and CityId = @cityId4))
				begin
				print('Given district already exists');

				declare @districtId9 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId2 and CityId = @cityId4 and DistrictId = @districtId9))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId2 or CityId != @cityId4 or DistrictId != @districtId9))
					begin
					update Town set CountryId = @countryId2, CityId = @cityId4, @districtId = @districtId9 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId2, @cityId4, @districtId9)
					end;
				end;
			else if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId != @countryId2 or CityId != @cityId4))
				begin
				update Districts set CountryId = @countryId2, CityId = @cityId4 where DistrictName = @districtName;

				declare @districtId10 int = (select DistrictId
										    from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								            where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId2 and CityId = @cityId4 and DistrictId = @districtId10))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId2 or CityId != @cityId4 or DistrictId != @districtId10))
					begin
					update Town set CountryId = @countryId2, CityId = @cityId4, @districtId = @districtId10 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId2, @cityId4, @districtId10)
					end;
				end;
			else
				begin
				insert into Districts(DistrictName, CountryId, CityId) values (@districtName, @countryId2, @cityId4);

				declare @districtId11 int = (select DistrictId
										     from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								             where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId2 and CityId = @cityId4 and DistrictId = @districtId11))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId2 or CityId != @cityId4 or DistrictId != @districtId11))
					begin
					update Town set CountryId = @countryId2, CityId = @cityId4, @districtId = @districtId10 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId2, @cityId4, @districtId11)
					end;
				end;
			end;
		else
			begin
			insert into Cities(CityName, CountryId) values (@cityName, @countryId2);

			declare @cityId5 int = (select CityId
								    from (select CityId, lower(CityName) as CityName from Cities) tbl
								    where CityName = @cityName);

			if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId = @countryId2 and CityId = @cityId5))
				begin
				print('Given district already exists');

				declare @districtId12 int = (select DistrictId
										     from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								             where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId2 and CityId = @cityId5 and DistrictId = @districtId12))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId2 or CityId != @cityId5 or DistrictId != @districtId12))
					begin
					update Town set CountryId = @countryId2, CityId = @cityId5, @districtId = @districtId12 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId2, @cityId5, @districtId12)
					end;
				end;
			else if(lower(@districtName) in (select lower(DistrictName) from Districts where CountryId != @countryId2 or CityId != @cityId5))
				begin
				update Districts set CountryId = @countryId2, CityId = @cityId5 where DistrictName = @districtName;

				declare @districtId13 int = (select DistrictId
										     from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								             where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId2 and CityId = @cityId5 and DistrictId = @districtId13))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId2 or CityId != @cityId5 or DistrictId != @districtId13))
					begin
					update Town set CountryId = @countryId2, CityId = @cityId5, @districtId = @districtId13 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId2, @cityId5, @districtId13)
					end;
				end;
			else
				begin
				insert into Districts(DistrictName, CountryId, CityId) values (@districtName, @countryId2, @cityId5)

				declare @districtId14 int = (select DistrictId
										     from (select DistrictId, lower(DistrictName) as DistrictName from Districts) tbl
								             where DistrictName = @districtName);

				if(lower(@townName) in (select lower(TownName) from Town where CountryId = @countryId2 and CityId = @cityId5 and DistrictId = @districtId14))
					begin
					print('Given town already exists');
					end;
				else if(lower(@townName) in (select lower(TownName) from Town where CountryId != @countryId2 or CityId != @cityId5 or DistrictId != @districtId14))
					begin
					update Town set CountryId = @countryId2, CityId = @cityId5, @districtId = @districtId14 where TownName = @townName
					end;
				else
					begin
					insert into Town(TownName, CountryId, CityId, DistrictId) values (@townName, @countryId2, @cityId5, @districtId14)
					end;
				end;
			end;
		end;
end;

drop procedure CountryUpdater;

exec CountryUpdater 'Turkiye','Izmir','TestDistrict','TestTown2';