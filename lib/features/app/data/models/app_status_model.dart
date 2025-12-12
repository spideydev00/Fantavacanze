import 'package:fantavacanze_official/features/app/domain/entities/app_status.dart';

class AppStatusModel {
  final AppStatusType status;

  AppStatusModel({required this.status});

  factory AppStatusModel.fromJson(Map<String, dynamic> json) {
    return AppStatusModel(
      status: AppStatusType.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
    );
  }
}
