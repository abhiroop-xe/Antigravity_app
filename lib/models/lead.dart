class Lead {
  final String id;
  final String name;
  final String email;
  final String company;
  final String role;
  final String phone;
  final String enrichmentStatus; // 'pending', 'enriched', 'failed'
  final String enrichmentData; // The AI summary

  Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.company,
    required this.role,
    this.phone = '',
    this.enrichmentStatus = 'pending',
    this.enrichmentData = '',
  });

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      phone: map['phone'] ?? '',
      enrichmentStatus: map['enrichment_status'] ?? 'pending',
      enrichmentData: map['enrichment_data']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'company': company,
      'role': role,
      'phone': phone,
      'enrichment_status': enrichmentStatus,
      'enrichment_data': enrichmentData,
    };
  }

  Lead copyWith({
    String? enrichmentStatus,
    String? enrichmentData,
  }) {
    return Lead(
      id: this.id,
      name: this.name,
      email: this.email,
      company: this.company,
      role: this.role,
      phone: this.phone,
      enrichmentStatus: enrichmentStatus ?? this.enrichmentStatus,
      enrichmentData: enrichmentData ?? this.enrichmentData,
    );
  }
}
