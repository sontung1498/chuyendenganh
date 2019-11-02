create database quanlykhachsan
use quanlykhachsan


create table tblKhachHang(
	maKhachHang int Identity(1,1) primary key,
	tenKhachHang Nvarchar(50),
	soCMT varchar(15),
	soDT varchar(15),
	ngaySinh smalldatetime
);
--ràng buộc mỗi khách hàng chỉ có 1 số CMT--
alter table tblKhachHang
add constraint unique_cmt unique (soCMT)


create table tblNhanVien(
	maNhanVien int Identity(1,1) primary key,
	tenNhanVien Nvarchar(50),
	ngaySinh smalldatetime,
	gioiTinh bit,
	ngayVaoLam smalldatetime,
	diaChi Nvarchar(50)
);

create table tblChiTiet_phong(
	maLoaiPhong int Identity(1,1) primary key,
	tenLoaiPhong Nvarchar(20),
	donGiaNgay int,
	donGiaGio int
);

alter table tblChiTiet_phong
add donGia2Giodau int;

create table tblPhong(
	maPhong int Identity(1,1) primary key,
	soPhong int,
	maLoaiPhong int references tblChiTiet_phong(maLoaiPhong) 
);

alter table tblPhong
add tinhTrang bit;


create table tblDichVu(
	maDichVu int Identity(1,1) primary key,
	tenDichVu Nvarchar(50),
	donGia int
);

create table tblHD_datphong(
	maHoaDon int references tblHoaDon(maHoaDon),
	thoiGianDat datetime default(getdate()),
	tienCoc int
)
alter table tblHD_datphong
add maHoaDon int references tblHoaDon(maHoaDon)

create table tblHoaDon(
	maHoaDon int Identity(1,1) primary key,
	maNhanVien int references tblNhanVien(maNhanVien),
	maKhachHang int references tblKhachHang(maKhachHang),
	ngayLap datetime default(getdate()),
);


create table tblHD_phong(
	maHoaDon int references tblHoaDon(maHoaDon),
	maPhong int references tblPhong(maPhong),
	gioCheckIn smalldatetime,
	gioCheckOut smalldatetime,
);


drop table tblHD_dichvu
create table tblHD_dichvu(
	maHoaDon int references tblHoaDon(maHoaDon),
	maDichVu int references tblDichVu(maDichVu),
	maPhong int references tblPhong(maPhong),
	soLanSuDung int
);

--có thể thừa

create table tblKhachHang_dv(
	maKhachHang int references tblKhachHang(maKhachHang),
	maDichVu int references tblDichVu(maDichVu)
);


create table tblPhong_dv(
	maPhong int references tblPhong(maPhong),
	maDichVu int references tblDichVu(maDichVu)
);

--chú thích

select tblHoaDon.maHoaDon, tblKhachHang.tenKhachHang, tblNhanVien.tenNhanVien, tblHoaDon.ngayLap
from tblHoaDon, tblKhachHang, tblNhanVien
where tblHoaDon.maKhachHang = tblKhachHang.maKhachHang and tblHoaDon.maNhanVien =  tblNhanVien.maNhanVien


insert into tblNhanVien(tenNhanVien,ngaySinh,gioiTinh,ngayVaoLam,diaChi)
values(N'Cao Sơn Tùng','09/14/1998','1','09/18/2019',N'Yên Bái')

select*from tblNhanVien

--hóa đơn--

create proc laphoadon 
(
	@maNhanVien int, @maKhachHang int 

)
as
begin
	insert into tblHoaDon 