import 'package:flutter/material.dart';
import '../models/lead.dart';
import '../services/csv_service.dart';
import '../services/enrichment_service.dart';

class LeadProvider extends ChangeNotifier {
  final CsvService _csvService = CsvService();
  final EnrichmentService _enrichmentService = EnrichmentService();
  
  List<Lead> _leads = [];
  bool _isLoading = false;

  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;

  int get enrichedCount => _leads.where((l) => l.enrichmentStatus == 'enriched').length;
  int get pendingCount => _leads.where((l) => l.enrichmentStatus == 'pending').length;

  Future<void> importCsv() async {
    _setLoading(true);
    try {
      final newLeads = await _csvService.pickAndParseCsv();
      _leads.addAll(newLeads);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> enrichLead(String leadId) async {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index == -1) return;

    final lead = _leads[index];
    
    // Optimistic Update
    _leads[index] = lead.copyWith(enrichmentStatus: 'enriching');
    notifyListeners();

    try {
      final summary = await _enrichmentService.enrichLead(lead.company, lead.role);
      _leads[index] = lead.copyWith(
        enrichmentStatus: 'enriched',
        enrichmentData: summary,
      );
    } catch (e) {
      _leads[index] = lead.copyWith(enrichmentStatus: 'failed', enrichmentData: 'Error: $e');
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
