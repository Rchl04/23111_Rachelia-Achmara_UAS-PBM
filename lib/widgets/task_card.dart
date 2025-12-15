// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onStatusChange,
    required this.onDelete,
  });

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final apiService = ApiService();
    try {
      final response = await apiService.updateTaskStatus(task.id, newStatus);

      if (!context.mounted) return;

      if (response['status'] == 'success') {
        _showSnackBar(context, 'Status tugas diperbarui ke: $newStatus');
        onStatusChange();
      } else {
        _showSnackBar(
          context,
          response['message'] ?? 'Gagal mengubah status.',
          isError: true,
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      _showSnackBar(context, 'Koneksi gagal: $e', isError: true);
    }
  }

  Future<void> _deleteTask(BuildContext context) async {
    final apiService = ApiService();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Anda yakin ingin menghapus tugas "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await apiService.deleteTask(task.id);

      if (!context.mounted) return;

      if (response['status'] == 'success') {
        _showSnackBar(context, 'Tugas "${task.title}" berhasil dihapus.');
        onDelete();
      } else {
        _showSnackBar(
          context,
          response['message'] ?? 'Gagal menghapus tugas.',
          isError: true,
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      _showSnackBar(context, 'Koneksi gagal: $e', isError: true);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'on progress':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(task.status),
          child: Text(
            task.status[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == 'completed'
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Deadline: ${DateFormat('d MMM yyyy').format(task.deadline)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              task.description.isEmpty
                  ? '— Tidak ada deskripsi —'
                  : task.description,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteTask(context);
            } else {
              _updateStatus(context, value);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'pending',
              child: Text('Set ke Pending'),
            ),
            const PopupMenuItem<String>(
              value: 'on progress',
              child: Text('Set ke On Progress'),
            ),
            const PopupMenuItem<String>(
              value: 'completed',
              child: Text('Set ke Completed'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Hapus Tugas', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
