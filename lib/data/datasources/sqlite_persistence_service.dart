import 'dart:developer' as dev;
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/entities/macro_log.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/value_objects/zone_type.dart';
import '../../domain/value_objects/measurement_type.dart';
import './sqlite_helper.dart';

class SqlitePersistenceService {
  final SqliteHelper _helper;

  SqlitePersistenceService(this._helper);

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<List<WorkoutDay>> loadAllDays() async {
    dev.log("SQLITE: Loading all days from database...");
    final db = await _helper.database;

    // Load Photos
    final List<Map<String, dynamic>> photoMaps = await db.query('photos');
    final Map<String, List<PhotoRecord>> photoByDate = {};
    for (var map in photoMaps) {
      final date = map['date'] as String;
      photoByDate
          .putIfAbsent(date, () => [])
          .add(
            PhotoRecord(
              id: map['id'].toString(),
              filePath: map['file_path'],
              capturedAt: DateTime.fromMillisecondsSinceEpoch(map['captured_at']),
              zoneType: ZoneType.values.firstWhere((e) => e.name == map['zone_type']),
            ),
          );
    }

    // Load Macros
    final List<Map<String, dynamic>> macroMaps = await db.query('macros');
    final Map<String, MacroLog> macrosByDate = {};
    for (var map in macroMaps) {
      macrosByDate[map['date']] = MacroLog(
        calories: map['calories'],
        protein: map['protein'],
        carbs: map['carbs'],
        fat: map['fat'],
      );
    }

    // Load Measurements
    final List<Map<String, dynamic>> measurementMaps = await db.query('measurements');
    final Map<String, List<Measurement>> measurementsByDate = {};
    for (var map in measurementMaps) {
      measurementsByDate[map['date']] = [
        Measurement(type: MeasurementType.weight, value: map['weight']),
        Measurement(type: MeasurementType.waist, value: map['waist']),
        Measurement(type: MeasurementType.chest, value: map['chest']),
        Measurement(type: MeasurementType.hips, value: map['hips']),
        Measurement(type: MeasurementType.neck, value: map['neck']),
        Measurement(type: MeasurementType.armRight, value: map['arm_right']),
        Measurement(type: MeasurementType.armLeft, value: map['arm_left']),
        Measurement(type: MeasurementType.thighRight, value: map['thigh_right']),
        Measurement(type: MeasurementType.thighLeft, value: map['thigh_left']),
      ];
    }

    // Combine into WorkoutDay
    final Set<String> allDates = {...photoByDate.keys, ...macrosByDate.keys, ...measurementsByDate.keys};

    dev.log("SQLITE: Successfully loaded ${allDates.length} days.");
    return allDates.map((dateStr) {
      final parts = dateStr.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return WorkoutDay(
        date: date,
        photos: photoByDate[dateStr] ?? [],
        macros: macrosByDate[dateStr],
        measurements: measurementsByDate[dateStr] ?? [],
        activeZones: ZoneType.values.toList(), // Will be filtered by UI based on current config
      );
    }).toList();
  }

  Future<void> savePhoto(DateTime date, PhotoRecord photo) async {
    final db = await _helper.database;
    final dateStr = _formatDate(date);
    dev.log("SQLITE: Saving photo for $dateStr [${photo.zoneType.name}]");

    await db.insert('photos', {
      'id': photo.id,
      'date': dateStr,
      'zone_type': photo.zoneType.name,
      'file_path': photo.filePath,
      'captured_at': photo.capturedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveMacros(DateTime date, MacroLog macros) async {
    final db = await _helper.database;
    final dateStr = _formatDate(date);
    dev.log("SQLITE: Saving macros for $dateStr");

    await db.insert('macros', {
      'date': dateStr,
      'calories': macros.calories,
      'protein': macros.protein,
      'carbs': macros.carbs,
      'fat': macros.fat,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveMeasurements(DateTime date, List<Measurement> measurements) async {
    final db = await _helper.database;
    final dateStr = _formatDate(date);
    dev.log("SQLITE: Saving measurements for $dateStr");

    final Map<String, dynamic> values = {'date': dateStr, 'updated_at': DateTime.now().millisecondsSinceEpoch};

    for (var m in measurements) {
      switch (m.type) {
        case MeasurementType.weight:
          values['weight'] = m.value;
          break;
        case MeasurementType.waist:
          values['waist'] = m.value;
          break;
        case MeasurementType.chest:
          values['chest'] = m.value;
          break;
        case MeasurementType.hips:
          values['hips'] = m.value;
          break;
        case MeasurementType.neck:
          values['neck'] = m.value;
          break;
        case MeasurementType.armRight:
          values['arm_right'] = m.value;
          break;
        case MeasurementType.armLeft:
          values['arm_left'] = m.value;
          break;
        case MeasurementType.thighRight:
          values['thigh_right'] = m.value;
          break;
        case MeasurementType.thighLeft:
          values['thigh_left'] = m.value;
          break;
      }
    }

    await db.insert('measurements', values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearAll() async {
    dev.log("SQLITE: Clearing ALL database content");
    final db = await _helper.database;
    await db.delete('photos');
    await db.delete('macros');
    await db.delete('measurements');
  }
}
