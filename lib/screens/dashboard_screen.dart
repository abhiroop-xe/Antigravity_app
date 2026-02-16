import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/lead_provider.dart';
import '../widgets/lead_stats_card.dart';
import '../services/auth_service.dart';
import '../models/lead.dart';
import '../utils/governance_report.dart';
import '../main.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NebulaColors.accentPurple, NebulaColors.accentCyan],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [NebulaColors.accentPurple, NebulaColors.accentCyan],
              ).createShader(bounds),
              child: const Text(
                'Nebula',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  NebulaColors.accentPurple.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        actions: [
          // AI Mode Toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Consumer<LeadProvider>(
              builder: (context, provider, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: NebulaColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: NebulaColors.borderSubtle),
                ),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Mock',
                          style: TextStyle(
                              fontSize: 10,
                              color: provider.isMockMode
                                  ? NebulaColors.accentAmber
                                  : NebulaColors.textMuted)),
                      icon: Icon(Icons.money_off,
                          size: 14,
                          color: provider.isMockMode
                              ? NebulaColors.accentAmber
                              : NebulaColors.textMuted),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Live AI',
                          style: TextStyle(
                              fontSize: 10,
                              color: !provider.isMockMode
                                  ? NebulaColors.accentGreen
                                  : NebulaColors.textMuted)),
                      icon: Icon(Icons.auto_awesome,
                          size: 14,
                          color: !provider.isMockMode
                              ? NebulaColors.accentGreen
                              : NebulaColors.textMuted),
                    ),
                  ],
                  selected: {provider.isMockMode},
                  onSelectionChanged: (Set<bool> newSelection) {
                    provider.toggleMockMode(newSelection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    backgroundColor: Colors.transparent,
                    selectedBackgroundColor:
                        NebulaColors.accentPurple.withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          if (MediaQuery.of(context).size.width > 800)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: NebulaColors.borderSubtle),
                ),
              ),
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                indicatorColor: NebulaColors.accentPurple.withOpacity(0.15),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    selectedIcon: Icon(Icons.grid_view_rounded,
                        color: NebulaColors.accentPurple),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_rounded,
                        color: NebulaColors.accentPurple),
                    label: Text('Leads'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shield_outlined),
                    selectedIcon: Icon(Icons.shield_rounded,
                        color: NebulaColors.accentPurple),
                    label: Text('Govern'),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildBodyContent(),
            ),
          ),
        ],
      ),
      // Bottom nav for mobile
      bottomNavigationBar: MediaQuery.of(context).size.width <= 800
          ? Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: NebulaColors.borderSubtle),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                backgroundColor: NebulaColors.bgDeep,
                indicatorColor: NebulaColors.accentPurple.withOpacity(0.15),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded,
                        color: NebulaColors.textMuted),
                    selectedIcon: Icon(Icons.grid_view_rounded,
                        color: NebulaColors.accentPurple),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded,
                        color: NebulaColors.textMuted),
                    selectedIcon: Icon(Icons.people_rounded,
                        color: NebulaColors.accentPurple),
                    label: 'Leads',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.shield_outlined,
                        color: NebulaColors.textMuted),
                    selectedIcon: Icon(Icons.shield_rounded,
                        color: NebulaColors.accentPurple),
                    label: 'Govern',
                  ),
                ],
              ),
            )
          : null,
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
          height: 130,
          child: Row(
            children: [
              Expanded(
                child: LeadStatsCard(
                  title: 'TOTAL LEADS',
                  value: '${leadProvider.leads.length}',
                  color: NebulaColors.accentBlue,
                  icon: Icons.people_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LeadStatsCard(
                  title: 'ENRICHMENT',
                  value:
                      '${leadProvider.enrichedCount}/${leadProvider.leads.length}',
                  color: NebulaColors.accentPurple,
                  icon: Icons.auto_awesome,
                  pieSections: [
                    PieChartSectionData(
                        value: leadProvider.enrichedCount.toDouble(),
                        color: NebulaColors.accentPurple,
                        radius: 16,
                        showTitle: false),
                    PieChartSectionData(
                        value: leadProvider.pendingCount.toDouble(),
                        color: NebulaColors.bgSurface,
                        radius: 16,
                        showTitle: false),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: LeadStatsCard(
                  title: 'COMPLIANCE',
                  value: 'Active',
                  color: NebulaColors.accentGreen,
                  icon: Icons.verified_user_rounded,
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
            const Text(
              'Recent Leads',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NebulaColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Lead',
                  onPressed: leadProvider.isLoading
                      ? null
                      : () => _showAddLeadDialog(context),
                  color: NebulaColors.accentCyan,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload CSV',
                  onPressed: leadProvider.isLoading
                      ? null
                      : () => leadProvider.importCsv(context),
                  color: NebulaColors.accentPurple,
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: RefreshIndicator(
            color: NebulaColors.accentPurple,
            backgroundColor: NebulaColors.bgCard,
            onRefresh: () => leadProvider.fetchLeads(),
            child: _buildLeadsList(limit: 5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label, style: const TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddLeadDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NebulaColors.accentCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_rounded,
                  color: NebulaColors.accentCyan, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Add New Lead'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [NebulaColors.accentPurple, NebulaColors.accentBlue],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    companyController.text.isEmpty ||
                    roleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                try {
                  await Provider.of<LeadProvider>(context, listen: false)
                      .addLead(
                    context: context,
                    name: nameController.text,
                    email: emailController.text,
                    company: companyController.text,
                    role: roleController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Add Lead'),
            ),
          ),
        ],
      ),
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
            const Text(
              'All Leads',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: NebulaColors.textPrimary,
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Lead',
                  onPressed: leadProvider.isLoading
                      ? null
                      : () => _showAddLeadDialog(context),
                  color: NebulaColors.accentCyan,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.upload_file_rounded,
                  label: 'Upload CSV',
                  onPressed: leadProvider.isLoading
                      ? null
                      : () => leadProvider.importCsv(context),
                  color: NebulaColors.accentPurple,
                  isPrimary: true,
                ),
              ],
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NebulaColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_rounded,
                  color: NebulaColors.accentGreen, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Governance Report',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: NebulaColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: NebulaColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NebulaColors.borderSubtle),
            ),
            child: SingleChildScrollView(
              child: Text(
                GovernanceReport.generate(),
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  color: NebulaColors.accentGreen,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadsList({int? limit}) {
    final leadProvider = Provider.of<LeadProvider>(context);

    if (leadProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: NebulaColors.accentPurple,
          strokeWidth: 2,
        ),
      );
    }

    if (leadProvider.leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 64, color: NebulaColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No leads yet',
              style: TextStyle(
                  color: NebulaColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a CSV or add leads manually to get started.',
              style: TextStyle(color: NebulaColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final leadsToShow = limit != null
        ? leadProvider.leads.take(limit).toList()
        : leadProvider.leads;

    return ListView.builder(
      itemCount: leadsToShow.length,
      itemBuilder: (context, index) {
        final lead = leadsToShow[index];
        return _buildLeadCard(lead, leadProvider);
      },
    );
  }

  Widget _buildLeadCard(Lead lead, LeadProvider leadProvider) {
    final statusColor = switch (lead.enrichmentStatus) {
      'enriched' => NebulaColors.accentGreen,
      'enriching' => NebulaColors.accentAmber,
      'failed' => NebulaColors.accentRed,
      _ => NebulaColors.textMuted,
    };

    final statusLabel = switch (lead.enrichmentStatus) {
      'enriched' => 'Enriched',
      'enriching' => 'Processing...',
      'failed' => 'Failed',
      _ => 'Pending',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: NebulaColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NebulaColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showLeadDetails(context, lead),
          hoverColor: NebulaColors.accentPurple.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        NebulaColors.accentPurple.withOpacity(0.3),
                        NebulaColors.accentBlue.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: NebulaColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: NebulaColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lead.role} · ${lead.company}',
                        style: const TextStyle(
                          color: NebulaColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Enrich button
                if (lead.enrichmentStatus == 'pending')
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          NebulaColors.accentPurple,
                          NebulaColors.accentBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: NebulaColors.accentPurple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => leadProvider.enrichLead(lead.id),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Enrich',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (lead.enrichmentStatus == 'enriching')
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: NebulaColors.accentAmber,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLeadDetails(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NebulaColors.accentPurple, NebulaColors.accentBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(lead.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.email_outlined, 'Email', lead.email),
            if (lead.phone.isNotEmpty)
              _buildDetailRow(Icons.phone_outlined, 'Phone', lead.phone),
            _buildDetailRow(Icons.business_rounded, 'Company', lead.company),
            _buildDetailRow(Icons.work_outline_rounded, 'Role', lead.role),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 16, color: NebulaColors.accentPurple),
                SizedBox(width: 8),
                Text(
                  'AI Enrichment Data',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: NebulaColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NebulaColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NebulaColors.borderSubtle),
              ),
              child: Text(
                lead.enrichmentData is String &&
                        (lead.enrichmentData as String).isNotEmpty
                    ? lead.enrichmentData
                    : 'No enrichment data yet. Click "Enrich" to generate.',
                style: const TextStyle(
                  color: NebulaColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: NebulaColors.textMuted),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
                color: NebulaColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: NebulaColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
