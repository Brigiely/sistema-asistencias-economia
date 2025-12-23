<?php
require_once 'config/config.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

$conn = getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

// REGISTRAR ASISTENCIA
if ($action === 'registrar_asistencia' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $profesor_id = sanitize($data['profesor_id']);
    $fecha = sanitize($data['fecha']);
    $estado = sanitize($data['estado']);
    $hora_entrada = sanitize($data['hora_entrada'] ?? '');
    $hora_salida = sanitize($data['hora_salida'] ?? '');
    $observaciones = sanitize($data['observaciones'] ?? '');
    
    // Verificar si ya existe asistencia para ese día
    $check = $conn->prepare("SELECT id FROM asistencias WHERE profesor_id = ? AND fecha = ?");
    $check->bind_param("is", $profesor_id, $fecha);
    $check->execute();
    
    if ($check->get_result()->num_rows > 0) {
        jsonResponse(false, 'Ya existe un registro de asistencia para este profesor en esta fecha');
    }
    
    $stmt = $conn->prepare("INSERT INTO asistencias (profesor_id, fecha, hora_entrada, hora_salida, estado, observaciones) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("isssss", $profesor_id, $fecha, $hora_entrada, $hora_salida, $estado, $observaciones);
    
    if ($stmt->execute()) {
        jsonResponse(true, 'Asistencia registrada correctamente', ['id' => $stmt->insert_id]);
    } else {
        jsonResponse(false, 'Error al registrar asistencia: ' . $conn->error);
    }
}

// AGREGAR PROFESOR
if ($action === 'agregar_profesor' && $method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $nombre = sanitize($data['nombre']);
    $dni = sanitize($data['dni']);
    $carrera_id = sanitize($data['carrera_id']);
    $email = sanitize($data['email'] ?? '');
    $telefono = sanitize($data['telefono'] ?? '');
    
    // Verificar DNI duplicado
    $check = $conn->prepare("SELECT id FROM profesores WHERE dni = ?");
    $check->bind_param("s", $dni);
    $check->execute();
    
    if ($check->get_result()->num_rows > 0) {
        jsonResponse(false, 'Ya existe un profesor con este DNI');
    }
    
    $stmt = $conn->prepare("INSERT INTO profesores (nombre_completo, dni, carrera_id, email, telefono) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("ssiss", $nombre, $dni, $carrera_id, $email, $telefono);
    
    if ($stmt->execute()) {
        jsonResponse(true, 'Profesor agregado correctamente', ['id' => $stmt->insert_id]);
    } else {
        jsonResponse(false, 'Error al agregar profesor: ' . $conn->error);
    }
}

// LISTAR PROFESORES
if ($action === 'listar_profesores' && $method === 'GET') {
    $carrera_id = $_GET['carrera_id'] ?? '';
    
    $sql = "SELECT p.*, c.nombre as carrera_nombre 
            FROM profesores p 
            INNER JOIN carreras c ON p.carrera_id = c.id";
    
    if ($carrera_id) {
        $sql .= " WHERE p.carrera_id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $carrera_id);
        $stmt->execute();
        $result = $stmt->get_result();
    } else {
        $result = $conn->query($sql);
    }
    
    $profesores = [];
    while ($row = $result->fetch_assoc()) {
        $profesores[] = $row;
    }
    
    jsonResponse(true, 'Profesores obtenidos', $profesores);
}

// CONSULTAR ASISTENCIAS
if ($action === 'consultar_asistencias' && $method === 'GET') {
    $fecha_desde = $_GET['fecha_desde'] ?? '';
    $fecha_hasta = $_GET['fecha_hasta'] ?? '';
    $carrera_id = $_GET['carrera_id'] ?? '';
    
    $sql = "SELECT a.*, p.nombre_completo, p.dni, c.nombre as carrera_nombre 
            FROM asistencias a
            INNER JOIN profesores p ON a.profesor_id = p.id
            INNER JOIN carreras c ON p.carrera_id = c.id
            WHERE 1=1";
    
    $params = [];
    $types = '';
    
    if ($fecha_desde) {
        $sql .= " AND a.fecha >= ?";
        $params[] = $fecha_desde;
        $types .= 's';
    }
    
    if ($fecha_hasta) {
        $sql .= " AND a.fecha <= ?";
        $params[] = $fecha_hasta;
        $types .= 's';
    }
    
    if ($carrera_id) {
        $sql .= " AND p.carrera_id = ?";
        $params[] = $carrera_id;
        $types .= 'i';
    }
    
    $sql .= " ORDER BY a.fecha DESC, p.nombre_completo";
    
    if (!empty($params)) {
        $stmt = $conn->prepare($sql);
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        $result = $stmt->get_result();
    } else {
        $result = $conn->query($sql);
    }
    
    $asistencias = [];
    while ($row = $result->fetch_assoc()) {
        $asistencias[] = $row;
    }
    
    jsonResponse(true, 'Asistencias obtenidas', $asistencias);
}

// EXPORTAR CSV PARA POWER BI
if ($action === 'exportar_csv' && $method === 'GET') {
    $tipo = $_GET['tipo'] ?? 'asistencias';
    
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="' . $tipo . '_' . date('Y-m-d') . '.csv"');
    
    $output = fopen('php://output', 'w');
    
    // BOM para UTF-8
    fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF));
    
    if ($tipo === 'asistencias') {
        fputcsv($output, ['Fecha', 'Profesor', 'DNI', 'Carrera', 'Estado', 'Hora Entrada', 'Hora Salida', 'Observaciones']);
        
        $result = $conn->query("
            SELECT a.fecha, p.nombre_completo, p.dni, c.nombre as carrera, 
                   a.estado, a.hora_entrada, a.hora_salida, a.observaciones
            FROM asistencias a
            INNER JOIN profesores p ON a.profesor_id = p.id
            INNER JOIN carreras c ON p.carrera_id = c.id
            ORDER BY a.fecha DESC
        ");
        
        while ($row = $result->fetch_assoc()) {
            fputcsv($output, $row);
        }
    }
    
    if ($tipo === 'profesores') {
        fputcsv($output, ['ID', 'Nombre Completo', 'DNI', 'Carrera', 'Email', 'Teléfono']);
        
        $result = $conn->query("
            SELECT p.id, p.nombre_completo, p.dni, c.nombre as carrera, p.email, p.telefono
            FROM profesores p
            INNER JOIN carreras c ON p.carrera_id = c.id
            ORDER BY c.nombre, p.nombre_completo
        ");
        
        while ($row = $result->fetch_assoc()) {
            fputcsv($output, $row);
        }
    }
    
    if ($tipo === 'resumen') {
        fputcsv($output, ['Carrera', 'Profesor', 'Total Días', 'Presentes', 'Ausentes', 'Tardanzas', 'Justificados', '% Asistencia']);
        
        $result = $conn->query("
            SELECT c.nombre as carrera, p.nombre_completo,
                   COUNT(*) as total_dias,
                   SUM(CASE WHEN a.estado = 'presente' THEN 1 ELSE 0 END) as presentes,
                   SUM(CASE WHEN a.estado = 'ausente' THEN 1 ELSE 0 END) as ausentes,
                   SUM(CASE WHEN a.estado = 'tardanza' THEN 1 ELSE 0 END) as tardanzas,
                   SUM(CASE WHEN a.estado = 'justificado' THEN 1 ELSE 0 END) as justificados,
                   ROUND((SUM(CASE WHEN a.estado IN ('presente', 'tardanza') THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as porcentaje_asistencia
            FROM asistencias a
            INNER JOIN profesores p ON a.profesor_id = p.id
            INNER JOIN carreras c ON p.carrera_id = c.id
            GROUP BY c.nombre, p.nombre_completo
            ORDER BY c.nombre, p.nombre_completo
        ");
        
        while ($row = $result->fetch_assoc()) {
            fputcsv($output, $row);
        }
    }
    
    fclose($output);
    exit;
}

// Si no coincide ninguna acción
jsonResponse(false, 'Acción no válida');

$conn->close();
?>