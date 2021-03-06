import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notification_test/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_notification_test/red_page.dart';
import 'package:firebase_notification_test/green_page.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print('NotificationType: backgroundHandler');
  print(message.data.toString());
  print(message.notification!.title);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Firebase Notification'),
      routes: {
        'red': (_) => const RedPage(),
        'green': (_) => const GreenPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    LocalNotificationService.initialize(context);

    FirebaseMessaging.instance.getToken().then((token) {
      print('My Firebase Token: $token');
      //TODO: Save in shared preference and send to youinroll server
    });

    ///Gives you the message on which user taps and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final String routeFromMessage = message.data['route'];
        print(routeFromMessage);
        LocalNotificationService.display(message);
        Navigator.of(context).pushNamed(routeFromMessage);
      }

    });

    ///Foregound work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body);
        print(message.notification!.title);
      }
      LocalNotificationService.display(message);
    });

    ///Background  but app is open state: user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {

      final String routeFromMessage = message.data['route'];
      print(routeFromMessage);
      Navigator.of(context).pushNamed(routeFromMessage);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(18),
        child: Center(
          child: Text(
            'You will receive message soon',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
