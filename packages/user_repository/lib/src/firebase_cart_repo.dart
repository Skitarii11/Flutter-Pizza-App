import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/src/cart_repo.dart';

class FirebaseCartRepo implements CartRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<CartItem> _userCartCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .withConverter<CartItem>(
          fromFirestore: CartItem.fromFirestore,
          toFirestore: (CartItem item, _) => item.toFirestore(),
        );
  }

  @override
  Stream<List<CartItem>> getUserCart(String userId) {
    return _userCartCollection(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> addPizzaToCart(String userId, Pizza pizza, int quantity) async {
    final cartItemRef = _userCartCollection(userId).doc(pizza.pizzaId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartItemRef);

      if (snapshot.exists) {
        final existingItem = snapshot.data()!;
        transaction.update(cartItemRef, {'quantity': existingItem.quantity + quantity});
      } else {
        final newItem = CartItem(
          id: pizza.pizzaId,
          pizzaId: pizza.pizzaId,
          name: pizza.name,
          picture: pizza.picture,
          price: pizza.price - (pizza.price * pizza.discount / 100),
          quantity: quantity,
          addedAt: Timestamp.now(),
        );
        transaction.set(cartItemRef, newItem);
      }
    });
  }

  @override
  Future<void> updateCartItemQuantity(String userId, String cartItemId, int newQuantity) async {
    final quantityToSet = newQuantity < 0 ? 0 : newQuantity;

    await _userCartCollection(userId).doc(cartItemId).update({'quantity': quantityToSet});
  }

  @override
  Future<void> removeCartItem(String userId, String cartItemId) async {
    await _userCartCollection(userId).doc(cartItemId).delete();
  }

  @override
  Future<void> clearCart(String userId) async {
    final cartSnap = await _userCartCollection(userId).get();
    WriteBatch batch = _firestore.batch();
    for (var doc in cartSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}