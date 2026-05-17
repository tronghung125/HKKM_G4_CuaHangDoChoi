
-- CREATE DATABASE G4_ToyStore;
-- GO
-- USE G4_ToyStore;
-- GO


-- 1. NHÓM NGƯỜI DÙNG & THƯƠNG HIỆU

CREATE TABLE G4_Users (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Email NVARCHAR(255) NOT NULL UNIQUE,
    HKKM_Password_Hash NVARCHAR(255) NOT NULL,
    HKKM_Full_Name NVARCHAR(100) NOT NULL,
    HKKM_Phone NVARCHAR(20),
    HKKM_Address NVARCHAR(MAX),
    HKKM_Role NVARCHAR(50) DEFAULT 'Customer', -- Cột phân quyền Admin / Customer
    HKKM_Created_At DATETIME DEFAULT GETDATE()
);

CREATE TABLE G4_Brands (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Name NVARCHAR(100) NOT NULL,
    HKKM_Logo_Url NVARCHAR(MAX),
    HKKM_Description NVARCHAR(MAX)
);


-- 2. NHÓM DANH MỤC & SẢN PHẨM

CREATE TABLE G4_Categories (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Name NVARCHAR(100) NOT NULL,
    HKKM_Parent_Id INT NULL, -- NULL nếu là danh mục gốc (Level 1)
    HKKM_Icon_Url NVARCHAR(MAX),
    HKKM_Level INT DEFAULT 1,
    FOREIGN KEY (HKKM_Parent_Id) REFERENCES G4_Categories(HKKM_Id)
);

CREATE TABLE G4_Products (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Name NVARCHAR(255) NOT NULL,
    HKKM_Description NVARCHAR(MAX),
    HKKM_Base_Price DECIMAL(18, 2) NOT NULL, 
    HKKM_Stock_Quantity INT DEFAULT 0,
    HKKM_Brand_Id INT,
    HKKM_Gender NVARCHAR(20) CHECK (HKKM_Gender IN ('Boy', 'Girl', 'Unisex')), 
    HKKM_Age_Range NVARCHAR(50), 
    HKKM_Created_At DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (HKKM_Brand_Id) REFERENCES G4_Brands(HKKM_Id)
);

-- Bảng trung gian Nhiều-Nhiều giữa Sản phẩm và Danh mục
CREATE TABLE G4_Product_Categories (
    HKKM_Product_Id INT,
    HKKM_Category_Id INT,
    PRIMARY KEY (HKKM_Product_Id, HKKM_Category_Id),
    FOREIGN KEY (HKKM_Product_Id) REFERENCES G4_Products(HKKM_Id) ON DELETE CASCADE,
    FOREIGN KEY (HKKM_Category_Id) REFERENCES G4_Categories(HKKM_Id) ON DELETE CASCADE
);


-- 3. NHÓM KHUYẾN MÃI (PROMOTIONS)

CREATE TABLE G4_Promotions (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Name NVARCHAR(255) NOT NULL,
    HKKM_Discount_Type NVARCHAR(50) CHECK (HKKM_Discount_Type IN ('PERCENT', 'FIXED_AMOUNT')),
    HKKM_Discount_Value DECIMAL(18, 2) NOT NULL,
    HKKM_Start_Date DATETIME NOT NULL,
    HKKM_End_Date DATETIME NOT NULL
);

-- Bảng trung gian áp dụng Khuyến mãi cho Sản phẩm
CREATE TABLE G4_Product_Promotions (
    HKKM_Product_Id INT,
    HKKM_Promotion_Id INT,
    PRIMARY KEY (HKKM_Product_Id, HKKM_Promotion_Id),
    FOREIGN KEY (HKKM_Product_Id) REFERENCES G4_Products(HKKM_Id) ON DELETE CASCADE,
    FOREIGN KEY (HKKM_Promotion_Id) REFERENCES G4_Promotions(HKKM_Id) ON DELETE CASCADE
);


-- 4. NHÓM ĐƠN HÀNG (ORDERS)

CREATE TABLE G4_Orders (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_User_Id INT,
    HKKM_Total_Amount DECIMAL(18, 2) NOT NULL,
    HKKM_Status NVARCHAR(50) DEFAULT 'Pending', 
    HKKM_Created_At DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (HKKM_User_Id) REFERENCES G4_Users(HKKM_Id)
);

CREATE TABLE G4_Order_Items (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Order_Id INT,
    HKKM_Product_Id INT,
    HKKM_Quantity INT NOT NULL,
    HKKM_Price_At_Purchase DECIMAL(18, 2) NOT NULL, 
    FOREIGN KEY (HKKM_Order_Id) REFERENCES G4_Orders(HKKM_Id) ON DELETE CASCADE,
    FOREIGN KEY (HKKM_Product_Id) REFERENCES G4_Products(HKKM_Id)
);


-- 5. NHÓM MEGA MENU & CONTENT

CREATE TABLE G4_Menu_Items (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Name NVARCHAR(100) NOT NULL,
    HKKM_Link_Url NVARCHAR(MAX),
    HKKM_Parent_Id INT NULL,
    HKKM_Display_Order INT DEFAULT 0, 
    FOREIGN KEY (HKKM_Parent_Id) REFERENCES G4_Menu_Items(HKKM_Id)
);

CREATE TABLE G4_Menu_Featured_Content (
    HKKM_Id INT IDENTITY(1,1) PRIMARY KEY,
    HKKM_Menu_Item_Id INT NOT NULL,
    HKKM_Category_Id INT NULL,
    HKKM_Promotion_Id INT NULL,
    FOREIGN KEY (HKKM_Menu_Item_Id) REFERENCES G4_Menu_Items(HKKM_Id) ON DELETE CASCADE,
    FOREIGN KEY (HKKM_Category_Id) REFERENCES G4_Categories(HKKM_Id),
    FOREIGN KEY (HKKM_Promotion_Id) REFERENCES G4_Promotions(HKKM_Id)
);

USE G4_ToyStore;
GO


-- 1. THÊM DỮ LIỆU BẢNG GỐC (Users, Brands, Promotions)

INSERT INTO G4_Users (HKKM_Email, HKKM_Password_Hash, HKKM_Full_Name, HKKM_Phone, HKKM_Address, HKKM_Role)
VALUES 
(N'admin@toystore.com', N'hashed_pw_admin', N'Quản Trị Viên', N'0999999999', N'Trụ sở chính, TP.HCM', 'Admin'),
(N'khachhang1@gmail.com', N'hashed_pw_1', N'Nguyễn Văn An', N'0901234567', N'Quận 1, TP.HCM', 'Customer'),
(N'khachhang2@gmail.com', N'hashed_pw_2', N'Trần Thị Bình', N'0912345678', N'Quận Đống Đa, Hà Nội', 'Customer');

INSERT INTO G4_Brands (HKKM_Name, HKKM_Logo_Url, HKKM_Description)
VALUES 
(N'LEGO', N'https://link-to-logo/lego.png', N'Thương hiệu đồ chơi lắp ráp nổi tiếng từ Đan Mạch.'),
(N'Hot Wheels', N'https://link-to-logo/hotwheels.png', N'Đồ chơi xe mô hình siêu tốc độ.'),
(N'My Little Pony', N'https://link-to-logo/pony.png', N'Thương hiệu đồ chơi bé gái nổi tiếng.');

INSERT INTO G4_Promotions (HKKM_Name, HKKM_Discount_Type, HKKM_Discount_Value, HKKM_Start_Date, HKKM_End_Date)
VALUES 
(N'Khuyến mãi Hè Rộn Ràng 20%', N'PERCENT', 20.00, '2026-05-01', '2026-08-31'),
(N'Giảm trực tiếp 50k phí vận chuyển', N'FIXED_AMOUNT', 50000.00, '2026-04-01', '2026-12-31'),
(N'Flash Sale LEGO 35%', N'PERCENT', 35.00, '2026-04-19', '2026-04-20');


-- 2. THÊM DANH MỤC VÀ SẢN PHẨM (Categories, Products)

-- Chú ý: Thêm danh mục gốc (Level 1) trước, sau đó mới thêm danh mục con (Level 2)
INSERT INTO G4_Categories (HKKM_Name, HKKM_Parent_Id, HKKM_Icon_Url, HKKM_Level)
VALUES 
(N'Đồ chơi lắp ráp', NULL, N'icon-puzzle.png', 1), -- ID 1
(N'Búp bê & Phụ kiện', NULL, N'icon-doll.png', 1),   -- ID 2
(N'LEGO City', 1, N'icon-lego-city.png', 2),        -- ID 3 (Thuộc Đồ chơi lắp ráp)
(N'LEGO Friends', 1, N'icon-lego-friends.png', 2);  -- ID 4 (Thuộc Đồ chơi lắp ráp)

INSERT INTO G4_Products (HKKM_Name, HKKM_Description, HKKM_Base_Price, HKKM_Stock_Quantity, HKKM_Brand_Id, HKKM_Gender, HKKM_Age_Range)
VALUES 
(N'Trạm Cứu Hỏa LEGO City', N'Bộ lắp ráp trạm cứu hỏa 500 mảnh', 1200000.00, 50, 1, 'Boy', N'6-12y'), -- Brand 1: LEGO
(N'Đường đua siêu tốc Hot Wheels', N'Đường đua vòng lặp vô cực', 850000.00, 30, 2, 'Boy', N'3+'),   -- Brand 2: Hot Wheels
(N'Lâu đài ma thuật Pony', N'Lâu đài và 2 nhân vật Pony', 950000.00, 25, 3, 'Girl', N'3+'),         -- Brand 3: My Little Pony
(N'LEGO Friends Tiệm Cà Phê', N'Tiệm cà phê sinh động', 650000.00, 40, 1, 'Girl', N'6-12y');        -- Brand 1: LEGO


-- 3. THÊM BẢNG TRUNG GIAN (Product_Categories, Product_Promotions)

INSERT INTO G4_Product_Categories (HKKM_Product_Id, HKKM_Category_Id)
VALUES 
(1, 1), (1, 3), -- Trạm Cứu Hỏa thuộc "Đồ chơi lắp ráp" và "LEGO City"
(2, 1),         -- Đường đua thuộc "Đồ chơi lắp ráp" (giả sử)
(3, 2),         -- Lâu đài Pony thuộc "Búp bê & Phụ kiện"
(4, 1), (4, 4); -- Tiệm Cà Phê thuộc "Đồ chơi lắp ráp" và "LEGO Friends"

INSERT INTO G4_Product_Promotions (HKKM_Product_Id, HKKM_Promotion_Id)
VALUES 
(1, 3), -- Trạm cứu hỏa áp dụng "Flash Sale LEGO 35%"
(3, 1), -- Lâu đài Pony áp dụng "Khuyến mãi Hè 20%"
(4, 3); -- Tiệm Cà Phê áp dụng "Flash Sale LEGO 35%"


-- 4. THÊM ĐƠN HÀNG (Orders, Order_Items)

INSERT INTO G4_Orders (HKKM_User_Id, HKKM_Total_Amount, HKKM_Status)
VALUES 
(2, 780000.00, N'Delivered'), -- User 2 (Khách hàng 1) đã nhận hàng
(3, 950000.00, N'Shipping');  -- User 3 (Khách hàng 2) đang giao hàng

INSERT INTO G4_Order_Items (HKKM_Order_Id, HKKM_Product_Id, HKKM_Quantity, HKKM_Price_At_Purchase)
VALUES 
(1, 1, 1, 780000.00), -- Đơn 1 mua Trạm cứu hỏa
(2, 3, 1, 760000.00); -- Đơn 2 mua Pony 


-- 5. THÊM MEGA MENU & CONTENT (Menu_Items, Menu_Featured_Content)

INSERT INTO G4_Menu_Items (HKKM_Name, HKKM_Link_Url, HKKM_Parent_Id, HKKM_Display_Order)
VALUES 
(N'Sản phẩm', N'/san-pham', NULL, 1),         -- ID 1
(N'Khuyến mãi', N'/khuyen-mai', NULL, 2),     -- ID 2
(N'Thương hiệu', N'/thuong-hieu', NULL, 3),   -- ID 3
(N'LEGO', N'/thuong-hieu/lego', 3, 1);        -- ID 4 (Nằm trong Thương hiệu)

INSERT INTO G4_Menu_Featured_Content (HKKM_Menu_Item_Id, HKKM_Category_Id, HKKM_Promotion_Id)
VALUES 
(1, 1, NULL), -- Nhấn vào menu "Sản phẩm" hiển thị danh mục "Đồ chơi lắp ráp" nổi bật
(2, NULL, 3), -- Nhấn vào "Khuyến mãi" hiển thị banner của "Flash Sale LEGO 35%"
(4, 3, NULL); -- Nhấn vào menu "LEGO" hiển thị danh mục "LEGO City" nổi bật