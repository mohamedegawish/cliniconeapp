import 'package:flutter/material.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments if passed from the previous screen
    final doctor = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String name = doctor?['name'] ?? 'د. أحمد محمود';
    final String specialty = doctor?['specialty'] ?? 'استشاري أمراض القلب والأوعية الدموية';
    final String city = doctor?['city'] ?? 'الإسكندرية';
    final String location = doctor?['location'] ?? 'مستشفى المواساة';
    final String rating = doctor?['rating']?.toString() ?? '4.9';
    final String reviewCount = doctor?['review_count']?.toString() ?? '120';
    final String experience = doctor?['experience']?.toString() ?? '15';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF), // Light blue-grey background
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom button
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 80),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00B4FF), Color(0xFF0A2952)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.share, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),

                // Profile Card (Overlapping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Transform.translate(
                    offset: const Offset(0, -60),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B4FF).withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Image
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00B4FF).withValues(alpha: 0.3), width: 3),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text('👨‍⚕️', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Info
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: Color(0xFF0A2952),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialty,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              color: Color(0xFF00B4FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Location & Rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ($reviewCount تقييم)',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📍', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '$location، $city',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Stats Row
                          Row(
                            children: [
                              Expanded(child: _buildStatBox('المرضى', '1000+')),
                              const SizedBox(width: 10),
                              Expanded(child: _buildStatBox('الخبرة', '$experience سنة')),
                              const SizedBox(width: 10),
                              Expanded(child: _buildStatBox('التقييم', rating)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Details Sections
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // About Doctor
                        const Text(
                          'نبذة عن الطبيب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Color(0xFF0A2952),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'دكتور أحمد محمود هو استشاري أول في أمراض القلب والأوعية الدموية. حاصل على البورد الأمريكي والدكتوراة من جامعة لندن، يمتلك خبرة تزيد عن 15 عاماً في تشخيص وعلاج حالات القلب المعقدة.',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        

                        // Availability
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المواعيد المتاحة اليوم',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Color(0xFF0A2952),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '12 أكتوبر',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                color: const Color(0xFF00B4FF).withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          child: Row(
                            children: [
                              _buildTimeSlot('10:00 صباحاً', isSelected: true),
                              _buildTimeSlot('11:30 صباحاً', isSelected: false),
                              _buildTimeSlot('01:00 مساءً', isSelected: false),
                              _buildTimeSlot('02:45 مساءً', isSelected: false),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8EDF8)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'سعر الكشف',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF0A2952),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '200 جنيه',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Color(0xFF00B4FF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 16, bottom: 24, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/book_appointment', arguments: doctor);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4FF), Color(0xFF0077FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4FF).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'احجز موعد الآن',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              color: Color(0xFF0A2952),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00B4FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF00B4FF) : const Color(0xFFE8EDF8),
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: const Color(0xFF00B4FF).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Text(
        time,
        style: TextStyle(
          fontFamily: 'Tajawal',
          color: isSelected ? Colors.white : const Color(0xFF0A2952),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

