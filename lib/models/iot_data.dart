class IotData {
  final double temperature;
  final DateTime timestamp;
  final double? humidity;
  final int? soilMoisture;
  final String? status;

  IotData({
    required this.temperature,
    required this.timestamp,
    this.humidity,
    this.soilMoisture,
    this.status,
  });

  factory IotData.fromJson(Map<String, dynamic> json) {
    try {
      final tempValue = json['temperature'];
      double temperature;

      if (tempValue == null) {
        throw FormatException('Temperature field is missing');
      } else if (tempValue is String) {
        temperature = double.parse(tempValue);
      } else if (tempValue is num) {
        temperature = tempValue.toDouble();
      } else {
        throw FormatException('Invalid temperature type');
      }

      final timestampValue = json['updatedAt'] ?? json['timestamp'];
      DateTime timestamp;

      if (timestampValue == null) {
        timestamp = DateTime.now();
      } else if (timestampValue is String) {
        timestamp = DateTime.parse(timestampValue);
      } else {
        timestamp = DateTime.now();
      }

      double? humidity;
      final humValue = json['humidity'];
      if (humValue != null) {
        if (humValue is String) {
          humidity = double.tryParse(humValue);
        } else if (humValue is num) {
          humidity = humValue.toDouble();
        }
      }

      int? soilMoisture;
      final soilValue = json['soilMoisture'];
      if (soilValue != null) {
        if (soilValue is String) {
          soilMoisture = int.tryParse(soilValue);
        } else if (soilValue is num) {
          soilMoisture = soilValue.toInt();
        }
      }

      return IotData(
        temperature: temperature,
        timestamp: timestamp,
        humidity: humidity,
        soilMoisture: soilMoisture,
        status: json['status'] as String?,
      );
    } catch (e) {
      print('Error parsing IotData: $e');
      throw FormatException('Failed to parse IotData: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
      if (humidity != null) 'humidity': humidity,
      if (soilMoisture != null) 'soilMoisture': soilMoisture,
      if (status != null) 'status': status,
    };
  }

  @override
  String toString() {
    return 'IotData(temperature: $temperature, humidity: $humidity, soilMoisture: $soilMoisture, status: $status, timestamp: $timestamp)';
  }
}
