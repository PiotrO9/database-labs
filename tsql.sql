--1.	Zarobki poni�ej 3 tys nale�y zwi�kszy� o 20%, a zarobki powy�ej 3 tys nale�y obni�y� o 10%
UPDATE Pracownicy
SET pensja = CASE
	WHEN pensja < 3000 THEN pensja * 1.2
	WHEN pensja > 3000 THEN pensja * 0.9
	ELSE pensja
END;
SELECT * FROM Pracownicy;

--2.	Stw�rz procedur� kt�ra wypisze najwcze�niej zatrudnione osoby, w ka�dym departamencie. Identyfikator departamentu powinien by� przekazanym jako argument procedur. Natomiast data zatrudnienia przekazywana jest przez drugi argument, kt�ry jest zadeklarowany jako wyj�ciowy.
CREATE PROCEDURE WypiszNajwczesniejZatrudnione 
    @IdDepartamentu INT, 
    @DataZatrudnienia DATETIME OUTPUT
AS
BEGIN
    SELECT TOP 1 Imie, Nazwisko, data_zatrudnienia 
    FROM Pracownicy
    WHERE kierownik = @IdDepartamentu
    ORDER BY data_zatrudnienia ASC; -- Use the column name directly

    SET @DataZatrudnienia = (SELECT MIN(data_zatrudnienia) 
                             FROM Pracownicy 
                             WHERE kierownik = @IdDepartamentu);
END;

DECLARE @DataZatrudnienia2 DATETIME;
EXEC WypiszNajwczesniejZatrudnione @IdDepartamentu = 2, @DataZatrudnienia = @DataZatrudnienia2 OUTPUT;
PRINT @DataZatrudnienia2;

--3.	(Northwind) Utw�rz procedur� sk�adowan�, pokazuj�c� zam�wienia klient�w i sumaryczn� cen� produkt�w ka�dego zam�wienia.
--USE Northwind
CREATE PROCEDURE PokazZamowieniaKlientow
AS 
BEGIN
	SELECT 
		o.OrderID,
		c.ContactName,
		SUM(od.Quantity * od.UnitPrice) as total_price
	from ORDERS o
	JOIN [Order Details] od 
	ON o.OrderID = od.OrderID
	JOIN Products p 
	ON p.ProductID = od.ProductID
	JOIN Customers c
	ON c.CustomerID = o.CustomerID
	GROUP BY o.OrderID, c.ContactName, (od.Quantity * od.UnitPrice)
END;

EXEC PokazZamowieniaKlientow;

--4.	Zdefiniuj wyzwalacz, kt�ry zabroni zmniejszania pensji pracownikom
USE cwiczenia_lab_1
CREATE TRIGGER ZabronZmniejszeniaPensji on Pracownicy
AFTER UPDATE
as if update(pensja)
	BEGIN 
		declare @new money, @old money
		select @new = pensja from inserted
		select @old = pensja from deleted
		if @new<@old
				rollback
	END;

SELECT * FROM Pracownicy

UPDATE Pracownicy SET pensja = 1000 WHERE id = 1

--5.	Dla relacji Pracownicy stw�rz wyzwalacz, kt�ry w przypadku braku prowizji zamieni warto�� NULL na 10.
USE cwiczenia_lab_1
CREATE TRIGGER tt_prowizja ON pracownicy
AFTER INSERT
	AS
		BEGIN
			UPDATE pracownicy
			SET prowizja = 10
			FROM pracownicy
			INNER JOIN inserted ON pracownicy.id = inserted.id
			WHERE inserted.prowizja IS NULL;
		END;


--6.	Zapisz w tabeli LOG informacje o tym kto skasowa� kt�rego klienta.
USE Northwind;

CREATE TABLE LOG (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    KtoUsunal NVARCHAR(100),
    KtoryKlient INT,
    DataUsuniecia DATETIME
);

SELECT * FROM Customers;

CREATE TRIGGER LogUsunieciaKlienta
ON Customers
AFTER DELETE
AS
BEGIN
    INSERT INTO LOG (KtoUsunal, KtoryKlient, DataUsuniecia)
    SELECT USER_NAME(), deleted.CustomerID, GETDATE()
    FROM deleted;
END;

--Przyklad
--DELETE FROM Customers WHERE CustomerID = '1';

--7.	Korzystaj�c z tabeli produkty stw�rz transakcj�, kt�ra przeniesie wszystkie produkty z magazynu nr 1 do magazynu nr 2. Maksymalna pojemno�� magazynu nr 2 wynosi 500. Je�eli powy�sza operacja spowoduje przepe�nienie magazynu nale�y j� wycofa� i przenie�� produkty do magazynu nr 3.
create table produkty (
	id int identity primary key,
	nr_magazynu int,
	ilosc int
)

insert into produkty values (1, 200);
insert into produkty values (2, 200);
insert into produkty values (3, 300);

SELECT * FROM produkty;

begin transaction tran1
save transaction save1
update produkty set nr_magazynu = 2 where nr_magazynu = 1
if (select sum(ilosc) from produkty where nr_magazynu = 2) > 500
	begin
		rollback transaction save1
		update produkty set nr_magazynu = 3 where nr_magazynu = 1
	end
commit transaction

--8.	Korzystaj�c z tabeli pracownicy oraz dzia�y stw�rz transakcj�, kt�ra:
--�	umo�liwi zwi�kszenie zarobk�w w dziale HR o 10%
--�	dokona symulacji zwi�kszenia zarobk�w pozosta�ych pracownik�w, opr�cz prezesa, o 10% (wykorzystaj save point)
--�	wy�wietli informacj� o ile zwi�kszy�y si� miesi�czne wydatki na pensje (po podwy�ce w dziale sprzeda�y) i o ile zwi�kszy�yby si� gdyby podwy�ka dotyczy�a pozosta�ych pracownik�w, opr�cz prezesa (rezultat symulacji z punktu 2)
USE cwiczenia_lab_1

begin transaction t5
	declare @money1 money, @simulation money, @show_info money;
		
	SELECT @money1 = SUM(pensja) FROM pracownicy;
	UPDATE pracownicy SET pensja = pensja * 1.1 
	WHERE kod_dzialu = (SELECT kod_dzialu FROM departamenty WHERE nazwa LIKE 'sprzedaz');
	SELECT @simulation = SUM(pensja) FROM pracownicy;

	save transaction save1

	UPDATE pracownicy SET pensja = pensja * 1.1 
	WHERE kod_dzialu != (SELECT kod_dzialu FROM departamenty WHERE nazwa LIKE 'sprzedaz') AND stanowisko != 'prezes';

	SELECT @show_info = SUM(pensja) FROM pracownicy;

	SELECT @money1, (@simulation - @money1) as 'podwyzka w sprzedazy', (@show_info - @money1) as 'podwyzka wszyscy'

	rollback transaction save1;
commit transaction

SELECT SUM(pensja) FROM pracownicy;

SELECT * FROM Pracownicy

declare k1 CURSOR
for SELECT [Pracownicy.imie] from pracownicy
open k1
	declare @zmienna char(15), @i int = 1
	fetch next from k1 into @zmienna
	while @@FETCH_STATUS = 0
	begin
		print 'Pracownik nr ' + cast(@i as char(2)) + ' nazywa sie ' + @zmienna;
		set @i += 1
		fetch next from k1 into @zmienna
	end
close k1
deallocate k1

-- 5000, 5% kazdemu, start od najgorzej zarabiajacej
DECLARE k2 CURSOR FOR 
SELECT pensja FROM Pracownicy ORDER BY pensja ASC;

OPEN k2;

DECLARE @obecna_pensja INT, @kasa INT = 5000, @dodatek INT;

FETCH NEXT FROM k2 INTO @obecna_pensja;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @dodatek = @obecna_pensja * 0.05;

    IF @kasa >= @dodatek
		BEGIN
			UPDATE Pracownicy
			SET pensja = pensja + @dodatek
			WHERE CURRENT OF k2;

			SET @kasa = @kasa - @dodatek;
		END
    ELSE
    BEGIN
        UPDATE Pracownicy
        SET pensja = pensja + @kasa
        WHERE CURRENT OF k2;

        SET @kasa = 0;
    END

    FETCH NEXT FROM k2 INTO @obecna_pensja;
END

CLOSE k2;
DEALLOCATE k2;

SELECT * FROM pracownicy;