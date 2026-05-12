import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../utils/api_exception.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _service;

  List<AppointmentModel> _upcoming = [];
  List<AppointmentModel> _past = [];
  bool _isLoading = false;
  String? _error;

  AppointmentProvider(this._service);

  List<AppointmentModel> get upcoming => _upcoming;
  List<AppointmentModel> get past => _past;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final all = await _service.getMyAppointments();
      _upcoming = all.where((a) => a.isUpcoming).toList();
      _past = all.where((a) => a.isPast).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(int id) async {
    try {
      await _service.cancelAppointment(id);
      _upcoming.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } on ApiException {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
