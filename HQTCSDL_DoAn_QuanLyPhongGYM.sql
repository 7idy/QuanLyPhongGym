use master
go															 -- 
if exists (select name from sysdatabases where name = 'gym') --
drop database gym											 -- Nếu tồn tại database 'gym' thì xóa và tạo lại
go															 --
create database gym											 --

on primary
(
	name = DBGym_PRIMARY,
	filename = 'D:\Project-DuAn\QuanLyPhongGYM_HQTCSDL\DBGym_PRIMARY.mdf',
	size = 10Mb,
	maxsize = 50Mb,
	filegrowth = 10%
)

log on
(
	name = DBGym_LOG,
	filename = 'D:\Project-DuAn\QuanLyPhongGYM_HQTCSDL\DBGym_LOG.ldf',
	size = 5Mb,
	maxsize = 30Mb,
	filegrowth = 5%
)

go 
use gym
go

-- FILE GROUP =========================================================================================================
SELECT * FROM SYS.FILEGROUPS -- Xem thông tin filegroup

-- Tạo filegroup
alter database gym add filegroup FG1 
alter database gym add filegroup FG2 

-- Thêm datafile
alter database gym add file (name = N'F1', filename = 'D:\Project-DuAn\QuanLyPhongGYM_HQTCSDL\F1.ndf') to filegroup FG1
alter database gym add file (name = N'F2', filename = 'D:\Project-DuAn\QuanLyPhongGYM_HQTCSDL\F2.ndf') to filegroup FG1


-- TẠO BẢNG ===========================================================================================================

-- KHÁCH HÀNG _________________________________________________________________________________________________________
create table KHACHHANG
(
	maKH char (10) primary key not null,
	tenKH nvarchar (70) not null,
	ngaySinh date,
	gioiTinh nvarchar (10),
	diaChi nvarchar (80),
	soDT char (11),
) on FG1 -- Chỉ dịnh nơi lưu trữ là filegroup FG1

-- CHI NHÁNH _________________________________________________________________________________________________________
create table CHINHANH
(
	maCN char (10) primary key not null,
	tenCN nvarchar (50) not null,
	maDiaChi char (10),
	diaChi nvarchar (50)
) on FG1 -- Chỉ dịnh nơi lưu trữ là filegroup FG1

-- CƠ SỞ VẬT CHẤT ____________________________________________________________________________________________________
create table CSVC
(
	maThietBi char (10) primary key not null,
	tenThietBi nvarchar (50) not null,
	soLuong int,
	maCN char (10)
) on FG1 -- Chỉ dịnh nơi lưu trữ là filegroup FG1

-- PT (Personal Trainer: HLV cá nhân) ________________________________________________________________________________
create table PT
(
	maPT char (10) primary key not null,
	tenPT nvarchar (50) not null,
	giaThuePT money
) on FG1 -- Chỉ dịnh nơi lưu trữ là filegroup FG1

-- DỊCH VỤ ___________________________________________________________________________________________________________
create table DICHVU
(
	maDV char (10) primary key not null,
	tenDV nvarchar (50) not null,
	giaDV money
) on FG1 -- Chỉ dịnh nơi lưu trữ là filegroup FG1

-- ĐĂNG KÝ ___________________________________________________________________________________________________________
create table DANGKY
(
	maDK char (10) primary key not null,
	maKH char (10) not null,
	maCN char (10)
) on FG1 -- Chỉ dịnh nơi lưu trữ là filegroup FG1

-- CHI TIẾT ĐĂNG KÝ __________________________________________________________________________________________________
create table CTDK
(
	maDK char (10) not null,
	maPT char (10) not null,
	maDV char (10) not null,
	ngayDK date,
	ngayBD date,
	ngayKT date,
	donGia money, -- (donGia = giaDV * soThang + giaThuePT)
	primary key (maDK, maPT, maDV)
) on FG1 -- Chỉ dịnh nơi lưu trữ là filegroup FG1


-- KHÓA NGOẠI ========================================================================================================
alter table DANGKY
add constraint fk_DK_CN foreign key (maCN) references CHINHANH (maCN),
	constraint fk_DK_KH foreign key (maKH) references KHACHHANG (maKH)

alter table CSVC
add constraint fk_CSVC_CN foreign key (maCN) references CHINHANH (maCN)

alter table CTDK
add constraint fk_CTDK_DV foreign key (maDV) references DICHVU (maDV),
	constraint fk_CTDK_DK foreign key (maDK) references DANGKY (maDK),
	constraint fk_CTDK_PT foreign key (maPT) references PT (maPT)


-- TRIGGER ===========================================================================================================

-- KHACHHANG _________________________________________________________________________________________________________
-- maKH là duy nhất --------------------------------------------------------------------------------------------------
alter table KHACHHANG
add constraint uni_maKH unique (maKH)

-- ngaySinh phải trước năm hiện tại ----------------------------------------------------------------------------------
alter table KHACHHANG
add constraint chk_ngaySinh check (year(getdate()) > year(ngaySinh))

-- gioiTinh phải là 'Nam' hoặc 'Nữ' ----------------------------------------------------------------------------------
ALTER TABLE KHACHHANG
ADD CONSTRAINT chk_gioiTinh CHECK (gioiTinh = N'Nam' OR gioiTinh = N'Nữ')

-- soDT phải là số dương và độ dài tối đa 10 ký tự số ----------------------------------------------------------------
alter table KHACHHANG
add constraint chk_soDT check (len(soDT) = 10 and soDT > 0)

-- CSVC ______________________________________________________________________________________________________________
-- maThietBi là duy nhất ---------------------------------------------------------------------------------------------
alter table CSVC
add constraint uni_maThietBi unique (maThietBi)

-- soLuong phải là số dương ------------------------------------------------------------------------------------------
alter table CSVC
add constraint chk_soLuong check (soLuong > 0)

-- PT (Personal Trainer) _____________________________________________________________________________________________
-- maPT là duy nhất --------------------------------------------------------------------------------------------------
alter table PT
add constraint uni_maPT unique (maPT)

-- giaThuePT phải là số dương ----------------------------------------------------------------------------------------
alter table PT
add constraint chk_giaThuePT check (giaThuePT > 0)

-- DICHVU ____________________________________________________________________________________________________________
-- maDV là duy nhất --------------------------------------------------------------------------------------------------
alter table DICHVU
add constraint uni_maDV unique (maDV)

-- giaDV phải là số dương -------------------------------------------------------------------------------------------- 
alter table DICHVU
add constraint chk_giaDV check (giaDV > 0)

-- DANGKY ____________________________________________________________________________________________________________
-- MADK là duy nhất --------------------------------------------------------------------------------------------------
alter table DANGKY
add constraint uni_maDK unique (maDK)

-- CTDK ______________________________________________________________________________________________________________
-- ngayBD phải trước ngayKT ------------------------------------------------------------------------------------------
alter table CTDK
add constraint chk_date check (ngayBD < ngayKT)

-- ngayDK phải trước hoặc trùng với ngayBD ---------------------------------------------------------------------------
alter table CTDK
add constraint chk_date1 check (NgayDK <= NgayBD)

-- donGia phải là số dương -------------------------------------------------------------------------------------------
alter table CTDK
add constraint chk_donGia check (donGia > 0)

-- donGia = giaDV * soThang + giaThuePT ------------------------------------------------------------------------------
create trigger tg_donGia on CTDK
for insert 
as
begin
	update CTDK
		set donGia =( (select giaDV from DICHVU where DICHVU.maDV = CTDK.maDV) * 
		DATEDIFF(M,(select ngayBD from CTDK where CTDK.maDK = inserted.maDK ),(select ngayKT from CTDK 
					where CTDK.maDK = inserted.maDK)) + (select giaThuePT from PT where pt.maPT = CTDK.maPT))
					from CTDK join inserted on CTDK.maDK = inserted.maDK  
end

-- DATA =============================================================================================================

-- KHACHHANG ________________________________________________________________________________________________________
set dateformat DMY;
insert into KHACHHANG
values ('KH001', N'Nguyễn Lê Gia Bảo', '01/01/2001', N'Nam', N'TP.HCM', '0123456788')
insert into KHACHHANG
values ('KH002', N'Lê Bữu Điền', '16/09/2001', N'Nam', N'Bến Tre', '0123456789')
insert into KHACHHANG
values ('KH003', N'Trần Hồng Uyên', '11/07/2002', N'Nữ', N'TP.HCM', '0123456710')
insert into KHACHHANG
values ('KH004', N'Hồ Nguyễn Kim Phụng', '21/03/2001', N'Nữ', N'TP.HCM', '0123456721')
insert into KHACHHANG
values ('KH005', N'Trang Thu An', '03/02/2001', N'Nữ', N'TP.HCM', '0123456733')
insert into KHACHHANG
values ('KH006', N'Hồ Thị Thanh Thảo', '25/11/2001', N'Nữ', N'Vĩnh Long', '0123456799')
insert into KHACHHANG
values ('KH007', N'Mai Thị Cẩm Tiên', '15/07/2001', N'Nữ', N'Cần Thơ', '0123456743')
insert into KHACHHANG
values ('KH008', N'Lê Ngọc Ngân', '05/01/2001', N'Nữ', N'TP.HCM', '0123456744')
insert into KHACHHANG
values ('KH009', N'Mai Tuấn Thành', '25/04/2001', N'Nam', N'Thanh Hóa', '0123456759')
insert into KHACHHANG
values ('KH010', N'Nguyễn Thành Bảo', '11/11/2001', N'Nam', N'Long An', '0123456752')
insert into KHACHHANG
values ('KH011', N'Trần Mỹ Uyên', '17/09/2001', N'Nữ', N'Tiền Giang', '0123454752')
insert into KHACHHANG
values ('KH012', N'Trần Thảo Uyên', '17/09/2001', N'Nữ', N'Tiền Giang', '0123056752')
insert into KHACHHANG
values ('KH013', N'Võ Phúc Trung', '28/11/2001', N'Nam', N'Quảng Nam', '0123453252')
insert into KHACHHANG
values ('KH014', N'Võ Hoàng Triều', '21/03/2001', N'Nam', N'TP. HCM', '0123896752')
insert into KHACHHANG
values ('KH015', N'Trần Thị Mộng Huyền', '05/12/2001', N'Nữ', N'Đồng Tháp', '0123456777')
select * from KHACHHANG

-- CHI NHÁNH ________________________________________________________________________________________________________
insert into CHINHANH
values ('CN001', 'TidyGym1', N'DC001', 'TP. HCM')
insert into CHINHANH
values ('CN002', 'TidyGym2', N'DC002', 'TP. HCM')
insert into CHINHANH
values ('CN003', 'TidyGym3', N'DC003', N'Hà Nội')
insert into CHINHANH
values ('CN004', 'TidyGym4', N'DC004', N'Đà Nẵng')
insert into CHINHANH
values ('CN005', 'TidyGym5', N'DC005', N'TP. HCM')
select * from CHINHANH

-- CƠ SỞ VẬT CHẤT ___________________________________________________________________________________________________
insert into CSVC
values ('TB001', N'Máy tập chân', 2, 'CN001')
insert into CSVC
values ('TB002', N'Máy tập đùi', 2, 'CN001')
insert into CSVC
values ('TB003', N'Máy tập cơ xô', 3, 'CN001')
insert into CSVC
values ('TB004', N'Máy tập ngực, tay sau', 3, 'CN001')
insert into CSVC
values ('TB005', N'Máy kéo cap và ròng rọc', 2, 'CN002')
insert into CSVC
values ('TB006', N'Máy đạp chân ngang', 2, 'CN002')
insert into CSVC
values ('TB007', N'Máy tập cơ ngực', 4, 'CN002')
insert into CSVC
values ('TB008', N'Máy đẩy ngực', 2, 'CN002')
insert into CSVC
values ('TB009', N'Ghế tập ngực đa năng', 2, 'CN003')
insert into CSVC
values ('TB010', N'Máy tập xô vai', 5, 'CN003')
insert into CSVC
values ('TB011', N'Ghế gập tay', 9, 'CN003')
insert into CSVC
values ('TB012', N'Máy tập lưng, xô', 2, 'CN004')
insert into CSVC
values ('TB013', N'Tạ tay', 50, 'CN004')
insert into CSVC
values ('TB014', N'Thanh tạ đòn', 17, 'CN005')
insert into CSVC
values ('TB015', N'Tạ cầm tay', 50, 'CN005')
insert into CSVC
values ('TB016', N'Bánh tạ', 70, 'CN004')
insert into CSVC
values ('TB017', N'Ghế gập bụng', 10, 'CN004')
insert into CSVC
values ('TB018', N'Bóng tập', 30, 'CN005')
insert into CSVC
values ('TB019', N'Bánh xe tập bụng', 7, 'CN001')
insert into CSVC
values ('TB020', N'Máy chạy bộ', 30, 'CN005')
insert into CSVC
values ('TB021', N'Máy tập xe đạp', 26, 'CN005')
select * from CSVC

-- PT (Personal Trainer) ____________________________________________________________________________________________
insert into PT
values ('PT001', 'Thibaut', 1500000)
insert into PT
values ('PT002', 'Fabrice Le Physique', 1000000)
insert into PT
values ('PT003', 'Fabrice', 2000000)
insert into PT
values ('PT004', 'Aaron Williamson', 1500000)
insert into PT
values ('PT005', 'Harley Pasternak', 2000000)
insert into PT
values ('PT006', 'Attila Toth', 2500000)
insert into PT
values ('PT007', 'Dominick Nicolai', 2500000)
insert into PT
values ('PT008', 'Bret Contreras', 1500000)
insert into PT
values ('PT009', 'Jeff Seid', 2500000)
insert into PT
values ('PT010', 'Kayla Itsines', 2000000)
select * from PT

-- DỊCH VỤ __________________________________________________________________________________________________________
insert into DICHVU values (N'DV001', N'Xông hơi', 200000)
insert into DICHVU values (N'DV002', N'Massage', 400000)
insert into DICHVU values (N'DV003', N'Yoga', 320000)
insert into DICHVU values (N'DV004', N'Boxing', 300000)
insert into DICHVU values (N'DV005', N'Gym', 350000)
insert into DICHVU values (N'DV006', N'Aerobic', 250000)
insert into DICHVU values (N'DV007', N'Nước dinh dưỡng, trái cây tươi', 100000)
insert into DICHVU values (N'DV008', N'Vui chơi cho trẻ em', 70000)
select * from DICHVU

-- ĐĂNG KÝ __________________________________________________________________________________________________________
set dateformat DMY;
insert into DANGKY
values ('DK001', 'KH001', 'CN001')
insert into DANGKY
values ('DK002', 'KH002', 'CN002')
insert into DANGKY
values ('DK003', 'KH003', 'CN005')
insert into DANGKY
values ('DK004', 'KH004', 'CN003')
insert into DANGKY
values ('DK005', 'KH005', 'CN001')
insert into DANGKY
values ('DK006', 'KH006', 'CN002')
insert into DANGKY
values ('DK007', 'KH007', 'CN003')
insert into DANGKY
values ('DK008', 'KH008', 'CN004')
insert into DANGKY
values ('DK009', 'KH009', 'CN004')
insert into DANGKY
values ('DK010', 'KH010', 'CN005')
select * from DANGKY

-- CHI TIẾT ĐĂNG KÝ _________________________________________________________________________________________________
set dateformat dmy;
insert into CTDK
values ('DK001', 'PT001', 'DV001', '20/11/2019', '20/11/2019', '20/12/2020', null)
insert into CTDK
values ('DK002', 'PT002', 'DV002', '11/10/2019', '12/10/2019', '11/12/2021', null)
insert into CTDK
values ('DK003', 'PT006', 'DV003', '24/11/2019', '24/11/2019', '24/11/2020', null)
insert into CTDK
values ('DK004', 'PT003', 'DV005', '17/11/2019', '17/11/2019', '17/11/2021', null)
insert into CTDK
values ('DK005', 'PT004', 'DV006', '29/12/2019', '29/12/2019', '29/12/2021', null)
insert into CTDK
values ('DK006', 'PT007', 'DV001', '20/01/2019', '20/01/2019', '20/01/2020', null)
insert into CTDK
values ('DK007', 'PT005', 'DV002', '30/04/2019', '30/04/2019', '30/04/2021', null)
insert into CTDK
values ('DK008', 'PT008', 'DV001', '20/10/2019', '21/10/2019', '20/11/2020', null)
insert into CTDK
values ('DK009', 'PT009', 'DV003', '20/08/2019', '20/08/2019', '20/08/2020', null)
insert into CTDK
values ('DK010', 'PT010', 'DV004', '08/03/2019', '09/03/2019', '08/03/2021', null)
select * from CTDK

	
-- STORED PROCEDURE VÀ FUNCTION =====================================================================================
-- (Thủ tục lưu trữ)  (Chức năng)

-- STORED PROCEDURE _________________________________________________________________________________________________
-- KHÁCH HÀNG -------------------------------------------------------------------------------------------------------
create proc insert_KHACHHANG
@maKH char (10),
@tenKH nvarchar (70),
@ngaySinh date,
@gioiTinh nvarchar (10),
@diaChi nvarchar (80),
@soDT char (11)
as
	begin
		begin
			insert into KHACHHANG 
			values (@maKH, @tenKH, @ngaySinh, @gioiTinh, @diaChi, @soDT)
		end
	end

set dateformat dmy
exec insert_KHACHHANG 'KH100', N'Nguyễn Quang Hải', '20/02/1997', N'Nam', N'TP. Hồ Chí Minh', '0859371821'
	

create proc update_KHACHHANG
@maKH char (10),
@tenKH nvarchar (70),
@ngaySinh date,
@gioiTinh nvarchar (10),
@diaChi nvarchar (80),
@soDT char (11)
as
	begin
		update KHACHHANG
		set tenKH = @tenKH, ngaySinh = @ngaySinh, gioiTinh = @gioiTinh, diaChi = @diaChi, soDT = @soDT
		where maKH = @maKH
	end

set dateformat dmy
exec update_KHACHHANG 'KH014', N'Phan Thanh Bình', '28/09/2001', N'Nam', 'TP. Hồ Chí Minh', '0573920175'


create proc delete_KHACHHANG
@makh char (10)
as
	begin
		delete from KHACHHANG
		where maKH = @makh
	end

exec delete_KHACHHANG 'KH100'


create proc info_KHACHHANG
as
	begin
		select * from KHACHHANG
	end

exec info_KHACHHANG

-- CHI NHÁNH --------------------------------------------------------------------------------------------------------
create proc insert_CHINHANH
@maCN char (10),
@tenCN nvarchar (50),
@maDiaChi char (10),
@diaChi nvarchar (50)
as
	begin	
		begin
			insert into CHINHANH
			values (@maCN, @tenCN, @maDiaChi, @diaChi)
		end
	end

exec insert_CHINHANH 'CN006', N'TidyGym6', 'DC006', N'Cần Thơ'


create proc update_CHINHANH
@maCN char (10),
@tenCN nvarchar (50),
@maDiaChi char (10),
@diaChi nvarchar (50)
as
	begin
		update CHINHANH
		set tenCN = @tenCN, maDiaChi = @maDiaChi, diaChi = @diaChi
		where maCN = @maCN
	end

exec update_CHINHANH 'CN006', N'TidyGym6', 'DC006', N'Bến Tre'


create proc delete_CHINHANH
@maCN char (10)
as
	begin 
		delete from CHINHANH
		where maCN = @maCN
	end

exec delete_CHINHANH 'CN006'


create proc info_CHINHANH
as
	begin
		select * from CHINHANH
	end

exec info_CHINHANH

-- CƠ SỞ VẬT CHẤT ---------------------------------------------------------------------------------------------------
create proc insert_CSVC
@maThietBi char (10),
@tenThietBi char (50),
@soLuong int,
@maCN char (10)
as
	begin
		begin
			insert into CSVC 
			values (@maThietBi, @tenThietBi, @soLuong, @maCN)
		end
	end

exec insert_CSVC 'TB022', N'Thanh đòn dài', 70, 'CN002'


create proc update_CSVC
@maThietBi char (10),
@tenThietBi char (50),
@soLuong int,
@maCN char (10)
as
	begin
		update CSVC
		set tenThietBi = @tenThietBi, soLuong = @soLuong, maCN = @maCN
		where maThietBi = @maThietBi
	end

exec update_CSVC 'TB022', N'Tạ 20kg', 80, 'CN002'


create proc delete_CSVC
@maThietBi char (10)
as
	begin
		delete from CSVC
		where maThietBi = @maThietBi
	end

exec delete_CSVC 'TB022'


create proc info_CSVC
as
	begin
		select * from CSVC
	end

exec info_CSVC

-- PT (Personal Trainer) --------------------------------------------------------------------------------------------
create proc insert_PT
@maPT char (10),
@tenPT nvarchar (50),
@giaThuePT money
as
	begin
		begin
			insert into PT
			values (@maPT, @tenPT, @giaThuePT)
		end
	end

exec insert_PT 'PT011', N'Lý Đức', '900000'


create proc update_PT
@maPT char (10),
@tenPT nvarchar (50),
@giaThuePT money
as
	begin 
		update PT
		set tenPT = @tenPT, giaThuePT = @giaThuePT
		where maPT = @maPT
	end

exec update_PT 'PT011', N'Lý Đức', '950000'


create proc delete_PT
@maPT char (10)
as
	begin
		delete from PT
		where maPT = @maPT
	end

exec delete_PT 'PT011'


create proc info_PT
as
	begin
		select * from PT
	end

exec info_PT

-- DỊCH VỤ ----------------------------------------------------------------------------------------------------------
create proc insert_DICHVU
@maDV char (10),
@tenDV nvarchar (50),
@giaDV money
as
	begin
		begin
			insert into DICHVU
			values (@maDV, @tenDV, @giaDV)
		end
	end

exec insert_DICHVU 'DV100', N'Giữ xe', '5000'


create proc update_DICHVU
@maDV char (10),
@tenDV nvarchar (50),
@giaDV money
as
	begin
		update DICHVU
		set tenDV = @tenDV, giaDV = @giaDV
		where maDV = @maDV
	end

exec update_DICHVU 'DV100', N'Giữ xe', '2000'


create proc delete_DICHVU
@maDV char (10)
as
	begin 
		delete from DICHVU
		where maDV = @maDV
	end

exec delete_DICHVU 'DV100'


create proc info_DICHVU
as
	begin
		select * from DICHVU
	end

exec info_DICHVU

-- ĐĂNG KÝ ----------------------------------------------------------------------------------------------------------
create proc insert_DANGKY
@maDK char (10),
@maKH char (10),
@maCN char (10)
as
	begin
		begin
			insert into DANGKY
			values (@maDK, @maKH, @maCN)
		end
	end 

exec insert_DANGKY 'DK100', 'KH004', 'CN003'


create proc update_DANGKY
@maDK char (10),
@maKH char (10),
@maCN char (10)
as
	begin
		update DANGKY
		set maKH = @maKH, maCN = @maCN
		where maDK = @maDK
	end

exec update_DANGKY 'DK100', 'KH010', 'CN001'


create proc delete_DANGKY
@maDK char (10)
as
	begin
		delete from DANGKY
		where maDK = @maDK
	end

exec delete_DANGKY 'DK100'


create proc info_DANGKY
as
	begin
		select * from DANGKY
	end

exec info_DANGKY

-- CHI TIẾT ĐĂNG KÝ -------------------------------------------------------------------------------------------------
create proc insert_CTDK
@maDK char (10),
@maPT char (10),
@maDV char (10),
@ngayDK date,
@ngayBD date,
@ngayKT date,
@donGia money
as
	begin
		begin 
			insert into CTDK
			values (@maDK, @maPT, @maDV, @ngayDK, @ngayBD, @ngayKT, @donGia)
		end
	end

DROP TRIGGER tg_donGia
exec insert_CTDK 'DK003', 'PT007', 'DV001', '11/11/2020', '11/11/2020', '11/11/2021', null


create proc update_CTDK
@maDK char (10),
@maPT char (10),
@maDV char (10),
@ngayDK date,
@ngayBD date,
@ngayKT date,
@donGia money
as
	begin
		update CTDK
		set maPT = @maPT, maDV = @maDV, ngayDK = @ngayDK, ngayBD = @ngayBD, ngayKT = @ngayKT, donGia = @donGia
		where maDK = @maDK and maPT = @maPT and maDV = @maDV
	end

exec update_CTDK 'DK003', 'PT007', 'DV001', '11/11/2020', '12/11/2020', '12/11/2021', null


create proc delete_CTDK
@maDK char (10),
@maPT char (10),
@maDV char (10)
as
	begin
		delete from CTDK
		where maDK = @maDK and maPT = @maPT and maDV = @maDV
	end

exec delete_CTDK 'DK003', 'PT007', 'DV001'


create proc info_CTDK
as
	begin
		select * from CTDK
	end

exec info_CTDK

-- FUNCTION _________________________________________________________________________________________________________
-- Đếm số lượng khách hàng ------------------------------------------------------------------------------------------
create function count_KH()
returns table
as
	return (select count(maKH) as N'Tổng số khách hàng'
			from KHACHHANG)

select * from count_KH()

-- Đếm số lượng CHINHANH có địa chỉ ở TP. HCM -----------------------------------------------------------------------
create function count_CN_HCM()
returns table
as
	return (select count(maCN) as N'Số chi nhánh tại TP. HCM'
			from CHINHANH
			where diaChi = 'TP. HCM')

select * from count_CN_HCM()

-- Đếm số lượng PT --------------------------------------------------------------------------------------------------
create function count_PT()
returns table
as
	return (select count(maPT) as N'Số lượng PT' 
			from PT)

select * from count_PT()

-- Đếm số lượng PT có giaThuePT trên 2.000.000 ----------------------------------------------------------------------
create function count_PT_GiaThueTren2000000()
returns table
as
	return (select count(maPT) as N'Số PT có giá thuê trên 2.000.000'
			from PT
			where giaThuePT > 2000000)

select * from count_PT_GiaThueTren2000000()

-- Đếm số lượng ngayDK trong tháng 11 -------------------------------------------------------------------------------
create function count_ngayDK_Thang11()
returns table
as
	return (select count(maDK) as N'Tổng đơn đăng ký trong tháng 11'
			from CTDK
			where MONTH(ngayDK) = 11)

select * from count_ngayDK_Thang11()

-- Chỉ ra giaDV cao nhất --------------------------------------------------------------------------------------------
create function max_giaDV()
returns table
as
	return (select max(giaDV) as N'Giá dịch vụ cao nhất'
			from DICHVU)

select * from max_giaDV()

-- Chỉ ra giaDV thấp nhất -------------------------------------------------------------------------------------------
create function min_giaDV()
returns table
as
	return (select min(giaDV) as N'Giá dịch vụ thấp nhất'
			from DICHVU)

select * from min_giaDV()


-- BẢO MẬT VÀ PHÂN QUYỀN CƠ SỞ DỮ LIỆU ==============================================================================
-- BẢO MẬT __________________________________________________________________________________________________________
alter database gym	-- thay đổi mô hình khôi phục trong CSDL gym
set recovery full	-- thành full recovery

-- Backup ___________________________________________________________________________________________________________
-- fullbakup --------------------------------------------------------------------------------------------------------
set dateformat dmy
insert into KHACHHANG
values ('KH016', N'Lý Uyễn Nhi', '05/12/2001', N'Nữ', N'TP. Hồ Chí Minh', '0123111777')

backup database gym 
to disk = 'D:\gym_full.bak' 
with init, description = 'Backup full Vao O Dia D' 

-- differential backup 1 --------------------------------------------------------------------------------------------
set dateformat dmy
insert into KHACHHANG
values ('KH017', N'Đỗ Duy Phương', '05/11/2001', N'Nam', N'TP. Hồ Chí Minh', '0123000777')

backup database gym 
to disk = 'D:\gym_diff.bak' 
with init, differential

-- differential backup 2 --------------------------------------------------------------------------------------------
set dateformat dmy
insert into KHACHHANG
values ('KH018', N'Phạm Gia Bảo', '05/10/2001', N'Nam', N'Tây Ninh', '0123001177')

BACKUP DATABASE gym 
TO DISK = 'D:\gym_diff.bak'
WITH DIFFERENTIAL

-- log backup 1 -----------------------------------------------------------------------------------------------------
set dateformat dmy
insert into KHACHHANG
values ('KH019', N'Phạm Gia Đạt', '05/09/2001', N'Nam', N'TP. Hồ Chí Minh', '0183927591')

backup log gym 
to disk = 'D:\gym_log.trn' 
WITH INIT

-- log backup 2 -----------------------------------------------------------------------------------------------------
set dateformat dmy
insert into KHACHHANG
values ('KH020', N'Nguyễn Công Phượng', '05/09/1996', N'Nam', N'TP. Hồ Chí Minh', '0183921191')

BACKUP LOG gym 
TO DISK = 'D:\gym_log.trn'


-- RESTORE __________________________________________________________________________________________________________
-- Đầu tiên backup log tail_caiDuoi ---------------------------------------------------------------------------------
BACKUP LOG gym 
TO DISK= 'D:\gym_log.trn' 
with no_truncate

-- Bước 1: Phục hồi lại sử dụng file backup full gần nhất -----------------------------------------------------------
restore database gym 
from disk = 'D:\gym_full.bak' 
with replace, norecovery

-- Bước 2: Phục hồi lại differential backup gần nhất ----------------------------------------------------------------
restore database gym
from disk ='D:\gym_diff.bak'
with file = 2, norecovery

-- Bước 3: Phục hồi lại log backup từ sau lần differential backup gần nhất ------------------------------------------
restore database gym 
from disk = 'D:\gym_log.trn' 
with file = 1, norecovery

restore database gym 
from disk = 'D:\gym_log.trn' 
with file = 2, norecovery

restore database gym 
from disk = 'D:\gym_log.trn' 
with file = 3, recovery


-- PHÂN QUYỀN CƠ SỞ DỮ LIỆU _________________________________________________________________________________________
-- Tạo các tài khoản ------------------------------------------------------------------------------------------------
sp_addlogin 'Manager', 'M123'		-- Tạo login truy cập vào hệ thống
sp_adduser 'Manager', 'Manager'		-- Tạo user truy cập vào database

sp_addlogin 'Staff', 'S123'			-- Tên đăng nhập, mật khẩu
sp_adduser 'Staff', 'Staff'			-- Tên đăng nhập, Tên người dùng	

sp_addlogin 'Customer', 'C123' 
sp_adduser 'Customer', 'Customer'

-- Tạo các nhóm quyền -----------------------------------------------------------------------------------------------
-- Ban quản lý
sp_addrole 'BQL'
grant select, insert, delete, update
on KHACHHANG
to BQL

grant select, insert, delete, update
on CHINHANH
to BQL

grant select, insert, delete, update
on CSVC
to BQL

grant select, insert, delete, update
on PT
to BQL

grant select, insert, delete, update
on DICHVU
to BQL

grant select, insert, delete, update
on DANGKY
to BQL

grant select, insert, delete, update
on CTDK
to BQL

-- Nhân viên --------------------------------------------------------------------------------------------------------
sp_addrole 'NV'
grant select, insert, update 
on DANGKY
to NV

grant select, insert, update
on CTDK
to NV

-- Khách hàng -------------------------------------------------------------------------------------------------------
sp_addrole 'KH'
grant select
on KHACHHANG
to KH

grant select
on PT
to KH

grant select
on DICHVU
to KH

-- Thêm các tài khoản vào các nhóm quyền tương ứng ------------------------------------------------------------------
sp_addrolemember 'BQL', 'Manager'	-- Thêm user 'Manager' vào nhóm quyền 'BQL'
sp_addrolemember 'NV', 'Staff' 
sp_addrolemember 'KH', 'Customer'


--___________________________________________________________________________________________________________________
-- Môn học: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU.
-- Đề tài: QUẢN LÝ PHÒNG GYM.

-- Thành viên thực hiện:
-- 1. Lê Bữu Điền - 2001190473 (Nhóm trưởng).
-- 2. Nguyễn Lê Gia Bảo - 2001190421.
-- 3. Đỗ Duy Phương - 2001190754.
-- 4. Lý Uyễn Nhi - 2008192120.