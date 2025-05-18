import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/cart_repository.dart';
import 'package:user_repository/order_repository.dart' as app_order;

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final app_order.OrderRepo _orderRepo;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _ordersSubscription;
  User? _currentUser;

  OrderBloc({
    required app_order.OrderRepo orderRepo,
    required FirebaseAuth firebaseAuth,
  })  : _orderRepo = orderRepo,
        _firebaseAuth = firebaseAuth,
        super(OrderInitial()) {
    
    _firebaseAuth.authStateChanges().listen((user) {
      _currentUser = user;
      if (_currentUser != null) {
        add(LoadUserOrders()); // Load orders when user logs in
      } else {
        _ordersSubscription?.cancel();
        emit(OrderInitial()); // Reset state or emit UserOrdersLoaded([])
      }
    });
    
    on<PlaceNewOrder>(_onPlaceNewOrder);
    on<LoadUserOrders>(_onLoadUserOrders);
    on<_UserOrdersUpdated>(_onUserOrdersUpdated);
    on<_UserOrdersStreamErrorOccurred>(_onUserOrdersStreamErrorOccurred);
  }

  Future<void> _onPlaceNewOrder(PlaceNewOrder event, Emitter<OrderState> emit) async {
    if (_currentUser == null) {
      emit(const OrderPlacementFailure("User not authenticated."));
      return;
    }
    emit(OrderPlacementInProgress());
    try {
      final List<app_order.OrderItem> orderItems = event.cartItems
          .map((cartItem) => app_order.OrderItem.fromCartItem(cartItem))
          .toList();

      final newOrder = app_order.Order(
        userId: _currentUser!.uid,
        items: orderItems,
        totalPrice: event.totalPrice,
        orderDate: Timestamp.now(),
      );

      await _orderRepo.placeOrder(newOrder);
      emit(const OrderPlacementSuccess("dummy_order_id_placeholder"));
    } catch (e) {
      emit(OrderPlacementFailure(e.toString()));
    }
  }

  void _onLoadUserOrders(LoadUserOrders event, Emitter<OrderState> emit) {
    if (_currentUser == null) {
      return;
    }
    if (state is! UserOrdersLoaded && state is! UserOrdersLoading) {
       emit(UserOrdersLoading());
    }
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderRepo.getUserOrders(_currentUser!.uid).listen(
      (orders) => add(_UserOrdersUpdated(orders)),
      onError: (error) => add(_UserOrdersStreamErrorOccurred(error.toString())),
    );
  }

  void _onUserOrdersUpdated(_UserOrdersUpdated event, Emitter<OrderState> emit) {
    emit(UserOrdersLoaded(event.orders));
  }

  void _onUserOrdersStreamErrorOccurred(_UserOrdersStreamErrorOccurred event, Emitter<OrderState> emit) {
    emit(UserOrdersError(event.error));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
