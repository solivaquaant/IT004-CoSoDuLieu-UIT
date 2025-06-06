USE CK2017_2018

CREATE DATABASE CK2017_2018

CREATE TABLE KhachHang (
    MaKH INT PRIMARY KEY,
    HoTen VARCHAR(255),
    NgaySinh DATE,
    DiaChi VARCHAR(255),
    SoDT VARCHAR(15),
    CMND VARCHAR(12)
);

CREATE TABLE LoaiTaiKhoan (
    MaLTK INT PRIMARY KEY,
    TenLTK VARCHAR(255),
    MoTa VARCHAR(255)
);

CREATE TABLE TaiKhoan (
    SoTK INT PRIMARY KEY,
    MaKH INT,
    MaLTK INT,
    NgayMo DATE,
    SoDu FLOAT,
    LaiSuat FLOAT,
    TrangThai VARCHAR(255),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    FOREIGN KEY (MaLTK) REFERENCES LoaiTaiKhoan(MaLTK)
);

CREATE TABLE LoaiGiaoDich (
    MaLGD INT PRIMARY KEY,
    TenLGD VARCHAR(255),
    MoTa VARCHAR(255)
);

CREATE TABLE GiaoDich (
    MaGD INT PRIMARY KEY,
    SoTK INT,
    MaLGD INT,
    NgayGD DATE,
    SoTien FLOAT,
    NoiDung VARCHAR(255),
    FOREIGN KEY (SoTK) REFERENCES TaiKhoan(SoTK),
    FOREIGN KEY (MaLGD) REFERENCES LoaiGiaoDich(MaLGD)
);

--DE 1:
--a. Hiển thị thông tin các tài khoản của các khách hàng (SoTK, TrangThai, SoDu) đã 
--mở tài khoản vào ngày ‘01/01/2017’ (NgayMo) và sắp xếp kết quả theo số dư 
--tăng dần. (1đ)
SELECT SoTK, TrangThai, SoDu
FROM TaiKhoan
WHERE NgayMo = '20170101'
ORDER BY SODU ASC

--b. Liệt kê mã loại giao dịch (MaLGD) cùng với tổng số tiền (SoTien) giao dịch của 
--từng loại giao dịch. (1đ)
SELECT MaLGD, SUM(SoTien) TongTien
FROM GiaoDich
GROUP BY MaLGD

--c. Cho biết những khách hàng (MaKH, HoTen, CMND) đã mở cả hai loại tài khoản: 
--tiết kiệm (TenLTK= ‘Tiết kiệm’) và thanh toán (TenLTK= ‘Thanh toán’). (1đ)
SELECT KH.MaKH, HoTen, CMND
FROM KhachHang KH JOIN TaiKhoan TK ON KH.MAKH = TK.MAKH
JOIN LoaiTaiKhoan LTK ON LTK.MaLTK = TK.MaLTK
WHERE TenLTK = 'Tiet Kiem'
INTERSECT
SELECT KH.MaKH, HoTen, CMND
FROM KhachHang KH JOIN TaiKhoan TK ON KH.MAKH = TK.MAKH
JOIN LoaiTaiKhoan LTK ON LTK.MaLTK = TK.MaLTK
WHERE TenLTK = 'Thanh Toan'

--d. Liệt kê thông tin các giao dịch (MaGD, SoTK, MaLGD, NgayGD, SoTien, 
--NoiDung) có số tiền lớn nhất trong tháng 12 năm 2017. (1đ)
SELECT TOP 1 WITH TIES *
FROM GiaoDich
WHERE MONTH(NgayGD) = 12 AND YEAR(NgayGD) = 2017
ORDER BY SoTien DESC

--e. Liệt kê danh sách các khách hàng (MaKH, HoTen, SoDT) đã mở tất cả các loại 
--tài khoản. (1đ))
SELECT MaKH, HoTen, SoDT
FROM KhachHang WHERE NOT EXISTS
	(SELECT * FROM LOAITAIKHOAN WHERE NOT EXISTS 
		(SELECT * FROM TAIKHOAN TK WHERE KHACHHANG.MAKH = TK.MAKH AND TK.MALTK = LOAITAIKHOAN.MALTK))

--f. Liệt kê những loại tài khoản (MaLTK, TenLTK) được mở nhiều nhất trong năm 
--2016. (1đ)
SELECT LTK.MaLTK, TenLTK, COUNT(SoTK) SoLanMoNN
FROM LoaiTaiKhoan LTK JOIN TaiKhoan TK ON LTK.MaLTK = TK.MaLTK
WHERE YEAR(NgayMo) = 2016
GROUP BY LTK.MaLTK, TenLTK
HAVING COUNT(SoTK) = 
	(SELECT TOP 1 COUNT(SoTK) SoLanMo
	FROM LoaiTaiKhoan LTK JOIN TaiKhoan TK ON LTK.MaLTK = TK.MaLTK
	WHERE YEAR(NgayMo) =2016
	GROUP BY LTK.MaLTK
	ORDER BY SoLanMo DESC
	)

--DE 2:
--a. Hiển thị danh sách các giao dịch (MaGD, SoTK, SoTien) đã thực hiện giao 
--dịch vào ngày ‘01/01/2017’ (NgayGD) và sắp xếp kết quả theo thứ tự giảm dần 
--số tiền. (1đ)
SELECT MaGD, SoTK, SoTien
FROM GiaoDich
WHERE NgayGD = '20170101' 
ORDER BY SoTien DESC

--b. Liệt kê mã loại tài khoản (MaLTK) cùng với tổng số dư (SoDu) của từng loại 
--tài khoản. (1đ)
SELECT MaLTK, SUM(SoDu)
FROM TaiKhoan
GROUP BY SoTK

--c. Cho biết những khách hàng (MaKH, HoTen, CMND) đã mở cả hai loại tài 
--khoản: thanh toán (TenLTK= ‘Thanh toán’) và vay (TenLTK= ‘Vay’). (1đ)
SELECT KH.MaKH, HoTen, CMND
FROM KhachHang KH JOIN TaiKhoan TK ON KH.MAKH = TK.MAKH
JOIN LoaiTaiKhoan LTK ON LTK.MaLTK = TK.MaLTK
WHERE TenLTK = 'Thanh Toan'
UNION
SELECT KH.MaKH, HoTen, CMND
FROM KhachHang KH JOIN TaiKhoan TK ON KH.MAKH = TK.MAKH
JOIN LoaiTaiKhoan LTK ON LTK.MaLTK = TK.MaLTK
WHERE TenLTK = 'Vay'

--d. Liệt kê các tài khoản (SoTK, MaKH, MaLTK, NgayMo, SoDu, LaiSuat, 
--TrangThai) mở trong tháng 12 năm 2017 có số dư lớn nhất. (1đ)
SELECT SoTK, MaKH, MaLTK, NgayMo, SoDu, LaiSuat, TrangThai
FROM TaiKhoan
WHERE MONTH(NgayMo) = 12 AND YEAR(NgayMo) = 2017
AND SoDu = (
    SELECT MAX(SoDu)
    FROM TaiKhoan
    WHERE MONTH(NgayMo) = 12 AND YEAR(NgayMo) = 2017
);


--e. Liệt kê danh sách các tài khoản (SoTK, SoDu, TrangThai) đã thực hiện tất cả 
--các loại giao dịch. (1đ)
SELECT SoTK, SoDu, TrangThai FROM TaiKhoan WHERE NOT EXISTS
	(SELECT * FROM LoaiGiaoDich WHERE NOT EXISTS
		(SELECT * FROM GiaoDich WHERE GiaoDich.MaLGD = LoaiGiaoDich.MaLGD AND GiaoDich.SoTK = TaiKhoan.SoTK))

--f. Liệt kê các khách hàng (MaKH, HoTen) có số lượng tài khoản ‘chưa kích hoạt’ 
--nhiều nhất. (1đ)
