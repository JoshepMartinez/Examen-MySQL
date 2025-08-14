1️⃣ TotalGastoCliente(ClienteID, Anio)

Calcula el gasto total de un cliente en un año específico.
DELIMITER $$
CREATE FUNCTION TotalGastoCliente(pClienteID INT, pAnio INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT IFNULL(SUM(Total), 0)
    INTO total
    FROM Invoice
    WHERE CustomerId = pClienteID
      AND YEAR(InvoiceDate) = pAnio;
    RETURN total;
END$$
DELIMITER ;

2️⃣ PromedioPrecioPorAlbum(AlbumID)

Retorna el precio promedio de las canciones de un álbum.
DELIMITER $$
CREATE FUNCTION PromedioPrecioPorAlbum(pAlbumID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);
    SELECT IFNULL(AVG(UnitPrice), 0)
    INTO promedio
    FROM Track t
    JOIN InvoiceLine il ON il.TrackId = t.TrackId
    WHERE t.AlbumId = pAlbumID;
    RETURN promedio;
END$$
DELIMITER ;


3️⃣ DuracionTotalPorGenero(GeneroID)

Calcula la duración total de todas las canciones vendidas de un género específico.
DELIMITER $$
CREATE FUNCTION DuracionTotalPorGenero(pGeneroID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE duracion_total DECIMAL(10,2);
    SELECT IFNULL(SUM((t.Milliseconds / 1000.0 / 60.0) * il.Quantity), 0)
    INTO duracion_total
    FROM Track t
    JOIN InvoiceLine il ON il.TrackId = t.TrackId
    WHERE t.GenreId = pGeneroID;
    RETURN duracion_total;
END$$
DELIMITER ;

4️⃣ DescuentoPorFrecuencia(ClienteID)

Calcula el descuento según la frecuencia de compra:
DELIMITER $$
CREATE FUNCTION DescuentoPorFrecuencia(pClienteID INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE compras INT;
    DECLARE descuento DECIMAL(5,2);

    SELECT COUNT(*) 
    INTO compras
    FROM Invoice
    WHERE CustomerId = pClienteID;

    IF compras > 20 THEN
        SET descuento = 0.20;
    ELSEIF compras >= 10 THEN
        SET descuento = 0.10;
    ELSE
        SET descuento = 0.00;
    END IF;

    RETURN descuento;
END$$
DELIMITER ;

5️⃣ VerificarClienteVIP(ClienteID)

Considera "VIP" si el cliente gasta más de $1000 USD en un año.
DELIMITER $$
CREATE FUNCTION VerificarClienteVIP(pClienteID INT)
RETURNS VARCHAR(3)
DETERMINISTIC
BEGIN
    DECLARE gasto_anual DECIMAL(10,2);

    SELECT SUM(Total)
    INTO gasto_anual
    FROM Invoice
    WHERE CustomerId = pClienteID
      AND YEAR(InvoiceDate) = YEAR(CURDATE());

    IF gasto_anual > 1000 THEN
        RETURN 'YES';
    ELSE
        RETURN 'NO';
    END IF;
END$$
DELIMITER ;