USE QL_TTCB

--DE 2
--CAU 1.
--TAO CAC QUAN HE
CREATE DATABASE QL_TTCB

CREATE TABLE ToBay
(
	MaTB int not null,
	TenTB varchar(50),
	NgayTL smalldatetime,
	ThongTin varchar(100),
	MaNV int
)

CREATE TABLE NhanVien
(
	MaNV int not null,
	HoTen varchar(50),
	Email varchar(50),
	SDT varchar(20),
	NgayVL smalldatetime,
	Luong money,
	ChucVu varchar(50),
	MaTB int
)

CREATE TABLE MayBay
(
	MaMB int not null,
	TenMB varchar(50),
	LoaiMB varchar(50),
	SucChua int,
	NgaySX smalldatetime,
	ThongTin varchar(100)
)

CREATE TABLE ChuyenBay
(
	MaCB int not null,
	DiemDi varchar(50),
	DiemDen varchar(50),
	KhoiHanh smalldatetime,
	HaCanh smalldatetime
)

CREATE TABLE LichBay
(
	MaTB int not null,
	MaCB int not null,
	MaMB int
)

--KHOA CHINH
ALTER TABLE ToBay ADD CONSTRAINT PK_ToBay PRIMARY KEY (MaTB)
ALTER TABLE NhanVien ADD CONSTRAINT PK_NhanVien PRIMARY KEY (MaNV)
ALTER TABLE MayBay ADD CONSTRAINT PK_MayBay PRIMARY KEY (MaMB)
ALTER TABLE ChuyenBay ADD CONSTRAINT PK_ChuyenBay PRIMARY KEY (MaCB)
ALTER TABLE LichBay ADD CONSTRAINT PK_LichBay PRIMARY KEY (MaTB, MaCB)

--KHOA NGOAI
ALTER TABLE ToBay ADD CONSTRAINT FK_TB_NV FOREIGN KEY (MaNV) REFERENCES NhanVien (MaNV)
ALTER TABLE NhanVien ADD CONSTRAINT FK_NV_TB FOREIGN KEY (MaTB) REFERENCES ToBay (MaTB)
ALTER TABLE LichBay ADD CONSTRAINT FK_LB_MB FOREIGN KEY (MaMB) REFERENCES MayBay (MaMB)
ALTER TABLE LichBay ADD CONSTRAINT FK_LB_TB FOREIGN KEY (MaTB) REFERENCES ToBay (MaTB)
ALTER TABLE LichBay ADD CONSTRAINT FK_LB_CB FOREIGN KEY (MaCB) REFERENCES ChuyenBay (MaCB)

--CAU 2.
--2.1
ALTER TABLE MayBay ADD CONSTRAINT CHK_MB_LOAIMB CHECK (LoaiMB IN ('Airbus A300', 'Boeing 707', 'Boeing 747'))

--2.2
--TRIGGER TREN CHUYENBAY
CREATE TRIGGER TRG_LICHBAY
ON LichBay
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @NgaySX smalldatetime, @KhoiHanh smalldatetime, @MaMB int, @MaCB int

    SELECT @MaMB = MaMB, @MaCB = MaCB FROM INSERTED

    SELECT @NgaySX = NgaySX FROM MayBay WHERE MaMB = @MaMB
    SELECT @KhoiHanh = KhoiHanh FROM ChuyenBay WHERE MaCB = @MaCB

    IF @KhoiHanh < @NgaySX
    BEGIN
		PRINT 'LOI: NGAY KHOI HANH PHAI LON HON NGAY SAN XUAT!'
        ROLLBACK TRANSACTION
    END
END

CREATE TRIGGER TRG_CHUYENBAY
ON ChuyenBay
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGAYSX SMALLDATETIME, @KHOIHANH SMALLDATETIME, @MAMB INT, @MACB INT

	SELECT @KHOIHANH = KhoiHanh, @MaCB = MaCB
	FROM INSERTED

	SELECT @NGAYSX = NgaySX , @MAMB = MayBay.MaMB
	FROM MayBay JOIN LichBay ON LichBay.MaMB = MayBay.MAMB
	WHERE @MACB = LichBay.MaCB
	AND @MAMB = MayBay.MAMB

	IF (@NGAYSX > @KHOIHANH)
	BEGIN
		ROLLBACK TRANSACTION
	END
END

--CAU 3.
--3.1
SELECT TB.MaTB, TB.TenTB
FROM ToBay TB JOIN LichBay LB ON TB.MaTB = LB. MaTB
JOIN ChuyenBay CB ON CB.MaCB = LB.MaCB
WHERE DiemDen = 'Singapore'
AND YEAR(KhoiHanh) = 2023

--3.2
SELECT MB.MAMB, MB.TenMB, COUNT(*) SoLuongCB
FROM MayBay MB JOIN LichBay LB ON MB.MaMB = LB.MaMB
GROUP BY MB.MAMB, MB.TenMB 

--3.3
SELECT MaTB, TenTB FROM ToBay WHERE NOT EXISTS 
	(SELECT * FROM ChuyenBay WHERE DiemDi = 'Viet Nam' AND NOT EXISTS 
		(SELECT * FROM LichBay WHERE LichBay.MaTB = ToBay.MaTB AND LichBay.MaCB = ChuyenBay.MaCB))


