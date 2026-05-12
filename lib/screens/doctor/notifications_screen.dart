import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService(ApiClient());
  List<NotificationModel> _notifications = [];
  int _unread = 0;
  bool _isLoading = true;
  bool _isMarkingAll = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = result.items;
          _unread        = result.unread;
          _isLoading     = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(int id) async {
    try {
      await _service.markRead(id);
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == id);
        if (idx != -1 && !_notifications[idx].isRead) {
          _notifications[idx] = _notifications[idx].copyWith(isRead: true);
          _unread = (_unread - 1).clamp(0, _unread);
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    setState(() => _isMarkingAll = true);
    try {
      await _service.markAllRead();
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _unread        = 0;
      });
    } catch (_) {}
    if (mounted) setState(() => _isMarkingAll = false);
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'appointment': return Icons.calendar_month;
      case 'payment':     return Icons.monetization_on;
      default:            return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'appointment': return const Color(0xFF00B4FF);
      case 'payment':     return const Color(0xFF10B981);
      default:            return const Color(0xFF8B5CF6);
    }
  }

  String _relativeTime(String createdAt) {
    try {
      final dt   = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1)  return 'الآن';
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24)   return 'منذ ${diff.inHours} ساعة';
      return 'منذ ${diff.inDays} يوم';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _buildHeader(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF))))
          else if (_notifications.isEmpty)
            const Expanded(child: _EmptyState())
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetch,
                color: const Color(0xFF00B4FF),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (_, i) => _buildCard(_notifications[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          Column(
            children: [
              const Text('الإشعارات', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (_unread > 0)
                Text('$_unread غير مقروء',
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
            ],
          ),
          GestureDetector(
            onTap: _unread > 0 && !_isMarkingAll ? _markAllRead : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _unread > 0 ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isMarkingAll
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('قراءة الكل',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.white.withValues(alpha: _unread > 0 ? 1.0 : 0.4),
                        fontSize: 12,
                      )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(NotificationModel n) {
    final color = _colorForType(n.type);
    return GestureDetector(
      onTap: () => _markRead(n.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : const Color(0xFFEFF8FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead ? const Color(0xFFE8EDF8) : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconForType(n.type), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(n.title,
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: const Color(0xFF0A2952)),
                          overflow: TextOverflow.ellipsis),
                      ),
                      if (!n.isRead)
                        Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.message,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF64748B)),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(_relativeTime(n.createdAt),
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.notifications_none, size: 64, color: Color(0xFFCBD5E1)),
        SizedBox(height: 16),
        Text('لا توجد إشعارات',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Color(0xFF94A3B8))),
      ],
    ),
  );
}
