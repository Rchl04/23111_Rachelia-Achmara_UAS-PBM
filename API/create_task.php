<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Hanya menerima POST request.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);
$user_id = $data['user_id'] ?? '';
$title = $data['title'] ?? '';
$description = $data['description'] ?? '';
$deadline = $data['deadline'] ?? ''; // Format YYYY-MM-DD

if (empty($user_id) || empty($title) || empty($deadline)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Field User ID, Title, dan Deadline wajib diisi.']);
    exit;
}

$status = 'pending'; // Default status saat membuat tugas

$sql = "INSERT INTO tasks (user_id, title, description, deadline, status) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
// 'i' untuk integer (user_id), 's' untuk string/varchar/text
$stmt->bind_param("issss", $user_id, $title, $description, $deadline, $status);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Tugas baru berhasil dibuat.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Gagal membuat tugas.']);
}

$stmt->close();
$conn->close();
