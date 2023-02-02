import 'package:dio/dio.dart';
import 'package:flutter_pocketbase/models/user_model.dart';
import 'package:flutter_pocketbase/services/dio_service.dart';
import 'package:flutter_pocketbase/services/pocketbase_service.dart';
import 'package:flutter_pocketbase/services/shared_prefs_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final UserModel user;
  final String token;

  AuthResult(this.user, this.token);
}

class AuthRepository {
  Ref? _ref;
  PocketBase? pb;
  Dio? dio;
  SharedPreferences? prefs;

  AuthRepository(Ref ref) {
    _ref = ref;
    pb = ref.read(pocketbaseProvider);
    dio = ref.read(dioProvider);
    prefs = ref.watch(sharedPrefsProvider).maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
  }

  Future<AuthResult?> login(String email, String password) async {
    try {
      Response response = await dio!.post('/api/collections/users/auth-with-password', data: {
        "identity": email,
        "password": password
      });

      AuthResult result = AuthResult(
        UserModel(
          response.data['record']['id'], 
          response.data['record']['username'], 
          response.data['record']['email'], 
          DateTime.parse(response.data['record']['created']), 
          DateTime.parse(response.data['record']['updated'])
        ), 
        response.data['token']
      );

      await prefs?.setString('token', response.data['token']);
      
      return result;
      
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<AuthResult?> logged() async {
    try {
      final a = this._ref?.read(sharedPrefsProvider).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
      print(a);

      final String? token = await prefs?.getString('token');
      print("token: " + token!);
      // Response response = await dio!.get('/api/collections/users/auth-refresh');

      // print(response.data.toString());

      return null;
      
    } catch (e) {
      print({e});
      return null;
    }
  }

  Future<UserModel?> logOut() async {
    // final pb = _ref.read(pocket_provider);
    return Future.delayed(const Duration(milliseconds: 100))
      .then((value) => null);
  }
}

final auth_repository_provider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});