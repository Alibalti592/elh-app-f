import 'package:elh/repository/CarteRepository.dart';
import 'package:elh/repository/DeceRepository.dart';
import 'package:elh/repository/DetteRepository.dart';
import 'package:elh/repository/DeuilRepository.dart';
import 'package:elh/repository/MaraudeRepository.dart';
import 'package:elh/repository/MosqueRepository.dart';
import 'package:elh/repository/PardonRepository.dart';
import 'package:elh/repository/PompeRepository.dart';
import 'package:elh/repository/PriereRepository.dart';
import 'package:elh/repository/RelationRepository.dart';
import 'package:elh/repository/SalatRepository.dart';
import 'package:elh/repository/TestamentRepository.dart';
import 'package:elh/services/TestamentService.dart';
import 'package:elh/services/UploadService.dart';
import 'package:elh/ui/views/modules/Carte/CardText.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
//repo
import 'package:elh/repository/PageRepository.dart';
import 'package:elh/repository/DonRepository.dart';
import 'package:elh/repository/FaqRepository.dart';
import 'package:elh/repository/TodoRepository.dart';
import 'package:elh/repository/ContactRepository.dart';
import 'package:elh/repository/NotificationRepository.dart';
import 'package:elh/repository/UserRepository.dart';
import 'package:elh/repository/ChatRepository.dart';
import 'package:elh/repository/UserDataRepository.dart';
import 'package:elh/services/AppReviewService.dart';
//services
import 'package:elh/services/AuthenticationService.dart';
import 'package:elh/services/BBNavigationService.dart';
import 'package:elh/services/BaseApi/AuthApiHelper.dart';
import 'package:elh/services/BaseApi/BaseApiHelper.dart';
import 'package:elh/services/BaseApi/HandleApiReponseError.dart';
import 'package:elh/services/CacheDataService.dart';
import 'package:elh/services/ErrorMessageService.dart';
import 'package:elh/services/ImageService.dart';
import 'package:elh/services/LocalAuthService.dart';
import 'package:elh/services/PushNotificationService.dart';
import 'package:elh/services/UnitService.dart';
import 'package:elh/services/UserInfosReactiveService.dart';
import 'package:elh/services/ChatReactiveService.dart';
import 'package:elh/services/dateService.dart';
import 'package:elh/ui/views/modules/user/loginModel.dart';
import 'package:stacked_services/stacked_services.dart';
//store
import 'package:elh/store/DashboardStore.dart';
import 'package:elh/store/LocationStore.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  //stores
  locator.registerLazySingleton(() => DashboardStore());
  locator.registerLazySingleton(() => LocationStore());
  //services
  locator.registerLazySingleton(() => BaseApiHelper());
  locator.registerLazySingleton(() => AuthApiHelper());
  locator.registerLazySingleton(() => HandleApiResponseError());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => BBNavigationService());
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => ChatReactiveService());
  locator.registerLazySingleton(() => UserInfoReactiveService());
  locator.registerLazySingleton(() => ErrorMessageService());
  locator.registerLazySingleton(() => PushNotificationService());
  locator.registerLazySingleton(() => TestamentService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => UnitService());
  locator.registerLazySingleton(() => ImageService());
  locator.registerLazySingleton(() => UploadService());
  locator.registerLazySingleton(() => CacheDataService());
  locator.registerLazySingleton(() => AppReviewService());
  locator.registerLazySingleton(() => LocalAuthService());
  locator.registerLazySingleton(() => CardText());
  locator.registerFactory(()       => FlutterSecureStorage());
  //module service
  //REPO
  locator.registerLazySingleton(() => DetteRepository());
  locator.registerLazySingleton(() => PageRepository());
  locator.registerLazySingleton(() => DonRepository());
  locator.registerLazySingleton(() => PriereRepository());
  locator.registerLazySingleton(() => PardonRepository());
  locator.registerLazySingleton(() => DeuilRepository());
  locator.registerLazySingleton(() => CarteRepository());
  locator.registerLazySingleton(() => TestamentRepository());
  locator.registerLazySingleton(() => MaraudeRepository());
  locator.registerLazySingleton(() => SalatRepository());
  locator.registerLazySingleton(() => TodoRepository());
  locator.registerLazySingleton(() => DeceRepository());
  locator.registerLazySingleton(() => PompeRepository());
  locator.registerLazySingleton(() => FaqRepository());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => ContactRepository());
  locator.registerLazySingleton(() => NotificationRepository());
  locator.registerLazySingleton(() => ChatRepository());
  locator.registerLazySingleton(() => UserDataRepository());
  locator.registerLazySingleton(() => MosqueRepository());
  locator.registerLazySingleton(() => RelationRepository());
  locator.registerLazySingleton(() => DateService());
  locator.registerFactory(()       => LoginModel());
}