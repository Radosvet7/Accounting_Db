# Accounting Database creation and querying

## 1. Create a database called Accounting with the following diagram:

image diagram

```sql
CREATE TABLE Countries (
	[Id] INT PRIMARY KEY NOT NULL IDENTITY,
	[Name] VARCHAR(10) NOT NULL
);


CREATE TABLE Addresses (
	[Id] INT NOT NULL PRIMARY KEY IDENTITY,
	[StreetName] NVARCHAR(20) NOT NULL,
	[StreetNumber] INT,
	[PostCode] INT NOT NULL,
	[City] VARCHAR(25) NOT NULL,
	[CountryId] INT NOT NULL FOREIGN KEY REFERENCES Countries(Id)
);


CREATE TABLE [Vendors] (
	[Id] INT NOT NULL PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) NOT NULL,
	[NumberVAT] NVARCHAR(15) NOT NULL,
	[AddressId] INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
);


CREATE TABLE [Clients] (
	[Id] INT NOT NULL PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) NOT NULL,
	[NumberVAT] NVARCHAR(15) NOT NULL,
	[AddressId] INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
);


CREATE TABLE Categories (
	[Id] INT NOT NULL PRIMARY KEY IDENTITY,
	[Name] VARCHAR(10) NOT NULL
);


CREATE TABLE Products (
	[Id] INT NOT NULL PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(35) NOT NULL,
	[Price] DECIMAL(18,2) NOT NULL,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	VendorId INT NOT NULL FOREIGN KEY REFERENCES Vendors(Id)
);



CREATE TABLE Invoices (
	[Id] INT NOT NULL PRIMARY KEY IDENTITY,
	[Number] INT UNIQUE NOT NULL,
	IssueDate DATETIME2 NOT NULL,
	DueDate DATETIME2 NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	Currency VARCHAR(5) NOT NULL,
	ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id)
);


CREATE TABLE ProductsClients (
	ProductId INT NOT NULL FOREIGN KEY REFERENCES Products(Id),
	ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id),
	CONSTRAINT PK_ProductsClients PRIMARY KEY (ProductId, ClientId)
);
```

## 2. Insert some sample data into the database. Write a query to add the following records into the corresponding tables. All IDs should be auto-generated.

image for insertion

```sql
INSERT INTO Products ([Name], 
	Price, 
	CategoryId, 
	VendorId)
	VALUES
	('SCANIA Oil Filter XD01', 78.69, 1, 1),
	('MAN Air Filter XD01', 97.38, 1, 5 ),
	('DAF Light Bulb 05FG87', 55.00, 2,	13),
	('ADR Shoes 47-47.5', 49.85, 3, 5),
	('Anti-slip pads S', 5.87, 5, 7);

INSERT INTO Invoices (Number, IssueDate, DueDate, Amount, Currency, ClientId)
	VALUES
	(1219992181, '2023-03-01', '2023-04-30', 180.96, 'BGN', 3),
	(1729252340, '2022-11-06', '2023-01-04', 158.18, 'EUR', 13),
	(1950101013, '2023-02-17', '2023-04-18', 615.15, 'USD', 19);
```
