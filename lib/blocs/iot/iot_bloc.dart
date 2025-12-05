import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/iot_repository.dart';
import '../../models/iot_data.dart';
import 'iot_event.dart';
import 'iot_state.dart';

class IotBloc extends Bloc<IotEvent, IotState> {
  final IotRepository iotRepository;
  Timer? _periodicTimer;

  IotBloc({required this.iotRepository}) : super(IotInitialState()) {
    on<FetchCurrentDataEvent>((event, emit) async {
      if (state is! IotLoadedState) {
        emit(IotLoadingState());
      }

      try {
        final currentData = await iotRepository.fetchCurrentData();

        await iotRepository.saveDataPoint(currentData);

        final hourlyData = await iotRepository.getHourlyData();
        final dailyData = await iotRepository.getDailyData();

        emit(IotLoadedState(
          currentData: currentData,
          hourlyData: hourlyData,
          dailyData: dailyData,
        ));
      } catch (e) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        emit(IotErrorState(errorMessage: errorMessage));
      }
    });

    on<StartPeriodicFetchEvent>((event, emit) {
      _periodicTimer?.cancel();

      add(FetchCurrentDataEvent());

      _periodicTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
        add(FetchCurrentDataEvent());
      });
    });

    on<StopPeriodicFetchEvent>((event, emit) {
      _periodicTimer?.cancel();
      _periodicTimer = null;
    });

    on<LoadHourlyDataEvent>((event, emit) async {
      if (state is IotLoadedState) {
        try {
          final hourlyData = await iotRepository.getHourlyData();
          emit((state as IotLoadedState).copyWith(hourlyData: hourlyData));
        } catch (e) {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          emit(IotErrorState(errorMessage: errorMessage));
        }
      }
    });

    on<LoadDailyDataEvent>((event, emit) async {
      if (state is IotLoadedState) {
        try {
          final dailyData = await iotRepository.getDailyData();
          emit((state as IotLoadedState).copyWith(dailyData: dailyData));
        } catch (e) {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          emit(IotErrorState(errorMessage: errorMessage));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _periodicTimer?.cancel();
    return super.close();
  }
}
