import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_client.dart';
import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';
import '../../store/doctor_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _doctorService = DoctorService(ApiClient());

  String _selectedSpecialty = 'الكل';
  String? _selectedGovernorate;
  String? _selectedCity;

  Map<String, List<String>> _locations = {};
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DoctorProvider>();
      provider.fetchSpecialties();
      provider.fetchDoctors();
    });
  }

  Future<void> _loadLocations() async {
    try {
      final map = await _doctorService.getLocations();
      if (mounted) setState(() { _locations = map; _isLoadingLocations = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  void _applyFilters() {
    context.read<DoctorProvider>().fetchDoctors(
          specialty:
              _selectedSpecialty == 'الكل' ? null : _selectedSpecialty,
          governorate: _selectedGovernorate,
          city: _selectedCity,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildLocationFilters(),
                  const SizedBox(height: 24),
                  _buildSpecialtiesSection(),
                  const SizedBox(height: 20),
                  _buildDoctorsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C1A3A), Color(0xFF0A2952)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00B4FF).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك 👋',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        'ابحث عن طبيبك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'ابحث بالاسم أو التخصص...',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilters() {
    if (_isLoadingLocations) {
      return const SizedBox(
        height: 48,
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B4FF)))),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _dropdownBox(
            hint: 'المحافظة',
            value: _selectedGovernorate,
            items: _locations.keys.toList(),
            onChanged: (val) {
              setState(() {
                _selectedGovernorate = val;
                _selectedCity = null;
              });
              _applyFilters();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _dropdownBox(
            hint: 'المدينة',
            value: _selectedCity,
            items: _selectedGovernorate == null
                ? []
                : (_locations[_selectedGovernorate] ?? []),
            onChanged: (val) {
              setState(() => _selectedCity = val);
              _applyFilters();
            },
          ),
        ),
        if (_selectedGovernorate != null || _selectedCity != null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFDC2626), size: 20),
            onPressed: () {
              setState(() {
                _selectedGovernorate = null;
                _selectedCity = null;
              });
              _applyFilters();
            },
          ),
      ],
    );
  }

  Widget _dropdownBox({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDF8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint,
              style:
                  const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF00B4FF)),
          items: items
              .map((v) => DropdownMenuItem<String>(
                    value: v,
                    child: Text(v,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: Color(0xFF0A2952))),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التخصصات',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Color(0xFF0A2952),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<DoctorProvider>(
          builder: (_, provider, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: provider.specialties.map((spec) {
                  final isActive = spec == _selectedSpecialty;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedSpecialty = spec);
                      _applyFilters();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF0C1A3A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF0C1A3A)
                              : const Color(0xFFE8EDF8),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        spec,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF4A5568),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDoctorsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'أفضل الأطباء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFF0A2952),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'الكل',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Color(0xFF00B4FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<DoctorProvider>(
          builder: (_, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    color: Color(0xFF00B4FF),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (provider.error != null) {
              return _buildErrorState(provider);
            }

            if (provider.doctors.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'لا يوجد أطباء متاحون بهذا التصفية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: provider.doctors
                  .map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDoctorCard(doc),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(DoctorProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Color(0xFF94A3B8), size: 48),
          const SizedBox(height: 12),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF00B4FF)),
            label: const Text(
              'إعادة المحاولة',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFF00B4FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF8)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F0FF), Color(0xFFD0E4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('👨‍⚕️', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Color(0xFF0A2952),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doc.specialty,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Color(0xFF00B4FF),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      '${doc.rating} (${doc.reviewCount})',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: Color(0xFFF59E0B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('📍', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 2),
                    Text(
                      doc.city ?? '',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/doctor_profile',
              arguments: doc.toJson(),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C1A3A), Color(0xFF1A3A6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'احجز',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

