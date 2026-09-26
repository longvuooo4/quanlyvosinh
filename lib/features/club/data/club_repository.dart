import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/club_snapshot.dart';

abstract interface class ClubRepository {
  Future<ClubSnapshot> load();
  Future<void> save(ClubSnapshot snapshot);
}

class LocalClubRepository implements ClubRepository {
  LocalClubRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'karate_club_data_v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<ClubSnapshot> load() async {
    final value = await _preferences.getString(_storageKey);
    if (value == null || value.isEmpty) return ClubSnapshot.empty();
    return ClubSnapshot.fromJson(
      Map<String, dynamic>.from(jsonDecode(value) as Map),
    );
  }

  @override
  Future<void> save(ClubSnapshot snapshot) =>
      _preferences.setString(_storageKey, jsonEncode(snapshot.toJson()));
}

class MemoryClubRepository implements ClubRepository {
  MemoryClubRepository([ClubSnapshot? initial])
    : snapshot = initial ?? ClubSnapshot.empty();

  ClubSnapshot snapshot;

  @override
  Future<ClubSnapshot> load() async => snapshot;

  @override
  Future<void> save(ClubSnapshot snapshot) async => this.snapshot = snapshot;
}
