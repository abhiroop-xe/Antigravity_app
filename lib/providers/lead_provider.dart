import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lead.dart';
import '../services/csv_service.dart';
import '../services/enrichment_service.dart';
import '../main.dart';

class LeadProvider extends ChangeNotifier {
  SupabaseClient? get _supabase {
    try {
      if (!isSupabaseInitialized) return null;
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  final CsvService _csvService = CsvService();
  final EnrichmentService _enrichmentService = EnrichmentService();

  List<Lead> _leads = [];
  bool _isLoading = false;

  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;
  bool get isMockMode => _enrichmentService.isMockMode;

  void toggleMockMode(bool value) {
    _enrichmentService.setMockMode(value);
    notifyListeners();
  }

  int get enrichedCount =>
      _leads.where((l) => l.enrichmentStatus == 'enriched').length;
  int get pendingCount =>
      _leads.where((l) => l.enrichmentStatus == 'pending').length;

  Future<void> fetchLeads() async {
    _setLoading(true);
    try {
      final client = _supabase;
      if (client == null) return; // Guest mode — no DB fetch

      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await client
          .from('leads')
          .select()
          .order('created_at', ascending: false);

      _leads = (response as List).map((m) => Lead.fromMap(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch Leads Failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> importCsv(BuildContext context) async {
    _setLoading(true);
    try {
      final client = _supabase;
      final userId = client?.auth.currentUser?.id;
      final newLeadsData = await _csvService.pickAndParseCsv();

      if (newLeadsData.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No leads found in CSV or action cancelled.')),
          );
        }
        return;
      }

      if (client != null && userId != null) {
        // Authenticated: Sync with Supabase
        final leadsToInsert = newLeadsData.map((l) {
          final map = l.toMap();
          map['user_id'] = userId;
          map.remove('id'); // Let DB generate ID
          return map;
        }).toList();

        await client.from('leads').insert(leadsToInsert);
        await fetchLeads(); // Refresh list from DB
      } else {
        // Guest Mode: Update local state only for demo
        _leads.addAll(newLeadsData);
        notifyListeners();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Successfully imported ${newLeadsData.length} leads!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV Import: $errorMsg')),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addLead({
    required BuildContext context,
    required String name,
    required String email,
    required String company,
    required String role,
  }) async {
    _setLoading(true);
    try {
      final client = _supabase;
      final userId = client?.auth.currentUser?.id;
      final leadId = DateTime.now().millisecondsSinceEpoch.toString();

      if (client != null && userId != null) {
        await client.from('leads').insert({
          'user_id': userId,
          'name': name,
          'email': email,
          'company': company,
          'role': role,
          'enrichment_status': 'pending',
        });
        await fetchLeads();
      } else {
        // Guest Mode Demo
        _leads.insert(
            0,
            Lead(
              id: leadId,
              userId: 'guest',
              name: name,
              email: email,
              company: company,
              role: role,
              enrichmentStatus: 'pending',
            ));
        notifyListeners();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead added successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding lead: $e')),
        );
      }
      rethrow;
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
      final summary =
          await _enrichmentService.enrichLead(lead.company, lead.role);

      final client = _supabase;
      if (client != null) {
        await client.from('leads').update({
          'enrichment_status': 'enriched',
          'enrichment_data': summary,
        }).eq('id', leadId);
      }

      _leads[index] = lead.copyWith(
        enrichmentStatus: 'enriched',
        enrichmentData: summary,
      );
    } catch (e) {
      _leads[index] = lead.copyWith(
          enrichmentStatus: 'failed', enrichmentData: 'Error: $e');
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
