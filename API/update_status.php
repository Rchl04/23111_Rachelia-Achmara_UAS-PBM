<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Hanya menerima POST request.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);
$taskId = $data['id'] ?? '';
$newStatus = $data['status'] ?? ''; // Status baru: 'pending', 'on progress', 'completed'

if (empty($taskId) || empty($newStatus)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'ID tugas dan status baru harus diisi.']);
    exit;
}

// Validasi Status
if (!in_array($newStatus, ['pending', 'on progress', 'completed'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Status tidak valid. Status harus salah satu dari: pending, on progress, completed.']);
    exit;
}

$sql = "UPDATE tasks SET status = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $newStatus, $taskId); // 's' untuk string (status), 'i' untuk integer (id)

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Status tugas berhasil diperbarui.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Gagal memperbarui status.']);
}

$stmt->close();
$conn->close();
