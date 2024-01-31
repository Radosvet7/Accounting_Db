--1.
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

--2.
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

--3.
UPDATE Invoices
	SET DueDate = '2023-04-01'
	WHERE MONTH(IssueDate) = 11 and YEAR(IssueDate) = 2022

UPDATE Clients
	SET AddressId = 3
	WHERE [Name] LIKE '%CO%'

--4.
DELETE FROM Invoices
	WHERE ClientId IN (SELECT DISTINCT Id FROM Clients WHERE LEFT(NumberVAT, 2) = 'IT')

DELETE FROM ProductsClients
	WHERE ClientId IN (SELECT DISTINCT Id FROM Clients WHERE LEFT(NumberVAT, 2) = 'IT')

DELETE FROM Clients
	WHERE LEFT(NumberVAT, 2) = 'IT'

--5.
SELECT [number],
       currency
FROM   invoices
ORDER  BY amount DESC,
          duedate ASC

--6.
select p.Id, p.Name, p.Price, c.Name as CategoryName 
from Products as p
join Categories as c on p.CategoryId = c.Id
WHERE c.Name IN ('ADR', 'Others')
ORDER BY p.Price DESC

--7.
SELECT c.Id, 
c.[Name] AS Client,
CONCAT(a.StreetName, ' ', a.StreetNumber, ', ', a.City, ', ', a.PostCode, ', ', cn.[Name]) as Adreess
FROM Clients as c
JOIN Addresses as a on c.AddressId = a.Id
JOIN Countries AS cn on a.countryId = cn.Id
LEFT JOIN ProductsClients as pc on c.Id = pc.ClientId
WHERE pc.ProductId IS NULL
ORDER BY c.[Name] ASC

--8.
SELECT TOP 7 i.number,
             i.amount,
             c.NAME AS Client
FROM   invoices AS i
       JOIN clients AS c
         ON i.clientid = c.id
WHERE  ( Year(i.issuedate) < 2023
         AND i.currency = 'EUR' )
        OR ( i.amount > 500
             AND LEFT(c.numbervat, 2) = 'DE' )
ORDER  BY i.number ASC,
          i.amount DESC 

--9.
SELECT c.[name]     AS Client,
       Max(p.price) AS Price,
       c.numbervat  AS [VAT Number]
FROM   clients AS c
       JOIN productsclients AS pc
         ON pc.clientid = c.id
       JOIN products AS p
         ON pc.productid = p.id
WHERE  c.[name] NOT LIKE '%KG'
GROUP  BY c.[name],
          c.numbervat
ORDER  BY Max(p.price) DESC

--10.
SELECT c.[name]            AS Client,
       Floor(Avg(p.price)) AS [Average Price]
FROM   clients AS C
       JOIN productsclients AS pc
         ON pc.clientid = c.id
       JOIN products AS p
         ON pc.productid = p.id
       JOIN vendors AS v
         ON p.vendorid = v.id
WHERE  v.numbervat LIKE '%FR%'
GROUP  BY c.[name]
ORDER  BY Floor(Avg(p.price)) ASC,
          c.[name] DESC

--11.
CREATE FUNCTION Udf_productwithclients(@name NVARCHAR(35))
returns INT
AS
  BEGIN
      DECLARE @result INT

      SELECT @result = Count (*)
      FROM   clients AS c
             JOIN productsclients AS pc
               ON pc.clientid = c.id
             JOIN products AS p
               ON pc.productid = p.id
                  AND p.[name] = @name

      IF ( @result IS NULL )
        SET @result = 0;

      RETURN @result;
  END;

SELECT dbo.udf_ProductWithClients('DAF FILTER HU12103X')

--12.
CREATE PROCEDURE Usp_searchbycountry @country VARCHAR(10)
AS
    SELECT v.[name]                                     AS Vendor,
           v.numbervat                                  AS VAT,
           Concat_ws(' ', a.streetname, a.streetnumber) AS [Street Info],
           Concat_ws(' ', a.city, a.postcode)           AS [City Info]
    FROM   vendors AS v
           JOIN addresses AS a
             ON v.addressid = a.id
           JOIN countries AS c
             ON a.countryid = c.id
    WHERE  c.[name] = @country
    ORDER  BY v.[name] ASC,
              a.city ASC;

EXEC usp_SearchByCountry 'France'