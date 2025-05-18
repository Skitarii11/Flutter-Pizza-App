import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/cart_repository.dart';

class OrderItem {
  final String pizzaId;
  final String name;
  final String picture;
  final double priceAtCheckout;
  final int quantity;

  OrderItem({
    required this.pizzaId,
    required this.name,
    required this.picture,
    required this.priceAtCheckout,
    required this.quantity,
  });

  // Create OrderItem from CartItem
  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      pizzaId: cartItem.pizzaId,
      name: cartItem.name,
      picture: cartItem.picture,
      priceAtCheckout: cartItem.price,
      quantity: cartItem.quantity,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pizzaId': pizzaId,
      'name': name,
      'picture': picture,
      'priceAtCheckout': priceAtCheckout,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      pizzaId: data['pizzaId'] as String,
      name: data['name'] as String,
      picture: data['picture'] as String,
      priceAtCheckout: (data['priceAtCheckout'] as num).toDouble(),
      quantity: data['quantity'] as int,
    );
  }
}

class Order {
  final String? id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final Timestamp orderDate;
  final String status;

  Order({
    this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    this.status = 'pending',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'totalPrice': totalPrice,
      'orderDate': orderDate,
      'status': status,
    };
  }

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data()!;
    return Order(
      id: snapshot.id,
      userId: data['userId'] as String,
      items: (data['items'] as List<dynamic>)
          .map((itemData) => OrderItem.fromFirestore(itemData as Map<String, dynamic>))
          .toList(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      orderDate: data['orderDate'] as Timestamp,
      status: data['status'] as String? ?? 'pending',
    );
  }
}