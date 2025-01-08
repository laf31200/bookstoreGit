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

