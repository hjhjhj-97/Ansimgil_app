class EmergencyContact {
  final int? id;
  final String name;
  final String phoneNumber;
  final bool isPrimary;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      isPrimary: map['is_primary'] == 1,
    );
  }

  EmergencyContact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}