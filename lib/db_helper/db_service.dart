// services/db_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:qr_printer/db_helper/models/network_model.dart';

import 'database.dart';

class DBService extends GetxService {
  late AppDatabase _database;

  Future<DBService> init() async {
    _database = await $FloorAppDatabase
        .databaseBuilder('cam_printer.db')
        .build();
    return this;
  }

  //  Get all network
  Future<List<NetworkModel>> getAllNetworks() async {
    return await _database.networkDao.getAllNetworks();
  }

  // Insert a new network
  Future<void> insertNetwork(NetworkModel network) async {
    await _database.networkDao.insertNetwork(network);
  }

  // Delete a network by ID
  Future<void> deleteNetwork(int id) async {
    await _database.networkDao.deleteNetwork(id);
  }

}