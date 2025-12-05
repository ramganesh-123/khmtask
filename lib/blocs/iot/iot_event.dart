abstract class IotEvent {}

class FetchCurrentDataEvent extends IotEvent {}

class StartPeriodicFetchEvent extends IotEvent {}

class StopPeriodicFetchEvent extends IotEvent {}

class LoadHourlyDataEvent extends IotEvent {}

class LoadDailyDataEvent extends IotEvent {}
