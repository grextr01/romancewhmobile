part of 'hive_user.dart';

class HiveUserAdapter extends TypeAdapter<HiveUser> {
  @override
  final int typeId = 0;

  @override
  HiveUser read(BinaryReader reader) {
    return HiveUser(
        token: reader.read(),
        userId: reader.read(),
        firstName: reader.read(),
        lastName: reader.read(),
        username: reader.read());
  }

  @override
  void write(BinaryWriter writer, HiveUser obj) {
    writer.write(obj.token);
    writer.write(obj.userId);
    writer.write(obj.firstName);
    writer.write(obj.lastName);
    writer.write(obj.username);
  }
}
