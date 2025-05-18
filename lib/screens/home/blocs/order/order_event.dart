part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object> get props => [];
}

class PlaceNewOrder extends OrderEvent {
  final List<CartItem> cartItems;
  final double totalPrice;

  const PlaceNewOrder({
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  List<Object> get props => [cartItems, totalPrice];
}

class LoadUserOrders extends OrderEvent {}

class _UserOrdersUpdated extends OrderEvent {
  final List<app_order.Order> orders;
  const _UserOrdersUpdated(this.orders);
  @override
  List<Object> get props => [orders];
}

class _UserOrdersStreamErrorOccurred extends OrderEvent {
  final String error;
  const _UserOrdersStreamErrorOccurred(this.error);

  @override
  List<Object> get props => [error];
}