// Forcing file re-analysis by Zapp (v3)
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
// Use relative imports for your own files
import 'auth_page.dart';
import 'task_list_page.dart';

const String keyApplicationId = '8GjtjshxHHcSGKBWttc0flLvIefiXMFZ59vXYi61';
const String keyClientKey = 'ge9sljH13jjoGXKXqQitZcDYYK3fCFjKdpIZsQJQ';
const String keyParseServerUrl = 'https://parseapi.back4app.com';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse SDK
  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    debug: true, // Set to false in production
  );

  runApp(const MyApp());
}

// Re-analyzing file
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Helper function to check if a user is already logged in
  Future<bool> hasUserLogged() async {
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      return false;
    }
    // Checks whether the user's session token is valid
    final ParseResponse? response =
        await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);

    return response?.success ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: hasUserLogged(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking login status
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            // User is logged in, go to the task list
            return const TaskListPage();
          } else {
            // User is not logged in, show the auth page
            return const AuthPage();
          }
        },
      ),
    );
  }
}
