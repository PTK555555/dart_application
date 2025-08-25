import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  stdout.write("===== Login =====\nUsername: ");
  String username = stdin.readLineSync()!;
  stdout.write("Password: ");
  String password = stdin.readLineSync()!;

  // --- Login Request ---
  var loginRes = await http.post(
    Uri.parse("http://localhost:3000/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"username": username, "password": password}),
  );

  if (loginRes.statusCode == 200) {
    print("Login success\n");

    while (true) {
      print("========= Expense Tracking App =========");
      print("1. Show all");
      print("2. Today's expense");
      print("3. Search expense");
      print("4. Add new expense");
      print("5. Delete an expense");
      print("6. Exit");
      stdout.write("Choose: ");
      String? choice = stdin.readLineSync();

      if (choice == "1") {
        var res = await http.get(Uri.parse("http://localhost:3000/expenses"));
        var expenses = jsonDecode(res.body);
        showExpenses(expenses);
      } else if (choice == "2") {
        var res = await http.get(
          Uri.parse("http://localhost:3000/expenses/today"),
        );
        var expenses = jsonDecode(res.body);
        showExpenses(expenses);
      } else if (choice == "6") {
        print("----- Bye -------");
        break;
      } else {
        print("Invalid choice");
      }
    }
  } else {
    print("Login failed: ${loginRes.body}");
  }
}

void showExpenses(List<dynamic> expenses) {
  int total = 0;
  print("----------- Expenses -----------");
  for (var e in expenses) {
    print("${e['item']} : ${e['paid']}฿ : ${e['date']}");
    total += e['paid'] as int;
  }
  print("Total expenses = ${total}฿\n");
}

555555555