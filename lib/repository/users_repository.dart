import 'package:logging/logging.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/users_service.dart';

class UsersRepository {
  UsersRepository(this._usersService);

  final UsersService _usersService;
  final log = Logger('UserRepository');

  Future<Paginated<Profile>> getUsers({int page = 1, int perPage = 20}) async {
    final response = await _usersService.getUsers(page: page, perPage: perPage);

    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Profile> getUser(int id) async {
    final response = await _usersService.getUser(id);

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<Profile>> getActiveUsers({int page = 1, int perPage = 20}) async {
    final response = await _usersService.getActiveEmployee(page: page, perPage: perPage);

    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<List<Profile>> getAllEmployee() async {
    late Paginated<Profile> paginated;
    int page = 0;

    do {
      final result = await getActiveUsers(page: ++page, perPage: 100);
      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<Paginated<Profile>> getAllUser() async {
    late Paginated<Profile> paginated;
    int page = 0;
    do {
      final result = await getUsers(page: ++page, perPage: 50);
      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated;
  }

  Future<Profile> updateOrCreate(Profile user, {String? password}) async {
    log.fine('updateUser: $updateOrCreate');
    final boolConverter = JsonBoolConverter();

    Map<String, dynamic> body = {
      'email': user.email,
      'name': user.name,
      'lang': user.lang,
      if (user.phone != null) 'phone': user.phone,
      if (user.phonePrefix?.startsWith('+') == true) 'phonePrefix': user.phonePrefix,
      if (user.phonePrefix != null && user.phonePrefix?.startsWith('+') != true)
        'phonePrefix': '+${user.phonePrefix}',
      'hourRate': user.hourRate,
      'rateCurrency': user.rateCurrency,
      'employeeInfo': user.employeeInfo,
      'adminInfo': user.adminInfo,
      if (password?.isNotEmpty == true) 'password': password,
      'allowEdit': boolConverter.toJson(user.allowEdit),
      'allowVerifiedAdd': boolConverter.toJson(user.allowVerifiedAdd),
      'allowBonus': boolConverter.toJson(user.allowBonus),
      'allowOwnProjects': boolConverter.toJson(user.allowOwnProjects),
      'assignAllToProject': boolConverter.toJson(user.assignAllToProject),
      'allowRemove': boolConverter.toJson(user.allowRemove),
      'allowWageView': boolConverter.toJson(user.allowWageView),
      'allowWeb': boolConverter.toJson(user.allowWeb),
      'allowRateEdit': boolConverter.toJson(user.allowRateEdit),
      'allowNewRate': boolConverter.toJson(user.allowRateEdit),
      'trackGps': boolConverter.toJson(user.trackGps),
      'supervisorAllowEdit': boolConverter.toJson(user.supervisorAllowEdit),
      'supervisorAllowAdd': boolConverter.toJson(user.supervisorAllowAdd),
      'supervisorAllowBonusAdd': boolConverter.toJson(user.supervisorAllowBonusAdd),
      'supervisorAllowWageView': boolConverter.toJson(user.supervisorAllowWageView),
      'supervisorFilesAccess': boolConverter.toJson(user.supervisorFilesAccess),
      'paidBreaks': boolConverter.toJson(user.paidBreaks),
    };

    if (user.isCreate) {
      body['offDaysLimit'] = 0;
      body['role'] = user.role == -1 ? 1 : user.role;
      body['take_screencasts'] = 1;
      body['blur_creencasts'] = 0;

      final response = await _usersService.postUser(body);
      if (response.isSuccessful) {
        return response.body!;
      } else {
        throw response.error!;
      }
    } else {
      final response = await _usersService.putUser(user.id, body);
      if (response.isSuccessful) {
        return response.body!;
      } else {
        throw response.error!;
      }
    }
  }

  Future<bool> resetPassword(int? id) async {
    final response = await _usersService.resetUserPassword(id);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<String> generatePin(int? id) async {
    final response = await _usersService.generateUserPin(id);
    if (response.isSuccessful) {
      log.finest('generatePin [$id] -> ${response.body}');
      return response.body!.value;
    } else {
      throw response.error!;
    }
  }

  Future<bool> removePin(int? id) async {
    final response = await _usersService.removeUserPin(id);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<Profile> activateUser(int? id) async {
    final response = await _usersService.activateUser(id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Profile> deactivateUser(int? id) async {
    final response = await _usersService.deactivateUser(id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Profile> demoteUser(int? id, {int role = 1}) async {
    final response = await _usersService.demoteUser(id, role);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Profile> promoteUser(int? id, {int role = 5}) async {
    final response = await _usersService.promoteUser(id, role);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  void deleteUser(int id) {
    //todo not implemented!! or remove
    // _usersService.de
  }
}
