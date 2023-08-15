import 'dart:convert';

import 'package:chopper/chopper.dart' as chopp;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:staffmonitor/bloc/files/file_upload_cubit.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/service/api/converter/json_to_type_converter.dart';
import 'package:staffmonitor/utils/time_utils.dart';

void main() {
  test('zonk', () {
    List<int> list = [10, 10, 220];
    print('list: $list');
    Set<int> set = Set.from(list);
    print('set: $set');
  });

  test('A parse test', () {
    String body =
        '{"id": 1,  "name": "John",  "email": "john@company.com",  "lang": "en",  "phone": 7575333888,  "defaultProject": {  "id": 1,  "name": "Test"  },  "availableProjects": [  {  "id": 1,  "name": "Test"  }  ],  "preferredProjects": [9, 16, 21],  "lastProjectsLimit": 3,  "employeeInfo": "Good work",  "role": 1,  "status": 1,  "adminInfo": "",  "hourRate": "5.75",  "rateCurrency": "USD",  "allowEdit": 1,  "allowRemove": 1,  "allowBonus": 1,  "allowWageView": 1,  "allowOwnProjects": 1,  "assignAllToProject": 1,  "allowWeb": 1,  "allowRateEdit": 1,  "allowNewRate": 1,  "createdAt": 1545245502,  "updatedAt": 1545247839  }';

    Profile.fromJson(jsonDecode(body));
  });
  test('A profile parse test', () {
    String body =
        '{"id":33,"name":"Rafał Orlik","email":"orlik.raf@gmail.com","phone":null,"lang":"pl","defaultProject":null,"availableProjects":[{"id":34,"name":"#WYRÓWNANIE GODZIN#"},{"id":37,"name":"Brandenbura, Wrocław pompa Ciepla"},{"id":35,"name":"Grochowiec Godzięcin, rekuperacja"},{"id":40,"name":"Jakubkowice pompa + reku"},{"id":38,"name":"Kiełczów przewiert"},{"id":36,"name":"Kwakszyc Lutynia, Panas 12 TCAP split + zmiękczacz"},{"id":39,"name":"Lewandowska Bałdowice, Panas 9kw AIO + bufor + demontaz"}],"preferredProjects":[],"lastProjectsLimit":3,"offDaysLimit":0,"employeeInfo":"","createdAt":1614336538,"updatedAt":1615716804,"hourRate":"0.00","rateCurrency":"PLN","overtimes":[],"role":3,"status":1,"adminInfo":"","allowEdit":1,"allowRemove":1,"allowBonus":1,"allowWageView":1,"allowOwnProjects":1,"assignAllToProject":1,"allowWeb":1}';

    Profile.fromJson(jsonDecode(body));
  });
  test('Sessions list parse', () {
    final String body =
        '[{"id":633,"verified":1,"clockIn":1621859181,"clockInProposed":1621859181,"clockOut":1621859188,"clockOutProposed":1621859188,"note":null,"project":{"id":12,"name":"# INNE #","color":"#ff4935"},"files":[],"bonus":"0.00","bonusProposed":"0.00","createdAt":1621859182,"updatedAt":1621859844,"hourRate":"28.00","rateCurrency":"PLN","totalWage":"0.05","calculated":0,"overtime":0,"multiplier":[{"multiplier":13.248,"time":7}]},{"id":632,"verified":1,"clockIn":1621814400,"clockInProposed":1621814400,"clockOut":1621859100,"clockOutProposed":1621859100,"note":"test","project":{"id":12,"name":"# INNE #","color":"#ff4935"},"files":[],"bonus":"0.00","bonusProposed":"0.00","createdAt":1621859128,"updatedAt":1621859162,"hourRate":"28.00","rateCurrency":"PLN","totalWage":"1756.52","calculated":1,"overtime":22,"multiplier":[{"multiplier":1,"time":18000},{"multiplier":1.2,"time":10800},{"multiplier":11.04,"time":7140},{"multiplier":13.248,"time":8760}]},{"id":607,"verified":1,"clockIn":1620506400,"clockInProposed":1620506400,"clockOut":1620506460,"clockOutProposed":1620506460,"note":"test","project":{"id":14,"name":"# SERWISY #","color":"#ff0000"},"files":[],"bonus":"0.00","bonusProposed":"0.00","createdAt":1620506482,"updatedAt":1620506581,"hourRate":"28.00","rateCurrency":"PLN","totalWage":"0.47","calculated":1,"overtime":0,"multiplier":null},{"id":454,"verified":1,"clockIn":1617055200,"clockInProposed":1617055200,"clockOut":1617141540,"clockOutProposed":1617141540,"note":null,"project":null,"files":[],"bonus":"0.00","bonusProposed":"0.00","createdAt":1617049749,"updatedAt":1618740601,"hourRate":"20.00","rateCurrency":"PLN","totalWage":"4441.34","calculated":1,"overtime":22,"multiplier":[{"multiplier":1.2,"time":18000},{"multiplier":1.44,"time":10800},{"multiplier":13.248,"time":57540}]},{"id":452,"verified":1,"clockIn":1616968800,"clockInProposed":1616968800,"clockOut":1617055140,"clockOutProposed":1617055140,"note":null,"project":null,"files":[],"bonus":"0.00","bonusProposed":"0.00","createdAt":1617049697,"updatedAt":1618740601,"hourRate":"20.00","rateCurrency":"PLN","totalWage":"4441.34","calculated":1,"overtime":22,"multiplier":[{"multiplier":1.2,"time":18000},{"multiplier":1.44,"time":10800},{"multiplier":13.248,"time":57540}]},{"id":417,"verified":1,"clockIn":1615763640,"clockInProposed":1615763640,"clockOut":1615816800,"clockOutProposed":1615816800,"note":null,"project":{"id":12,"name":"# INNE #","color":"#ff4935"},"files":[],"bonus":"0.00","bonusProposed":"0.00","createdAt":1615817663,"updatedAt":1618740601,"hourRate":"20.00","rateCurrency":"PLN","totalWage":"1879.79","calculated":1,"overtime":22,"multiplier":[{"multiplier":1,"time":17760},{"multiplier":1.2,"time":11040},{"multiplier":11.04,"time":6960},{"multiplier":13.248,"time":17400}]},{"id":515,"verified":1,"clockIn":1615301760,"clockInProposed":1615301760,"clockOut":1615302000,"clockOutProposed":1615302000,"note":null,"project":null,"files":[],"bonus":"0.00","bonusProposed":"0.00","createdAt":1618322176,"updatedAt":1618740601,"hourRate":"28.00","rateCurrency":"PLN","totalWage":"1.87","calculated":1,"overtime":0,"multiplier":null}]';

    final converter = JsonToTypeConverter({
      Session: (j) => Session.fromJson(j),
    });

    final convertResponse = converter
        .convertResponse<List<Session>, Session>(chopp.Response(Response(body, 200), body));

    if (convertResponse.isSuccessful) {
      print('converter result: ${convertResponse.body}');
    } else {
      print('converter result error: ${convertResponse.error}');
    }
  });

  test('time_utils test', () {
    final date = DateTime(2021, 2, 5);

    final first = date.firstDayOfMonth;
    expect(date.year, first.year);
    expect(2, first.month);
    expect(1, first.day);
    expect(0, first.hour);
    expect(0, first.minute);

    final last = date.lastDayOfMonth;
    expect(date.year, last.year);
    expect(2, last.month);
    expect(28, last.day);
    expect(23, last.hour);
    expect(59, last.minute);

    final next = DateTime(2021, 12, 5).nextMonth;
    expect(2022, next.year);
    expect(1, next.month);
    expect(5, next.day);
    expect(0, next.minute);
    expect(0, next.second);
  });
  test('jsonEncode int', () {
    int id = 5;
    String five = '5';
    var encodedId = jsonEncode(id);
    var encodedString = jsonEncode(five);
    expect(false, encodedString == encodedId);
  });
  test('file state', () {
    // Map < int, List<String> map = {};
    final p1 = FileUploadInProgress({
      '12': List.from(['aa'])
    }, [], {}, {}, {});
    final p2 = FileUploadInProgress({
      '12': List.from(['aa'])
    }, [], {}, {}, {});
    final p3 = FileUploadInProgress({
      '12': List.from(['aa', 'ab'])
    }, [], {}, {}, {});

    expect(true, p1 == p2);
    expect(false, p1 == p3);
  });
}
