import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/iot_data.dart';

class IotRepository {
  static const String _apiUrl = 'https://api.khmengineers.in/api/data';
  static const String _apiKey = 'KHM123';
  static const String _storageKey = 'iot_data_history';

  Future<IotData> fetchCurrentData() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'x-api-key': _apiKey,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              'Request timeout - please check your internet connection');
        },
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');

        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid data format received from API');
        }

        return IotData.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed - invalid API key');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error - please try again later');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on FormatException catch (e) {
      throw Exception('Invalid data format: ${e.message}');
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection');
      }
      throw Exception('Error fetching data: $e');
    }
  }

  Future<void> saveDataPoint(IotData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<IotData> existingData = await getStoredData();

      existingData.add(data);

      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      existingData =
          existingData.where((d) => d.timestamp.isAfter(sevenDaysAgo)).toList();

      final jsonList = existingData.map((d) => d.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<List<IotData>> getStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => IotData.fromJson(json)).toList();
    } catch (e) {
      print('Error loading data: $e');
      return [];
    }
  }

  Future<List<IotData>> getHourlyData() async {
    final allData = await getStoredData();
    final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));

    return allData.where((d) => d.timestamp.isAfter(oneDayAgo)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<List<IotData>> getDailyData() async {
    final allData = await getStoredData();
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    final recentData =
        allData.where((d) => d.timestamp.isAfter(sevenDaysAgo)).toList();

    Map<String, List<double>> dailyTemps = {};

    for (var data in recentData) {
      final dateKey =
          '${data.timestamp.year}-${data.timestamp.month}-${data.timestamp.day}';
      dailyTemps.putIfAbsent(dateKey, () => []);
      dailyTemps[dateKey]!.add(data.temperature);
    }

    List<IotData> dailyAverages = [];
    dailyTemps.forEach((dateKey, temps) {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final avgTemp = temps.reduce((a, b) => a + b) / temps.length;
      dailyAverages.add(IotData(temperature: avgTemp, timestamp: date));
    });

    return dailyAverages..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
