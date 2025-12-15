// lib/constants.dart

// Ganti sesuai IP yang Anda gunakan. 10.0.2.2 untuk Android Emulator.
const String baseUrl = "http://10.0.2.2/task_api";

// Endpoint API
const String registerUrl = '$baseUrl/register.php';
const String loginUrl = '$baseUrl/login.php';
const String createUrl = '$baseUrl/create_task.php';
const String getTasksUrl = '$baseUrl/get_task.php';
const String updateStatusUrl = '$baseUrl/update_status.php';
const String deleteUrl = '$baseUrl/delete_task.php';
