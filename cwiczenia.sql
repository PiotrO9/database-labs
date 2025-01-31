USE Northwind

--1. Pokaz wartosc zamowienia po podanym id

CREATE PROCEDURE PokazWartoscZamowienia4
	@Id INT,
	@Suma INT OUTPUT
AS
BEGIN
	SELECT @Suma = SUM(od.UnitPrice * od.Quantity) FROM Orders o 
	JOIN [Order Details] od
	ON od.OrderID = o.OrderID
	WHERE o.OrderID = @Id
	GROUP BY o.OrderID
END;

DECLARE @wynik INT
EXEC PokazWartoscZamowienia4 @Id = 10249, @Suma = @wynik OUTPUT;
PRINT @wynik

SELECT * FROM Employees


--2. Pokaz ile razy dany klient robil zakupy na bazie id klienta

CREATE PROCEDURE PokazIleRazyKlientRobilZakupy3
	@klientId VARCHAR(10),
	@ilosc INT OUTPUT
AS
BEGIN
	SELECT @ilosc = COUNT(*) FROM Orders o
	JOIN Customers c
	ON o.CustomerID = c.CustomerID
	WHERE o.CustomerID = @klientId
END;

DECLARE @ileRazyBylyZakupy INT
EXEC PokazIleRazyKlientRobilZakupy3 @klientId = 'ALFKI', @ilosc = @ileRazyBylyZakupy OUTPUT;

PRINT @ileRazyBylyZakupy

SELECT DISTINCT COUNT(*) FROM Orders o
	JOIN Customers c
	ON o.CustomerID = c.CustomerID
	WHERE o.CustomerID = 'ALFKI';


--3. Napisz procedure, ktora zabroni zwiekszania pensji pracownikom o wiecej niz 10% aktualnej pensji

USE Northwind

CREATE TRIGGER ZabronZwiekszaniaPensji3
on Employees
AFTER UPDATE
AS if update(Salary)
	BEGIN
		DECLARE @new money, @old money
		SELECT @new = Salary from inserted
		SELECT @old = Salary from deleted
		if (@new > @old * 1.1)
			rollback TRANSACTION;
	END;


SELECT EmployeeID, Salary FROM Employees 

UPDATE Employees SET Salary = 100 WHERE EmployeeID = 3


--4. Za pomocπ kursora policz ile kosztowa≥y wszystkie pozycje dla zamowienia o id 10248

DECLARE @licznik INT = 0
DECLARE @ilosc INT, @cena INT

DECLARE k1 CURSOR
FOR SELECT od.Quantity, od.UnitPrice FROM [Order Details] od WHERE od.OrderID = 10248

OPEN k1
	FETCH NEXT FROM k1 INTO @ilosc, @cena
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @licznik = @licznik + (@ilosc * @cena)
		FETCH NEXT FROM k1 INTO @ilosc, @cena
	END;

CLOSE k1
DEALLOCATE k1

SELECT @licznik AS SumaZamowienia

SELECT od.OrderID, SUM(od.UnitPrice * od.Quantity) as Suma
FROM [Order Details] od 
WHERE od.OrderID = 10248
GROUP BY od.OrderID

--5. Za pomocπ kursora znajdü najdroøsza pozycje w zakupach o id 10248
DECLARE @najwyzszaCena INT = 0
DECLARE @ilosc2 INT, @cena2 INT

DECLARE k2 CURSOR
FOR SELECT od.Quantity, od.UnitPrice FROM [Order Details] od WHERE od.OrderID = 10248

OPEN k2
	FETCH NEXT FROM k2 into @ilosc2, @cena2
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if @najwyzszaCena < (@cena2 * @ilosc2)
			set @najwyzszaCena = (@cena2 * @ilosc2)
		FETCH NEXT FROM k2 into @ilosc2, @cena2
	END;
CLOSE k2
DEALLOCATE k2

SELECT @najwyzszaCena AS najwyzsza

SELECT MAX(od.UnitPrice * od.Quantity) as maksymalnaCena
FROM [Order Details] od 
WHERE od.OrderID = 10248


--6.	Korzystajπc z tabeli produkty stwÛrz transakcjÍ, ktÛra przeniesie wszystkie produkty z magazynu nr 1 do magazynu nr 2. Maksymalna pojemnoúÊ magazynu nr 2 wynosi 500. Jeøeli powyøsza operacja spowoduje przepe≥nienie magazynu naleøy jπ wycofaÊ i przenieúÊ produkty do magazynu nr 3.
create database testTransakcje
USE testTransakcje

create table produkty (
	id int identity primary key,
	nr_magazynu int,
	ilosc int
)

insert into produkty values (1, 200);
insert into produkty values (2, 200);
insert into produkty values (3, 300);


BEGIN TRANSACTION tran1
SAVE TRANSACTION save1
UPDATE produkty SET nr_magazynu = 2 WHERE nr_magazynu = 1
if (SELECT SUM(ilosc) FROM produkty where nr_magazynu = 1) > 500
	BEGIN
		ROLLBACK TRANSACTION save1
		UPDATE produkty set nr_magazynu = 3 where nr_magazynu = 1
	END;
COMMIT TRANSACTION