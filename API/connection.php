<?php
// Koneksi ke database MySQL Laragon

$host = "localhost";
$user = "root";     // Username default Laragon
$pass = "";         // Password default Laragon (kosong)
$db = "markasdone"; // Ganti ke nama database yang sudah Anda buat!

// Membuat koneksi baru
$conn = new mysqli($host, $user, $pass, $db);

// Memeriksa koneksi
if ($conn->connect_error) {
    // Jika koneksi gagal, hentikan eksekusi dan kirim pesan error JSON
    http_response_code(500); // Internal Server Error
    die(json_encode(array("status" => "error", "message" => "Connection failed: " . $conn->connect_error)));
}

// Mengatur header agar PHP menerima input JSON dan mengembalikan output JSON
header('Content-Type: application/json; charset=utf-8');

// Mengatur charset koneksi
$conn->set_charset("utf8mb4");
