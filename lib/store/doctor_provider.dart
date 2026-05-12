import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/doctor_service.dart';
import '../utils/api_exception.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _service;

  List<DoctorModel> _doctors = [];
  List<String> _specialties = ['الكل'];
  bool _isLoading = false;
  String? _error;

  DoctorProvider(this._service);

  List<DoctorModel> get doctors => _doctors;
  List<String> get specialties => _specialties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDoctors({
    String? specialty,
    String? governorate,
    String? city,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctors = await _service.getDoctors(
        specialty: specialty,
        governorate: governorate,
        city: city,
        search: search,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSpecialties() async {
    try {
      final list = await _service.getSpecialties();
      _specialties = ['الكل', ...list];
      notifyListeners();
    } on ApiException {
      // Keep default ['الكل'] on failure — non-critical
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
