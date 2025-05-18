import 'package:user_repository/src/models/order_model.dart';

abstract class OrderRepo {
  Future<void> placeOrder(Order order);
  Stream<List<Order>> getUserOrders(String userId);
}