import 'package:flutter/material.dart';
import 'package:sar_web/firebase_options.dart';
import 'package:sar_web/routes.dart';
import 'package:firebase_core/firebase_core.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAppCheck.instance.activate(
  //   webProvider:
  //       ReCaptchaV3Provider('6Le059wpAAAAAJamdGcW1rQ6nfi3XlDM3Go5ZW7j'),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theatrica',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
            primary: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Routes.generateRoute,
      initialRoute: '/',
    );
  }
}
