USE BIBLIOTEKA

--Podaj identyfikator i nazwisko czytelnika, który wypo¿yczy³ najwiêksz¹ liczbê egzemplarzy ksi¹¿ek.
SELECT top 1
	c.id_czytelnik,
	c.nazwisko
FROM czytelnik c
JOIN wypozyczenie w 
	ON w.id_czytelnik = c.id_czytelnik
GROUP BY  
	c.id_czytelnik, 
	c.nazwisko
ORDER BY COUNT(*) DESC

--Wska¿ pracownika, który obs³u¿y³ najwiêksz¹ liczbê wypo¿yczeñ (zarówno wypo¿yczenia, jak i zwroty).
SELECT 
	p.id_pracownik, 
	p.nazwisko, 
	COUNT(w1.id_wypozyczenie) + COUNT(w2.id_wypozyczenie) AS liczba_obslug
FROM pracownik p
LEFT JOIN wypozyczenie w1 ON p.id_pracownik = w1.id_pracownik_wyp
LEFT JOIN wypozyczenie w2 ON p.id_pracownik = w2.id_pracownik_zwr
GROUP BY p.id_pracownik, p.nazwisko
ORDER BY liczba_obslug

--ZnajdŸ tytu³y ksi¹¿ek, które maj¹ najwiêcej wydañ (ró¿ne rok_wydania w tabeli egzemplarz).
SELECT DISTINCT 
	k.tytul,
	e.rok_wydania,
	COUNT(k.tytul) AS ilosc_wydan
FROM ksiazka k
JOIN egzemplarz e 
ON e.id_ksiazka = k.id_ksiazka
GROUP BY k.tytul, k.id_ksiazka, e.rok_wydania
HAVING COUNT(k.tytul) > 1

--Wyœwietl nazwy wydawnictw, które nie dostarczy³y ¿adnych egzemplarzy ksi¹¿ek w bazie.
SELECT 
	e.id_wydawnictwo, 
	w.id_wydawnictwo 
FROM egzemplarz e
right JOIN wydawnictwo w ON w.id_wydawnictwo = e.id_wydawnictwo
WHERE e.id_wydawnictwo is null

--Przygotuj raport z tytu³ami ksi¹¿ek oraz ca³kowit¹ liczb¹ zakupionych egzemplarzy na podstawie tabeli pozycja_faktury. Posortuj wyniki malej¹co po liczbie egzemplarzy.
SELECT 
	k.tytul,
	count(k.tytul) AS ilosc_zakupionych_ksiazek
FROM pozycja_faktury pf
JOIN ksiazka k ON pf.id_ksiazka = k.id_ksiazka
GROUP BY k.tytul
ORDER BY count(k.tytul) DESC

--Wyœwietl listê wypo¿yczeñ, które nie zosta³y jeszcze zwrócone (data_zwrotu jest NULL), wraz z imieniem i nazwiskiem czytelnika, tytu³em ksi¹¿ki i rokiem wydania egzemplarza.
SELECT 
	c.imie,
	c.nazwisko,
	k.tytul
FROM wypozyczenie w
JOIN czytelnik c 
ON c.id_czytelnik = w.id_czytelnik
JOIN egzemplarz e ON
e.id_egzemplarz = w.id_egzemplarz
JOIN ksiazka k ON
k.id_ksiazka = e.id_ksiazka
WHERE w.data_zwrotu IS null

--Wyœwietl nazwy wydawnictw oraz ca³kowity koszt zakupionych ksi¹¿ek od ka¿dego z nich (suma ilosc * cena z tabeli pozycja_faktury).
SELECT 
	w.nazwa,
	SUM(pf.ilosc * pf.cena) AS laczna_cena
FROM pozycja_faktury pf
JOIN ksiazka k ON 
pf.id_ksiazka = k.id_ksiazka
JOIN faktura f ON
f.id_faktura = pf.id_faktura
JOIN wydawnictwo w ON
f.id_wydawnictwo = w.id_wydawnictwo
GROUP BY w.nazwa

--ZnajdŸ tytu³y ksi¹¿ek, które by³y wypo¿yczane najczêœciej. Posortuj wyniki malej¹co po liczbie wypo¿yczeñ.
SELECT 
	k.id_ksiazka,
	k.tytul,
	COUNT(*) AS liczba_wypozyczen
FROM wypozyczenie w
JOIN egzemplarz e 
ON e.id_egzemplarz = w.id_egzemplarz
JOIN ksiazka k 
ON k.id_ksiazka = e.id_ksiazka
GROUP BY k.id_ksiazka, k.tytul
order by liczba_wypozyczen desc

--ZnajdŸ czytelników, którzy mieli przerwê miêdzy wypo¿yczeniami d³u¿sz¹ ni¿ 6 miesiêcy.
WITH wypozyczenia_cte AS (
    SELECT id_czytelnik, data_wypozyczenia,
           LAG(data_wypozyczenia) OVER (PARTITION BY id_czytelnik ORDER BY data_wypozyczenia) AS poprzednia_data
    FROM wypozyczenie
)
SELECT DISTINCT c.id_czytelnik, c.nazwisko
FROM wypozyczenia_cte w
JOIN czytelnik c ON w.id_czytelnik = c.id_czytelnik
WHERE DATEDIFF(MONTH, w.poprzednia_data, w.data_wypozyczenia) > 6;

--ZnajdŸ tytu³y ksi¹¿ek, które nie zosta³y wypo¿yczone ani razu.
SELECT DISTINCT k.tytul
FROM ksiazka k
LEFT JOIN egzemplarz e ON k.id_ksiazka = e.id_ksiazka
LEFT JOIN wypozyczenie w ON e.id_egzemplarz = w.id_egzemplarz
WHERE w.id_wypozyczenie IS NULL;
