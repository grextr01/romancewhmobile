import 'package:hive/hive.dart';

part 'hive_user.g.dart';

@HiveType(typeId: 0)
class HiveUser {
  @HiveField(0)
  String token;
  @HiveField(1)
  String userId;
  @HiveField(2)
  String firstName;
  @HiveField(3)
  String lastName;
  @HiveField(4)
  String username;

  HiveUser(
      {required this.token,
      required this.userId,
      required this.firstName,
      required this.lastName,
      required this.username});
}
