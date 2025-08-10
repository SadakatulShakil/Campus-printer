import 'package:floor/floor.dart';
import '../models/network_model.dart';

@dao
abstract class NetworkDao {
  @Query('SELECT * FROM networks')
  Future<List<NetworkModel>> getAllNetworks();

  @insert
  Future<void> insertNetwork(NetworkModel network);

  @Query('DELETE FROM networks WHERE id = :id')
  Future<void> deleteNetwork(int id);
}
