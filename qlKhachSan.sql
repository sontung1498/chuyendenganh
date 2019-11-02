create database qlKhachSan
use qlKhachSan

drop database qlKhachSan

create table tblChiTiet_Phong
(
	maLoaiPhong int identity(1,1) primary key,
	tenLoaiPhong Nvarchar(30),
	donGiaNgay int not null,
	donGiaGio int not null,
	donGia2GioDau int not null
)

create table tblPhong
(
	maPhong int identity(1,1) primary key,
	soPhong int not null,
	maLoaiPhong int,
	tinhTrang bit,
	
	constraint FK_Phong_CTphong 
	FOREIGN KEY (maLoaiPhong) 
	references tblChiTiet_phong(maLoaiPhong)
)

create table tblNhanVien
(
	maNhanVien int identity(1,1) primary key,
	tenNhanVien Nvarchar(30),
	ngaySinh smalldatetime,
	gioiTinh bit,
	ngayVaoLam smalldatetime,
	diaChi Nvarchar(50)
)

create table tblKhachHang
(
	maKhachHang int identity(1,1) primary key,
	tenKhachHang Nvarchar(30),
	soCMT varchar(15) unique,
	soDT varchar(15),
	ngaySinh smalldatetime,
	gioiTinh bit
)



create table tblDichVu
(
	maDichVu int identity(1,1) primary key,
	tenDichVu Nvarchar(30),
	donGia int
)

create table tblHoaDon
(
	maHoaDon int identity(1,1) primary key,
	maKhachHang int not null references tblKhachHang(maKhachHang),
	maNhanVien int not null references tblNhanVien(maNhanVien),
	ngayLap datetime default(getdate()),
)

create table tblHD_datPhong
(
	maHoaDon int references tblHoaDon(maHoaDon),
	tgDat datetime default(getdate()),
	tienCoc int default('0')
)

create table tblHD_phong
(
	maHoaDon int references tblHoaDon(maHoaDon),
	maPhong int references tblPhong(maPhong),
	gioCheckIn datetime,
	gioCheckOut datetime,

)

create table tblHD_dichvu
(
	mahoaDon int references tblHoaDon(maHoaDon),
	maPhong int references tblPhong(maPhong),
	maDichVu int references tblDichVu(maDichVu),
	soLanSD int default('0')
)
--view---

--kiem tra thoi gian su dung cac phong trong hoa don--

create view tgsudung
as
select hdp.maHoaDon, hdp.maPhong, p.soPhong , datediff(HOUR,hdp.gioCheckIn,hdp.gioCheckOut) as 'gio su dung'
from tblHD_phong as hdp, tblPhong as p
where hdp.maPhong = p.maPhong

drop view tgsudung

select*from tgsudung

--kiem tra cac hoa don duoc lap trong thang nay--

create view hoadontrongthang
as
select hd.maHoaDon, kh.tenKhachHang, nv.tenNhanVien, hd.ngayLap
from tblHoaDon as hd, tblKhachHang as kh, tblNhanVien as nv
where MONTH(ngayLap) = MONTH(GETDATE()) and hd.maKhachHang = kh.maKhachHang and hd.maNhanVien = nv.maNhanVien

select*from hoadontrongthang
go
-- kiểm tra các dịch vụ sử dụng của từng phòng trong hóa đơn--

create view ktdichvu
as
select tblHoaDon.maHoaDon, tblPhong.soPhong, tblDichVu.tenDichVu, tblHD_dichvu.soLanSD
from tblHD_dichvu
inner join tblHoaDon on tblHD_dichvu.mahoaDon = tblHoaDon.maHoaDon
inner join tblPhong on tblHD_dichvu.maPhong = tblPhong.maPhong
inner join tblDichVu on tblHD_dichvu.maDichVu = tblDichVu.maDichVu

select*from ktdichvu
-- hien thi cac so tien coc cua tung hoa don--

create view kttiencoc
as
select tblHoaDon.maHoaDon, tblKhachHang.tenKhachHang,tblHD_datPhong.tgDat as 'thoi gian dat phong', tblHD_datPhong.tienCoc
from tblHD_datPhong 
 inner join tblHoaDon on tblHoaDon.maHoaDon = tblHD_datPhong.maHoaDon
 inner join tblKhachHang on tblKhachHang.maKhachHang = tblHoaDon.maKhachHang
 group by tblHoaDon.maHoaDon,tblKhachHang.tenKhachHang,tblHD_datPhong.tgDat,tblHD_datPhong.tienCoc

 select*from kttiencoc



--

-- rang buoc trigger va proc--
go



-- lập hóa đơn--
create proc laphoadon
(
	@maKhachHang int, @maNhanVien int, @tienCoc int
)
as
begin
	insert into tblHoaDon( maKhachHang, maNhanVien)
	values (@maKhachHang, @maNhanVien)
	select @@identity 
	insert into tblHD_datPhong(maHoaDon,tienCoc)
	values(@@IDENTITY,@tienCoc)
end

go

exec laphoadon '5','2','200000'
go
-- kiểm tra hóa đơn bằng cách nhập vào số hóa đơn--

create proc ktHoaDon
(
	@maKhachHang int
)
as
begin
	select kh.maKhachHang as 'mã khách hàng', kh.tenKhachHang as 'tên Khách hàng', hd.maHoaDon as 'mã hóa đơn', 
	hd.ngayLap as 'ngày lập',nv.tenNhanVien as 'người lập' , hdp.tienCoc as 'tiền cọc'
	from tblKhachHang as kh, tblHoaDon as hd, tblNhanVien as nv, tblHD_datPhong as hdp
	where @maKhachHang = hd.maKhachHang and hd.maKhachHang = kh.maKhachHang and hd.maHoaDon = hdp.maHoaDon 
	and hd.maNhanVien = nv.maNhanVien
end
go

exec ktHoaDon '3'
go

-- kiểm tra các phòng trong hóa đơn bằng cách nhập vào số hóa đơn--
create proc kiemtraphong_hd
(
	@maHoaDon int
)
as
begin
	select hd.maHoaDon as 'mã hóa đơn', hdp.maPhong as 'mã phòng', p.soPhong as 'số phòng'
	from tblHoaDon as hd, tblHD_phong as hdp, tblPhong as p
	where @maHoaDon = hd.maHoaDon and hd.maHoaDon = hdp.maHoaDon and hdp.maPhong= p.maPhong
end

exec kiemtraphong_hd '1'
go


-- cập nhật các phòng được khách hàng thuê--
create proc thuePhong
(
	@maHoaDon int, @maPhong int
)
as
begin
	insert into tblHD_phong(maHoaDon,maPhong)
	values (@maHoaDon, @maPhong)
end
go

exec thuePhong '7','5'
exec thuePhong '1','5'
go

-- cập nhật thời gian check in của từng phòng--
create proc updateNhanPhong
(
	@maHoaDon int, @maPhong int
)
as
begin
	declare @gioCheckIn datetime
	set @gioCheckIn = GETDATE()
	update tblHD_phong
	set gioCheckIn = @gioCheckIn
	where @maHoaDon = maHoaDon and @maPhong = maPhong
end

exec updateNhanPhong '6' , '8'
go


-- cập nhật thời gian check out của từng phòng--
create proc updateTraPhong
(
	@maHoaDon int, @maPhong int
)
as
begin
	declare @gioCheckOut datetime
	set @gioCheckOut = GETDATE()
	update tblHD_phong
	set gioCheckOut = @gioCheckOut
	where @maHoaDon = maHoaDon and @maPhong = maPhong
end
go

exec updateTraPhong '6','4'
--xuất hóa đơn cho khách hàng--

create proc xuathd
(
	@mahoadon int, @maphong int
)
as
begin
	declare @thoigiansudung int, @tongtien int
	set @thoigiansudung = (select datediff(HOUR,tblHD_phong.gioCheckIn,tblHD_phong.gioCheckOut) from tblHD_phong where @mahoadon = tblHD_phong.maHoaDon and @maphong = tblHD_phong.maPhong)
	if(@thoigiansudung<3)
		begin
			set  @tongtien = (select ((@thoigiansudung* tblChiTiet_Phong.donGia2GioDau)+(tblHD_dichvu.soLanSD*tblDichVu.donGia)-tblHD_datPhong.tienCoc) 
			from tblHoaDon, tblHD_phong, tblHD_dichvu, tblPhong,  tblDichVu, tblChiTiet_Phong, tblHD_datPhong
			where @mahoadon = tblHoaDon.maHoaDon and @maphong = tblHD_phong.maPhong and tblHoaDon.maHoaDon = tblHD_dichvu.mahoaDon and
			tblHoaDon.maHoaDon = tblHD_phong.maHoaDon and tblHD_dichvu.maDichVu = tblDichVu.maDichVu and 
			tblHD_phong.maPhong= tblPhong.maPhong and tblPhong.maLoaiPhong = tblChiTiet_Phong.maLoaiPhong)
			end
	else
		begin
			set  @tongtien = (select ((@thoigiansudung* tblChiTiet_Phong.donGiaGio)+(tblHD_dichvu.soLanSD*tblDichVu.donGia)-tblHD_datPhong.tienCoc) 
			from tblHoaDon, tblHD_phong, tblHD_dichvu, tblPhong,  tblDichVu, tblChiTiet_Phong, tblHD_datPhong
			where @mahoadon = tblHoaDon.maHoaDon and @maphong = tblHD_phong.maPhong and tblHoaDon.maHoaDon = tblHD_dichvu.mahoaDon and
			tblHoaDon.maHoaDon = tblHD_phong.maHoaDon and tblHD_dichvu.maDichVu = tblDichVu.maDichVu and 
			tblHD_phong.maPhong= tblPhong.maPhong and tblPhong.maLoaiPhong = tblChiTiet_Phong.maLoaiPhong)
		end
	select hd.maHoaDon, nv.tenNhanVien as 'nguoi lap', kh.tenKhachHang, p.soPhong, @tongtien as 'tong tien'
	from tblHoaDon as hd, tblNhanVien as nv, tblKhachHang as kh, tblHD_phong as hdp, tblHD_dichvu as hddv, tblPhong as p, tblDichVu as dv, tblChiTiet_Phong as ctp, tblHD_datPhong as hddp
	where @mahoadon = hd.maHoaDon and @maphong = hdp.maPhong and hd.maKhachHang = kh.maKhachHang and hd.maHoaDon = hddp.maHoaDon and
	hd.maNhanVien = nv.maNhanVien and hd.maHoaDon = hdp.maHoaDon and hdp.maPhong = p.maPhong and 
	p.maLoaiPhong = ctp.maLoaiPhong and hd.maHoaDon = hddv.mahoaDon and hddv.maDichVu = dv.maDichVu
end

drop proc xuathd

exec xuathd '6', '4'

--trigger khi thêm phòng vào hóa đơn đặt phòng- tình trạng phòng đó phải là true--

create trigger KTtinhtrangphong
on tblHD_phong
for insert, update
as
	if(UPDATE(maPhong))
	begin
		declare @tinhTrang bit, @maPhong int
		set @maPhong = (select maPhong from inserted)
		set @tinhTrang = (select tblPhong.tinhTrang from tblPhong where @maPhong = tblPhong.maPhong)
		if(@tinhTrang = 0)
		begin
			print(N'phòng đã được thuê hoặc đang sửa chữa')
			rollback tran
		end
		else
			begin
			print(N'Phòng được đặt thành công')
			end
	end

--trigger update lai tinh trang phong sau khi khach den nhan nhan phong--

create trigger upttphong
on tblHD_Phong
for insert, update
as
	if(UPDATE(gioCheckIn))
	begin	
		update tblPhong set tinhTrang = 0 
		from inserted
		where tblPhong.maPhong = inserted.maPhong
		print(N'đã cập nhật lại tình trạng phòng')
end

--trigger update lai tinh trang phong sau khi duoc tra phong--

create trigger upttphong2
on tblHD_Phong
for insert, update
as
	if(UPDATE(gioCheckOut))
	begin	
		update tblPhong set tinhTrang = 1 
		from inserted
		where tblPhong.maPhong = inserted.maPhong
		print(N'đã cập nhật lại tình trạng phòng')
end



