import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../api/api_client.dart';
import '../../models/appointment_model.dart';
import '../../services/queue_service.dart';
import '../../store/auth_provider.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late QueueService _queueService;
  AppointmentModel? _currentAppointment;
  int _remainingCount = 0;
  bool _isLoading = true;

  bool _isChecking = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _queueService = QueueService(ApiClient());
    _fetchQueue();
  }

  Future<void> _fetchQueue() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorId = authProvider.user?.id;
    if (doctorId == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await _queueService.getQueue(doctorId);
      if (mounted) {
        setState(() {
          _currentAppointment = data['current_appointment'];
          _remainingCount = data['remaining_count'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleCheckup() async {
    if (_isChecking) {
      // End checkup and advance queue
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final doctorId = authProvider.user?.id;
      if (doctorId == null) return;

      setState(() => _isLoading = true);
      try {
        final data = await _queueService.advanceQueue(doctorId);
        _timer?.cancel();
        setState(() {
          _isChecking = false;
          _seconds = 0;
          _currentAppointment = data['current_appointment'];
          _remainingCount = data['remaining_count'];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنهاء الكشف والانتقال للمريض التالي', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: Color(0xFF10B981))
        );
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      if (_currentAppointment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد مرضى في الانتظار حالياً'), backgroundColor: Colors.orange)
        );
        return;
      }
      setState(() {
        _isChecking = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
  }

  String get _formattedTime {
    int m = _seconds ~/ 60;
    int s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -20,
                  right: -40,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [const Color(0xFF00B4FF).withValues(alpha:0.4), Colors.transparent],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'طابور الانتظار',
                              style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة تدفق المرضى داخل العيادة (Live)',
                              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white.withValues(alpha:0.8), fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                              SizedBox(width: 6),
                              Text('Live', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _fetchQueue,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    // Overlapping Current Patient Card
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A2952), Color(0xFF194A6E)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF0A2952).withValues(alpha:0.3), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha:0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: _isChecking ? const Color(0xFFEF4444) : const Color(0xFF10B981), size: 12),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isChecking ? 'جاري الكشف' : 'المريض التالي', 
                                    style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              _currentAppointment?.queueNumber?.toString().padLeft(3, '0') ?? '--',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF00B4FF), height: 1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentAppointment?.patientName ?? 'لا يوجد مرضى',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            if (_isChecking) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha:0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _formattedTime,
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFEF4444), fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _toggleCheckup,
                                icon: Icon(_isChecking ? Icons.stop_rounded : Icons.play_arrow_rounded, color: _isChecking ? Colors.white : const Color(0xFF0A2952)),
                                label: Text(
                                  _isChecking ? 'إنهاء الكشف' : 'بدء الكشف الطبي', 
                                  style: TextStyle(fontFamily: 'Cairo', color: _isChecking ? Colors.white : const Color(0xFF0A2952), fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isChecking ? const Color(0xFFEF4444) : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: _isChecking ? 10 : 0,
                                  shadowColor: const Color(0xFFEF4444).withValues(alpha:0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Queue Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.people_alt_rounded, color: Color(0xFF0A2952), size: 20),
                            SizedBox(width: 8),
                            Text('حالة الطابور', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2952))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_remainingCount متبقي', 
                            style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF00B4FF), fontWeight: FontWeight.bold, fontSize: 12)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_currentAppointment == null && _remainingCount == 0)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.local_cafe_rounded, size: 60, color: const Color(0xFF94A3B8).withValues(alpha:0.3)),
                            const SizedBox(height: 16),
                            const Text('الطابور فارغ حالياً!', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            const Text('يمكنك أخذ استراحة قصيرة', style: TextStyle(fontFamily: 'Tajawal', color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
