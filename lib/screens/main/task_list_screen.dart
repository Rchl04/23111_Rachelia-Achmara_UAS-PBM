// lib/screens/main/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/task.dart';
import '../../../services/api_service.dart';
import '../../../widgets/task_card.dart'; // Import TaskCard
import 'create_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Task>> _futureTasks;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchTasks();
  }

  Future<void> _loadUserIdAndFetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      setState(() {
        _currentUserId = int.tryParse(userId);
        if (_currentUserId != null) {
          _futureTasks = _fetchTasks();
        }
      });
    }
  }

  Future<List<Task>> _fetchTasks() async {
    if (_currentUserId == null) return [];

    final response = await _apiService.getTasks(_currentUserId!);

    if (response['status'] == 'success') {
      List tasksJson = response['tasks'];
      return tasksJson.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Gagal mengambil tugas.');
    }
  }

  void _navigateAndRefresh() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
    );
    setState(() {
      _futureTasks = _fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(
        child: Text("Gagal memuat User ID. Silakan Login ulang."),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {
            _futureTasks = _fetchTasks();
          });
          return _futureTasks;
        },
        child: FutureBuilder<List<Task>>(
          future: _futureTasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Belum ada tugas! Tarik ke bawah untuk refresh.'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final task = snapshot.data![index];
                  // Refresh Task List setelah status/delete berubah
                  return TaskCard(
                    task: task,
                    onStatusChange: () => setState(() {
                      _futureTasks = _fetchTasks();
                    }),
                    onDelete: () => setState(() {
                      _futureTasks = _fetchTasks();
                    }),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh,
        child: const Icon(Icons.add),
      ),
    );
  }
}
