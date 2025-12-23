-- Crear base de datos

CREATE DATABASE IF NOT EXISTS asistencias_profesores;
USE asistencias_profesores;

-- =========================
-- TABLAS MAESTRAS
-- =========================

CREATE TABLE IF NOT EXISTS carreras (
  carrera_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  facultad VARCHAR(120) NOT NULL DEFAULT 'Facultad de Economía'
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS profesores (
  profesor_id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(12) NOT NULL UNIQUE,
  nombres VARCHAR(80) NOT NULL,
  apellidos VARCHAR(80) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  carrera_id INT NOT NULL,
  estado ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prof_carrera
    FOREIGN KEY (carrera_id) REFERENCES carreras(carrera_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_email_lamolina
    CHECK (email LIKE '%@lamolina.edu.pe')
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cursos (
  curso_id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(12) NOT NULL UNIQUE,
  nombre VARCHAR(120) NOT NULL,
  carrera_id INT NOT NULL,
  nivel ENUM('BASICO','INTERMEDIO','AVANZADO') NOT NULL DEFAULT 'INTERMEDIO',
  creditos TINYINT NOT NULL DEFAULT 3,
  CONSTRAINT fk_curso_carrera
    FOREIGN KEY (carrera_id) REFERENCES carreras(carrera_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS profesor_curso (
  profesor_id INT NOT NULL,
  curso_id INT NOT NULL,
  anio SMALLINT NOT NULL,
  ciclo ENUM('I','II') NOT NULL,
  PRIMARY KEY (profesor_id, curso_id, anio, ciclo),
  CONSTRAINT fk_pc_prof
    FOREIGN KEY (profesor_id) REFERENCES profesores(profesor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pc_curso
    FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================
-- ASISTENCIA (ENTRADA / SALIDA)
-- =========================
CREATE TABLE IF NOT EXISTS asistencia (
  asistencia_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  profesor_id INT NOT NULL,
  fecha DATE NOT NULL,
  entrada DATETIME NOT NULL,
  salida DATETIME NULL,
  sede VARCHAR(60) NOT NULL DEFAULT 'Campus La Molina',
  punto_control VARCHAR(60) NOT NULL DEFAULT 'Facultad de Economía',
  metodo ENUM('QR','BIOMETRIA','TARJETA','MANUAL') NOT NULL DEFAULT 'QR',
  observacion VARCHAR(255) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_asist_prof
    FOREIGN KEY (profesor_id) REFERENCES profesores(profesor_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_salida_mayor
    CHECK (salida IS NULL OR salida > entrada),
  UNIQUE KEY uk_prof_fecha_entrada (profesor_id, entrada)
) ENGINE=InnoDB;

-- =========================
-- DATA SIMULADA
-- =========================

INSERT INTO carreras (nombre, facultad) VALUES
('Gestión Empresarial', 'Facultad de Economía'),
('Economía', 'Facultad de Economía'),
('Estadística e Informática', 'Facultad de Economía')
ON DUPLICATE KEY UPDATE facultad=VALUES(facultad);

-- Profesores (12: 4 por carrera)
INSERT INTO profesores (codigo, nombres, apellidos, email, carrera_id, estado) VALUES
('PGE001','Andrea','Salazar Rivas','andrea.salazar@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'ACTIVO'),
('PGE002','Luis','Vargas Pineda','luis.vargas@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'ACTIVO'),
('PGE003','Mariana','Céspedes León','mariana.cespedes@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'ACTIVO'),
('PGE004','Jorge','Mendoza Alarcón','jorge.mendoza@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'ACTIVO'),

('PEC001','Valeria','Huamán Soto','valeria.huaman@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'ACTIVO'),
('PEC002','Diego','Ramos Gutiérrez','diego.ramos@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'ACTIVO'),
('PEC003','Carmen','Luján Palacios','carmen.lujan@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'ACTIVO'),
('PEC004','Renzo','Quispe Carrillo','renzo.quispe@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'ACTIVO'),

('PEI001','Sofía','Torres Medina','sofia.torres@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'ACTIVO'),
('PEI002','Ricardo','Paredes Núñez','ricardo.paredes@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'ACTIVO'),
('PEI003','Paola','Gálvez Cárdenas','paola.galvez@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'ACTIVO'),
('PEI004','Héctor','Rojas Valdivia','hector.rojas@lamolina.edu.pe',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'ACTIVO')
ON DUPLICATE KEY UPDATE
  nombres=VALUES(nombres),
  apellidos=VALUES(apellidos),
  carrera_id=VALUES(carrera_id),
  estado=VALUES(estado);

-- Cursos (Estadística e Informática: los que indicaste)
INSERT INTO cursos (codigo, nombre, carrera_id, nivel, creditos) VALUES
('EI101','Introducción a la Ciencia de Datos',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'BASICO',3),
('EI102','Análisis Estadístico',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'INTERMEDIO',4),
('EI103','Álgebra Matricial',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'BASICO',4),
('EI104','Estadística General',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'BASICO',4),
('EI105','Estadística Computacional',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'INTERMEDIO',3),
('EI106','Machine Learning',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'AVANZADO',4),
('EI107','Ciencia de Datos',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'AVANZADO',4),
('EI108','Estudio de Mercados (Estadística Aplicada)',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'INTERMEDIO',3),
('EI109','Estadística Bayesiana',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'AVANZADO',4),
('EI110','Métodos No Paramétricos',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'AVANZADO',3),
('EI111','Regresión',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'INTERMEDIO',4),
('EI112','Técnicas Multivariadas',(SELECT carrera_id FROM carreras WHERE nombre='Estadística e Informática'),'AVANZADO',4)
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  carrera_id=VALUES(carrera_id),
  nivel=VALUES(nivel),
  creditos=VALUES(creditos);

-- Cursos (Gestión Empresarial: acordes)
INSERT INTO cursos (codigo, nombre, carrera_id, nivel, creditos) VALUES
('GE201','Fundamentos de Administración',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'BASICO',3),
('GE202','Contabilidad Gerencial',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'INTERMEDIO',4),
('GE203','Finanzas Corporativas',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'INTERMEDIO',4),
('GE204','Gestión de Operaciones',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'INTERMEDIO',3),
('GE205','Marketing Estratégico',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'INTERMEDIO',3),
('GE206','Gestión de Proyectos',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'INTERMEDIO',3),
('GE207','Gestión del Talento Humano',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'INTERMEDIO',3),
('GE208','Analítica de Negocios',(SELECT carrera_id FROM carreras WHERE nombre='Gestión Empresarial'),'AVANZADO',4)
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  carrera_id=VALUES(carrera_id),
  nivel=VALUES(nivel),
  creditos=VALUES(creditos);

-- Cursos (Economía: acordes)
INSERT INTO cursos (codigo, nombre, carrera_id, nivel, creditos) VALUES
('EC301','Microeconomía I',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'BASICO',4),
('EC302','Macroeconomía I',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'BASICO',4),
('EC303','Econometría I',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'INTERMEDIO',4),
('EC304','Teoría del Crecimiento Económico',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'AVANZADO',3),
('EC305','Economía Pública',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'INTERMEDIO',3),
('EC306','Economía Internacional',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'INTERMEDIO',3),
('EC307','Política Monetaria y Financiera',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'AVANZADO',3),
('EC308','Evaluación de Proyectos de Inversión',(SELECT carrera_id FROM carreras WHERE nombre='Economía'),'INTERMEDIO',3)
ON DUPLICATE KEY UPDATE
  nombre=VALUES(nombre),
  carrera_id=VALUES(carrera_id),
  nivel=VALUES(nivel),
  creditos=VALUES(creditos);

-- Asignación profesor-curso (año/ciclo)
INSERT INTO profesor_curso (profesor_id, curso_id, anio, ciclo) VALUES
-- Estadística e Informática
((SELECT profesor_id FROM profesores WHERE codigo='PEI001'), (SELECT curso_id FROM cursos WHERE codigo='EI101'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEI001'), (SELECT curso_id FROM cursos WHERE codigo='EI107'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEI002'), (SELECT curso_id FROM cursos WHERE codigo='EI111'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEI002'), (SELECT curso_id FROM cursos WHERE codigo='EI106'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEI003'), (SELECT curso_id FROM cursos WHERE codigo='EI102'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEI003'), (SELECT curso_id FROM cursos WHERE codigo='EI112'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEI004'), (SELECT curso_id FROM cursos WHERE codigo='EI109'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEI004'), (SELECT curso_id FROM cursos WHERE codigo='EI110'), 2025, 'II'),

-- Gestión Empresarial
((SELECT profesor_id FROM profesores WHERE codigo='PGE001'), (SELECT curso_id FROM cursos WHERE codigo='GE201'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE001'), (SELECT curso_id FROM cursos WHERE codigo='GE205'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE002'), (SELECT curso_id FROM cursos WHERE codigo='GE202'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE002'), (SELECT curso_id FROM cursos WHERE codigo='GE203'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE003'), (SELECT curso_id FROM cursos WHERE codigo='GE204'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE003'), (SELECT curso_id FROM cursos WHERE codigo='GE206'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE004'), (SELECT curso_id FROM cursos WHERE codigo='GE207'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE004'), (SELECT curso_id FROM cursos WHERE codigo='GE208'), 2025, 'II'),

-- Economía
((SELECT profesor_id FROM profesores WHERE codigo='PEC001'), (SELECT curso_id FROM cursos WHERE codigo='EC301'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEC001'), (SELECT curso_id FROM cursos WHERE codigo='EC306'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEC002'), (SELECT curso_id FROM cursos WHERE codigo='EC302'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEC002'), (SELECT curso_id FROM cursos WHERE codigo='EC303'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEC003'), (SELECT curso_id FROM cursos WHERE codigo='EC305'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEC003'), (SELECT curso_id FROM cursos WHERE codigo='EC308'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEC004'), (SELECT curso_id FROM cursos WHERE codigo='EC304'), 2025, 'II'),
((SELECT profesor_id FROM profesores WHERE codigo='PEC004'), (SELECT curso_id FROM cursos WHERE codigo='EC307'), 2025, 'II')
ON DUPLICATE KEY UPDATE anio=VALUES(anio);

-- Asistencias (solo entrada y salida)
INSERT INTO asistencia (profesor_id, fecha, entrada, salida, sede, punto_control, metodo, observacion) VALUES
((SELECT profesor_id FROM profesores WHERE codigo='PEI001'), '2025-12-18', '2025-12-18 07:52:10', '2025-12-18 16:35:22', 'Campus La Molina', 'Facultad de Economía', 'BIOMETRIA', NULL),
((SELECT profesor_id FROM profesores WHERE codigo='PEI002'), '2025-12-18', '2025-12-18 08:05:41', '2025-12-18 15:58:03', 'Campus La Molina', 'Facultad de Economía', 'QR', NULL),
((SELECT profesor_id FROM profesores WHERE codigo='PGE001'), '2025-12-18', '2025-12-18 08:11:02', '2025-12-18 17:02:10', 'Campus La Molina', 'Facultad de Economía', 'TARJETA', NULL),
((SELECT profesor_id FROM profesores WHERE codigo='PEC002'), '2025-12-18', '2025-12-18 07:49:33', '2025-12-18 16:10:45', 'Campus La Molina', 'Facultad de Economía', 'QR', NULL),

((SELECT profesor_id FROM profesores WHERE codigo='PEI003'), '2025-12-19', '2025-12-19 08:02:15', '2025-12-19 16:44:19', 'Campus La Molina', 'Facultad de Economía', 'BIOMETRIA', NULL),
((SELECT profesor_id FROM profesores WHERE codigo='PEI004'), '2025-12-19', '2025-12-19 07:56:07', '2025-12-19 13:25:40', 'Campus La Molina', 'Facultad de Economía', 'QR', 'Salida temprana por comisión'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE003'), '2025-12-19', '2025-12-19 08:18:59', '2025-12-19 17:09:02', 'Campus La Molina', 'Facultad de Economía', 'TARJETA', NULL),
((SELECT profesor_id FROM profesores WHERE codigo='PEC001'), '2025-12-19', '2025-12-19 08:00:12', '2025-12-19 16:02:55', 'Campus La Molina', 'Facultad de Economía', 'QR', NULL),

((SELECT profesor_id FROM profesores WHERE codigo='PGE002'), '2025-12-20', '2025-12-20 08:06:34', '2025-12-20 15:40:11', 'Campus La Molina', 'Facultad de Economía', 'MANUAL', 'Registro manual por mantenimiento del lector'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE004'), '2025-12-20', '2025-12-20 08:13:20', '2025-12-20 16:55:00', 'Campus La Molina', 'Facultad de Economía', 'QR', NULL),
((SELECT profesor_id FROM profesores WHERE codigo='PEC003'), '2025-12-20', '2025-12-20 07:58:48', '2025-12-20 16:20:30', 'Campus La Molina', 'Facultad de Economía', 'TARJETA', NULL),
((SELECT profesor_id FROM profesores WHERE codigo='PEC004'), '2025-12-20', '2025-12-20 08:09:05', '2025-12-20 12:59:42', 'Campus La Molina', 'Facultad de Economía', 'QR', 'Salida por clase externa');

-- Opcional: algunos registros “solo entrada” (aún no marcan salida)
INSERT INTO asistencia (profesor_id, fecha, entrada, salida, sede, punto_control, metodo, observacion) VALUES
((SELECT profesor_id FROM profesores WHERE codigo='PEI002'), '2025-12-23', '2025-12-23 08:03:10', NULL, 'Campus La Molina', 'Facultad de Economía', 'QR', 'Aún en campus'),
((SELECT profesor_id FROM profesores WHERE codigo='PGE001'), '2025-12-23', '2025-12-23 07:57:55', NULL, 'Campus La Molina', 'Facultad de Economía', 'BIOMETRIA', 'Aún en campus');
