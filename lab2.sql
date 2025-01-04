--1.	Spoœród klientów z Londynu wybierz tych których nazwa zaczyna na siê na A, B lub C
SELECT * from Customers Where city = 'London' AND (ContactName Like 'A%' OR ContactName Like 'B%' OR ContactName Like 'C%')

--2.	Wyœwietl informacje o zamówieniach z czerwca 1997 obs³ugiwanych na wschodzie, których wartoœæ przekroczy³a œredni¹ wartoœæ wszystkich zamówieñ
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

--3.	Wypisz produkt, który ma najni¿sz¹ cenê
SELECT MIN(UnitPrice) AS najnizsza_cena FROM Products

--4.	ZnaleŸæ produkty o cenach najni¿szych w swoich kategoriach
SELECT * 
FROM Products p
	JOIN Categories c
	ON p.CategoryID = c.CategoryID
WHERE UnitPrice = (
	SELECT MIN(UnitPrice) 
	FROM Products p2
	WHERE p2.CategoryID = p.CategoryID
)

--5.	Podaj ilu pracowników mieszka w takich samych miastach
SELECT City, Count(*) as ilosc_mieszkañcow_w_miescie 
FROM Employees 
GROUP BY City
HAVING Count(*) > 1
ORDER BY ilosc_mieszkañcow_w_miescie DESC

--6.	Wskazaæ produkt, którego nikt inny nie zamawia³
SELECT * FROM Products p 
WHERE p.ProductID 
NOT IN (
	SELECT ProductID FROM [Order Details] od
)

--7.	Wypisz klientów, którzy nie zamawiali
SELECT CustomerID FROM Customers c WHERE c.CustomerID NOT IN (
	SELECT CustomerID FROM Orders
)

--8.	Którzy klienci najczêœciej zamawiali
SELECT TOP 1 CustomerID, count(*) as ilosc_zamowien
FROM Orders 
GROUP BY CustomerID 
Order BY ilosc_zamowien DESC

--9.	Napisz kwerendê, która zwróci listê miast, w których mieszkaj¹ zarówno klienci, jak i pracownicy
SELECT e.City FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE e.City IN (
	SELECT City FROM Customers
)
GROUP BY e.City


--Zadania do samodzielnego wykonania:
--1.	Policzyæ œrednie ceny produktów dla ka¿dej z kategorii z wyj¹tkiem kategorii Seafood 
SELECT c.CategoryName, AVG(p.UnitPrice) as srednia_cena_produktu_w_kategorii FROM Products p
JOIN Categories c 
ON c.CategoryID = p.CategoryID
WHERE c.CategoryName != 'Seafood'
GROUP BY c.CategoryName

--2.	Podaj œredni¹ wartoœæ zamówieñ w ka¿dej kategorii
SELECT c.CategoryName, ROUND(AVG(od.UnitPrice * od.Quantity), 2) as srednia_wartosc_zamowienia FROM [Order Details] od
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY C.CategoryName

--3.	Wypisz kategorie których œrednie ceny s¹ powy¿ej 10
SELECT c.CategoryName, Round(AVG(p.UnitPrice), 2) 
FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName

--4.	Wypisz najd³u¿ej pracuj¹ce osoby na ka¿dym stanowisku
SELECT e.Title, e.FirstName, e.LastName, e.HireDate 
FROM Employees e
JOIN (
	Select Title, MIN(HireDate) AS EarliestHireDate 
	FROM Employees
	GROUP BY Title
) as earliest 
ON earliest.Title = e.Title
AND earliest.EarliestHireDate = e.HireDate

--5.	Oblicz wiek pracowników (funkcja YEAR, DATEDIFF)
SELECT FirstName, DATEDIFF(YEAR, BirthDate, GETDATE()) AS Age 
FROM Employees;

--6.	ZnajdŸ pracownika o najd³u¿szym nazwisku (funkcja length) 
SELECT TOP 1 FirstName, LastName FROM Employees
ORDER BY len(LastName) desc

--7.	Podaj ilu pracowników mieszka w takich samych miastach
SELECT City, COUNT(City) as liczba_pracownikow FROM Employees
GROUP BY City
ORDER BY liczba_pracownikow desc

--8.	SprawdŸ czy do wszystkich klientów posiadasz numer faksu
SELECT * FROM Customers
WHERE Fax is null