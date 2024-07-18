--format đề thi SQL:
--1. select, join, where (kiểm tra cú pháp, cho điểm)
--2. sum, count... + group (theo từng) + select ...where
--3. phép toán tập hợp: intersect, except, union,... (nhiều điều kiện trên 1 thuộc tính)
--4. tính toán có group (giống số 2)
--5. phép chia (đối tượng, điều kiện, bảng kết nối)
--6. truy vấn lồng

USE CK2018_2019

CREATE DATABASE CK2018_2019

CREATE TABLE MATHANG (
    MAMH VARCHAR(20) PRIMARY KEY,
    TENMH VARCHAR(50),
    DVT VARCHAR(20),
    NUOCSX VARCHAR(50)
);

CREATE TABLE NHACC (
    MACC VARCHAR(20) PRIMARY KEY,
    TENCC VARCHAR(50),
    DIACHICC VARCHAR(100)
);

CREATE TABLE CUNGCAP (
    MACC VARCHAR(20),
    MAMH VARCHAR(20),
    TUNGAY DATE,
    PRIMARY KEY (MACC, MAMH),
    FOREIGN KEY (MACC) REFERENCES NHACC(MACC),
    FOREIGN KEY (MAMH) REFERENCES MATHANG(MAMH)
);

CREATE TABLE DONDH (
    MADH VARCHAR(20) PRIMARY KEY,
    NGAYDH DATE,
    MACC VARCHAR(20),
    TONGTRIGIA DECIMAL(15, 2) DEFAULT 0,
    SOMH INT DEFAULT 0,
    FOREIGN KEY (MACC) REFERENCES NHACC(MACC)
);

CREATE TABLE CHITIET (
    MADH VARCHAR(20),
    MAMH VARCHAR(20),
    SOLUONG INT,
    DONGIA DECIMAL(10, 2),
    TRIGIA AS (SOLUONG * DONGIA),
    PRIMARY KEY (MADH, MAMH),
    FOREIGN KEY (MADH) REFERENCES DONDH(MADH),
    FOREIGN KEY (MAMH) REFERENCES MATHANG(MAMH)
);
--ĐỀ 1
--Liệt kê danh sách các đơn hàng (MADH, NGAYDH, TONGTRIGIA) của tên nhà cung 
--cấp ‘Vinamilk’ có tổng trị giá lớn hơn 1.000.000 đồng. (1 điểm)
SELECT MADH, NGAYDH, TONGTRIGIA 
FROM DONDH JOIN NHACC ON DONDH.MACC = NHACC.MACC
WHERE TENCC = 'Vinamilk'
AND TONGTRIGIA > 1000000;

--b. Tính tổng số lượng sản phẩm có mã mặt hàng (MAMH) là ‘MH001’ đã đặt hàng trong 
--năm 2018. (1 điểm)
SELECT SUM(SOLUONG) AS TONGSL
FROM CHITIET CT JOIN DONDH DH ON CT.MADH = DH.MADH
WHERE MAMH = 'MH001' AND YEAR(NGAYDH) = 2018

--c. Liệt kê những nhà cung cấp (MACC, TENCC) có thể cung cấp những mặt hàng do ‘Việt 
--Nam’ sản xuất mà không cung cấp những mặt hàng do ‘Trung Quốc’ sản xuất. (1 điểm)
SELECT NHACC.MACC, TENCC
FROM NHACC JOIN CUNGCAP CC ON NHACC.MACC = CC.MACC
JOIN MATHANG MH ON CC.MAMH = MH.MAMH
WHERE NUOCSX = 'Viet Nam'
EXCEPT
SELECT NHACC.MACC, TENCC
FROM NHACC JOIN CUNGCAP CC ON NHACC.MACC = CC.MACC
JOIN MATHANG MH ON CC.MAMH = MH.MAMH
WHERE NUOCSX = 'Trung Quoc'

--d. Tính tổng số mặt hàng (SOMH) của tất cả các đơn đặt hàng theo từng năm. Thông tin hiển 
--thị: Năm đặt hàng, Tổng số mặt hàng. (1 điểm)
SELECT YEAR(NGAYDH) AS NamDatHang, SUM(SOMH) AS TongSoMatHang
FROM DONDH DH 
GROUP BY YEAR(NGAYDH)

--e. Tìm những mã đơn đặt hàng (MADH) đã đặt tất cả các mặt hàng của nhà cung cấp có tên 
--là ‘Vissan’ (TENCC). (1 điểm)
SELECT MADH FROM DONDH WHERE NOT EXISTS
	(SELECT * 
	FROM MATHANG JOIN CUNGCAP CC ON CC.MAMH = MATHANG.MAMH 
	JOIN NHACC ON NHACC.MACC = CC.MACC
	WHERE TENCC = 'Vissan' 
	AND NOT EXISTS
		(SELECT * FROM CHITIET CT WHERE CT.MADH = DONDH.MADH AND CT.MAMH = MATHANG.MAMH))

--f. Tìm những mặt hàng (MAMH, TENMH) có số lượng đặt hàng nhiều nhất trong năm 
--2018. (1 điểm)
SELECT MH.MAMH, TENMH, MAX(TONGSOLUONG)
FROM MATHANG MH JOIN CHITIET CT ON MH.MAMH = CT.MAMH
JOIN DONDH DH ON CT.MADH = DH.MADH
JOIN 
	(SELECT MAMH, SUM(SOLUONG) AS TONGSOLUONG
	FROM CHITIET CT  JOIN DONDH DH ON CT.MADH = DH.MADH
	WHERE YEAR(NGAYDH)=2018
	GROUP BY MAMH) AS TONGSL
ON TONGSL.MAMH = MH.MAMH