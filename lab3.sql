--1.	Podaj identyfikator najd�u�ej realizowanego zam�wienia (DATEDIFF)
SELECT 
	TOP 1
	OrderID,
	DATEDIFF(DAY, OrderDate, ShippedDate) as ile_dni_bylo_realizowane_zamowienie
FROM Orders
Order BY ile_dni_bylo_realizowane_zamowienie desc

--2.	Wskaza� pracownika kt�ry obs�ugiwa� klienta, kt�rego nie obs�ugiwa� nikt 
SELECT DISTINCT c.CustomerID, COUNT(c.CustomerID) as ile_pracownikow_obslugiwalo 
FROM Orders o
	JOIN Employees e
ON e.EmployeeID = o.EmployeeID
	JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID
HAVING COUNT(c.CustomerID) = 1

--3.	Poda� klient�w, kt�rzy mieli przerw� w zakupach d�u�sz� ni� 2 miesi�ce
SELECT 
	o1.CustomerID,
	o1.OrderDate,
	o2.OrderDate,
	DATEDIFF(MONTH, o1.OrderDate, o2.OrderDate) as gap
FROM Orders o1
	JOIN Orders o2
ON o1.CustomerID = o2.CustomerID
AND o2.OrderDate > o1.OrderDate
WHERE DATEDIFF(DAY, o1.OrderDate, o2.OrderDate) > 2
ORDER BY gap DESC

--4.	Wypisa� identyfikatory tych pracownik�w, kt�rzy realizowali wi�cej zam�wie� ni� liczba zam�wie� zrealizowanych przez pracownik�w z tego samego kraju co spedytorzy.
WITH EmployeeOrders AS (SELECT 
    EmployeeID,
    COUNT(OrderID) as total
FROM Orders
GROUP BY EmployeeID),
ShipperCountryOrders AS 
(SELECT DISTINCT
	Employees.Country,
	Orders.ShipCountry
FROM Orders 
	JOIN Employees 
on Employees.EmployeeID = Orders.EmployeeID
WHERE Employees.Country = Orders.ShipCountry)

--5.	Wypisz pracownika, kt�ry nie obs�ugiwa� �adnego zam�wienia
SELECT * FROM Employees e
	WHERE e.EmployeeID NOT IN (
	SELECT DISTINCT e.EmployeeID FROM Employees e
	JOIN Orders o 
	ON O.EmployeeID = E.EmployeeID
)

--6.	Podaj nazw� najskuteczniejszego spedytora
SELECT TOP 1 s.ShipperID, s.CompanyName, COUNT(s.ShipperID) as ile_operacji_spedycyjnych
FROM Orders o
	JOIN Shippers s 
ON s.ShipperID = o.ShipVia
GROUP BY s.ShipperID, s.CompanyName
ORDER BY ile_operacji_spedycyjnych DESC

--7.	Przygotuj raport wszystkich klient�w oraz produkty w ramach zam�wie�. Wy�wietl r�wnie� produkty kt�re nie zosta�y nigdy zam�wione oraz klient�w kt�rzy nigdy nic zam�wili (FULL OUTER JOIN).
SELECT 
	c.CompanyName,
	o.OrderID,
	p.ProductName
FROM Customers c
	FULL OUTER JOIN Orders o 
ON o.CustomerID = c.CustomerID
	FULL OUTER JOIN [Order Details] od
ON od.OrderID = o.OrderID
	FULL OUTER JOIN Products p
ON od.ProductID = p.ProductID
ORDER BY c.CustomerID, o.OrderID

--8.	Wypisz nazwy produkt�w, kt�re zosta�y zam�wione zar�wno przez klient�w z Barcelony jak i klient�w z Sewilli
SELECT DISTINCT p.ProductName 
FROM Orders o
JOIN Customers c ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON od.OrderID = O.OrderID
JOIN Products p ON p.ProductID = od.ProductID
WHERE (c.City = 'Barcelona' OR c.City = 'Sevilla')
ORDER BY p.ProductName

--Zadania do samodzielnego wykonania:
--1.	W firmie u�ywaj�cej bazy Northwind pracownicy (tabela Employees) posiadaj� adresy emial�owe. Za��my, �e standardowo nazwa konta (cz�� przed znakiem @) zbudowana jest z pierwszej litery imienia (firstname) oraz pierwszych o�miu znak�w nazwiska (lastname). Utw�rz zapytanie, kt�re wygeneruje te nazwy email�owe. W tym zadaniu nale�y u�y� funkcji �a�cuchowych LOWER i SUBSTRING.
SELECT 
	FirstName,
	LastName, 
	LOWER(SUBSTRING(FirstName, 1, 1)) + LOWER(SUBSTRING(LastName, 1, 8)) + '@wsiz.edu.pl' as Email
FROM Employees

--2.	Podaj dzie� w kt�rym by�o najwi�cej zam�wie�
SELECT TOP 1
	OrderDate, COUNT(OrderDate) as Zamowienia_danego_dnia, WEEKDAY(OrderDate)
FROM Orders
GROUP BY OrderDate
ORDER BY COUNT(OrderDate) DESC

--3.	Wypisz nazw� i adres najcz�ciej zamawiaj�cego klienta
SELECT TOP 1
	c.CompanyName,
	c.Address
FROM Orders o
JOIN Customers c
ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName, c.Address
ORDER BY COUNT(o.CustomerID) DESC

--4.	Wypisz nazwisko pracownika, kt�ry najd�u�ej pracuje
SELECT TOP 1
	LastName
FROM Employees
ORDER BY HireDate ASC
