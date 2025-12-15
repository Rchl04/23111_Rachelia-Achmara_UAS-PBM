<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Hanya menerima POST request.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);
$taskId = $data['id'] ?? '';

if (empty($taskId)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'ID tugas harus diisi.']);
    exit;
}

$sql = "DELETE FROM tasks WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $taskId); // 'i' untuk integer (id)

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Tugas berhasil dihapus.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Gagal menghapus tugas.']);
}

$stmt->close();
$conn->close();
