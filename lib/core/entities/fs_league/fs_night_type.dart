import 'package:hive/hive.dart';

part 'fs_night_type.g.dart';

@HiveType(typeId: 17)
enum FsNightType {
  @HiveField(0)
  def('default'),
  @HiveField(1)
  halloween('halloween'),
  @HiveField(2)
  apresSki('apres-ski'),
  @HiveField(3)
  christmas('christmas'),
  @HiveField(4)
  carnival('carnival'),
  @HiveField(5)
  newYearsEve('new-years-eve');

  final String value;
  const FsNightType(this.value);

  static FsNightType fromString(String? value) {
    return FsNightType.values.firstWhere(
      (type) => type.value == value,
    );
  }
}
