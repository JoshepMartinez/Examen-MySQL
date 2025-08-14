select i.InvoiceId, c.FirstName, i.InvoiceDate, COUNT(i.Total) as ventas
from Invoice i
join Customer c on i.InvoiceId = c.CustomerId
WHERE i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY i.InvoiceId, c.FirstName
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