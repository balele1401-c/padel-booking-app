import 'package:flutter/foundation.dart';
import '../models/court_model.dart';
import '../services/court_service.dart';

class CourtProvider extends ChangeNotifier {
  final CourtService _courtService;

  CourtProvider({CourtService? courtService})
      : _courtService = courtService ?? CourtService();

  /// Stream of active courts for Customer Home
  Stream<List<CourtModel>> get activeCourtsStream =>
      _courtService.getActiveCourtsStream();

  /// Stream of all courts for Admin Management
  Stream<List<CourtModel>> get allCourtsStream =>
      _courtService.getAllCourtsStream();
}
