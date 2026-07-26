import 'package:flutter/foundation.dart';
import '../models/court_model.dart';
import '../services/court_service.dart';

class CourtProvider extends ChangeNotifier {
  final CourtService _courtService;

  bool _isLoading = false;
  String? _errorMessage;

  CourtProvider({CourtService? courtService})
      : _courtService = courtService ?? CourtService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Stream of active courts for Customer Home
  Stream<List<CourtModel>> get activeCourtsStream =>
      _courtService.getActiveCourtsStream();

  /// Stream of all courts for Admin Management
  Stream<List<CourtModel>> get allCourtsStream =>
      _courtService.getAllCourtsStream();

  /// Add new court (Admin)
  Future<bool> addCourt(CourtModel court) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _courtService.addCourt(court);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update existing court (Admin)
  Future<bool> updateCourt(CourtModel court) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _courtService.updateCourt(court);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete court (Admin)
  Future<bool> deleteCourt(String courtId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _courtService.deleteCourt(courtId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
