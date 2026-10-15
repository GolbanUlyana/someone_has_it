import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../models/borrow_request.dart';
import '../services/database_service.dart';

class ItemDetailScreen extends StatelessWidget {
  final Item item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final isOwner = item.ownerId == db.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                item.category.emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: item.status == ItemStatus.available
                      ? const Color(0xFF50C878).withOpacity(0.15)
                      : const Color(0xFFE74C3C).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status.label,
                  style: TextStyle(
                    color: item.status == ItemStatus.available
                        ? const Color(0xFF50C878)
                        : const Color(0xFFE74C3C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.category.emoji} ${item.category.label}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Опис',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF34495E),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF4A90E2),
                  child: Text(
                    item.ownerName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Власник',
                        style: TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
                      ),
                      Text(
                        item.ownerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!isOwner && item.status == ItemStatus.available)
            ElevatedButton.icon(
              onPressed: () => _showBorrowDialog(context, db),
              icon: const Icon(Icons.handshake),
              label: const Text('Попросити позичити'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          if (isOwner) ...[
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Видалити річ?'),
                    content: const Text('Цю дію не можна скасувати.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Скасувати'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Видалити',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await db.deleteItem(item.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Видалити',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBorrowDialog(BuildContext context, DatabaseService db) {
    DateTime returnDate = DateTime.now().add(const Duration(days: 3));
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Запит на позичку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('На який термін вам потрібна річ?'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Дата повернення'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(returnDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: returnDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => returnDate = picked);
                },
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Повідомлення (необов\'язково)',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = db.currentUser!;
                final request = BorrowRequest(
                  id: const Uuid().v4(),
                  itemId: item.id,
                  itemTitle: item.title,
                  requesterId: user.id,
                  requesterName: user.name,
                  ownerId: item.ownerId,
                  requestDate: DateTime.now(),
                  returnDate: returnDate,
                  message: messageController.text.trim().isEmpty
                      ? null
                      : messageController.text.trim(),
                );
                await db.addRequest(request);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Запит надіслано!'),
                      backgroundColor: Color(0xFF50C878),
                    ),
                  );
                }
              },
              child: const Text('Надіслати'),
            ),
          ],
        ),
      ),
    );
  }
}