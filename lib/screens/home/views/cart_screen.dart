import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/screens/home/blocs/cart/cart_bloc.dart';
import 'package:pizza_app/screens/home/blocs/order/order_bloc.dart';
import 'package:pizza_app/screens/home/views/order_history_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Order History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, orderState) {
          if (orderState is OrderPlacementSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order placed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (orderState is OrderPlacementFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order failed: ${orderState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (orderState is OrderPlacementInProgress) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Placing your order...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text(
                  'Your cart is empty!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            final activeCartItems = state.items.where((item) => item.quantity > 0).toList();
            final bool canCheckout = activeCartItems.isNotEmpty;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      bool isQuantityZero = item.quantity == 0;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: isQuantityZero ? Colors.grey.shade300 : null,
                        child: ListTile(
                          leading: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(item.picture, fit: BoxFit.cover),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Quantity: ${item.quantity}\nPrice: \$${item.price.toStringAsFixed(2)} each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: isQuantityZero ? Colors.grey : Colors.orange,
                                ),
                                onPressed: isQuantityZero 
                                    ? null
                                    : () {
                                        context.read<CartBloc>().add(DecreaseItemQuantity(item.id));
                                      },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                onPressed: () {
                                    context.read<CartBloc>().add(IncreaseItemQuantity(item.id));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () {
                                    context.read<CartBloc>().add(RemoveItemFromCart(item.id));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('\$${state.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                           onPressed: !canCheckout
                              ? null 
                              : () {
                                  if (state is CartLoaded && canCheckout) {
                                      context.read<OrderBloc>().add(
                                            PlaceNewOrder(
                                              cartItems: activeCartItems,
                                              totalPrice: state.totalPrice,
                                            ),
                                          );
                                    }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                          child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Something went wrong with the cart.'));
        },
      ),
    )
    );
  }
}