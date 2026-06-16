import '../config/app_config.dart';
import 'api_service.dart';
import 'mock_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;
  ServiceLocator._();

  late final ApiService _apiService = ApiService();
  late final MockService _mockService = MockService();

  bool get useMocks => AppConfig.useMockServices;

  ApiService get api => _apiService;
  MockService get mock => _mockService;
}
