-- Crea la base de datos
IF NOT EXISTS (SELECT NAME FROM sys.databases WHERE name = 'IncidentDB')
BEGIN
    CREATE DATABASE IncidentDB;
END
GO

USE IncidentDB;
GO

-- Tabla: Incidents
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Incidents' AND xtype='U')
BEGIN
    CREATE TABLE Incidents(
        Id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),   
        Title NVARCHAR(100) NOT NULL,
        Description NVArchar(MAX) NULL,
        Severity NVARCHAR(20) NOT NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'OPEN',
        ServiceId NVARCHAR(50) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

        CONSTRAINT PK_Incidents PRIMARY KEY (Id),
        CONSTRAINT CK_Incidents_Severity CHECK (Severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
        CONSTRAINT CK_Incidents_Status CHECK (Status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'))
    );
END
GO

-- Indice orientado al endpoint del listado
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Incidents_Status_Severity_CreatedAt' AND object_id = OBJECT_ID('Incidents'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Incidents_Status_Severity_CreatedAt
    ON Incidents (Status, Severity, CreatedAt DESC)
    INCLUDE (Title, Description, ServiceId, UpdatedAt);
END

-- Seeds
IF NOT EXISTS (SELECT TOP 1 1 FROM Incidents)
BEGIN
    INSERT INTO Incidents (Id, Title, Description, Severity, Status, ServiceId, CreatedAt, UpdatedAt)
    VALUES
    (
        'A1B2C3D4-E5F6-7890-ABCD-EF1234567890',
        'Pago falla al confirmar',
        'Error 500 intermitente al procesar pagos con tarjeta de crédito.',
        'HIGH', 'OPEN', 'payments-api',
        '2026-03-01T08:30:00', '2026-03-01T08:30:00'
    ),
    (
        'B2C3D4E5-F6A7-8901-BCDE-F12345678901',
        'Timeout en consulta de saldo',
        'El endpoint /balance responde con timeout después de 30 segundos.',
        'CRITICAL', 'IN_PROGRESS', 'accounts-api',
        '2026-03-02T14:15:00', '2026-03-03T09:00:00'
    ),
    (
        'C3D4E5F6-A7B8-9012-CDEF-123456789012',
        'Notificaciones duplicadas',
        'Los usuarios reciben emails duplicados al cambiar estado de pedido.',
        'MEDIUM', 'RESOLVED', 'notifications-api',
        '2026-03-03T10:00:00', '2026-03-05T16:45:00'
    ),
    (
        'D4E5F6A7-B8C9-0123-DEF0-234567890123',
        'Login lento en horas pico',
        'El servicio de autenticación tarda más de 5s entre 9-11 AM.',
        'HIGH', 'OPEN', 'auth-api',
        '2026-03-04T11:20:00', '2026-03-04T11:20:00'
    ),
    (
        'E5F6A7B8-C9D0-1234-EF01-345678901234',
        'Error en reporte mensual',
        'El reporte de ventas mensual no incluye transacciones del último día.',
        'LOW', 'CLOSED', 'reports-api',
        '2026-02-28T09:00:00', '2026-03-06T12:00:00'
    );
END
GO