// lib/screens/main/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _tasks = [];

  int pending = 0;
  int onProgress = 0;
  int completed = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('userId');

    if (userIdString == null) return;

    final userId = int.parse(userIdString);

    try {
      final response = await _apiService.getTasks(userId);

      final List<dynamic> tasks = response['data'] ?? [];

      pending = 0;
      onProgress = 0;
      completed = 0;

      for (var task in tasks) {
        if (task['status'] == 'pending') pending++;
        if (task['status'] == 'on progress') onProgress++;
        if (task['status'] == 'completed') completed++;
      }

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get nearestDeadlineTasks {
    final sorted = [..._tasks];
    sorted.sort(
      (a, b) => DateTime.parse(
        a['deadline'],
      ).compareTo(DateTime.parse(b['deadline'])),
    );
    return sorted.take(3).toList();
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ringkasan Tugas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildStatusCard('Pending', pending, Colors.red),
              const SizedBox(width: 8),
              _buildStatusCard('On Progress', onProgress, Colors.orange),
              const SizedBox(width: 8),
              _buildStatusCard('Completed', completed, Colors.green),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Deadline Terdekat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (nearestDeadlineTasks.isEmpty) const Text('Tidak ada tugas.'),

          ...nearestDeadlineTasks.map(
            (task) => Card(
              child: ListTile(
                title: Text(task['title']),
                subtitle: Text('Deadline: ${task['deadline']}'),
                trailing: Text(task['status']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
