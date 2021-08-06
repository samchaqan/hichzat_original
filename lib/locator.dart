import 'package:get_it/get_it.dart';
import 'package:hichzat/repository/user_repository.dart';
import 'package:hichzat/services/fake_auth_service.dart';
import 'package:hichzat/services/firebase_auth_service.dart';
import 'package:hichzat/services/firestore_db_service.dart';

GetIt locator = GetIt.asNewInstance();

void setupLocator(){
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FakeAuthenticationService());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => FirestoreDBService());
}