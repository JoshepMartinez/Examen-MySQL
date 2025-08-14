select i.InvoiceId, c.FirstName, i.InvoiceDate, COUNT(i.Total) as ventas
from Invoice i
join Customer c on i.InvoiceId = c.CustomerId
WHERE i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY i.InvoiceId
order by i.Total desc
limit 1;


-- Lista los cinco artistas con más canciones vendidas en el último año.
select a.name, t.Composer, SUM(t.Bytes) as vendidos
from Track t
join Artist a on t.TrackId = a.ArtistId
GROUP BY a.ArtistId
order by vendidos desc
limit 5;

-- Obtén el total de ventas y la cantidad de canciones vendidas por país.
select i.BillingCountry, SUM(t.Bytes) as total_ventas, COUNT(t.AlbumId) as canciones
from Invoice i
join Track t on t.TrackId = i.InvoiceId
join Album a on t.AlbumId = a.ArtistId
group by t.Name, i.BillingCountry
order by canciones desc;


-- Calcula el número total de clientes que realizaron compras por cada género en un mes específico.
select i.InvoiceDate, SUM(c.CustomerId) as total_clientes, g.Name 
from Customer c
join Genre g on c.CustomerId = g.GenreId
join Invoice i on i.InvoiceId = c.CustomerId
GROUP BY i.InvoiceDate, g.Name;



-- Encuentra a los clientes que han comprado todas las canciones de un mismo álbum.
select c.FirstName, a.Title, SUM(a.AlbumId)
from Customer c
join Album a on c.CustomerId = a.AlbumId
GROUP BY c.CustomerId
order by a.AlbumId desc


-- Lista los tres países con mayores ventas durante el último semestre.
SELECT i.BillingCountry, SUM(il.UnitPrice * il.Quantity) AS TotalVentas
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
WHERE i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY i.BillingCountry
ORDER BY TotalVentas DESC
LIMIT 3;

-- Muestra los cinco géneros menos vendidos en el último año.
SELECT g.Name AS Genero, COUNT(il.TrackId) AS CancionesVendidas
FROM Genre g
LEFT JOIN Track t ON t.GenreId = g.GenreId
LEFT JOIN InvoiceLine il ON il.TrackId = t.TrackId
LEFT JOIN Invoice i ON i.InvoiceId = il.InvoiceId
    AND i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY g.GenreId, g.Name
ORDER BY CancionesVendidas ASC
LIMIT 5;

-- Calcula el promedio de edad de los clientes al momento de su primera compra.
WITH primera_compra AS (
    SELECT 
        c.CustomerId,
        c.FirstName,
        MIN(i.InvoiceDate) AS fecha_primera_compra
    FROM Customer c
    JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, c.FirstName
)
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_primera_compra, CURDATE())), 2) AS antiguedad_promedio_en_anios
FROM primera_compra;


-- Genera un informe de los clientes con más compras recurrentes.
SELECT c.CustomerId, c.FirstName || ' ' || c.LastName AS cliente,
       COUNT(i.InvoiceId) AS num_facturas
FROM Customer c
JOIN Invoice  i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId, cliente
HAVING COUNT(i.InvoiceId) > 1
ORDER BY num_facturas DESC, cliente;


-- Precio promedio de venta por género
SELECT g.Name AS genero, ROUND(AVG(il.UnitPrice), 2) AS precio_promedio
FROM InvoiceLine il
JOIN Track t  ON t.TrackId  = il.TrackId
JOIN Genre g  ON g.GenreId  = t.GenreId
GROUP BY g.Name
ORDER BY genero;



-- Lista las cinco canciones más largas vendidas en el último año.//
SELECT t.TrackId, t.Name AS cancion,
       ROUND(t.Milliseconds / 1000 / 60, 2) AS minutos
FROM InvoiceLine il
JOIN Invoice i ON i.InvoiceId = il.InvoiceId
JOIN Track   t ON t.TrackId   = il.TrackId
WHERE i.InvoiceDate >= CURDATE() - INTERVAL 1 YEAR
ORDER BY t.Milliseconds DESC
LIMIT 5;

-- Clientes que compraron más canciones de Jazz
SELECT c.CustomerId, c.FirstName || ' ' || c.LastName AS cliente,
       SUM(il.Quantity) AS canciones_jazz
FROM Customer c
JOIN Invoice i   ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
JOIN Track t     ON t.TrackId = il.TrackId
JOIN Genre g     ON g.GenreId = t.GenreId
WHERE g.Name = 'Jazz'
GROUP BY c.CustomerId, cliente
ORDER BY canciones_jazz DESC, cliente;


-- Total de minutos comprados por cliente en el último mes //
SELECT c.CustomerId, CONCAT(c.FirstName, ' ', c.LastName) AS cliente,
       ROUND(SUM((t.Milliseconds / 1000 / 60) * il.Quantity), 2) AS minutos_total
FROM Customer c
JOIN Invoice i     ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
JOIN Track t       ON t.TrackId = il.TrackId
WHERE i.InvoiceDate >= CURDATE() - INTERVAL 1 MONTH
GROUP BY c.CustomerId, cliente
ORDER BY minutos_total DESC;

-- Número de ventas diarias de canciones en cada mes del último trimestre (3 meses) //
SELECT 
    DATE(i.InvoiceDate) AS dia,
    DATE_FORMAT(i.InvoiceDate, '%Y-%m') AS mes,
    SUM(il.Quantity) AS canciones_vendidas
FROM Invoice i
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
WHERE i.InvoiceDate >= CURDATE() - INTERVAL 3 MONTH
GROUP BY dia, mes
ORDER BY dia;

-- Calcula el total de ventas por cada vendedor en el último semestre.
SELECT 
    e.EmployeeId,
    CONCAT(e.FirstName, ' ', e.LastName) AS vendedor,
    ROUND(SUM(i.Total), 2) AS total_ventas
FROM Employee e
JOIN Customer c 
    ON c.SupportRepId = e.EmployeeId
JOIN Invoice i 
    ON i.CustomerId = c.CustomerId
WHERE i.InvoiceDate >= CURDATE() - INTERVAL 6 MONTH
GROUP BY e.EmployeeId, vendedor
ORDER BY total_ventas DESC;

-- Encuentra el cliente que ha realizado la compra más cara en el último año.
SELECT 
    i.InvoiceId, 
    CONCAT(c.FirstName, ' ', c.LastName) AS cliente,
    i.Total AS total_factura,
    i.InvoiceDate
FROM Invoice i
JOIN Customer c 
    ON c.CustomerId = i.CustomerId
WHERE i.InvoiceDate >= CURDATE() - INTERVAL 1 YEAR
ORDER BY i.Total DESC
LIMIT 1;

-- Lista los cinco álbumes con más canciones vendidas durante los últimos tres meses.
SELECT 
    a.AlbumId,
    a.Title AS album,
    ar.Name AS artista,
    SUM(il.Quantity) AS canciones_vendidas
FROM InvoiceLine il
JOIN Invoice i 
    ON i.InvoiceId = il.InvoiceId
JOIN Track t 
    ON t.TrackId = il.TrackId
JOIN Album a 
    ON a.AlbumId = t.AlbumId
JOIN Artist ar 
    ON ar.ArtistId = a.ArtistId
WHERE i.InvoiceDate >= CURDATE() - INTERVAL 3 MONTH
GROUP BY a.AlbumId, album, artista
ORDER BY canciones_vendidas DESC
LIMIT 5;

-- Obtén la cantidad de canciones vendidas por cada género en el último mes.
SELECT 
    g.GenreId,
    g.Name AS genero,
    SUM(il.Quantity) AS canciones_vendidas
FROM InvoiceLine il
JOIN Invoice i 
    ON i.InvoiceId = il.InvoiceId
JOIN Track t 
    ON t.TrackId = il.TrackId
JOIN Genre g 
    ON g.GenreId = t.GenreId
WHERE i.InvoiceDate >= CURDATE() - INTERVAL 1 MONTH
GROUP BY g.GenreId, genero
ORDER BY canciones_vendidas DESC;

-- Lista los clientes que no han comprado nada en el último año.
SELECT 
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS cliente,
    c.Email
FROM Customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM Invoice i
    WHERE i.CustomerId = c.CustomerId
      AND i.InvoiceDate >= CURDATE() - INTERVAL 1 YEAR
)
ORDER BY cliente;