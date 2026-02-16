class Lead {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String company;
  final String role;
  final String phone;
  final String enrichmentStatus; // 'pending', 'enriched', 'failed'
  final dynamic enrichmentData; // The AI summary (jsonb in DB)

  Lead({
    required this.id,
    required this.userId,
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
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      phone: map['phone'] ?? '',
      enrichmentStatus: map['enrichment_status'] ?? 'pending',
      enrichmentData: map['enrichment_data'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
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
    dynamic enrichmentData,
  }) {
    return Lead(
      id: id,
      userId: userId,
      name: name,
      email: email,
      company: company,
      role: role,
      phone: phone,
      enrichmentStatus: enrichmentStatus ?? this.enrichmentStatus,
      enrichmentData: enrichmentData ?? this.enrichmentData,
    );
  }
}
