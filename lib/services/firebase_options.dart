import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart' as firebase_config;

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: firebase_config.DefaultFirebaseOptions.currentPlatform,
  );
}
