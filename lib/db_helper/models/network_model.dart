import 'package:floor/floor.dart';

@Entity(tableName: 'networks')
class NetworkModel {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String qrData;
  final String username;
  final String password;

  NetworkModel({
    this.id,
    required this.qrData,
    required this.username,
    required this.password,
  });

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      id: json['id'] as int?,
      qrData: json['qrData'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }


}
