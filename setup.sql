-- Creation des tables --
CREATE TABLE Books (
    BookID INTEGER,
    Title VARCHAR(30),
    Author VARCHAR(30),
    Genre VARCHAR(30),
    Price FLOAT,
    Stock INTEGER,

    CONSTRAINT pk_Books PRIMARY KEY (BookID),
    CONSTRAINT Books_not_negative_values CHECK (Price >= 0)
);

CREATE TABLE Customers ( 
    CustomerID INTEGER ,
    Name VARCHAR(30),
    Email VARCHAR(50),
    Phone VARCHAR (15),

    CONSTRAINT pk_Customers PRIMARY KEY (CustomerID)

);

CREATE TABLE Orders (
  OrderID INTEGER ,
  CustomerID INTEGER ,
  BookID INTEGER ,
  Quantity INTEGER ,
  OrderDate DATE ,

  CONSTRAINT pk_Orders PRIMARY KEY (OrderID),
  CONSTRAINT fk_Orders_CustomerId  FOREIGN KEY (CustomerID)
  REFERENCES Customers (CustomerID) ON DELETE CASCADE,
  CONSTRAINT fk_Orders_BookID  FOREIGN KEY (BookID)
  REFERENCES Books (BookID) ON DELETE CASCADE

);
-- Verfier la creation des tables et listage--
SELECT name FROM sqlite_master WHERE type='table';


-- voir la structure des tables --
SELECT * FROM PRAGMA_table_info('Books');

SELECT * FROM PRAGMA_table_info('Customers');

SELECT * FROM PRAGMA_table_info('Orders');

-- voir les relations entre table --


WITH fk AS (
    SELECT m.name AS table_name, f.*
    FROM sqlite_master m, pragma_foreign_key_list(m.name) f
    WHERE m.type = 'table' 
)
SELECT * FROM fk;


-- affichage des table avec les donnees du fichier bookstore_data --
SELECT * FROM Books
SELECT * FROM Customers
SELECT * FROM Orders


-- Afficher tous les livres ecris par j.k rowling --
SELECT * FROM Books WHERE Author = "J.K. Rowling"


-- Afficher les nom , email et phone , des client qui a commader au moins 3 commade --
SELECT DISTINCT Name,Email,Phone FROM Customers, Orders
WHERE Customers.CustomerID=Orders.CustomerID 
GROUP BY Orders.CustomerID
HAVING SUM(Quantity) >= 3 ;

-- Simule une commande --
INSERT INTO Orders 
VALUES (4,2,1,1,'2024-12-21');

-- mettre a jour le stock apres la commande--

UPDATE Books
SET Stock= Stock-1 
WHERE BookID=1;

-- la somme total de somme encrager par livre --
SELECT Title AS TITLE , SUM(Orders.quantity*Books.Price) AS TOTALSALES
FROM Books,Orders
WHERE Books.BookID=Orders.BookID 
GROUP BY Title ;

-- Afficher les titres, quantités et dates de commandes pour CustomerID = 3 --
SELECT Title, Quantity, OrderDate 
FROM Orders, Books 
WHERE CustomerID = 3
AND Orders.BookID = Books.BookID;

-- Afficher les titres et quantités des livres commandés en 2024 --
SELECT Title, Quantity 
FROM Orders, Books 
WHERE OrderDate LIKE "%2024%"
AND Orders.BookID = Books.BookID;

-- Afficher les quantités et dates de commande dont le titre contient "Harry" --
SELECT Quantity, OrderDate 
FROM Orders, Books 
WHERE Title LIKE "%Harry%"
AND Orders.BookID = Books.BookID;

-- Afficher les dates de commande et quantités pour BookID = 1 --
SELECT OrderDate, Quantity 
FROM Orders 
WHERE BookID = 1;

-- Afficher les 2 livres les plus commandés avec leurs titres et quantités totales --
SELECT Title, SUM(Quantity) AS Total_Quantity 
FROM Orders, Books 
WHERE Books.BookID = Orders.BookID 
GROUP BY Orders.BookID 
ORDER BY Total_Quantity DESC 
LIMIT 2;

-- Calculer le chiffre d'affaires pour les commandes passées entre le 1er décembre 2024 et le 1er janvier 2025 --
SELECT OrderDate, Quantity * Price AS TURNOVER 
FROM Orders, Books 
WHERE Books.BookID = Orders.BookID 
AND OrderDate BETWEEN '2024-12-01' AND '2025-01-01' 
GROUP BY Orders.BookID, OrderDate 
ORDER BY OrderDate;

-- Supprimer le livre ayant BookID = 1070 --
DELETE FROM Books 
WHERE BookID = 5;

-- Afficher les noms, emails et numéros de téléphone des clients ayant passé au moins 2 commandes --
SELECT DISTINCT Name, Email, Phone 
FROM Customers, Orders 
WHERE Customers.CustomerID = Orders.CustomerID 
GROUP BY Orders.CustomerID 
HAVING SUM(Quantity) >= 2;
