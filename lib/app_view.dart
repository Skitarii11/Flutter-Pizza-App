import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizza_app/screens/home/blocs/cart/cart_bloc.dart';
import 'package:user_repository/cart_repository.dart';
import 'package:user_repository/user_repository.dart';

import 'screens/auth/views/welcome_screen.dart';
import 'screens/home/views/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState.status == AuthenticationStatus.authenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<SignInBloc>(
                create: (context) => SignInBloc(
                  userRepository: context.read<UserRepository>(),
                ),
              ),
              BlocProvider<GetPizzaBloc>(
                create: (context) => GetPizzaBloc(
                  pizzaRepository: context.read<PizzaRepo>(),
                )..add(GetPizza()),
              ),
              BlocProvider<CartBloc>(
                create: (context) => CartBloc(
                  cartRepo: context.read<CartRepo>(),
                  firebaseAuth: FirebaseAuth.instance,
                ),
              ),
            ],
            child: MaterialApp(
              title: 'Pizza Delivery (Authenticated)',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.light(
                  background: Colors.grey.shade200,
                  onBackground: Colors.black,
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
              ),
              home: const HomeScreen(),
            ),
          );
        } else {
          return MaterialApp(
            title: 'Pizza Delivery (Welcome)',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                background: Colors.grey.shade200,
                onBackground: Colors.black,
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
            home: BlocProvider<SignInBloc>(
              create: (context) => SignInBloc(
                userRepository: context.read<UserRepository>(),
              ),
              child: const WelcomeScreen(),
            ),
          );
        }
      },
    );
  }
}