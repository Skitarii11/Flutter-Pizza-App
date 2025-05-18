import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/src/oder_repo.dart';
import 'package:user_repository/src/models/order_model.dart' as my_order_prefix;

class FirebaseOrderRepo implements OrderRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<my_order_prefix.Order> get _ordersCollection =>
      _firestore.collection('orders').withConverter<my_order_prefix.Order>(
            fromFirestore: my_order_prefix.Order.fromFirestore,
            toFirestore: (my_order_prefix.Order order, _) => order.toFirestore(),
          );

  @override
  Future<void> placeOrder(my_order_prefix.Order order) async {
    await _ordersCollection.add(order);
  }

  @override
  Stream<List<my_order_prefix.Order>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}