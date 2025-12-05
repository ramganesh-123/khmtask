import '../../models/iot_data.dart';

abstract class IotState {}

class IotInitialState extends IotState {}

class IotLoadingState extends IotState {}

class IotLoadedState extends IotState {
  final IotData currentData;
  final List<IotData> hourlyData;
  final List<IotData> dailyData;

  IotLoadedState({
    required this.currentData,
    required this.hourlyData,
    required this.dailyData,
  });

  IotLoadedState copyWith({
    IotData? currentData,
    List<IotData>? hourlyData,
    List<IotData>? dailyData,
  }) {
    return IotLoadedState(
      currentData: currentData ?? this.currentData,
      hourlyData: hourlyData ?? this.hourlyData,
      dailyData: dailyData ?? this.dailyData,
    );
  }
}

class IotErrorState extends IotState {
  final String errorMessage;

  IotErrorState({required this.errorMessage});
}
