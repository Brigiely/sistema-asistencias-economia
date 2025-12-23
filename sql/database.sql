-- Crear base de datos
CREATE DATABASE IF NOT EXISTS asistencias_profesores;
USE asistencias_profesores;

-- =========================
-- TABLAS
-- =========================

CREATE TABLE carreras (
  id_carrera INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE profesores (
  id_profesor INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(80) NOT NULL,
  apellidos VARCHAR(120) NOT NULL,
  dni CHAR(8) NOT NULL UNIQUE,
  email VARCHAR(120) NOT NULL UNIQUE,
  id_carrera INT NOT NULL,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera)
) ENGINE=InnoDB;

CREATE TABLE cursos (
  id_curso INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  id_carrera INT NOT NULL,
  FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera)
) ENGINE=InnoDB;

CREATE TABLE profesor_curso (
  id_profesor INT NOT NULL,
  id_curso INT NOT NULL,
  PRIMARY KEY (id_profesor, id_curso),
  FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor),
  FOREIGN KEY (id_curso) REFERENCES cursos(id_curso)
) ENGINE=InnoDB;

-- =========================
-- CARRERAS
-- =========================

INSERT INTO carreras (nombre) VALUES
('Gestión Empresarial'),
('Economía'),
('Estadística e Informática');

-- =========================
-- CURSOS
-- =========================

-- Estadística e Informática
INSERT INTO cursos (nombre, id_carrera) VALUES
('Introducción a la Ciencia de Datos', 3),
('Análisis Estadístico', 3),
('Álgebra Matricial', 3),
('Estadística General', 3),
('Computacional', 3),
('Machine Learning', 3),
('Ciencia de Datos', 3),
('Estudio de Mercados', 3),
('Estadística Bayesiana', 3),
('Métodos No Paramétricos', 3),
('Regresión', 3),
('Técnicas Multivariadas', 3);

-- Economía
INSERT INTO cursos (nombre, id_carrera) VALUES
('Microeconomía I', 2),
('Macroeconomía I', 2),
('Econometría I', 2),
('Economía Pública', 2),
('Política Económica', 2),
('Economía Internacional', 2);

-- Gestión Empresarial
INSERT INTO cursos (nombre, id_carrera) VALUES
('Contabilidad Financiera', 1),
('Finanzas Corporativas', 1),
('Marketing Estratégico', 1),
('Gestión de Operaciones', 1),
('Planeamiento Estratégico', 1),
('Gestión de Proyectos', 1);

-- =========================
-- PROFESORES
-- =========================

INSERT INTO profesores (nombres, apellidos, dni, email, id_carrera) VALUES
('Juan', 'Pérez García', '12345678', 'juan.perez@lamolina.edu.pe', 1),
('María', 'González López', '87654321', 'maria.gonzalez@lamolina.edu.pe', 3),
('Carlos', 'Rodríguez Soto', '11223344', 'carlos.rodriguez@lamolina.edu.pe', 2),
('Ana', 'Vargas Medina', '22334455', 'ana.vargas@lamolina.edu.pe', 3),
('Luis', 'Salazar Núñez', '33445566', 'luis.salazar@lamolina.edu.pe', 1),
('Rosa', 'Quispe Huamán', '44556677', 'rosa.quispe@lamolina.edu.pe', 2),
('Diego', 'Campos Rivas', '55667788', 'diego.campos@lamolina.edu.pe', 3),
('Patricia', 'Torres Cárdenas', '66778899', 'patricia.torres@lamolina.edu.pe', 1);

-- =========================
-- ASIGNACIÓN PROFESOR - CURSO
-- =========================

INSERT INTO profesor_curso VALUES
(2, 1),
(2, 2),
(2, 6),
(4, 3),
(4, 12),
(7, 6),
(7, 7),
(1, 19),
(1, 20),
(5, 22),
(8, 21),
(3, 13),
(3, 15),
(6, 14),
(6, 16);
