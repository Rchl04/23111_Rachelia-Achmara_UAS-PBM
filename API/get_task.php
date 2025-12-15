<?php
include 'connection.php';

// Ambil user_id dari GET parameter (ideal untuk request GET)
$user_id = $_GET['user_id'] ?? null;

if (empty($user_id)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'user_id harus disediakan.']);
    exit;
}

// Ambil semua tugas milik user, urutkan berdasarkan deadline terdekat (ASC)
$sql = "SELECT id, user_id, title, description, deadline, status, created_at FROM tasks WHERE user_id = ? ORDER BY deadline ASC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

echo json_encode([
    'status' => 'success',
    'tasks' => $tasks
]);

$stmt->close();
$conn->close();
