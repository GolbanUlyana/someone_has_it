import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/borrow_request.dart';
import '../services/database_service.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final incoming = db.incomingRequests;
    final outgoing = db.outgoingRequests;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Запити'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Вхідні'),
              Tab(text: 'Вихідні'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, incoming, db, isIncoming: true),
            _buildList(context, outgoing, db, isIncoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<BorrowRequest> requests,
    DatabaseService db, {
    required bool isIncoming,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isIncoming
                  ? 'Немає вхідних запитів'
                  : 'Ви ще не надсилали запитів',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        req.itemTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    _buildStatusBadge(req.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      isIncoming
                          ? 'Від: ${req.requesterName}'
                          : 'Власник: ${req.ownerId}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF7F8C8D)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Повернути до: ${DateFormat('dd.MM.yyyy').format(req.returnDate)}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF7F8C8D)),
                    ),
                  ],
                ),
                if (req.message != null && req.message!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      req.message!,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF34495E)),
                    ),
                  ),
                ],
                if (isIncoming && req.status == RequestStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => db.updateRequest(
                              req.copyWith(status: RequestStatus.rejected)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Відхилити',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => db.updateRequest(
                              req.copyWith(status: RequestStatus.approved)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF50C878),
                          ),
                          child: const Text('Схвалити'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (req.status == RequestStatus.approved &&
                    req.ownerId == db.currentUser?.id) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => db.updateRequest(
                          req.copyWith(status: RequestStatus.returned)),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Позначити як повернено'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color;
    switch (status) {
      case RequestStatus.pending:
        color = const Color(0xFFF39C12);
        break;
      case RequestStatus.approved:
        color = const Color(0xFF50C878);
        break;
      case RequestStatus.rejected:
        color = const Color(0xFFE74C3C);
        break;
      case RequestStatus.returned:
        color = const Color(0xFF4A90E2);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}