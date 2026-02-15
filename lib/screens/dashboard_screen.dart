import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/lead_provider.dart';
import '../widgets/lead_stats_card.dart';
import '../services/auth_service.dart';
import '../models/lead.dart';
import '../utils/governance_report.dart';
import 'login_screen.dart' as import_login;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Lead Engine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
               await AuthService().signOut();
               if (context.mounted) {
                 Navigator.of(context).pushReplacement(
                   MaterialPageRoute(builder: (_) => const import_login.LoginScreen()),
                 );
               }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar (Desktop-ish view)
          if (MediaQuery.of(context).size.width > 800)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.people), label: Text('Leads')),
                NavigationRailDestination(icon: Icon(Icons.security), label: Text('Governance')),
              ],
            ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildBodyContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return _buildLeadsView();
      case 2:
        return _buildGovernanceView();
      default:
        return _buildDashboardView();
    }
  }

  Widget _buildDashboardView() {
    final leadProvider = Provider.of<LeadProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Row
        SizedBox(
          height: 140,
          child: Row(
            children: [
              Expanded(
                child: LeadStatsCard(
                  title: 'Enrichment Status',
                  value: '${leadProvider.enrichedCount} / ${leadProvider.leads.length}',
                  color: Colors.purple,
                  pieSections: [
                    PieChartSectionData(value: leadProvider.enrichedCount.toDouble(), color: Colors.purple, radius: 20, showTitle: false),
                    PieChartSectionData(value: leadProvider.pendingCount.toDouble(), color: Colors.grey[300], radius: 20, showTitle: false),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LeadStatsCard(
                  title: 'Audit Logs',
                  value: 'Safe',
                  color: Colors.green,
                   // Placeholder for another chart
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Leads Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Leads', style: Theme.of(context).textTheme.headlineSmall),
            FloatingActionButton.extended(
              onPressed: () => leadProvider.importCsv(),
              label: const Text('Upload CSV'),
              icon: const Icon(Icons.upload_file),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(child: _buildLeadsList(limit: 5)), // Show only recent 5 on dashboard
      ],
    );
  }

  Widget _buildLeadsView() {
    final leadProvider = Provider.of<LeadProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Leads', style: Theme.of(context).textTheme.headlineMedium),
             FloatingActionButton.extended(
              onPressed: () => leadProvider.importCsv(),
              label: const Text('Upload CSV'),
              icon: const Icon(Icons.upload_file),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildLeadsList()),
      ],
    );
  }

  Widget _buildGovernanceView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Governance Report', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SingleChildScrollView(
              child: Text(
                GovernanceReport.generate(),
                style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsList({int? limit}) {
    final leadProvider = Provider.of<LeadProvider>(context);
    
    if (leadProvider.leads.isEmpty) {
      return const Center(child: Text('No leads uploaded. Upload a CSV to start.', style: TextStyle(color: Colors.grey)));
    }

    final leadsToShow = limit != null 
        ? leadProvider.leads.take(limit).toList() 
        : leadProvider.leads;

    return ListView.builder(
      itemCount: leadsToShow.length,
      itemBuilder: (context, index) {
        final lead = leadsToShow[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(lead.name.isNotEmpty ? lead.name[0] : '?')),
            title: Text(lead.name),
            subtitle: Text('${lead.role} @ ${lead.company}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (lead.enrichmentStatus == 'enriched')
                  const Icon(Icons.check_circle, color: Colors.green),
                if (lead.enrichmentStatus == 'failed')
                  const Icon(Icons.error, color: Colors.red),
                  
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: lead.enrichmentStatus == 'pending' 
                      ? () => leadProvider.enrichLead(lead.id) 
                      : null,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(lead.enrichmentStatus == 'enriching' ? '...' : 'Smart Enrich'),
                ),
              ],
            ),
            onTap: () => _showLeadDetails(context, lead),
          ),
        );
      },
    );
  }

  void _showLeadDetails(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${lead.name} details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${lead.email}'), // In real app, this might be masked
            Text('Phone: ${lead.phone}'),
            const Divider(),
            const Text('AI Enrichment Data:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Text(lead.enrichmentData.isNotEmpty ? lead.enrichmentData : 'No enrichment data yet.'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
