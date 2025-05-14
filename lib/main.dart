import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/app.dart';
import 'package:pizza_app/simple_bloc_observer.dart';
import 'package:user_repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: const FirebaseOptions(
      apiKey: "AIzaSyDkjD9R2cRBW44yFI-l5RosbkBfCGtDnTk",
      authDomain: "mobile-ce285.firebaseapp.com",
      databaseURL: "https://mobile-ce285-default-rtdb.firebaseio.com",
      projectId: "mobile-ce285",
      storageBucket: "mobile-ce285.firebasestorage.app",
      messagingSenderId: "913516697875",
      appId: "1:913516697875:web:ed9cd3f89391004674e2e6",
      measurementId: "G-SEMJKCXX1S"
    ),
  );
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp(FirebaseUserRepo()));
}