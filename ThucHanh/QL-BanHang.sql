-- QUẢN LÝ BÁN HÀNG

USE QLBH

--I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):

--1. Tạo các quan hệ và khai báo các khóa chính, khóa ngoại của quan hệ.

CREATE DATABASE QLBH

CREATE TABLE KHACHHANG
(
	MAKH char(4) NOT NULL,
	HOTEN varchar (40),
	DCHI varchar (50),
	SODT varchar (20),
	NGSINH smalldatetime,
	NGDK smalldatetime,
	DOANHSO money
)

CREATE TABLE NHANVIEN
(
	MANV char(4) NOT NULL,
	HOTEN varchar(40),
	SODT varchar(20),
	NGVL smalldatetime
)

CREATE TABLE SANPHAM 
(
	MASP char(4) NOT NULL,
	TENSP varchar(40),
	DVT varchar(20),
	NUOCSX varchar(40),
	GIA money
)

CREATE TABLE HOADON
(
	SOHD int NOT NULL,
	NGHD smalldatetime,
	MAKH char(4),
	MANV char(4),
	TRIGIA money
)

CREATE TABLE CTHD
(
	SOHD int NOT NULL,
	MASP char(4),
	SL int
)
ALTER TABLE CTHD ALTER COLUMN MASP char(4) NOT NULL

-- Xác định khóa chính cho các bảng

ALTER TABLE KHACHHANG ADD CONSTRAINT PK_KH PRIMARY KEY (MAKH)
ALTER TABLE NHANVIEN ADD CONSTRAINT PK_NV PRIMARY KEY (MANV)
ALTER TABLE SANPHAM ADD CONSTRAINT PK_SP PRIMARY KEY (MASP)
ALTER TABLE HOADON ADD CONSTRAINT PK_HD PRIMARY KEY (SOHD)
ALTER TABLE CTHD ADD CONSTRAINT PK_CTHD PRIMARY KEY (SOHD, MASP)

--Xác định khóa ngoại

ALTER TABLE HOADON ADD 
CONSTRAINT FK_HD_NV FOREIGN KEY (MANV) REFERENCES NHANVIEN (MANV),
CONSTRAINT FK_HD_KH FOREIGN KEY (MAKH) REFERENCES KHACHHANG (MAKH)

ALTER TABLE CTHD ADD
CONSTRAINT FK_CTHD_HD FOREIGN KEY (SOHD) REFERENCES HOADON(SOHD),
CONSTRAINT FK_CTHD_SP FOREIGN KEY (MASP) REFERENCES SANPHAM(MASP)

--2. Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM.
ALTER TABLE SANPHAM ADD GHICHU varchar(20)

--3. Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG.
ALTER TABLE KHACHHANG ADD LOAIKH tinyint

--4. Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).
ALTER TABLE SANPHAM ALTER COLUMN GHICHU varchar(100)

--5. Xóa thuộc tính GHICHU trong quan hệ SANPHAM.
ALTER TABLE SANPHAM DROP COLUMN GHICHU

--6. Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: 'Vanglai', “Thuong xuyen”, “Vip”, …
ALTER TABLE KHACHHANG ALTER COLUMN LOAIKH varchar(20)
ALTER TABLE KHACHHANG ADD CONSTRAINT CK_LOAIKH CHECK (LOAIKH = 'Vang lai' OR LOAIKH = 'Thuong xuyen' OR LOAIKH = 'Vip')

--7. Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”)
ALTER TABLE SANPHAM ADD CONSTRAINT CK_DVT CHECK (DVT='cay' OR DVT='hop' OR DVT='cai' OR DVT='quyen' OR DVT='chuc')

--8. Giá bán của sản phẩm từ 500 đồng trở lên.
ALTER TABLE SANPHAM ADD CONSTRAINT CK_GIA CHECK (GIA>500)

--9. Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.
ALTER TABLE CTHD ADD CONSTRAINT CK_SL CHECK (SL>=1)

--10. Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.
ALTER TABLE KHACHHANG ADD CONSTRAINT CK_NGAYDK CHECK (NGDK > NGSINH)

--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó 
--đăng ký thành viên (NGDK).
CREATE TRIGGER TRG_KHACHHANG_11
ON KHACHHANG
AFTER UPDATE
AS
BEGIN
	DECLARE @ngayhd smalldatetime, @ngaydk smalldatetime, @makh char(4)
	SELECT @ngaydk = NGDK, @makh = MAKH
	FROM INSERTED
	SELECT @ngayhd = NGHD
	FROM HOADON
	WHERE MAKH = @makh
	IF (@ngayhd < @ngaydk)
		BEGIN
			PRINT 'LOI: NGAY DANG KY KHONG DUNG!'
			ROLLBACK TRANSACTION
		END
END

CREATE TRIGGER TRG_HOADON_11
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @ngayhd smalldatetime, @ngaydk smalldatetime, @makh char(4)
	SELECT @ngayhd = NGHD, @makh = MAKH
	FROM INSERTED
	SELECT @ngaydk = NGDK
	FROM KHACHHANG
	WHERE MAKH = @makh
	IF (@ngayhd < @ngaydk)
		BEGIN
			PRINT 'LOI: NGAY HOA DON KHONG DUNG!'
			ROLLBACK TRANSACTION
		END
END

--TEST:
INSERT INTO KHACHHANG (MAKH, NGDK) VALUES ('EX1', '20220101')
INSERT INTO HOADON (SOHD, MAKH, NGHD) VALUES ('3333','EX1','20230101')
INSERT INTO HOADON (SOHD, MAKH, NGHD) VALUES ('4444','EX1','20200101')
SELECT * FROM KHACHHANG
SELECT * FROM HOADON
UPDATE KHACHHANG
SET NGDK = '20230505'
WHERE MAKH = 'EX1'
DELETE FROM HOADON
WHERE SOHD = '3333'
DELETE FROM KHACHHANG
WHERE MAKH = 'EX1'

--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
CREATE TRIGGER TRG_NHANVIEN_12
ON NHANVIEN
AFTER UPDATE
AS
BEGIN
	DECLARE @ngayhd smalldatetime, @ngayVL smalldatetime, @maNV char(4)
	SELECT @ngayVL = NGVL, @manv = MANV
	FROM INSERTED
	SELECT @ngayhd = NGHD
	FROM HOADON
	WHERE MANV = @manv
	IF (@ngayhd < @ngayvl)
		BEGIN
			PRINT 'LOI: NGAY VAO LAM KHONG DUNG!'
			ROLLBACK TRANSACTION
		END
END

CREATE TRIGGER TRG_HOADON_12
ON HOADON
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @ngayhd smalldatetime, @ngayVL smalldatetime, @manv char(4)
	SELECT @ngayhd = NGHD, @manv = MANV
	FROM INSERTED
	SELECT @ngayvl = NGVL
	FROM NHANVIEN
	WHERE MANV = @manv
	IF (@ngayhd < @ngayvl)
		BEGIN
			PRINT 'LOI: NGAY HOA DON KHONG DUNG!'
			ROLLBACK TRANSACTION
		END
END

--13. Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.
CREATE TRIGGER TRG_CTHD_13
ON CTHD
FOR DELETE,UPDATE
AS
	DECLARE @SL INT, @SOHD INT
	SELECT @SL=COUNT(CTHD.SOHD),@SOHD=DELETED.SOHD
	FROM  DELETED ,CTHD
	WHERE CTHD.SOHD=DELETED.SOHD
	GROUP BY DELETED.SOHD

IF(@SL<1)
BEGIN
DELETE FROM HOADON
WHERE  SOHD=@SOHD
PRINT 'DA DELETE CTHD CUOI CUNG CUA HOADON TREN'
END 
 
CREATE TRIGGER TRG_HOADON_13
ON HOADON
FOR INSERT
AS
BEGIN
	DECLARE @SOHD INT
	SELECT @SOHD=SOHD
	FROM  INSERTED
	UPDATE CTHD
	SET  MASP='NONE',SL=0
	WHERE SOHD=@SOHD
	PRINT 'DE NGHI UPDATE LAI CTHD(MAC DINH:MASP="NONE", SL=0)'
END

DELETE FROM HOADON WHERE SOHD = '4444'
SELECT * FROM HOADON
INSERT INTO HOADON (SOHD) VALUES ('4444')
SELECT * FROM CTHD

--14. Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
-- Trigger for INSERT and UPDATE //giống phần trong hướng dẫn Lab 5
CREATE TRIGGER TRG_HOADON_14
ON CTHD
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @sohd INT, @tongtien MONEY
    SELECT @sohd = SOHD FROM inserted
    SELECT @tongtien = SUM(SL * GIA) FROM CTHD, SANPHAM WHERE CTHD.MASP = SANPHAM.MASP AND SOHD = @sohd
    UPDATE HOADON SET TRIGIA = @tongtien WHERE SOHD = @sohd
END

CREATE TRIGGER TRG_DEL_HOADON_14
ON CTHD
AFTER DELETE
AS
BEGIN
    DECLARE @sohd INT, @tongtien MONEY
    SELECT @sohd = SOHD FROM deleted
    SELECT @tongtien = SUM(SL * GIA) FROM CTHD, SANPHAM WHERE CTHD.MASP = SANPHAM.MASP AND SOHD = @sohd
    UPDATE HOADON SET TRIGIA = @tongtien WHERE SOHD = @sohd
END

--INSERT INTO HOADON (SOHD, TRIGIA) VALUES('2222',0)
--INSERT INTO CTHD (SOHD, MASP, SL) VALUES ('2222', 'TV02',2)
--SELECT * FROM HOADON
--DELETE FROM HOADON WHERE SOHD = '2222'

--15. Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó đã mua.
-- Trigger for INSERT, DELETE and UPDATE on HOADON
CREATE TRIGGER TRG_CTHD_15
ON CTHD
FOR INSERT
AS
BEGIN
	DECLARE @SoHD INT, @MaSP CHAR(4), @SoLg INT, @TriGia MONEY
	SELECT @SoHD = SOHD, @MaSP = MASP, @SoLg = SL
	FROM INSERTED
	SET @TriGia = @SoLg * (SELECT GIA FROM SANPHAM WHERE MASP = @MaSP)
	DECLARE CUR_CTHD CURSOR
	FOR
		SELECT MASP, SL
		FROM CTHD 
		WHERE SOHD = @SoHD

	OPEN CUR_CTHD
	FETCH NEXT FROM CUR_CTHD
	INTO @MaSP, @SoLg

	WHILE (@@FETCH_STATUS =0)
	BEGIN
		SET @TriGia = @TriGia + @SoLg * (SELECT GIA FROM SANPHAM WHERE MASP = @MaSP)
		FETCH NEXT FROM CUR_CTHD
		INTO @MaSP, @SoLg
	END

	CLOSE CUR_CTHD
	DEALLOCATE CUR_CTHD
	UPDATE HOADON
	SET TRIGIA = @TriGia 
	WHERE SOHD = @SoHD
END

--II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language)

--1. Nhập dữ liệu cho các quan hệ trên.

INSERT INTO NHANVIEN VALUES ('NV01', 'Nguyen Nhu Nhut', '0927345678', '20060413'),
('NV02', 'Le Thi Phi Yen', '0987567390', '20060421'),
('NV03', 'Nguyen Van B', '0997047382', '20060427'),
('NV04', 'Ngo Thanh Tuan', '0913758498', '20060624'),
('NV05', 'Nguyen Thi Truc Thanh', '0918590387', '20060720');
SELECT * FROM NHANVIEN
---
INSERT INTO KHACHHANG VALUES 
('KH01', 'Nguyen Van A', '731 Tran Hung Dao, Q5, TpHCM', '08823451', '19601022', '20060722',13060000, NULL),
('KH02', 'Tran Ngoc Han', '23/5 Nguyen Trai, Q5, TpHCM', '0908256478', '19740403', '20060730',280000, NULL),
('KH03', 'Tran Ngoc Linh', '45 Nguyen Canh Chan, Q1, TpHCM', '0938776266', '19800612', '20060805',3860000, NULL),
('KH04', 'Tran Minh Long', '50/34 Le Dai Hanh, Q10, TpHCM', '0917325476', '19650309', '20061002',250000, NULL),
('KH05', 'Le Nhat Minh', '34 Truong Dinh, Q3, TpHCM', '08246108', '19500310', '20061028', 21000, NULL),
('KH06', 'Le Hoai Thuong', '227 Nguyen Van Cu, Q5, TpHCM', '08631738', '19811231', '20061124',915000, NULL),
('KH07', 'Nguyen Van Tam', '32/3 Tran Binh Trong, Q5, TpHCM', '0916783565', '19710406', '20061201',12500, NULL),
('KH08', 'Phan Thi Thanh', '45/2 An Duong Vuong, Q5, TpHCM', '0938435756', '19710110','20061213',365000, NULL),
('KH09', 'Le Ha Vinh',  '873 Le Hong Phong, Q5, TpHCM','08654763','19790903','20070114',70000, NULL),
('KH10',  'Ha Duy Lap','34/34B Nguyen Trai, Q1, TpHCM','08768904','19830502','20070116',67500, NULL);
SELECT * FROM KHACHHANG
---
INSERT INTO SANPHAM VALUES 
('BC01', 'But chi', 'cay', 'Singapore', '3000'),
('BC02', 'But chi', 'cay', 'Singapore', '5000'),
('BC03', 'But chi', 'cay', 'Viet Nam', '3500'),
('BC04', 'But chi', 'hop', 'Viet Nam', '30000'),
('BB01', 'But bi', 'cay', 'Viet Nam', '5000'),
('BB02', 'But bi', 'cay', 'Trung Quoc', '7000'),
('BB03', 'But bi', 'hop', 'Thai Lan', '100000'),
('TV01', 'Tap 100 giay mong', 'quyen', 'Trung Quoc', '2500'),
('TV02', 'Tap 200 giay mong', 'quyen', 'Trung Quoc', '4500'),
('TV03', 'Tap 100 giay tot', 'quyen', 'Viet Nam', '3000'),
('TV04', 'Tap 200 giay tot', 'quyen', 'Viet Nam', '5500'),
('TV05', 'Tap 100 trang', 'chuc', 'Viet Nam', '23000'),
('TV06', 'Tap 200 trang', 'chuc', 'Viet Nam', '53000'),
('TV07', 'Tap 100 trang', 'chuc','Trung Quoc','34000'),
('ST01','So tay 500 trang', 'quyen','Trung Quoc','40000'),
('ST02','So tay loai 1', 'quyen','Viet Nam','55000'),
('ST03','So tay loai 2', 'quyen','Viet Nam','51000'),
('ST04','So tay', 'quyen','Thai Lan','55000'),
('ST05','So tay mong', 'quyen','Thai Lan','20000'),
('ST06','Phan viet bang', 'hop','Viet Nam','5000'),
('ST07','Phan khong bui', 'hop','Viet Nam','7000'),
('ST08','Bong bang', 'cai','Viet Nam','1000'),
('ST09','But long', 'cay','Viet Nam','5000'),
('ST10','But long', 'cay','Trung Quoc','7000');
SELECT * FROM SANPHAM
--
INSERT INTO HOADON VALUES 
(1001, '20060723', 'KH01', 'NV01', '320000'),
(1002, '20060812', 'KH01', 'NV02', '840000'),
(1003, '20060823', 'KH02', 'NV01', '100000'),
(1004, '20060901', 'KH02', 'NV01', '180000'),
(1005, '20061020', 'KH01', 'NV02', '3800000'),
(1006, '20061016', 'KH01', 'NV03', '2430000'),
(1007, '20061028', 'KH03', 'NV03', '510000'),
(1008, '20061028', 'KH01', 'NV03', '440000'),
(1009, '20061028', 'KH03', 'NV04', '200000'),
(1010, '20061101', 'KH01', 'NV01', '5200000'),
(1011, '20061104', 'KH04', 'NV03', '250000'),
(1012, '20061130', 'KH05', 'NV03', '21000'),
(1013, '20061212', 'KH06', 'NV01', '5000'),
(1014, '20061231', 'KH03', 'NV02', '3150000'),
(1015, '20070101', 'KH06', 'NV01', '910000'),
(1016, '20070101', 'KH07', 'NV02', '12500'),
(1017, '20070102', 'KH08', 'NV03', '35000'),
(1018, '20070113', 'KH08', 'NV03', '330000'),
(1019, '20070113', 'KH01', 'NV03', '30000'),
(1020, '20070114', 'KH09', 'NV04', '70000'),
(1021, '20070116', 'KH10', 'NV03', '67500');
INSERT INTO HOADON (SOHD, NGHD, MANV, TRIGIA) VALUES
(1022, '20070116','NV03', '7000'),
(1023, '20070117','NV01', '330000');
SELECT * FROM HOADON
--
INSERT INTO CTHD VALUES 
(1001, 'TV02', 10),
(1001, 'ST01', 5),
(1001, 'BC01', 5),
(1001, 'BC02', 10),
(1001, 'ST08', 10),
(1002, 'BC04', 20),
(1002, 'BB01', 20),
(1002, 'BB02', 20),
(1003, 'BB03', 10),
(1004, 'TV01', 20),
(1004, 'TV02', 10),
(1004, 'TV03', 10),
(1004, 'TV04', 10),
(1005, 'TV05', 50),
(1005, 'TV06', 50),
(1006, 'TV07', 20),
(1006, 'ST01', 30),
(1006, 'ST02', 10),
(1007, 'ST03', 10),
(1008, 'ST04', 8),
(1009, 'ST05', 10),
(1010, 'TV07', 50),
(1010, 'ST07', 50),
(1010, 'ST08', 100),
(1010, 'ST04', 50),
(1010, 'TV03', 100),
(1011, 'ST06', 50),
(1012, 'ST07', 3),
(1013, 'ST08', 5),
(1014, 'BC02', 80),
(1014, 'BB02', 100),
(1014, 'BC04', 60),
(1014,'BB01',50),
(1015,'BB02',30),
(1015,'BB03',7),
(1016,'TV01',5),
(1017,'TV02',1),
(1017,'TV03',1),
(1017,'TV04',5),
(1018,'ST04',6),
(1019,'ST05',1),
(1019,'ST06',2),
(1020,'ST07',10),
(1021,'ST08',5),
(1021,'TV01',7),
(1021,'TV02',10),
(1022,'ST07',1),
(1023,'ST04',6);
SELECT * FROM CTHD

--2. Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa toàn bộ dữ liệu của quan hệ KHACHHANG.
SELECT * INTO SANPHAM1 FROM SANPHAM
SELECT * FROM SANPHAM1

SELECT * INTO KHACHHANG1 FROM KHACHHANG
SELECT * FROM KHACHHANG1

--3. Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1)
UPDATE SANPHAM1
SET GIA = GIA * 1.05
WHERE NUOCSX = 'Thai Lan';

--4. Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống(cho quan hệ SANPHAM1).
UPDATE SANPHAM1
SET GIA = GIA * 0.95
WHERE NUOCSX = 'Trung Quoc' AND GIA <= 10000

--5. Cập nhật giá trị LOAIKH là “Vip” đối với những khách hàng đăng ký thành viên trước ngày 
--1/1/2007 có doanh số từ 10.000.000 trở lên hoặc khách hàng đăng ký thành viên từ 1/1/2007 trở về 
--sau có doanh số từ 2.000.000 trở lên (cho quan hệ KHACHHANG1).
UPDATE KHACHHANG1
SET LOAIKH = 'Vip'
WHERE (NGDK < '20070101' AND DOANHSO >= 10000000) OR (NGDK >= '20070101' AND DOANHSO >= 2000000)

--III. Ngôn ngữ truy vấn dữ liệu có cấu trúc:

--1. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc';

--2. In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.
SELECT MASP, TENSP
FROM SANPHAM
WHERE DVT IN ('cay', 'quyen')

--3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP LIKE 'B%01'

--4. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 đến 40.000.
SELECT MASP, TENSP
FROM SANPHAM
WHERE (NUOCSX = 'Trung Quoc') AND (GIA BETWEEN 30000 AND 400000)

--5. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản xuất có giá từ 30.000 đến 40.000.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX IN ('Trung Quoc',  'Thai Lan') 
AND (GIA BETWEEN 30000 AND 400000)

--6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.
SELECT SOHD, TRIGIA
FROM HOADON
WHERE NGHD IN ('20070101', '20070102')

--7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và trị giá của 
--hóa đơn (giảm dần).
SELECT SOHD, TRIGIA
FROM HOADON
WHERE (MONTH(NGHD) = 1) AND (YEAR(NGHD) = 2007)
ORDER BY NGHD ASC, TRIGIA DESC

--8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007.
SELECT KH.MAKH, KH.HOTEN
FROM KHACHHANG KH INNER JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE HD.NGHD = '20070101'

--9. In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày 
--28/10/2006.
SELECT HD.SOHD, HD.TRIGIA
FROM HOADON HD INNER JOIN NHANVIEN NV ON HD.MANV = NV.MANV
WHERE NV.HOTEN = 'Nguyen Van B' AND HD.NGHD = '20061028'

--10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong 
--tháng 10/2006.
SELECT SP.MASP, SP.TENSP
FROM SANPHAM SP
JOIN CTHD ON SP.MASP = CTHD.MASP
JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
JOIN KHACHHANG KH ON HD.MAKH = KH.MAKH
WHERE KH.HOTEN = 'Nguyen Van A' 
AND MONTH(HD.NGHD) = 10 
AND YEAR(HD.NGHD) = 2006;

--11. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02
SELECT SOHD
FROM CTHD
WHERE MASP IN ('BB01', 'BB02')

--12. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số 
--lượng từ 10 đến 20.
SELECT DISTINCT SOHD
FROM CTHD
WHERE MASP = 'BB01'
AND SL BETWEEN 10 AND 20
UNION
SELECT DISTINCT SOHD
FROM CTHD
WHERE MASP = 'BB02'
AND SL BETWEEN 10 AND 20

--13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với 
--số lượng từ 10 đến 20.
SELECT SOHD 
FROM CTHD
WHERE MASP = 'BB01' AND SL BETWEEN 10 AND 20
INTERSECT
SELECT SOHD 
FROM CTHD
WHERE MASP = 'BB02' AND SL BETWEEN 10 AND 20

--14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được 
--bán ra trong ngày 1/1/2007.
SELECT DISTINCT SP.MASP, TENSP
FROM SANPHAM SP JOIN CTHD ON SP.MASP = CTHD.MASP 
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
WHERE NUOCSX = 'Trung Quoc'
OR NGHD = '20070101'

--15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
SELECT SP.MASP, TENSP
FROM SANPHAM SP
WHERE NOT EXISTS 
	(SELECT * FROM CTHD 
	WHERE CTHD.MASP = SP.MASP)

--16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT SP.MASP, TENSP
FROM SANPHAM SP
WHERE NOT EXISTS 
	(SELECT * 
	FROM CTHD JOIN HOADON ON CTHD.SOHD = HOADON.SOHD 
	WHERE CTHD.MASP = SP.MASP AND YEAR(NGHD)=2006)

--17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong 
--năm 2006.
SELECT SP.MASP, TENSP
FROM SANPHAM SP
WHERE NUOCSX = 'Trung Quoc' AND NOT EXISTS 
	(SELECT * 
	FROM CTHD JOIN HOADON ON CTHD.SOHD = HOADON.SOHD 
	WHERE CTHD.MASP = SP.MASP AND YEAR(NGHD)=2006)
--Cach 2:
SELECT MASP, TENSP
FROM SANPHAM
WHERE (NUOCSX = 'Trung Quoc') AND MASP NOT IN
	(SELECT DISTINCT MASP 
	FROM CTHD JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
	WHERE YEAR(NGHD) =2006)

--18. Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD FROM HOADON HD WHERE NOT EXISTS
	(SELECT * FROM SANPHAM SP WHERE NUOCSX = 'Singapore' AND NOT EXISTS
		(SELECT * FROM CTHD WHERE CTHD.SOHD = HD.SOHD AND CTHD.MASP = SP.MASP))

--19. Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD FROM HOADON HD WHERE YEAR(NGHD) = 2006 AND NOT EXISTS
	(SELECT * FROM SANPHAM SP WHERE NUOCSX = 'Singapore' AND NOT EXISTS
		(SELECT * FROM CTHD WHERE CTHD.SOHD = HD.SOHD AND CTHD.MASP = SP.MASP))

--20. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT SOHD
FROM HOADON
EXCEPT
SELECT SOHD
FROM HOADON
WHERE MAKH IN (SELECT MAKH FROM KHACHHANG)

--21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.


--22. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?
SELECT MAX(TRIGIA) TRIGIAMAX, MIN(TRIGIA) TRIGIAMIN
FROM HOADON

--23. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) TRIGIATRUNGBINH
FROM HOADON
WHERE YEAR(NGHD) = 2006

--24. Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) DOANHTHU
FROM HOADON
WHERE YEAR(NGHD) = 2006

--25. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT SOHD, TRIGIA
FROM HOADON
WHERE YEAR(NGHD) =2006 AND TRIGIA = 
	(SELECT MAX(TRIGIA) 
	FROM HOADON)

--26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT HOTEN
FROM KHACHHANG KH JOIN HOADON HD ON KH.MAKH = HD.MAKH
WHERE YEAR(NGHD) = 2006
AND TRIGIA = 
	(SELECT MAX(TRIGIA) 
	FROM HOADON)

--27. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.
SELECT TOP 3 MAKH, HOTEN
FROM KHACHHANG 
ORDER BY DOANHSO DESC

--28. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP, TENSP 
FROM SANPHAM
WHERE GIA IN 
(SELECT DISTINCT TOP 3 GIA
FROM SANPHAM
ORDER BY GIA DESC)

--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức 
--giá cao nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Thai Lan' AND GIA IN 
	(SELECT DISTINCT TOP 3 GIA
	FROM SANPHAM
	ORDER BY GIA DESC)

--30. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức 
--giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA IN (
    SELECT TOP 3 GIA
    FROM SANPHAM
    WHERE NUOCSX = 'Trung Quoc'
    ORDER BY GIA DESC
)

--31. * In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).
SELECT TOP 3 MAKH, HOTEN, DOANHSO
FROM KHACHHANG
ORDER BY DOANHSO DESC

--32. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT NUOCSX, COUNT(*) SOLUONGSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
GROUP BY NUOCSX

--33. Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX, COUNT(*) SOLUONGSP
FROM SANPHAM
GROUP BY NUOCSX

--34. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
SELECT NUOCSX, MAX(GIA) GIA_MAX, MIN(GIA) GIA_MIN, AVG(GIA) GIA_TB
FROM SANPHAM
GROUP BY NUOCSX

--35. Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD, AVG(TRIGIA) DOANHTHU
FROM HOADON
GROUP BY NGHD

--36. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT MASP, SUM(SL) SOLUONG
FROM CTHD JOIN HOADON HD ON CTHD.SOHD = HD.SOHD
WHERE MONTH(NGHD)=10 AND YEAR(NGHD)=2006
GROUP BY MASP

--37. Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) THANG, SUM(TRIGIA) DOANHTHU
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)

--38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT SOHD
FROM (SELECT SOHD, COUNT(*) SL
FROM CTHD
GROUP BY SOHD) AS SOLUONG
WHERE SL > 3

--39. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT SOHD
FROM (SELECT SOHD, COUNT(*) SL
FROM CTHD JOIN SANPHAM SP ON CTHD.MASP = SP.MASP
WHERE NUOCSX = 'Viet Nam'
GROUP BY SOHD) AS SOLUONG
WHERE SL = 3

--40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
SELECT TOP 1 WITH TIES HD.MAKH, HOTEN, COUNT(SOHD) SL
FROM KHACHHANG KH JOIN HOADON HD ON KH.MAKH = HD.MAKH
GROUP BY HD.MAKH, HOTEN
ORDER BY SL DESC

--41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT TOP 1 WITH TIES MONTH(NGHD) THANG, SUM(TRIGIA) DOANHTHU
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)
ORDER BY DOANHTHU DESC

--42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT TOP 1 WITH TIES SP.MASP, TENSP
FROM SANPHAM SP JOIN CTHD ON SP.MASP = CTHD.MASP
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
WHERE YEAR(NGHD) = 2006
GROUP BY SP.MASP, TENSP
ORDER BY COUNT(*) ASC

--43. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT MAX_GIA.NUOCSX, MASP, TENSP
FROM SANPHAM SP JOIN
(SELECT NUOCSX, MAX(GIA) GIA_MAX
FROM SANPHAM
GROUP BY NUOCSX) AS MAX_GIA ON SP.NUOCSX = MAX_GIA.NUOCSX
WHERE SP.GIA =GIA_MAX

--44. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3


 --45. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhấT.
--Cách 1:
SELECT TOP 1 MAKH, COUNT(SOHD) SL
FROM HOADON
WHERE MAKH IN 
	(SELECT TOP 10 MAKH
    FROM KHACHHANG
    ORDER BY DOANHSO DESC)
GROUP BY MAKH
ORDER BY SL DESC

--Cách 2:
SELECT TOP 1 * 
FROM (SELECT TOP 10 KH.MAKH, KH.HOTEN, SUM(TRIGIA) DOANHSO, COUNT(HD.MAKH) SOLAN
	  FROM KHACHHANG KH JOIN HOADON HD ON KH.MAKH = HD.MAKH
	  GROUP BY KH.MAKH, KH.HOTEN
	  ORDER BY DOANHSO DESC) AS KQ
ORDER BY SOLAN DESC
