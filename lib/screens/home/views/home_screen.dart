import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/cart/cart_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';
import 'package:pizza_app/screens/home/views/details_screen.dart';
import 'package:pizza_app/screens/home/views/cart_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:pizza_app/screens/home/blocs/weather/weather_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DietaryFilter _currentDietaryFilter = DietaryFilter.all;
  SpicyFilter _currentSpicyFilter = SpicyFilter.all;

  Widget _buildFilterButton({
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon, size: 16, color: isActive ? Colors.white : Theme.of(context).colorScheme.primary) : const SizedBox.shrink(),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Theme.of(context).colorScheme.primary : Colors.white,
          foregroundColor: isActive ? Colors.white : Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Row(
          children: [
            Image.asset('assets/8.png', scale: 14),
            const SizedBox(width: 8),
            const Text(
              'PIZZA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
            )
          ],
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              int itemCount = 0;
              if (cartState is CartLoaded) {
                itemCount = cartState.items.fold(0, (sum, item) => sum + item.quantity);
              }
              return Badge(
                label: Text('$itemCount'),
                isLabelVisible: itemCount > 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  icon: const Icon(CupertinoIcons.cart)
                ),
              );
            },
          ),
          IconButton(
              onPressed: () {
                context.read<SignInBloc>().add(SignOutRequired());
              },
              icon: const Icon(CupertinoIcons.arrow_right_to_line)),
        ],
      ),
      body: Column(
      children: [
          // Weather
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, weatherState) {
              if (weatherState is WeatherLoading) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                );
              }
              if (weatherState is WeatherLoaded) {
                final weather = weatherState.weather;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (weather.weatherIconUrl != null)
                        Image.network(weather.weatherIconUrl!, width: 50, height: 50),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.name ?? "City"}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (weather.main?.temp != null)
                            Text(
                              '${weather.main!.temp!.toStringAsFixed(1)}°C',
                              style: const TextStyle(fontSize: 16),
                            ),
                          if (weather.weatherDescription != null)
                             Text(
                              '${weather.weatherDescription}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              if (weatherState is WeatherError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Weather: ${weatherState.message}', style: const TextStyle(color: Colors.red)),
                );
              }
              return const SizedBox.shrink();
            },
          ),

         Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: BlocBuilder<GetPizzaBloc, GetPizzaState>(
                builder: (context, pizzaState) {
                  if (pizzaState is GetPizzaSuccess) {
                    _currentDietaryFilter = pizzaState.activeDietaryFilter;
                    _currentSpicyFilter = pizzaState.activeSpicyFilter;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterButton(
                        label: 'All Food',
                        isActive: _currentDietaryFilter == DietaryFilter.all && _currentSpicyFilter == SpicyFilter.all,
                        onPressed: () {
                          setState(() {
                            _currentDietaryFilter = DietaryFilter.all;
                            _currentSpicyFilter = SpicyFilter.all;
                          });
                          context.read<GetPizzaBloc>().add(LoadPizzas(
                            dietaryFilter: _currentDietaryFilter,
                            spicyFilter: _currentSpicyFilter,
                          ));
                        },
                      ),
                      _buildFilterButton(
                        label: 'Veg',
                        icon: Icons.eco,
                        isActive: _currentDietaryFilter == DietaryFilter.veg,
                        onPressed: () {
                          setState(() {
                             _currentDietaryFilter = _currentDietaryFilter == DietaryFilter.veg ? DietaryFilter.all : DietaryFilter.veg;
                          });
                           context.read<GetPizzaBloc>().add(LoadPizzas(
                            dietaryFilter: _currentDietaryFilter,
                            spicyFilter: _currentSpicyFilter,
                          ));
                        },
                      ),
                      _buildFilterButton(
                        label: 'Non-Veg',
                        icon: Icons.kebab_dining,
                        isActive: _currentDietaryFilter == DietaryFilter.nonVeg,
                        onPressed: () {
                           setState(() {
                            _currentDietaryFilter = _currentDietaryFilter == DietaryFilter.nonVeg ? DietaryFilter.all : DietaryFilter.nonVeg;
                           });
                           context.read<GetPizzaBloc>().add(LoadPizzas(
                            dietaryFilter: _currentDietaryFilter,
                            spicyFilter: _currentSpicyFilter,
                          ));
                        },
                      ),
                      const SizedBox(width: 10), // Spacer
                       _buildFilterButton(
                        label: '🌶️ Bland',
                        isActive: _currentSpicyFilter == SpicyFilter.bland,
                        onPressed: () {
                           setState(() {
                             _currentSpicyFilter = _currentSpicyFilter == SpicyFilter.bland ? SpicyFilter.all : SpicyFilter.bland;
                           });
                           context.read<GetPizzaBloc>().add(LoadPizzas(
                            dietaryFilter: _currentDietaryFilter,
                            spicyFilter: _currentSpicyFilter,
                          ));
                        },
                      ),
                       _buildFilterButton(
                        label: '🌶️ Balance',
                        isActive: _currentSpicyFilter == SpicyFilter.balance,
                        onPressed: () {
                           setState(() {
                            _currentSpicyFilter = _currentSpicyFilter == SpicyFilter.balance ? SpicyFilter.all : SpicyFilter.balance;
                           });
                           context.read<GetPizzaBloc>().add(LoadPizzas(
                            dietaryFilter: _currentDietaryFilter,
                            spicyFilter: _currentSpicyFilter,
                          ));
                        },
                      ),
                       _buildFilterButton(
                        label: '🌶️ Spicy',
                        isActive: _currentSpicyFilter == SpicyFilter.spicy,
                        onPressed: () {
                           setState(() {
                            _currentSpicyFilter = _currentSpicyFilter == SpicyFilter.spicy ? SpicyFilter.all : SpicyFilter.spicy;
                           });
                           context.read<GetPizzaBloc>().add(LoadPizzas(
                            dietaryFilter: _currentDietaryFilter,
                            spicyFilter: _currentSpicyFilter,
                          ));
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

      Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GetPizzaBloc, GetPizzaState>(
          builder: (context, pizzaState) {
            if (pizzaState is GetPizzaSuccess) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 9 / 16),
                itemCount: pizzaState.filteredPizzas.length,
                itemBuilder: (context, int i) {
                  final Pizza currentPizza = pizzaState.filteredPizzas[i];

                  return Material(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (newRouteContext) {
                              return DetailsScreen(currentPizza);
                            },
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(currentPizza.picture),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: currentPizza.isVeg
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text(
                                      currentPizza.isVeg
                                          ? "VEG"
                                          : "NON-VEG",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: Text(
                                      currentPizza.spicy == 1
                                          ? "🌶️ BLAND"
                                          : currentPizza.spicy == 2
                                              ? "🌶️ BALANCE"
                                              : "🌶️ SPICY",
                                      style: TextStyle(
                                          color: currentPizza.spicy == 1
                                              ? Colors.green
                                              : currentPizza.spicy == 2
                                                  ? Colors.orange
                                                  : Colors.redAccent,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              currentPizza.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              currentPizza.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "\$${(currentPizza.price - (currentPizza.price * (currentPizza.discount) / 100.0)).toStringAsFixed(2)}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "\$${currentPizza.price.toStringAsFixed(2)}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        context
                                            .read<CartBloc>()
                                            .add(AddItemToCart(currentPizza));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  '${currentPizza.name} added to cart!'),
                                                  duration: const Duration(seconds: 2),
                                                  backgroundColor: Colors.green,),
                                        );
                                      },
                                      icon: const Icon(
                                          CupertinoIcons.add_circled_solid))
                                ],
                              ))
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (pizzaState is GetPizzaLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const Center(
                child: Text("An error has occurred or no pizzas loaded."),
              );
            }
          },
        ),
      ),
    ),
    ],
    ),
  );
}
}