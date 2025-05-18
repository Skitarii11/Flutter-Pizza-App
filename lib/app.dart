import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'app_view.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'package:user_repository/cart_repository.dart';
import 'package:user_repository/order_repository.dart';
import 'package:user_repository/weather_repository.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(
          value: userRepository,
        ),
        RepositoryProvider<PizzaRepo>(
          create: (context) => FirebasePizzaRepo(),
        ),
        RepositoryProvider<WeatherRepository>(
          create: (context) => WeatherRepository(),
        ),
        RepositoryProvider<OrderRepo>(
          create: (context) => FirebaseOrderRepo(),
        ),
        RepositoryProvider<CartRepo>(
          create: (context) => FirebaseCartRepo(),
        ),
      ],
      child: BlocProvider<AuthenticationBloc>(
        create: (context) => AuthenticationBloc(
          userRepository: context.read<UserRepository>(),
        ),
        child: const MyAppView(),
      ),
    );
  }
}