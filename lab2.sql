--1.	Spo�r�d klient�w z Londynu wybierz tych kt�rych nazwa zaczyna na si� na A, B lub C
SELECT * from Customers Where city = 'London' AND (ContactName Like 'A%' OR ContactName Like 'B%' OR ContactName Like 'C%')

--2.	Wy�wietl informacje o zam�wieniach z czerwca 1997 obs�ugiwanych na wschodzie, kt�rych warto�� przekroczy�a �redni� warto�� wszystkich zam�wie�
SELECT DISTINCT
	Orders.OrderID,
	([Order Details].UnitPrice * [Order Details].Quantity) as kwota_produktu
FROM Orders
JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID 
JOIN EmployeeTerritories ON Employees.EmployeeID = EmployeeTerritories.EmployeeID
JOIN Territories ON EmployeeTerritories.TerritoryID = Territories.TerritoryID
JOIN Region ON Territories.RegionID = Region.RegionID
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
WHERE (
	YEAR(Orders.OrderDate) = 1997 AND
	Month(Orders.OrderDate) = 6
) AND
Region.RegionDescription = 'Western'
AND ([Order Details].UnitPrice * [Order Details].Quantity) > (
	SELECT DISTINCT
		avg([Order Details].UnitPrice * [Order Details].Quantity)
	FROM Orders
	JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID 
	JOIN EmployeeTerritories ON Employees.EmployeeID = EmployeeTerritories.EmployeeID
	JOIN Territories ON EmployeeTerritories.TerritoryID = Territories.TerritoryID
	JOIN Region ON Territories.RegionID = Region.RegionID
	JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
)

--3.	Wypisz produkt, kt�ry ma najni�sz� cen�
SELECT MIN(UnitPrice) AS najnizsza_cena FROM Products

--4.	Znale�� produkty o cenach najni�szych w swoich kategoriach
SELECT * 
FROM Products p
	JOIN Categories c
	ON p.CategoryID = c.CategoryID
WHERE UnitPrice = (
	SELECT MIN(UnitPrice) 
	FROM Products p2
	WHERE p2.CategoryID = p.CategoryID
)

--5.	Podaj ilu pracownik�w mieszka w takich samych miastach
SELECT City, Count(*) as ilosc_mieszka�cow_w_miescie 
FROM Employees 
GROUP BY City
HAVING Count(*) > 1
ORDER BY ilosc_mieszka�cow_w_miescie DESC

--6.	Wskaza� produkt, kt�rego nikt inny nie zamawia�
SELECT * FROM Products p 
WHERE p.ProductID 
NOT IN (
	SELECT ProductID FROM [Order Details] od
)

--7.	Wypisz klient�w, kt�rzy nie zamawiali
SELECT CustomerID FROM Customers c WHERE c.CustomerID NOT IN (
	SELECT CustomerID FROM Orders
)

--8.	Kt�rzy klienci najcz�ciej zamawiali
SELECT TOP 1 CustomerID, count(*) as ilosc_zamowien
FROM Orders 
GROUP BY CustomerID 
Order BY ilosc_zamowien DESC

--9.	Napisz kwerend�, kt�ra zwr�ci list� miast, w kt�rych mieszkaj� zar�wno klienci, jak i pracownicy
SELECT e.City FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE e.City IN (
	SELECT City FROM Customers
)
GROUP BY e.City


--Zadania do samodzielnego wykonania:
--1.	Policzy� �rednie ceny produkt�w dla ka�dej z kategorii z wyj�tkiem kategorii Seafood 
SELECT c.CategoryName, AVG(p.UnitPrice) as srednia_cena_produktu_w_kategorii FROM Products p
JOIN Categories c 
ON c.CategoryID = p.CategoryID
WHERE c.CategoryName != 'Seafood'
GROUP BY c.CategoryName

--2.	Podaj �redni� warto�� zam�wie� w ka�dej kategorii
SELECT c.CategoryName, ROUND(AVG(od.UnitPrice * od.Quantity), 2) as srednia_wartosc_zamowienia FROM [Order Details] od
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY C.CategoryName

--3.	Wypisz kategorie kt�rych �rednie ceny s� powy�ej 10
SELECT c.CategoryName, Round(AVG(p.UnitPrice), 2) 
FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName

--4.	Wypisz najd�u�ej pracuj�ce osoby na ka�dym stanowisku
SELECT e.Title, e.FirstName, e.LastName, e.HireDate 
FROM Employees e
JOIN (
	Select Title, MIN(HireDate) AS EarliestHireDate 
	FROM Employees
	GROUP BY Title
) as earliest 
ON earliest.Title = e.Title
AND earliest.EarliestHireDate = e.HireDate

--5.	Oblicz wiek pracownik�w (funkcja YEAR, DATEDIFF)
SELECT FirstName, DATEDIFF(YEAR, BirthDate, GETDATE()) AS Age 
FROM Employees;

--6.	Znajd� pracownika o najd�u�szym nazwisku (funkcja length) 
SELECT TOP 1 FirstName, LastName FROM Employees
ORDER BY len(LastName) desc

--7.	Podaj ilu pracownik�w mieszka w takich samych miastach
SELECT City, COUNT(City) as liczba_pracownikow FROM Employees
GROUP BY City
ORDER BY liczba_pracownikow desc

--8.	Sprawd� czy do wszystkich klient�w posiadasz numer faksu
SELECT * FROM Customers
WHERE Fax is null