-- QUẢN LÝ GIÁO VỤ

USE QLGV

--I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):

--1. Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. 

CREATE DATABASE QLGV

CREATE TABLE KHOA
(
MAKHOA varchar(4) NOT NULL,
TENKHOA varchar(40),
NGTLAP smalldatetime,
TRGKHOA char(4)
)

CREATE TABLE MONHOC
(
MAMH varchar(10) NOT NULL,
TENMH varchar(40),
TCLT tinyint,
TCTH tinyint,
MAKHOA varchar(4)
)

CREATE TABLE DIEUKIEN
(
	MAMH varchar(10) NOT NULL,
	MAMH_TRUOC varchar(10) NOT NULL
)

CREATE TABLE GIAOVIEN
(
	MAGV char(4) NOT NULL,
	HOTEN varchar(40),
	HOCVI varchar(10),
	HOCHAM varchar(10),
	GIOITINH varchar(3),
	NGSINH smalldatetime,
	NGVL smalldatetime,
	HESO numeric(4,2),
	MUCLUONG money,
	MAKHOA varchar(4)
)

CREATE TABLE LOP
(
	MALOP char(3) NOT NULL,
	TENLOP varchar(40),
	TRGLOP char(5),
	SISO tinyint,
	MAGVCN char(4)
)

CREATE TABLE HOCVIEN
(
	MAHV char(5) NOT NULL,
	HO varchar(40),
	TEN varchar(10),
	NGSINH smalldatetime,
	GIOITINH varchar(3),
	NOISINH varchar(40),
	MALOP char(3)
)

CREATE TABLE GIANGDAY
(
	MALOP char(3) NOT NULL,
	MAMH varchar(10) NOT NULL,
	MAGV char(4),
	HOCKY tinyint,
	NAM smallint,
	TUNGAY smalldatetime,
	DENNGAY smalldatetime
)

CREATE TABLE KETQUATHI
(
	MAHV char(5) NOT NULL,
	MAMH varchar(10) NOT NULL,
	LANTHI tinyint NOT NULL,
	NGTHI smalldatetime,
	DIEM numeric(4,2),
	KQUA varchar(10)
)

--Xác định khóa chính:
ALTER TABLE KHOA ADD CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA)
ALTER TABLE MONHOC ADD CONSTRAINT PK_MH PRIMARY KEY (MAMH)
ALTER TABLE DIEUKIEN ADD CONSTRAINT PK_DK PRIMARY KEY (MAMH, MAMH_TRUOC)
ALTER TABLE GIAOVIEN ADD CONSTRAINT PK_GV PRIMARY KEY (MAGV)
ALTER TABLE LOP ADD CONSTRAINT PK_LOP PRIMARY KEY (MALOP)
ALTER TABLE HOCVIEN ADD CONSTRAINT PK_HV PRIMARY KEY (MAHV)
ALTER TABLE GIANGDAY ADD CONSTRAINT PK_GD PRIMARY KEY (MALOP, MAMH)
ALTER TABLE KETQUATHI ADD CONSTRAINT PK_KQT PRIMARY KEY (MAHV, MAMH, LANTHI)

--Xác định khóa ngoại:
ALTER TABLE HOCVIEN ADD CONSTRAINT FK_HV_LOP FOREIGN KEY (MALOP) REFERENCES LOP (MALOP)

ALTER TABLE LOP ADD 
CONSTRAINT FK_LOP_GV FOREIGN KEY (MAGVCN) REFERENCES GIAOVIEN (MAGV),
CONSTRAINT FK_LOP_TL FOREIGN KEY (TRGLOP) REFERENCES HOCVIEN (MAHV)

ALTER TABLE KHOA ADD CONSTRAINT FK_KHOA_GV FOREIGN KEY (TRGKHOA) REFERENCES GIAOVIEN (MAGV)
ALTER TABLE MONHOC ADD CONSTRAINT FK_MH_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA (MAKHOA)

ALTER TABLE DIEUKIEN ADD 
CONSTRAINT FK_DK_MH FOREIGN KEY (MAMH) REFERENCES MONHOC (MAMH),
CONSTRAINT FK_DK_MHT FOREIGN KEY (MAMH_TRUOC) REFERENCES MONHOC (MAMH)

ALTER TABLE GIAOVIEN ADD CONSTRAINT FK_GV_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA (MAKHOA)

ALTER TABLE GIANGDAY ADD
CONSTRAINT FK_GD_LOP FOREIGN KEY (MALOP) REFERENCES LOP(MALOP),
CONSTRAINT FK_GD_MH FOREIGN KEY (MAMH) REFERENCES MONHOC (MAMH),
CONSTRAINT FK_GD_GV FOREIGN KEY (MAGV) REFERENCES GIAOVIEN (MAGV)

ALTER TABLE KETQUATHI ADD 
CONSTRAINT FK_KQT_HV FOREIGN KEY (MAHV) REFERENCES HOCVIEN (MAHV),
CONSTRAINT FK_KQT_MH FOREIGN KEY (MAMH) REFERENCES MONHOC (MAMH)
--Thêm vào 3 thuộc tính GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN.
ALTER TABLE HOCVIEN ADD GHICHU varchar(100)
ALTER TABLE HOCVIEN ADD DIEMTB numeric(4,2)
ALTER TABLE HOCVIEN ADD XEPLOAI varchar(10)

--2. Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp. VD: “K1101”
ALTER TABLE HOCVIEN ADD CONSTRAINT CHK_HV CHECK (MAHV LIKE 'K[0-9][0-9][0-9][0-9]')

--3. Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
ALTER TABLE HOCVIEN ADD CONSTRAINT CHK_HV_GIOITINH CHECK (GIOITINH IN ('Nam', 'Nu'))
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHK_GV_GIOITINH CHECK (GIOITINH IN ('Nam', 'Nu'))

--4. Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
ALTER TABLE KETQUATHI ADD CONSTRAINT CHK_KQT_DIEM CHECK ((DIEM BETWEEN 0 AND 10) AND (DIEM = ROUND (DIEM,2)))

--5. Kết quả thi là “Dat” nếu điểm từ 5 đến 10 và “Khong dat” nếu điểm nhỏ hơn 5.
ALTER TABLE KETQUATHI ADD CONSTRAINT CHK_KQT_KQUA CHECK ((DIEM BETWEEN 5 AND 10 AND KQUA = 'Dat') OR (DIEM < 5 AND KQUA = 'Khong dat'))

--6. Học viên thi một môn tối đa 3 lần.
ALTER TABLE KETQUATHI ADD CONSTRAINT CHK_KQT_LANTHI CHECK (LANTHI <= 3)

--7. Học kỳ chỉ có giá trị từ 1 đến 3.
ALTER TABLE GIANGDAY ADD CONSTRAINT CHK_GD_HOCKY CHECK (HOCKY BETWEEN 1 AND 3)

--8. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHK_GV_HOCVI CHECK (HOCVI IN ('CN', 'KS', 'ThS', 'TS', 'PTS'))

--9. Lớp trưởng của một lớp phải là học viên của lớp đó.
CREATE TRIGGER TRG_LOPTRG_9 
ON LOP 
FOR INSERT 
AS 
BEGIN 
	DECLARE @TRGLOP CHAR(5), @MALOP CHAR(3), @MAHV CHAR(5) 
	SELECT @TRGLOP = TRGLOP, @MALOP = MALOP 
	FROM INSERTED 
	SELECT @MAHV = MAHV 
	FROM HOCVIEN 
	WHERE MAHV = @TRGLOP AND MALOP = @MALOP 
	IF (@MAHV <> @TRGLOP) 
		BEGIN 
			PRINT('LOI: LOP TRUONG KHONG DUNG!');
			ROLLBACK TRANSACTION 
		END 
END

--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.
CREATE TRIGGER TRG_TRGKHOA_10
ON KHOA 
FOR INSERT, UPDATE
AS 
BEGIN
	DECLARE @TRGKHOA CHAR(5), @MAKHOA VARCHAR(4), @MAGV CHAR(4)
	SELECT @TRGKHOA = TRGKHOA, @MAKHOA = MAKHOA 
	FROM INSERTED 
	SELECT @MAGV = MAGV 
	FROM GIAOVIEN 
	WHERE MAGV = @TRGKHOA AND @MAKHOA = MAKHOA AND HOCVI IN ('TS', 'PTS') 
	IF (@TRGKHOA <> @MAGV) 
		BEGIN 
			PRINT('LOI');
			ROLLBACK TRANSACTION 
		END 
	ELSE 
		PRINT 'THANH CONG' 
END

--INSERT INTO KHOA (MAKHOA) VALUES ('EX1')
--UPDATE KHOA
--SET TRGKHOA = NULL
--WHERE MAKHOA = 'EX1'
--DELETE FROM KHOA WHERE MAKHOA ='EX1'
--DELETE FROM GIAOVIEN WHERE MAGV = 'GVE1'
--INSERT INTO GIAOVIEN (MAGV, HOCVI, MAKHOA) VALUES ('GVE1','CN','EX1')

--11. Học viên ít nhất là 18 tuổi.
ALTER TABLE HOCVIEN ADD CONSTRAINT CHK_HV_TUOI CHECK (YEAR(GETDATE())-YEAR(NGSINH) >=18)

--12. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY).
ALTER TABLE GIANGDAY ADD CONSTRAINT CHK_GD_NGAY CHECK (TUNGAY<DENNGAY)

--13. Giáo viên khi vào làm ít nhất là 22 tuổi.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHK_GV_TUOI CHECK (YEAR(NGVL) - YEAR(NGSINH) >= 22)

--14. Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 5.
ALTER TABLE MONHOC ADD CONSTRAINT CHK_MH_TINCHI CHECK (ABS(TCLT-TCTH) <= 5)

--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
CREATE TRIGGER TRG_MONHOC_15
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaHV CHAR(5), @MaMH VARCHAR(10), @NgThi SMALLDATETIME

    SELECT @MaHV = MAHV, @MaMH = MAMH, @NgThi = NGTHI FROM inserted

    IF NOT EXISTS (SELECT * FROM GIANGDAY WHERE MALOP = (SELECT MALOP FROM HOCVIEN WHERE MAHV = @MaHV) AND MAMH = @MaMH AND DENNGAY < @NgThi)
    BEGIN
		PRINT 'LOI: HOC VIEN KHONG DUOC THI MON NAY!'
        ROLLBACK TRANSACTION
    END
END

--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
CREATE TRIGGER TRG_GIANGDAY_16
ON GIANGDAY
AFTER INSERT
AS
BEGIN
	DECLARE @COUNT INT;
	SELECT @COUNT = COUNT(*) 
	FROM GIANGDAY 
	WHERE HOCKY = (SELECT HOCKY FROM inserted) 
	AND NAM = (SELECT NAM FROM inserted) 
	AND MALOP = (SELECT MALOP FROM inserted);
	IF @COUNT > 3
		BEGIN
			PRINT 'LOI: SO LUONG MON HOC TOI DA'
			ROLLBACK TRANSACTION;
		END
END

--INSERT INTO LOP (MALOP) VALUES ('L01')
--INSERT INTO GIANGDAY (MALOP, MAMH, HOCKY, NAM) VALUES ('L01', 'CTRR', 1, 2023);
--INSERT INTO GIANGDAY (MALOP, MAMH, HOCKY, NAM) VALUES ('L01', 'THDC', 1, 2023);
--INSERT INTO GIANGDAY (MALOP, MAMH, HOCKY, NAM) VALUES ('L01', 'CTDLGT', 1, 2023);
--INSERT INTO GIANGDAY (MALOP, MAMH, HOCKY, NAM) VALUES ('L01', 'CSDL', 1, 2023);

--DELETE FROM LOP
--WHERE MALOP = 'L01'

--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
-- Trigger for UPDATE on LOP
CREATE TRIGGER TRG_LOP_17
ON LOP
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @SiSo INT, @MaLop CHAR(3), @SoHocVien INT
	SELECT @SiSo = SISO, @MaLop = MALOP FROM inserted
    SELECT @SoHocVien = COUNT(*) FROM HOCVIEN WHERE MALOP = @MaLop
    IF @SiSo != @SoHocVien
    BEGIN
        PRINT 'LOI: SI SO KHONG DUNG!'
        ROLLBACK TRANSACTION
    END
END

UPDATE LOP
SET SISO = '100'
WHERE MALOP = 'K11'

-- Trigger for INSERT
CREATE TRIGGER TRG_HOCVIEN_INS_17
ON HOCVIEN
AFTER INSERT
AS
BEGIN
    DECLARE @MaLop CHAR(3)
    SELECT @MaLop = MALOP FROM inserted
    UPDATE LOP
    SET SISO = (SELECT COUNT(*) FROM HOCVIEN WHERE MALOP = @MaLop)
    WHERE MALOP = @MaLop
END

--INSERT INTO LOP (MALOP, SISO) VALUES ('K16',0)
--INSERT INTO HOCVIEN (MAHV, MALOP) VALUES ('K1601','K16')

--DELETE FROM HOCVIEN WHERE MAHV = 'K1601'
--DELETE FROM LOP WHERE MALOP = 'K16'

-- Trigger for DELETE
CREATE TRIGGER TRG_HOCVIEN_DEL_17
ON HOCVIEN
AFTER DELETE
AS
BEGIN
    DECLARE @MaLop CHAR(3)
    SELECT @MaLop = MALOP FROM deleted
    UPDATE LOP
    SET SISO = (SELECT COUNT(*) FROM HOCVIEN WHERE MALOP = @MaLop)
    WHERE MALOP = @MaLop
END

--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng --một bộ không được giống nhau (“A”,”A”) và cũng không tồn tại 
--hai bộ (“A”,”B”) và (“B”,”A”).
CREATE TRIGGER trg_CheckDieuKien
ON DIEUKIEN
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaMH VARCHAR(10), @MaMH_Truoc VARCHAR(10)
    SELECT @MaMH = MAMH, @MaMH_Truoc = MAMH_TRUOC FROM inserted
    IF @MaMH = @MaMH_Truoc
    BEGIN
        PRINT 'LOI: 2 MON HOC GIONG NHAU!'
        ROLLBACK TRANSACTION
    END
    IF EXISTS (SELECT * FROM DIEUKIEN WHERE MAMH = @MaMH_Truoc AND MAMH_TRUOC = @MaMH)
    BEGIN
        PRINT 'LOI: LAP LAI!'
        ROLLBACK TRANSACTION
    END
END

--INSERT INTO DIEUKIEN VALUES ('CTRR','CTRR')
--INSERT INTO DIEUKIEN VALUES ('CTRR','CSDL')

--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
CREATE TRIGGER TRG_GIAOVIEN_19
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @HocVi VARCHAR(10), @HocHam VARCHAR(10), @HeSo NUMERIC(4,2), @MucLuong MONEY
    SELECT @HocVi = HOCVI, @HocHam = HOCHAM, @HeSo = HESO, @MucLuong = MUCLUONG FROM inserted
    IF EXISTS (SELECT * FROM GIAOVIEN WHERE HOCVI = @HocVi AND HOCHAM = @HocHam AND HESO = @HeSo AND MUCLUONG != @MucLuong)
    BEGIN
		PRINT 'LOI: MUC LUONG KHONG DUNG!'
		ROLLBACK TRANSACTION
    END
END

--INSERT INTO GIAOVIEN VALUES
--('GV17', 'TNDT', 'PTS', 'GS', 'NU', '19991210', '20230111', 5.20, 10000, 'KHMT')
--SELECT * FROM GIAOVIEN

--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER trg_CheckThiLai
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaHV CHAR(5), @MaMH VARCHAR(10), @LanThi TINYINT, @Diem NUMERIC(4,2)
    SELECT @MaHV = MAHV, @MaMH = MAMH, @LanThi = LANTHI, @Diem = DIEM FROM inserted
    IF @LanThi > 1
    BEGIN
        IF NOT EXISTS (SELECT * FROM KETQUATHI WHERE MAHV = @MaHV AND MAMH = @MaMH AND LANTHI = @LanThi - 1 AND DIEM < 5)
        BEGIN
            PRINT 'LOI: HOC VIEN KHONG DUOC THI LAI!'
            ROLLBACK TRANSACTION
        END
    END
END

--INSERT INTO KETQUATHI (MAHV, MAMH, LANTHI, DIEM) VALUES ('K1101', 'CSDL', '2','6')
--SELECT * FROM KETQUATHI
--DELETE FROM KETQUATHI
--WHERE MAHV = 'K1101' AND MAMH = 'CSDL' AND LANTHI =2

--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
CREATE TRIGGER TRG_NGAYTHI_21
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaHV CHAR(5), @MaMH VARCHAR(10), @LanThi TINYINT, @NgThi SMALLDATETIME
    SELECT @MaHV = MAHV, @MaMH = MAMH, @LanThi = LANTHI, @NgThi = NGTHI FROM inserted
    IF @LanThi > 1
    BEGIN
        IF NOT EXISTS (SELECT * FROM KETQUATHI WHERE MAHV = @MaHV AND MAMH = @MaMH AND LANTHI = @LanThi - 1 AND NGTHI < @NgThi)
        BEGIN
            PRINT 'LOI: NGAY THI KHONG DUNG!'
            ROLLBACK TRANSACTION
        END
    END
END

-- Câu lệnh sau sẽ thành công do môn học đã kết thúc

--22. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
CREATE TRIGGER TRG_KETQUATHI_22
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaHV CHAR(5), @MaMH VARCHAR(10), @NgThi SMALLDATETIME
    SELECT @MaHV = MAHV, @MaMH = MAMH, @NgThi = NGTHI FROM inserted
    IF NOT EXISTS (SELECT * FROM GIANGDAY WHERE MALOP = (SELECT MALOP FROM HOCVIEN WHERE MAHV = @MaHV) AND MAMH = @MaMH AND DENNGAY < @NgThi)
    BEGIN
		PRINT  'LOI: HOC VIEN KHONG DUOC THI MON HOC NAY!'
        ROLLBACK TRANSACTION
    END
END

--INSERT INTO HOCVIEN (MAHV, HO, TEN, NGSINH, GIOITINH, NOISINH, MALOP)
--VALUES ('K1112', 'Nguyen', 'A', '2000-01-01', 'Nam', 'TP.HCM', 'K11')
--INSERT INTO KETQUATHI (MAHV, MAMH, LANTHI)
--VALUES ('K1112', 'LTCFW', 1)
--DELETE FROM HOCVIEN WHERE MAHV = 'K1112'

--23. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học xong những môn học phải học trước 
--mới được học những môn liền sau).
CREATE TRIGGER TRG_GIANGDAY_23
ON GIANGDAY
AFTER INSERT
AS
BEGIN
    DECLARE @MaLop CHAR(3), @MaMH VARCHAR(10), @HocKy TINYINT, @Nam SMALLINT, @MaMHTruoc VARCHAR(10), @Check BIT
	SET @Check = 1
    SELECT @MaLop = MALOP, @MaMH = MAMH, @HocKy = HOCKY, @Nam = NAM FROM inserted
    IF EXISTS (SELECT * FROM DIEUKIEN WHERE MAMH = @MaMH)
	BEGIN
		DECLARE ARR_MHTRUOC CURSOR 
		FOR
			SELECT MAMH_TRUOC
			FROM DIEUKIEN
			WHERE MAMH = @MaMH
		OPEN ARR_MHTRUOC

		FETCH NEXT FROM ARR_MHTRUOC
		INTO @MaMHTruoc

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF NOT EXISTS (SELECT * FROM GIANGDAY WHERE MALOP = @MaLop AND MAMH = @MaMHTruoc AND (NAM < @Nam OR (NAM = @Nam OR HOCKY < @HocKy)))
			BEGIN
				SET @Check =0
				BREAK
			END
			FETCH NEXT FROM ARR_MHTRUOC
			INTO @MaMHTruoc
		END
		CLOSE ARR_MHTRUOC
		DEALLOCATE ARR_MHTRUOC

		IF (@Check = 0)
		BEGIN
			ROLLBACK TRANSACTION
			PRINT 'LOI: LOP CHUA HOC MON HOC TRUOC!'
		END
	END
END

--24. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER TRG_GIANGDAY_24
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaGV CHAR(4), @MaMH VARCHAR(10)
    SELECT @MaGV = MAGV, @MaMH = MAMH FROM inserted
    IF NOT EXISTS (SELECT * FROM GIAOVIEN WHERE MAGV = @MaGV AND MAKHOA = (SELECT MAKHOA FROM MONHOC WHERE MAMH = @MaMH))
    BEGIN
		PRINT  'LOI: GIAO VIEN KHONG DUOC PHAN CONG!'
		ROLLBACK TRANSACTION
    END
END

--INSERT INTO GIANGDAY (MALOP, MAMH, MAGV) VALUES
--('K11','LTHDT','GV01')

----------------
--II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language):

--1. Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
UPDATE GIAOVIEN
SET HESO = HESO + 0.2
WHERE MAGV IN (SELECT TRGKHOA FROM KHOA)

--2. Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên (tất cả các 
--môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau 
--cùng).
UPDATE HOCVIEN
SET DIEMTB = (
    SELECT AVG(DIEM)
    FROM KETQUATHI KQT
    JOIN 
        (SELECT MAHV, MAMH, MAX(LANTHI) AS LANTHICUOI
        FROM KETQUATHI
        GROUP BY MAHV, MAMH) AS LTC 
    ON KQT.MAHV = LTC.MAHV AND KQT.MAMH = LTC.MAMH AND KQT.LANTHI = LTC.LANTHICUOI
    WHERE KQT.MAHV = HOCVIEN.MAHV
    GROUP BY KQT.MAHV
)

--3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất 
--kỳ thi lần thứ 3 dưới 5 điểm.
UPDATE HOCVIEN 
SET GHICHU = 'Cam thi'
WHERE MAHV IN (SELECT MAHV FROM KETQUATHI
WHERE LANTHI = 3 AND DIEM <5.00)

--4. Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
--o Nếu DIEMTB  9 thì XEPLOAI =”XS”
--o Nếu 8  DIEMTB < 9 thì XEPLOAI = “G”
--o Nếu 6.5  DIEMTB < 8 thì XEPLOAI = “K”
--o Nếu 5  DIEMTB < 6.5 thì XEPLOAI = “TB”
--o Nếu DIEMTB < 5 thì XEPLOAI = ”Y”
UPDATE HOCVIEN
SET XEPLOAI = 'XS'
WHERE DIEMTB>=9.0
UPDATE HOCVIEN
SET XEPLOAI = 'G'
WHERE DIEMTB >= 8.0 AND DIEMTB < 9
UPDATE HOCVIEN
SET XEPLOAI = 'K'
WHERE DIEMTB >= 6.5 AND DIEMTB < 8
UPDATE HOCVIEN
SET XEPLOAI = 'TB'
WHERE DIEMTB >= 5 AND DIEMTB < 6.5
UPDATE HOCVIEN
SET XEPLOAI = 'Y'
WHERE DIEMTB < 5

--Nhập dữ liệu cho các quan hệ trên.
INSERT INTO KHOA (MAKHOA, TENKHOA, NGTLAP) VALUES
('KHMT', 'Khoa hoc may tinh', '20050607'),
('HTTT', 'He thong thong tin', '20050607'),
('CNPM', 'Cong nghe phan mem', '20050607'),
('MTT', 'Mang va truyen thong', '20051020'),
('KTMT', 'Ky thuat may tinh', '20051220');
UPDATE KHOA
SET TRGKHOA = 'GV01'
WHERE MAKHOA = 'KHMT';
UPDATE KHOA
SET TRGKHOA = 'GV02'
WHERE MAKHOA = 'HTTT';
UPDATE KHOA
SET TRGKHOA = 'GV04'
WHERE MAKHOA = 'CNPM';
UPDATE KHOA
SET TRGKHOA = 'GV03'
WHERE MAKHOA = 'MTT';
SELECT * FROM KHOA
---
INSERT INTO GIAOVIEN VALUES
('GV01', 'Ho Thanh Son', 'PTS', 'GS', 'Nam', '19500502', '20040111', 5.00, 2250000, 'KHMT'),
('GV02', 'Tran Tam Thanh', 'TS', 'PGS', 'Nam', '19651217', '20040420', 4.50, 2025000, 'HTTT'),
('GV03', 'Do Nghiem Phung', 'TS', 'GS', 'Nu', '19500801', '20040923', 4.00, 1800000, 'CNPM'),
('GV04', 'Tran Nam Son', 'TS', 'PGS', 'Nam', '19610222', '20050112', 4.50, 2025000, 'KTMT'),
('GV05', 'Mai Thanh Danh', 'ThS', 'GV', 'Nam', '19580312', '20050112', 3.00, 1350000, 'HTTT'),
('GV06', 'Tran Doan Hung', 'TS', 'GV', 'Nam', '19530311', '20050112', 4.50, 2025000, 'KHMT'),
('GV07', 'Nguyen Minh Tien','ThS','GV','Nam','19711123','20050301' ,4.00 ,1800000 ,'KHMT'),
('GV08','Le Thi Tran','KS','Null','Nu','19740326','20050301' ,1.69 ,760500 ,'KHMT'),
('GV09','Nguyen To Lan','ThS','GV','Nu','19661231','20050301' ,4.00 ,1800000 ,'HTTT'),
('GV10','Le Tran Anh Loan','KS','Null','Nu','19720717' ,'20050301' ,1.86 ,837000 ,'CNPM'),
('GV11','Ho Thanh Tung','CN','GV','Nam','19800112' ,'20050515' ,2.67 ,1201500 ,'MTT'),
('GV12','Tran Van Anh' ,'CN' ,'Null' ,'Nu' ,'19810329' ,'20050515' ,1.69 ,760500 ,'CNPM'),
('GV13','Nguyen Linh Dan' ,'CN' ,'Null' ,'Nu' ,'19800523' ,'20050515' ,1.69 ,760500 ,'KTMT'),
('GV14','Truong Minh Chau' ,'ThS' ,'GV' ,'Nu' ,'19761130' ,'20050515' ,3.00 ,1350000 ,'MTT'),
('GV15','Le Ha Thanh' ,'ThS' ,'GV' ,'Nam' ,'19780504' ,'20050515' ,3.00 ,1350000,'KHMT');
SELECT * FROM GIAOVIEN
---
INSERT INTO MONHOC VALUES
('THDC', 'Tin hoc dai cuong', 4, 1, 'KHMT'),
('CTRR', 'Cau truc roi rac', 5, 0, 'KHMT'),
('CSDL', 'Co so du lieu', 3, 1, 'HTTT'),
('CTDLGT', 'Cau truc du lieu va giai thuat', 3, 1, 'KHMT'),
('PTTKTT', 'Phan tich thiet ke thuat toan', 3, 0, 'KHMT'),
('DHMT', 'Do hoa may tinh', 3, 1, 'KHMT'),
('KTMT', 'Kien truc may tinh', 3, 0, 'KTMT'),
('TKCSDL', 'Thiet ke co so du lieu', 3, 1, 'HTTT'),
('PTTKHTTT', 'Phan tich thiet ke he thong thong tin', 4, 1, 'HTTT'),
('HDH', 'He dieu hanh', 4, 0, 'KTMT'),
('NMCNPM', 'Nhap mon cong nghe phan mem', 3, 0, 'CNPM'),
('LTCFW', 'Lap trinh C for win', 3, 1, 'CNPM'),
('LTHDT', 'Lap trinh huong doi tuong', 3, 1, 'CNPM');
SELECT * FROM MONHOC
DELETE FROM MONHOC
---
INSERT INTO DIEUKIEN (MAMH, MAMH_TRUOC) VALUES
('CSDL', 'CTRR'),
('CSDL', 'CTDLGT'),
('CTDLGT', 'THDC'),
('PTTKTT', 'THDC'),
('PTTKTT', 'CTDLGT'),
('DHMT', 'THDC'),
('LTHDT', 'THDC'),
('PTTKHTTT', 'CSDL');
SELECT * FROM DIEUKIEN
DELETE FROM DIEUKIEN
---
INSERT INTO LOP (MALOP, TENLOP, SISO, MAGVCN) VALUES
('K11', 'Lop 1 khoa 1', 11, 'GV07'),
('K12', 'Lop 2 khoa 1', 12, 'GV09'),
('K13', 'Lop 3 khoa 1', 12, 'GV14');\
UPDATE LOP
SET TRGLOP = 'K1108'
WHERE MALOP = 'K11';
UPDATE LOP
SET TRGLOP = 'K1205'
WHERE MALOP = 'K12';
UPDATE LOP
SET TRGLOP = 'K1305'
WHERE MALOP = 'K13';
SELECT * FROM LOP
DELETE FROM LOP
---
INSERT INTO GIANGDAY VALUES
('K11', 'THDC', 'GV07', 1, 2006, '20060102', '20060512'),
('K12', 'THDC', 'GV06', 1, 2006, '20060102', '20060512'),
('K13', 'THDC', 'GV15', 1, 2006, '20060102', '20060512'),
('K11', 'CTRR', 'GV02', 1, 2006, '20060109', '20060517'),
('K12', 'CTRR', 'GV02', 1, 2006, '20060109', '20060517'),
('K13', 'CTRR', 'GV08', 1, 2006, '20060109', '20060517'),
('K11', 'CSDL', 'GV05', 2, 2006, '20060601', '20060715'),
('K12', 'CSDL', 'GV09', 2, 2006, '20060601', '20060715'),
('K13', 'CTDLGT','GV15' ,2 ,2006 ,'20060601' ,'20060715'),
('K13' ,'CSDL' ,'GV05' ,3 ,2006 ,'20060801' ,'20061215'),
('K13' ,'DHMT' ,'GV07' ,3 ,2006 ,'20060801' ,'20061215'),
('K11' ,'CTDLGT' ,'GV15' ,3 ,2006 ,'20060801' ,'20061215'),
('K12' ,'CTDLGT' ,'GV15' ,3 ,2006 ,'20060801' ,'20061215'),
('K11' ,'HDH' ,'GV04' ,1 ,2007,'20230102' ,'20230218'),
('K12' ,'HDH' ,'GV04' ,1 ,2007,'20230102' ,'20230320'),
('K11' ,'DHMT' ,'GV07' ,1 ,2007 ,'20230218','20230320');
SELECT * FROM GIANGDAY

DELETE FROM GIANGDAY
---
INSERT INTO HOCVIEN VALUES
('K1101','Nguyen Van','A','19860127','Nam','TpHCM','K11'),
('K1102','Tran Ngoc','Han','19860314','Nu','Kien Giang','K11'),
('K1103','Ha Duy','Lap','19860418','Nam','Nghe An','K11'),
('K1104','Tran Ngoc','Linh','19860330','Nu','Tay Ninh','K11'),
('K1105','Tran Minh','Long','19860227','Nam','TpHCM','K11'),
('K1106','Le Nhat','Minh','19860124','Nam','TpHCM','K11'),
('K1107','Nguyen Nhu','Nhut','19860127','Nam','Ha Noi','K11'),
('K1108','Nguyen Manh','Tam','19860227','Nam','Kien Giang','K11'),
('K1109','Phan Thi Thanh','Tam','19860127','Nu','Vinh Long','K11'),
('K1110','Le Hoai','Thuong','19860205','Nu','Can Tho','K11'),
('K1111','Le Ha','Vinh','19861225','Nam','Vinh Long','K11'),
('K1201','Nguyen Van','B','19860211','Nam','TpHCM','K12'),
('K1202','Nguyen Thi Kim','Duyen','19860118','Nu','TpHCM','K12'),
('K1203','Tran Thi Kim','Duyen','19860917','Nu','TpHCM','K12'),
('K1204','Truong My','Hanh','19860519','Nu','Dong Nai','K12'),
('K1205','Nguyen Thanh','Nam','19860417','Nam','TpHCM','K12'),
('K1206','Nguyen Thi Truc','Thanh','19860304','Nu','Kien Giang','K12'),
('K1207','Tran Thi Bich','Thuy','19860208','Nu','Nghe An','K12'),
('K1208','Huynh Thi Kim','Trieu','19860408','Nu','Tay Ninh','K12'),
('K1209','Pham Thanh','Trieu','19860223','Nam','TpHCM','K12'),
('K1210','Ngo Thanh','Tuan','19860214','Nam','TpHCM','K12'),
('K1211','Do Thi','Xuan','19860309','Nu','Ha Noi','K12'),
('K1212','Le Thi Phi','Yen','19860312','Nu','TpHCM','K12'),
('K1301','Nguyen Thi Kim','Cuc','19860609','Nu','Kien Giang','K13'),
('K1302','Truong Thi My','Hien','19860318','Nu','Nghe An','K13'),
('K1303','Le Duc','Hien','19860321','Nam','Tay Ninh','K13'),
('K1304','Le Quang','Hien','19860418','Nam','TpHCM','K13'),
('K1305','Le Thi','Huong','19860327','Nu','TpHCM','K13'),
('K1306','Nguyen Thai','Huu','19860330','Nam','Ha Noi','K13'),
('K1307','Tran Minh','Man','19860528','Nam','TpHCM','K13'),
('K1308','Nguyen Hieu','Nghia','19860408','Nam','Kien Giang','K13'),
('K1309','Nguyen Trung','Nghia', '19870118','Nam', 'Nghe An', 'K13'),
('K1310','Tran Thi Hong','Tham', '19860422','Nu', 'Tay Ninh', 'K13'),
('K1311','Tran Minh', 'Thuc', '19860404','Nam', 'TpHCM', 'K13'),
('K1312','Nguyen Thi Kim','Yen', '19860907','Nu','TpHCM', 'K13');
SELECT * FROM HOCVIEN

---
INSERT INTO KETQUATHI VALUES
('K1101', 'CSDL', 1, '20060720', 10.00, 'Dat'),
('K1101', 'CTDLGT', 1, '20061228', 9.00, 'Dat'),
('K1101', 'THDC', 1, '20060520', 9.00, 'Dat'),
('K1101', 'CTRR', 1, '20060513', 9.50, 'Dat'),
('K1102', 'CSDL', 1, '20060720', 4.00, 'Khong Dat'),
('K1102', 'CSDL', 2, '20060727', 4.25, 'Khong Dat'),
('K1102', 'CSDL', 3, '20060810', 4.50, 'Khong Dat'),
('K1102', 'CTDLGT', 1, '20061228', 4.50, 'Khong Dat'),
('K1102', 'CTDLGT', 2, '20070105', 4.00, 'Khong Dat'),
('K1102', 'CTDLGT', 3, '20070115', 6.00, 'Dat'),
('K1102', 'THDC', 1, '20060520', 5.00, 'Dat'),
('K1102', 'CTRR', 1, '20060513', 7.00, 'Dat'),
('K1103', 'CSDL', 1, '20060720', 3.50, 'Khong Dat'),
('K1103', 'CSDL', 2, '20060727', 8.25, 'Dat'),
('K1103', 'CTDLGT', 1, '20061228', 7.00, 'Dat'),
('K1103', 'THDC', 1, '20060520', 8.00, 'Dat'),
('K1103', 'CTRR', 1, '20060513', 6.50, 'Dat'),
('K1104', 'CSDL', 1, '20060720', 3.75, 'Khong Dat'),
('K1104', 'CTDLGT', 1, '20061228', 4.00, 'Khong Dat'),
('K1104', 'THDC', 1, '20060520', 4.00, 'Khong Dat'),
('K1104', 'CTRR', 1,'20060513',4.00 ,'Khong Dat'),
('K1104','CTRR',2 ,'20060520',3.50 ,'Khong Dat'),
('K1104','CTRR',3 ,'20060630',4.00 ,'Khong Dat'),
('K1201','CSDL',1 ,'20060720',6.00 ,'Dat'),
('K1201','CTDLGT',1 ,'20061228',5.00 ,'Dat'),
('K1201','THDC',1 ,'20060520',8.50 ,'Dat'),
('K1201','CTRR',1 ,'20060513',9.00 ,'Dat'),
('K1202','CSDL',1 ,'20060720',8.00 ,'Dat'),
('K1202','CTDLGT',1 ,'20061228',4.00 ,'Khong Dat'),
('K1202','CTDLGT',2 ,'20070105',5.00 ,'Dat'),
('K1202','THDC',1 ,'20060520',4.00 ,'Khong Dat'),
('K1202','THDC',2 ,'20060527',4.00 ,'Khong Dat'),
('K1202','CTRR ',1,'20060513 ',3.00,'Khong Dat'), 
('K1202','CTRR ',2,'20060520 ',4.00,'Khong Dat'), 
('K1202','CTRR',3,'20060630',6.25,'Dat'), 
('K1203','CSDL',1,'20060720',9.25,'Dat'), 
('K1203','CTDLGT',1,'20061228',9.50,'Dat'), 
('K1203','THDC',1,'20060520',10.0,'Dat'), 
('K1203','CTRR',1,'20060513',10.0,'Dat'), 
('K1204','CSDL',1,'20060720',8.50,'Dat'), 
('K1204','CTDLGT',1,'20061228',6.75,'Dat'), 
('K1204','THDC',1,'20060520',5.50,'Dat'), 
('K1204','CTRR',1,'20060513',5.00,'Dat'), 
('K1301','CSDL',1,'20061220',4.25,'Khong Dat'), 
('K1301','CTDLGT',1,'20060725',8.00,'Dat'), 
('K1301','THDC',1,'20060520',7.75,'Dat'), 
('K1301','CTRR',1,'20060513',8.00,'Dat'), 
('K1302','CSDL',1,'20061220',6.75,'Dat'), 
('K1302','CTDLGT',1,'20060725',5.00,'Dat'), 
('K1302','THDC',1,'20060520', 8.00,'Dat'),
('K1302','CTRR', 1,'20060513', 8.50,'Dat'),
('K1303','CSDL', 1,'20061220', 4.00,'Khong Dat'),
('K1303','CTDLGT', 1,'20060725', 4.50,'Khong Dat'),
('K1303','CTDLGT', 2,'20060807', 4.00,'Khong Dat'),
('K1303','CTDLGT', 3,'20060815', 4.25,'Khong Dat'),
('K1303','THDC', 1,'20060520', 4.50,'Khong Dat'),
('K1303','CTRR', 1,'20060513', 3.25,'Khong Dat'),
('K1303','CTRR', 2,'20060520', 5.00,'Dat'),
('K1304','CSDL', 1,'20061220', 7.75,'Dat'),
('K1304','CTDLGT', 1,'20060725', 9.75,'Dat'),
('K1304','THDC', 1,'20060520', 5.50,'Dat'),
('K1304','CTRR', 1,'20060513', 5.00,'Dat'),
('K1305','CSDL', 1,'20061220', 9.25,'Dat'),
('K1305','CTDLGT', 1,'20060725', 10.0 ,'Dat'),
('K1305','THDC',1 ,'20060520',8.00 ,'Dat'),
('K1305','CTRR',1 ,'20060513',10.0 ,'DaT');
SELECT * FROM KETQUATHI
DELETE FROM KETQUATHI

--III. Ngôn ngữ truy vấn dữ liệu:

--1. In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp.
SELECT HV.MAHV, HV.HO, HV.TEN, HV.NGSINH, HV.MALOP
FROM HOCVIEN HV JOIN LOP ON HV.MAHV = LOP.TRGLOP

--2. In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, 
--sắp xếp theo tên, họ học viên.
SELECT KQT.MAHV, HV.HO, HV.TEN, KQT.LANTHI, KQT.DIEM
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE KQT.MAMH = 'CTRR' AND HV.MALOP = 'K12'
ORDER BY HV.TEN, HV.HO ASC

--3. In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi 
--lần thứ nhất đã đạt.
SELECT HV.MAHV, HV.HO, HV.TEN, KQT.MAMH
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE KQT.LANTHI =1 AND KQT.KQUA = 'Dat'

--4. In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở 
--lần thi 1).
SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE HV.MALOP = 'K11' AND KQT.MAMH = 'CTRR' AND KQT.KQUA = 'Khong Dat' AND KQT.LANTHI = 1

--5. * Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả 
--các lần thi).
SELECT DISTINCT HV.MAHV, HV.HO, HV.TEN
FROM KETQUATHI KQT
JOIN HOCVIEN HV ON KQT.MAHV = HV.MAHV
WHERE KQT.MAHV NOT IN (
    SELECT HV.MAHV
    FROM HOCVIEN HV
    JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
    WHERE KQT.MAMH = 'CTRR'  AND KQT.KQUA = 'Dat' AND HV.MALOP LIKE 'K%'
    GROUP BY HV.MAHV, HV.HO, HV.TEN
    HAVING COUNT(KQT.KQUA) >= 1
);

--6. Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 
--2006.
SELECT DISTINCT MH.MAMH, TENMH
FROM MONHOC MH JOIN GIANGDAY GD ON MH.MAMH = GD.MAMH
JOIN GIAOVIEN GV ON GD.MAGV = GV.MAGV
WHERE HOTEN = 'Tran Tam Thanh'
AND HOCKY = 1

--7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy 
--trong học kỳ 1 năm 2006.
SELECT MH.MAMH, TENMH
FROM MONHOC MH JOIN GIANGDAY GD ON MH.MAMH = GD.MAMH
JOIN LOP ON GD.MAGV = LOP.MAGVCN
WHERE GD.MALOP = 'K11'
AND HOCKY = 1
AND NAM = 2006

--8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So 
--Du Lieu”.
SELECT HO, TEN
FROM HOCVIEN HV JOIN LOP ON HV.MAHV = LOP.TRGLOP
JOIN GIANGDAY GD ON GD.MALOP = LOP.MALOP
JOIN MONHOC MH ON GD.MAMH = MH.MAMH
JOIN GIAOVIEN GV ON GD.MAGV = GV.MAGV
WHERE HOTEN = 'Nguyen To Lan'
AND TENMH = 'Co So Du Lieu'

--9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So 
--Du Lieu”.
SELECT MH.MAMH, MH.TENMH
FROM MONHOC MH JOIN DIEUKIEN DK ON MH.MAMH = DK.MAMH_TRUOC
WHERE DK.MAMH = (SELECT MAMH FROM MONHOC WHERE TENMH = 'Co So Du Lieu');

--10. Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, 
--tên môn học) nào?
SELECT MH.MAMH, MH.TENMH
FROM MONHOC MH JOIN DIEUKIEN DK ON MH.MAMH = DK.MAMH
WHERE DK.MAMH_TRUOC = (SELECT MAMH FROM MONHOC WHERE TENMH = 'Cau Truc Roi Rac')

--11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 
--năm 2006.
SELECT HOTEN
FROM GIAOVIEN GV JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE MALOP = 'K11' AND HOCKY = 1 AND NAM = 2006
INTERSECT
SELECT HOTEN
FROM GIAOVIEN GV JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE MALOP = 'K12' AND HOCKY = 1 AND NAM = 2006

--12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng 
--chưa thi lại môn này.
SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE MAMH = 'CSDL' AND LANTHI  = 1 AND KQUA = 'Khong Dat' 
AND NOT EXISTS 
(SELECT * FROM KETQUATHI KQT WHERE LANTHI = 2)

--13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
SELECT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT * FROM GIANGDAY GD WHERE GD.MAGV=GV.MAGV)

--14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào 
--thuộc khoa giáo viên đó phụ trách.
SELECT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV
WHERE NOT EXISTS (SELECT * FROM GIANGDAY GD JOIN MONHOC ON GD.MAMH = MONHOC.MAMH
WHERE GD.MAGV=GV.MAGV AND MONHOC.MAKHOA = GV.MAKHOA)

--15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat”
--hoặc thi lần thứ 2 môn CTRR được 5 điểm.
SELECT HV.MAHV, HO, TEN
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE MALOP = 'K11' AND
MAMH = 'CTRR' AND DIEM = 5 AND LANTHI = 2
UNION
SELECT HV.MAHV, HO, TEN
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE MALOP = 'K11' AND
LANTHI > 3 AND KQUA = 'Khong dat'

--16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm 
--học.
SELECT DISTINCT HOTEN
FROM GIAOVIEN GV 
JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
JOIN
	(SELECT GD.MAGV, HOCKY, NAM, COUNT(MALOP) AS SOLAN
	FROM GIAOVIEN GV JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
	WHERE MAMH = 'CTRR'
	GROUP BY GD.MAGV, HOCKY, NAM) AS DEM
ON DEM.MAGV = GD.MAGV
WHERE SOLAN>=2

--17. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
SELECT HV.MAHV, HV.HO, HV.TEN, DIEM
FROM HOCVIEN HV
JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
JOIN
	(SELECT MAHV, MAX(LANTHI) AS LANTHICUOI
	FROM KETQUATHI KQT
	WHERE MAMH = 'CSDL'
	GROUP BY MAHV) AS LTC
ON KQT.MAHV = LTC.MAHV AND KQT.LANTHI = LTC.LANTHICUOI
WHERE KQT.MAMH = 'CSDL'

--18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần 
--thi)
--SELECT MAHV, MAX(DIEM) AS DIEMTHI
--FROM KETQUATHI KQT
--WHERE MAMH = (SELECT MAMH FROM MONHOC WHERE TENMH = 'Co So Du Lieu')
--GROUP BY MAHV, MAMH

SELECT HV.MAHV, HV.HO, HV.TEN, DIEMTHI
FROM HOCVIEN HV
JOIN 
	(SELECT MAHV, MAX(DIEM) AS DIEMTHI
	FROM KETQUATHI KQT
	WHERE MAMH = (SELECT MAMH FROM MONHOC WHERE TENMH = 'Co So Du Lieu')
	GROUP BY MAHV, MAMH) AS DIEMMAX
ON HV.MAHV = DIEMMAX.MAHV

--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT MAKHOA, TENKHOA
FROM KHOA
WHERE NGTLAP = 
	(SELECT TOP 1 NGTLAP
	FROM KHOA
	ORDER BY NGTLAP ASC)

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT HOCHAM, COUNT(MAGV) SLGV
FROM GIAOVIEN
WHERE HOCHAM IN ('GS', 'PGS')
GROUP BY HOCHAM

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi 
--khoa.
SELECT HOCVI, COUNT(MAGV) SOLUONG
FROM GIAOVIEN
GROUP BY HOCVI

--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).
SELECT KQT.MAMH, TENMH,KQUA, COUNT(MAHV) SLHV
FROM KETQUATHI KQT JOIN MONHOC MH ON KQT.MAMH = MH.MAMH
GROUP BY KQT.MAMH, TENMH, KQUA
ORDER BY MAMH ASC

--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho 
--lớp đó ít nhất một môn học.
SELECT DISTINCT GV.MAGV, GV.HOTEN
FROM GIAOVIEN GV JOIN LOP ON GV.MAGV = LOP.MAGVCN
JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV AND LOP.MALOP = GD.MALOP

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
SELECT HO, TEN
FROM HOCVIEN JOIN LOP ON HOCVIEN.MAHV = LOP.TRGLOP
WHERE SISO = 
	(SELECT TOP 1 SISO
	FROM LOP
	ORDER BY SISO DESC)

--25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả 
--các lần thi).
SELECT KQT.MAHV, KQT.MAMH, MAX(LANTHI) LANTHI_MAX
FROM KETQUATHI KQT
GROUP BY KQT.MAHV, KQT.MAMH

SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV JOIN (SELECT KQT.MAHV, KQT.MAMH, MAX(LANTHI) LANTHI_MAX
FROM KETQUATHI KQT
GROUP BY KQT.MAHV, KQT.MAMH) AS LANTHICUOI
ON LANTHICUOI.MAHV = HV.MAHV
GROUP BY HV.MAHV, HV.HO, HV.TEN
HAVING COUNT(*) > 3

--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT TOP 1 WITH TIES KQT.MAHV, HO, TEN, COUNT(DIEM) SLDIEM
FROM KETQUATHI KQT JOIN HOCVIEN HV ON KQT.MAHV = HV.MAHV
WHERE DIEM BETWEEN 9 AND 10
GROUP BY KQT.MAHV, HO, TEN
ORDER BY SLDIEM DESC

--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
SELECT HV.MALOP, HV.MAHV, HV.HO, HV.TEN, COUNT (KQT.MAHV) SM
FROM HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE KQT.DIEM BETWEEN 9 AND 10
GROUP BY HV.MALOP, HV.MAHV, HV.HO, HV.TEN
HAVING COUNT(KQT.MAHV) > = ALL 
	(SELECT COUNT(HV1.MAHV) SM
	FROM HOCVIEN HV1 JOIN KETQUATHI KQT1 ON HV1.MAHV = KQT1.MAHV
	WHERE KQT1.DIEM BETWEEN 9 AND 10
	GROUP BY HV1.MALOP, HV1.MAHV
	HAVING HV1.MALOP = HV.MALOP)
ORDER BY HV.MALOP ASC, SM DESC

--28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao 
--nhiêu lớp.
SELECT HOCKY, MAGV, COUNT(MAMH) SLMONHOC
FROM GIANGDAY GD
GROUP BY HOCKY, MAGV
ORDER BY HOCKY ASC

--29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
SELECT GD.NAM, GD.HOCKY,GV.MAGV, GV.HOTEN
FROM GIANGDAY GD JOIN GIAOVIEN GV ON GD.MAGV=GV.MAGV
GROUP BY GV.MAGV, GV.HOTEN, GD.NAM, GD.HOCKY
HAVING COUNT(*)= (SELECT MAX(SOLANGD.SL)
				  FROM (SELECT GD1.NAM, GD1.HOCKY, GD1.MAGV,COUNT(*) SL
						FROM GIANGDAY GD1
						GROUP BY GD1.NAM, GD1.HOCKY,GD1.MAGV) AS SOLANGD
				WHERE GD.NAM=SOLANGD.NAM AND GD.HOCKY=SOLANGD.HOCKY
				GROUP BY SOLANGD.NAM,SOLANGD.HOCKY)
ORDER BY GD.NAM

--30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) 
--nhất.
SELECT TOP 1 WITH TIES MH.MAMH, TENMH
FROM MONHOC MH JOIN KETQUATHI KQT ON MH.MAMH=KQT.MAMH
WHERE LANTHI=1 AND KQUA='Khong Dat'
GROUP BY MH.MAMH, TENMH
ORDER BY COUNT(*) DESC

--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
--Cách 1:
SELECT DISTINCT HV.MAHV, HO, TEN
FROM HOCVIEN HV JOIN KETQUATHI KQT
ON HV.MAHV=KQT.MAHV
WHERE NOT EXISTS 
	(SELECT *
	FROM KETQUATHI KQT
	WHERE KQT.MAHV=HV.MAHV AND LANTHI=1 AND KQT.KQUA= 'Khong Dat' )

--Cách 2:
SELECT MAHV, HO, TEN
FROM HOCVIEN
WHERE MAHV IN
(SELECT DISTINCT MAHV FROM KETQUATHI
EXCEPT
 SELECT DISTINCT MAHV FROM KETQUATHI WHERE KQUA = 'Khong Dat')

--32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT DISTINCT HV.MAHV, HO, TEN
FROM HOCVIEN HV JOIN KETQUATHI KQT
ON HV.MAHV=KQT.MAHV
WHERE NOT EXISTS 
	(SELECT *
	FROM KETQUATHI KQT
	WHERE LANTHI = (SELECT MAX(LANTHI) FROM KETQUATHI WHERE MAHV=HV.MAHV GROUP BY MAHV)
	AND KQT.MAHV=HV.MAHV AND KQT.KQUA= 'Khong Dat' )

--33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1).
SELECT MAHV, HO, TEN
FROM HOCVIEN
WHERE MAHV IN
	(SELECT DISTINCT MAHV FROM KETQUATHI
	EXCEPT
	SELECT DISTINCT MAHV FROM KETQUATHI 
	WHERE KQUA  = 'Khong Dat'
	INTERSECT 
	SELECT MAHV 
	FROM (SELECT DISTINCT MAHV, MAMH FROM KETQUATHI) AS KQ1
	GROUP BY MAHV
	HAVING COUNT(MAMH) = (SELECT COUNT(MAMH) TONGMH FROM MONHOC))

--34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi sau cùng).
SELECT HV.MAHV, HO, TEN
FROM HOCVIEN HV 
WHERE NOT EXISTS (SELECT * FROM MONHOC WHERE NOT EXISTS 
	(SELECT * FROM KETQUATHI WHERE LANTHI= (SELECT MAX(LANTHI) FROM KETQUATHI WHERE MAHV=HV.MAHV GROUP BY MAHV)
									AND KETQUATHI.MAHV=HV.MAHV AND KQUA='Dat'))

--35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần 
--thi sau cùng)
SELECT MAMH, MAHV, HO, TEN
FROM
	(SELECT MAMH, HV.MAHV, HV.HO, HV.TEN, RANK() OVER (PARTITION BY MAMH ORDER BY MAX(DIEM) DESC) AS XepHang
	FROM
		HOCVIEN HV JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
	WHERE HV.MAHV = KQT.MAHV AND LANTHI = (SELECT MAX(LANTHI) FROM KETQUATHI WHERE MAHV = HV.MAHV GROUP BY MAHV)
	GROUP BY MAMH, HV.MAHV, HO, TEN
) AS A
WHERE XepHang = 1

