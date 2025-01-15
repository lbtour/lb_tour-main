import '../../screens/discover/discover.dart';

class TouristSpot {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String description;
  final String availableHour;
  final String address;
  final String? formattedDate; // Add this field

  final List<Activity> activities;
  final List<String> virtualImages;
  int likes; // Ensure the likes property is defined
  Set<String> likedByUsers;

  TouristSpot({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.availableHour,
    required this.address,
    this.formattedDate, // Include formattedDate here
    required this.activities,
    required this.virtualImages,
    required this.likes, // Include likes here
    required this.likedByUsers,
  });

  factory TouristSpot.fromMap(String id, Map<dynamic, dynamic> map, {String? formattedDate}) {
    return TouristSpot(
      id: id,
      name: map['touristName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] ?? '',
      description: map['description'] ?? '',
      availableHour: map['availableHour'] ?? '',
      address: map['location'] ?? '',
      formattedDate: formattedDate, // Assign formattedDate
      activities: (map['activities'] as List<dynamic>? ?? [])
          .map((activity) => Activity.fromMap(activity))
          .toList(),
      virtualImages: List<String>.from(map['virtualImages'] ?? []),
      likes: map['likes'] ?? 0, // Parse likes here
      likedByUsers: Set<String>.from(map['userLikes']?.keys ?? []),
    );
  }
}
