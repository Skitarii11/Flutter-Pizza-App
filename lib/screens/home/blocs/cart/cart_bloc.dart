import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/cart_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepo _cartRepo;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _cartSubscription;
  User? _currentUser;

  CartBloc({required CartRepo cartRepo, required FirebaseAuth firebaseAuth})
      : _cartRepo = cartRepo,
        _firebaseAuth = firebaseAuth,
        super(CartLoading()) {
    
    _firebaseAuth.authStateChanges().listen((user) {
      _currentUser = user;
      if (_currentUser != null) {
        add(LoadCart());
      } else {
         _cartSubscription?.cancel();
         emit(CartLoaded.fromItems([]));
      }
    });

    on<LoadCart>(_onLoadCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<_CartUpdated>(_onCartUpdated);
    on<IncreaseItemQuantity>(_onIncreaseItemQuantity);
    on<DecreaseItemQuantity>(_onDecreaseItemQuantity);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
  }

  Future<void> _onIncreaseItemQuantity(IncreaseItemQuantity event, Emitter<CartState> emit) async {
    if (_currentUser == null) return;
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final itemToUpdate = currentState.items.firstWhere((item) => item.id == event.cartItemId, orElse: () => throw Exception("Item not found")); // Should not happen if UI is correct
      
      try {
        await _cartRepo.updateCartItemQuantity(_currentUser!.uid, event.cartItemId, itemToUpdate.quantity + 1);
      } catch (e) {
        emit(CartError("Failed to increase quantity: ${e.toString()}"));
      }
    }
  }

  Future<void> _onDecreaseItemQuantity(DecreaseItemQuantity event, Emitter<CartState> emit) async {
    if (_currentUser == null) return;
     if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final itemToUpdate = currentState.items.firstWhere((item) => item.id == event.cartItemId, orElse: () => throw Exception("Item not found"));

      try {
        await _cartRepo.updateCartItemQuantity(_currentUser!.uid, event.cartItemId, itemToUpdate.quantity - 1);
      } catch (e) {
        emit(CartError("Failed to decrease quantity: ${e.toString()}"));
      }
    }
  }

  Future<void> _onRemoveItemFromCart(RemoveItemFromCart event, Emitter<CartState> emit) async {
    if (_currentUser == null) return;
    try {
      await _cartRepo.removeCartItem(_currentUser!.uid, event.cartItemId);
    } catch (e) {
      emit(CartError("Failed to remove item: ${e.toString()}"));
    }
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    if (_currentUser == null) {
      emit(const CartError("User not authenticated."));
      return;
    }
    emit(CartLoading());
    _cartSubscription?.cancel();
    _cartSubscription = _cartRepo.getUserCart(_currentUser!.uid).listen(
      (items) => add(_CartUpdated(items)),
      onError: (error) => emit(CartError(error.toString())),
    );
  }

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
     if (_currentUser == null) {
      emit(const CartError("User not authenticated. Cannot add to cart."));
      return;
    }
    try {
      await _cartRepo.addPizzaToCart(_currentUser!.uid, event.pizza, event.quantity);
    } catch (e) {
      emit(CartError("Failed to add item: ${e.toString()}"));
    }
  }
  
  void _onCartUpdated(_CartUpdated event, Emitter<CartState> emit) {
    emit(CartLoaded.fromItems(event.cartItems));
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}
