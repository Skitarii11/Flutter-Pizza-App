part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}
class AddItemToCart extends CartEvent {
  final Pizza pizza;
  final int quantity;
  const AddItemToCart(this.pizza, {this.quantity = 1});
  @override
  List<Object?> get props => [pizza, quantity];
}

class _CartUpdated extends CartEvent {
  final List<CartItem> cartItems;
  const _CartUpdated(this.cartItems);
   @override
  List<Object?> get props => [cartItems];
}

class IncreaseItemQuantity extends CartEvent {
  final String cartItemId;

  const IncreaseItemQuantity(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class DecreaseItemQuantity extends CartEvent {
  final String cartItemId;

  const DecreaseItemQuantity(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class RemoveItemFromCart extends CartEvent {
  final String cartItemId;

  const RemoveItemFromCart(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}