part of 'cart_bloc.dart';

sealed class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object> get props => [];
}

final class CartLoading extends CartState {}
class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalPrice;

  const CartLoaded(this.items, {this.totalPrice = 0.0});

  factory CartLoaded.fromItems(List<CartItem> items) {
    double sum = 0;
    for (var item in items) {
      sum += item.price * item.quantity;
    }
    return CartLoaded(items, totalPrice: sum);
  }

  @override
  List<Object> get props => [items, totalPrice];
}
class CartError extends CartState {
  final String message;
  const CartError(this.message);
   @override
  List<Object> get props => [message];
}