--1.	Stw�rz baz� danych oznaczon� numerem albumu, w bazie zaprojektuj nast�puj�ce tabele wed�ug poni�szych instrukcji:
CREATE DATABASE cwiczenia_lab_1
use cwiczenia_lab_1

CREATE TABLE Dzialy (
	kod_dzialu INT IDENTITY(1,1) PRIMARY KEY,
	nazwa varchar(50),
	lokalizacja varchar(100)
)

CREATE TABLE Pracownicy (
	id INT IDENTITY(1,1) PRIMARY KEY,
	imie varchar(15),
	nazwisko varchar(35),
	stanowisko varchar(25),
	kierownik int,
	data_zatrudnienia DATETIME,
	pensja float,
	prowizja float
)

--2.	Wprowad� dane do bazy (skorzystaj z kodu zamieszczonego na BB)

INSERT INTO Pracownicy VALUES ('Kowalski','Jan','Prezes',NULL,'2002-01-01',7000.20,NULL);
INSERT INTO Pracownicy VALUES ('G�owacki','Mateusz','Kierownik',1,'2002-05-01',3210,150);
INSERT INTO Pracownicy VALUES ('Sikorski','Adam','Kierownik',1,'2002-05-01',3210,250);
INSERT INTO Pracownicy VALUES ('Nowak','Stanislaw','Kierownik',1,'2002-05-01',3210,350);
INSERT INTO Pracownicy VALUES ('Wisniewski','Marcin','Sprzedawca',4,'2007-06-27',1210,250);
INSERT INTO Pracownicy VALUES ('Kochanowski','Juliusz','Sprzedawca',4,'2005-11-22',1210,260);
INSERT INTO Pracownicy VALUES ('Charysz','Szczepan','Sprzedawca',4,'2006-12-01',1210,200);
INSERT INTO Pracownicy VALUES ('Kordecki','Adam','Laborant',3,'2002-12-11',2210,150);
INSERT INTO Pracownicy VALUES ('Kopacz','Ewa','Laborant',3,'2003-04-21',2110,150);
INSERT INTO Pracownicy VALUES ('Ziolkowska','Krystyna','Laborant',3,'2002-07-10',2510,100);
INSERT INTO Pracownicy VALUES ('Szela','Katarzyna','Konsultant',2,'2002-05-10',2810,100);
INSERT INTO Pracownicy VALUES ('K�dzior','Jakub','Analityk',2,'2002-05-10',2710,120);
INSERT INTO Pracownicy VALUES ('Ziobro','Marlena','Konsultant',2,'2003-02-13',2610,200);
INSERT INTO Pracownicy VALUES ('Pigwa','Genowefa','Ksiegowa',1,'2002-01-02',2000,NULL);

INSERT INTO Dzialy (nazwa, lokalizacja)
VALUES 
    ('Dzia� HR', 'Warszawa'),
    ('Dzia� IT', 'Krak�w'),
    ('Dzia� Marketingu', 'Wroc�aw'),
    ('Dzia� Sprzeda�y', 'Gda�sk')

--3.	Dodaj nowy rekord wprowadzaj�c swoje dane
INSERT INTO Pracownicy VALUES ('Ostrowski','Piotr','Programista',2,'2003-01-01',15000,1000);
SELECT * FROM Pracownicy

--4.	Do tabeli Pracownicy dodaj atrybut Adres
Alter TABLE Pracownicy 
ADD Adres VARCHAR(100) DEFAULT NULL;
SELECT * FROM Pracownicy

--5.	Usu� z tabeli Pracownicy atrybut Adres
Alter TABLE Pracownicy 
DROP COLUMN Adres;
SELECT * FROM Pracownicy

--6.	Wszystkim pracownikom z dzia�u 10 powi�ksz zarobki o 100 z�
SELECT * FROM Pracownicy;

UPDATE Pracownicy
SET pensja = pensja + 100;

--7.	Zmie� nazw� kolumny Id_depart w tabeli Departament na kod_dzia�u
SELECT * FROM Dzialy;
EXEC sp_rename 'Dzialy.kod_dzialu', 'id_dzialu', 'COLUMN';

--8.	Zmie� nazw� tabeli Departament na Dzia� 

--9.	Usu� z tabeli Pracownicy pracownika o identyfikatorze 14
SELECT * FROM Pracownicy;
DELETE FROM Pracownicy WHERE id = 14;

--10.	Zmodyfikuj tabele Pracownicy w taki spos�b by nie mo�liwe by�o wprowadzanie zarobk�w poni�ej p�acy minimalnej
--11.	Zweryfikuj dzia�anie na�o�onego ograniczenia

--Zapytania testowe

--1.	Dla ka�dego pracownika podaj na jakim stanowisku pracuje
SELECT imie, nazwisko, stanowisko FROM Pracownicy;

--2.	Znajd� r�nice mi�dzy najwy�szymi a najni�szymi zarobkami, nazwij kolumn� wy�wietlaj�ca wynik r�nica
SELECT (MAX(pensja) - MIN(pensja)) as roznica  FROM Pracownicy;

--3.	Ilu jest pracownik�w 
SELECT COUNT(*) FROM Pracownicy

--4.	Kto zarabia powy�ej 3 tys?
SELECT * FROM Pracownicy WHERE pensja > 3000

--5.	Kiedy zatrudniono pierwszego pracownika
SELECT MIN(data_zatrudnienia) FROM Pracownicy 

--6.	Wypisz nazwiska pracownik�w zatrudnionych w maju
SELECT * FROM Pracownicy WHERE MONTH(data_zatrudnienia) = 5

--7.	Wypisz nazwiska pracownik�w z dzia�u Sprzeda�y
SELECT * FROM Pracownicy WHERE kierownik IN (SELECT id_dzialu FROM Dzialy WHERE nazwa = 'Dzia� Sprzeda�y')

--8.	Podaj nazw� dzia�u z Krakowa
SELECT nazwa FROM Dzialy WHERE lokalizacja = 'Krak�w'

--9.	Ile os�b pracuje na stanowisku Sprzedawca
SELECT COUNT(*) FROM Pracownicy WHERE stanowisko = 'Sprzedawca'