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

## 3. We've decided to change the due date of the invoices, issued in November 2022. Update the due date and change it to 2023-04-01. Then, you have to change the addresses of the clients, which contain "CO" in their names. The new value of the addresses should be Industriestr, 79, 2353, Guntramsdorf, Austria.

```sql
UPDATE invoices
SET    duedate = '2023-04-01'
WHERE  Month(issuedate) = 11
       AND Year(issuedate) = 2022

UPDATE clients
SET    addressid = 3
WHERE  [name] LIKE '%CO%' 
```

## 4. In table Clients, delete every client, whose VAT number starts with "IT". Keep in mind that there could be foreign key constraint conflicts.

```sql
DELETE FROM invoices
WHERE  clientid IN (SELECT DISTINCT id
                    FROM   clients
                    WHERE  LEFT(numbervat, 2) = 'IT')

DELETE FROM productsclients
WHERE  clientid IN (SELECT DISTINCT id
                    FROM   clients
                    WHERE  LEFT(numbervat, 2) = 'IT')

DELETE FROM clients
WHERE  LEFT(numbervat, 2) = 'IT' 
```
## 5. Select all invoices, ordered by amount (descending), then by due date (ascending).

```sql
SELECT [number],
       currency
FROM   invoices
ORDER  BY amount DESC,
          duedate ASC
```
output result 5

## 6. Select all products with "ADR" or "Others" categories. Order results by Price (descending).

```sql
SELECT p.id,
       p.NAME,
       p.price,
       c.NAME AS CategoryName
FROM   products AS p
       JOIN categories AS c
         ON p.categoryid = c.id
WHERE  c.NAME IN ( 'ADR', 'Others' )
ORDER  BY p.price DESC
```
output result 6

## 7. Select all clients without products. Order them by name (ascending).

```sql
SELECT c.id,
       c.[name]   AS Client,
       Concat(a.streetname, ' ', a.streetnumber, ', ', a.city, ', ', a.postcode,
       ', ',
       cn.[name]) AS Adreess
FROM   clients AS c
       JOIN addresses AS a
         ON c.addressid = a.id
       JOIN countries AS cn
         ON a.countryid = cn.id
       LEFT JOIN productsclients AS pc
              ON c.id = pc.clientid
WHERE  pc.productid IS NULL
ORDER  BY c.[name] ASC
```
output result 7
