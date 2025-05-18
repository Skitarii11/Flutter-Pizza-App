import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pizza_app/screens/home/blocs/order/order_bloc.dart';
import 'package:user_repository/order_repository.dart' as app_order;

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is UserOrdersLoading || state is OrderInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserOrdersError) {
            return Center(child: Text('Error fetching orders: ${state.error}'));
          }
          if (state is UserOrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(
                child: Text(
                  'You have no past orders.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final app_order.Order order = state.orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text(
                      'Order ID: ${order.id?.substring(0, 8) ?? 'N/A'}...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: ${DateFormat.yMMMd().add_jm().format(order.orderDate.toDate())}\n'
                      'Total: \$${order.totalPrice.toStringAsFixed(2)}\n'
                      'Status: ${order.status}',
                    ),
                    children: order.items.map((item) {
                      return ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(item.picture, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image)),
                        ),
                        title: Text(item.name),
                        subtitle: Text('Qty: ${item.quantity} - \$${item.priceAtCheckout.toStringAsFixed(2)} each'),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No orders found or an unknown state.'));
        },
      ),
    );
  }
}