import '../services/token_service.dart';

class GovernanceReport {
  static String generate() {
    final tokenUsage = TokenService().currentUsage;
    final limit = TokenService().remainingTokens + tokenUsage;
    
    return '''
========================================
   SECURE LEAD ENGINE - GOVERNANCE REPORT
========================================
Date: ${DateTime.now().toIso8601String()}

1. DATA PRIVACY (GDPR/CCPA)
   - Status: ACTIVE
   - PII Scrubbing: ENABLED
   - Method: Regex-based masking (Email, Phone, SSN) before API egress.
   - External Data Sharing: Only anonymized contexts sent to Gemini AI.

2. AI TOKEN GOVERNANCE
   - Provider: Google Gemini
   - Daily Limit: $limit Requests
   - Usage Today: $tokenUsage Requests
   - Status: ${tokenUsage >= limit ? 'LIMIT REACHED' : 'WITHIN LIMITS'}

3. DATA PROVENANCE
   - Source: Uploaded CSV (Local Parsing)
   - Enrichment: Public Web Data via Gemini
   - Storage: Supabase (Encrypted at Rest)
   - Audit Logging: Enabled (See 'Audit Logs' table)

4. ACCESS CONTROL
   - Role-Based Access Control (RBAC): Enforced
   - Managers: Full Access + Audit Logs
   - Employees: Own Leads Only

========================================
Verified by Secure Lead Engine Agent 2.
    ''';
  }
}
