<?php
include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Hanya menerima POST request.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Email dan password harus diisi.']);
    exit;
}

// 1. Cari pengguna berdasarkan email
$sql = "SELECT id, username, password FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    // 2. Verifikasi password (membandingkan hash)
    if (password_verify($password, $user['password'])) {
        // Login berhasil, kembalikan data user (TANPA PASSWORD!)
        echo json_encode([
            'status' => 'success',
            'message' => 'Login berhasil.',
            'user' => [
                // Penting: Kirimkan ID sebagai string, karena SharedPreferences Flutter sering menyimpan ID sebagai String
                'id' => $user['id'],
                'username' => $user['username'],
                'email' => $email
            ]
        ]);
    } else {
        // Password salah
        http_response_code(401); // Unauthorized
        echo json_encode(['status' => 'error', 'message' => 'Email atau Password salah.']);
    }
} else {
    // Email tidak terdaftar
    http_response_code(401);
    echo json_encode(['status' => 'error', 'message' => 'Email atau Password salah.']);
}

$stmt->close();
$conn->close();
