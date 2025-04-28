import 'package:hive/hive.dart';

part 'user_photo.g.dart';

@HiveType(typeId: 1)
class UserPhoto {
  @HiveField(0)
  final String filePath;
  @HiveField(1)
  final double latitude;
  @HiveField(2)
  final double longitude;
  @HiveField(3)
  final DateTime timestamp;

  UserPhoto({
    required this.filePath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
} 