import 'package:pizza_repository/pizza_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CartRepo {
  Stream<List<CartItem>> getUserCart(String userId);
  Future<void> addPizzaToCart(String userId, Pizza pizza, int quantity);
  Future<void> updateCartItemQuantity(String userId, String cartItemId, int newQuantity);
  Future<void> removeCartItem(String userId, String cartItemId);
  Future<void> clearCart(String userId);
}

class CartItem {
  final String id;
  final String pizzaId;
  final String name;
  final String picture;
  final double price;
  int quantity;
  final Timestamp addedAt;

  CartItem({
    required this.id,
    required this.pizzaId,
    required this.name,
    required this.picture,
    required this.price,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data()!;
    return CartItem(
      id: snapshot.id,
      pizzaId: data['pizzaId'],
      name: data['name'],
      picture: data['picture'],
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'],
      addedAt: data['addedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pizzaId': pizzaId,
      'name': name,
      'picture': picture,
      'price': price,
      'quantity': quantity,
      'addedAt': addedAt,
    };
  }
}