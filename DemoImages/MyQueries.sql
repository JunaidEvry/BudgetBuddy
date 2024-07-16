CREATE DATABASE FinanceManager;
GO

USE FinanceManager;
GO

-- Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Type NVARCHAR(10) CHECK (Type IN ('Income', 'Expense')) NOT NULL
);
GO

-- Transactions table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    Date DATETIME NOT NULL,
    Type NVARCHAR(10) CHECK (Type IN ('Income', 'Expense')) NOT NULL,
    CategoryID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Description NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserID FOREIGN KEY (UserID) REFERENCES Users(UserID) ,
    CONSTRAINT FK_CategoryID FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) 
);
GO

-- Receipts table
CREATE TABLE Receipts (
    ReceiptID INT PRIMARY KEY IDENTITY(1,1),
    TransactionID INT NOT NULL,
    FilePath NVARCHAR(255) NOT NULL, -- Path to the uploaded receipt file
    UploadDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_TransactionID FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);
GO

-- Settings table
CREATE TABLE Settings (
    SettingID INT PRIMARY KEY IDENTITY(1,1),
    SettingName NVARCHAR(100) NOT NULL
);
GO

-- UserSettings table
CREATE TABLE UserSettings (
    UserSettingID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    SettingID INT NOT NULL,
    SettingValue NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserID_UserSettings FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_SettingID_UserSettings FOREIGN KEY (SettingID) REFERENCES Settings(SettingID)
);


select * from transactions;
select * from UserSettings;
select * from users;
select * from Categories;
select * from receipts;
select * from Settings;



insert ALTER TABLE Users ADD TokenExpiry DATETIME NULL;;

ALTER TABLE Categories
ADD UserID INT NOT NULL;


-- Add the foreign key constraint
ALTER TABLE Categories
ADD CONSTRAINT FK_Categories_Users
FOREIGN KEY (UserID) REFERENCES Users(UserID);

-- Ensure the Name column cannot have duplicate values for the same user and type
ALTER TABLE Categories
ADD CONSTRAINT UQ_User_Category_Type UNIQUE (UserID, Name, Type);


			INSERT INTO Settings (SettingName) VALUES ('theme');
INSERT INTO Settings (SettingName) VALUES ('timezone');
INSERT INTO Settings (SettingName) VALUES ('language');
INSERT INTO Settings (SettingName) VALUES ('dateFormat');
INSERT INTO Settings (SettingName) VALUES ('currency');

