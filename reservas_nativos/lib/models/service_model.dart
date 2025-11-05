class SalonService {
  final String id;
  final String name;
  final double price;
  final int duration; // minutos
  final String professionalId;
  final String companyId;

  SalonService({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.professionalId,
    required this.companyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'professionalId': professionalId,
      'companyId': companyId,
    };
  }

  factory SalonService.fromMap(String id, Map<String, dynamic> data) {
    return SalonService(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      duration: data['duration'] ?? 0,
      professionalId: data['professionalId'] ?? '',
      companyId: data['companyId'] ?? '',
    );
  }
}
