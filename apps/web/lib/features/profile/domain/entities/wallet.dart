class Wallet {
  const Wallet({
    required this.id,
    required this.address,
    this.label,
    this.createdAt,
  });

  final int id;
  final String address;
  final String? label;
  final String? createdAt;

  factory Wallet.fromJson(Map<String, Object?> json) {
    final idValue = json['id'];
    final id = idValue is num ? idValue.toInt() : int.tryParse('$idValue') ?? 0;
    return Wallet(
      id: id,
      address: json['address']?.toString() ?? '',
      label: json['label']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'address': address,
        'label': label,
        'created_at': createdAt,
      };
}
