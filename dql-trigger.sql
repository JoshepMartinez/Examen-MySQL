1️⃣ ActualizarTotalVentasEmpleado

📌 Cuando se inserta una venta (Invoice), actualiza el total de ventas acumuladas del empleado asociado.
Primero, creamos la columna donde guardaremos el acumulado si no existe:
DELIMITER $$
CREATE TRIGGER ActualizarTotalVentasEmpleado
AFTER INSERT ON Invoice
FOR EACH ROW
BEGIN
    UPDATE Employee e
    JOIN Customer c ON c.SupportRepId = e.EmployeeId
    SET e.TotalVentas = e.TotalVentas + NEW.Total
    WHERE c.CustomerId = NEW.CustomerId;
END$$
DELIMITER ;