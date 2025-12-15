<?php
include 'connection.php';

// Pastikan hanya menerima metode POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['status' => 'error', 'message' => 'Hanya menerima POST request.']);
    exit;
}

// Ambil data JSON dari body request Flutter
$data = json_decode(file_get_contents("php://input"), true);
$username = $data['username'] ?? '';
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

if (empty($username) || empty($email) || empty($password)) {
    http_response_code(400); // Bad Request
    echo json_encode(['status' => 'error', 'message' => 'Semua field harus diisi.']);
    exit;
}

// 1. Hash password sebelum disimpan (PENTING!)
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// 2. Periksa apakah email sudah terdaftar
$check_sql = "SELECT id FROM users WHERE email = ?";
$stmt_check = $conn->prepare($check_sql);
$stmt_check->bind_param("s", $email);
$stmt_check->execute();
$stmt_check->store_result();

if ($stmt_check->num_rows > 0) {
    http_response_code(409); // Conflict
    echo json_encode(['status' => 'error', 'message' => 'Email sudah terdaftar.']);
    $stmt_check->close();
    $conn->close();
    exit;
}
$stmt_check->close();

// 3. Masukkan data ke database
$sql = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $username, $email, $hashed_password);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Registrasi berhasil.']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Registrasi gagal.']);
}

$stmt->close();
$conn->close();
