CREATE DATABASE IF NOT EXISTS Si_Si_Awha;
USE Si_Si_Awha;

-- Tabla de Proveedores
CREATE TABLE Proveedores (
    ProveedorID INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    RazonSocial VARCHAR(100) NOT NULL,
    Direccion VARCHAR(255),
    Telefono VARCHAR(20),
    Email VARCHAR(100),
    Contacto VARCHAR(100)
);

-- Tabla de Productos
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY AUTO_INCREMENT,
    Codigo VARCHAR(10) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    Precio DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL
);

-- Tabla para el encabezado del albarán
CREATE TABLE AlbaranCompraEncabezado (
    AlbaranCompraID INT PRIMARY KEY AUTO_INCREMENT,
    Fecha DATE NOT NULL,
    ProveedorID INT NOT NULL,
    Total DECIMAL(10, 2) NOT NULL,
    Estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    Observaciones VARCHAR(255),
    FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID)
);

-- Tabla para los detalles del albarán
CREATE TABLE AlbaranCompraDetalle (
    DetalleID INT PRIMARY KEY AUTO_INCREMENT,
    AlbaranCompraID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioCompra DECIMAL(10, 2) NOT NULL,
    Subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (Cantidad * PrecioCompra) STORED,
    FOREIGN KEY (AlbaranCompraID) REFERENCES AlbaranCompraEncabezado(AlbaranCompraID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- Índices para albaranes
CREATE INDEX IX_AlbaranCompraEncabezado_Fecha ON AlbaranCompraEncabezado (Fecha);
CREATE INDEX IX_AlbaranCompraDetalle_ProductoID ON AlbaranCompraDetalle (ProductoID);

-- Trigger para actualizar el total
DELIMITER //
CREATE TRIGGER trg_ActualizarTotalAlbaranCompra
AFTER INSERT ON AlbaranCompraDetalle
FOR EACH ROW
BEGIN
    UPDATE AlbaranCompraEncabezado
    SET Total = (
        SELECT SUM(Cantidad * PrecioCompra)
        FROM AlbaranCompraDetalle
        WHERE AlbaranCompraID = NEW.AlbaranCompraID
    )
    WHERE AlbaranCompraID = NEW.AlbaranCompraID;
END//
DELIMITER ;

-- Almacenes
CREATE TABLE Almacenes (
    AlmacenID INT PRIMARY KEY AUTO_INCREMENT,
    Codigo VARCHAR(10) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(255)
);

-- Estanterías
CREATE TABLE Estanterias (
    EstanteriaID INT PRIMARY KEY AUTO_INCREMENT,
    Codigo VARCHAR(10) NOT NULL,
    AlmacenID INT NOT NULL,
    Descripcion VARCHAR(100),
    FOREIGN KEY (AlmacenID) REFERENCES Almacenes(AlmacenID)
);

-- Ubicaciones
CREATE TABLE Ubicaciones (
    UbicacionID INT PRIMARY KEY AUTO_INCREMENT,
    Codigo VARCHAR(10) NOT NULL,
    EstanteriaID INT NOT NULL,
    Nivel INT NOT NULL,
    Tramo INT NOT NULL,
    FOREIGN KEY (EstanteriaID) REFERENCES Estanterias(EstanteriaID)
);

-- Inventario
CREATE TABLE Inventario (
    InventarioID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT NOT NULL,
    UbicacionID INT NOT NULL,
    Cantidad INT NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
    FOREIGN KEY (UbicacionID) REFERENCES Ubicaciones(UbicacionID)
);

-- Trabajadores
CREATE TABLE Trabajadores (
    TrabajadorID INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Cargo VARCHAR(50)
);

-- Tipos de Bot
CREATE TABLE TiposBot (
    TipoBotID INT PRIMARY KEY AUTO_INCREMENT,
    Descripcion VARCHAR(100) NOT NULL
);

-- Bots
CREATE TABLE Bots (
    BotID INT PRIMARY KEY AUTO_INCREMENT,
    CodigoBot VARCHAR(50) NOT NULL,
    Serial VARCHAR(100) NOT NULL,
    TipoBotID INT NOT NULL,
    FOREIGN KEY (TipoBotID) REFERENCES TiposBot(TipoBotID)
);

-- Tipos de Movimiento
CREATE TABLE TiposMovimiento (
    TipoMovimientoID INT PRIMARY KEY AUTO_INCREMENT,
    Descripcion VARCHAR(100) NOT NULL
);

-- Movimientos de Almacén
CREATE TABLE MovimientosAlmacen (
    MovimientoID INT PRIMARY KEY AUTO_INCREMENT,
    Fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ProductoID INT NOT NULL,
    TipoMovimientoID INT NOT NULL,
    UbicacionOrigenID INT NULL,
    UbicacionDestinoID INT NULL,
    Cantidad INT NOT NULL,
    TrabajadorID INT NULL,
    BotID INT NULL,
    Observaciones VARCHAR(255),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
    FOREIGN KEY (TipoMovimientoID) REFERENCES TiposMovimiento(TipoMovimientoID),
    FOREIGN KEY (UbicacionOrigenID) REFERENCES Ubicaciones(UbicacionID),
    FOREIGN KEY (UbicacionDestinoID) REFERENCES Ubicaciones(UbicacionID),
    FOREIGN KEY (TrabajadorID) REFERENCES Trabajadores(TrabajadorID),
    FOREIGN KEY (BotID) REFERENCES Bots(BotID)
);

-- Índice para movimientos
CREATE INDEX IX_MovimientosAlmacen_Fecha ON MovimientosAlmacen(Fecha);