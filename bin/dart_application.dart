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
    final loginData = jsonDecode(loginRes.body);
    final userId = loginData['id'];
    final username = loginData['username'];

    // print header and welcome only once
    print("\n=========== Expense Tracking App =========");
    print("Welcome $username\n");

    while (true) {
      // just the menu here
      print("1. All expenses");
      print("2. Today's expense");
      print("3. Search expense");
      print("4. Add new expense");
      print("5. Delete an expense");
      print("6. Exit");
      stdout.write("Choose: ");
      String? choice = stdin.readLineSync();

      if (choice == "1") {
        // Show all
        var res = await http.get(Uri.parse("http://localhost:3000/expenses"));
        var expenses = jsonDecode(res.body);
        showExpenses(expenses);
      } else if (choice == "2") {
        // Today's expense
        var res = await http.get(
          Uri.parse("http://localhost:3000/expenses/today"),
        );
        var expenses = jsonDecode(res.body);
        showExpenses(expenses);
      } else if (choice == "3") {
        // Search expense
        stdout.write("Item to search: ");
        final keyword = stdin.readLineSync()?.trim() ?? '';

        final uri = Uri.parse(
          "http://localhost:3000/expenses/search?q=${Uri.encodeQueryComponent(keyword)}",
        );

        final res = await http.get(uri);

        if (res.statusCode != 200) {
          print("Search failed: ${res.body}\n");
        } else {
          final List<dynamic> expenses = jsonDecode(res.body);
          if (expenses.isEmpty) {
            print("No item: $keyword\n");
          } else {
            showExpenses(expenses);
          }
        }
      } else if (choice == "4") {
        // Add new expense
        print("===== Add new item =====");
        stdout.write("Item: ");
        final item = stdin.readLineSync()?.trim() ?? '';
        stdout.write("Paid: ");
        final paidStr = stdin.readLineSync()?.trim() ?? '0';
        final paid = int.tryParse(paidStr) ?? 0;

        final res = await http.post(
          Uri.parse("http://localhost:3000/expenses"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId, "item": item, "paid": paid}),
        );

        if (res.statusCode == 200) {
          print("Inserted!\n");
        } else {
          print("Failed to insert: ${res.body}\n");
        }
      } else if (choice == "5") {
        // Delete an expense
        print("===== Delete an item =====");
        stdout.write("Item id: ");
        final idStr = stdin.readLineSync()?.trim() ?? '';
        final id = int.tryParse(idStr);

        if (id == null) {
          print("Invalid id\n");
        } else {
          final res = await http.delete(
            Uri.parse("http://localhost:3000/expenses/$id"),
          );

          if (res.statusCode == 200) {
            print("Deleted!\n");
          } else {
            print("Failed to delete: ${res.body}\n");
          }
        }
      } else if (choice == "6") {
        // Exit
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
