part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}
class OrderPlacementInProgress extends OrderState {}
class OrderPlacementSuccess extends OrderState {
  final String orderId;
  const OrderPlacementSuccess(this.orderId);
   @override
  List<Object> get props => [orderId];
}
class OrderPlacementFailure extends OrderState {
  final String error;
  const OrderPlacementFailure(this.error);
  @override
  List<Object> get props => [error];
}

class UserOrdersLoading extends OrderState {}
class UserOrdersLoaded extends OrderState {
  final List<app_order.Order> orders;
  const UserOrdersLoaded(this.orders);
   @override
  List<Object> get props => [orders];
}
class UserOrdersError extends OrderState {
   final String error;
  const UserOrdersError(this.error);
  @override
  List<Object> get props => [error];
}