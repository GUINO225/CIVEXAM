class GuestIdentity {
  final String id;
  final String macAddress;
  final DateTime createdAt;

  const GuestIdentity({
    required this.id,
    required this.macAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'macAddress': macAddress,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GuestIdentity.fromJson(Map<String, dynamic> json) {
    return GuestIdentity(
      id: (json['id'] ?? '') as String,
      macAddress: (json['macAddress'] ?? '') as String,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '') as String) ??
          DateTime.now(),
    );
  }
}
