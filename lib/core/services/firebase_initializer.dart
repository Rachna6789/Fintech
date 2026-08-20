import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer._();

  static Future<void> initialize({FirebaseOptions? options}) async {
    if (Firebase.apps.isNotEmpty) return;

    await Firebase.initializeApp(
      options: options ?? DefaultFirebaseOptions.currentPlatform,
    );
  }
}
