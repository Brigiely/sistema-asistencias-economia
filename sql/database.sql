-- Crear base de datos
CREATE DATABASE IF NOT EXISTS asistencias_profesores;
USE asistencias_profesores;

-- Tabla de carreras
CREATE TABLE carreras (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) NOT NULL
);

-- Tabla de profesores
CREATE TABLE profesores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_completo VARCHAR(150) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    carrera_id INT NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carrera_id) REFERENCES carreras(id)
);

-- Tabla de asistencias
CREATE TABLE asistencias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    profesor_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora_entrada TIME,
    hora_salida TIME,
    estado ENUM('presente', 'ausente', 'tardanza', 'justificado') NOT NULL,
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (profesor_id) REFERENCES profesores(id)
);

-- Insertar las 3 carreras de Economía
INSERT INTO carreras (nombre, codigo) VALUES 
('Gestión Empresarial', 'GE'),
('Estadística e Informática', 'EI'),
('Economía', 'ECO');

-- Insertar profesores de ejemplo
INSERT INTO profesores (nombre_completo, dni, carrera_id, email) VALUES
('Juan Pérez García', '12345678', 1, 'jperez@economia.edu.pe'),
('María González López', '87654321', 2, 'mgonzalez@economia.edu.pe'),
('Carlos Rodríguez Soto', '11223344', 3, 'crodriguez@economia.edu.pe'),
('Ana Martínez Cruz', '44332211', 1, 'amartinez@economia.edu.pe'),
('Luis Fernández Ramos', '55667788', 2, 'lfernandez@economia.edu.pe');