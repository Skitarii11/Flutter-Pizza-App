import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart';

part 'get_pizza_event.dart';
part 'get_pizza_state.dart';

class GetPizzaBloc extends Bloc<GetPizzaEvent, GetPizzaState> {
  final PizzaRepo _pizzaRepository;
  List<Pizza> _masterPizzaList = [];

  GetPizzaBloc({required PizzaRepo pizzaRepository})
      : _pizzaRepository = pizzaRepository,
        super(GetPizzaInitial()) {
    on<LoadPizzas>(_onLoadPizzas);
  }

  Future<void> _onLoadPizzas(LoadPizzas event, Emitter<GetPizzaState> emit) async {
    if (_masterPizzaList.isEmpty) {
      emit(GetPizzaLoading());
      try {
        _masterPizzaList = await _pizzaRepository.getPizzas();
      } catch (e) {
        emit(GetPizzaFailure(e.toString()));
        return;
      }
    }

    // Apply filters
    List<Pizza> filteredList = List.from(_masterPizzaList);

    if (event.dietaryFilter == DietaryFilter.veg) {
      filteredList = filteredList.where((pizza) => pizza.isVeg).toList();
    } else if (event.dietaryFilter == DietaryFilter.nonVeg) {
      filteredList = filteredList.where((pizza) => !pizza.isVeg).toList();
    }

    if (event.spicyFilter == SpicyFilter.bland) {
      filteredList = filteredList.where((pizza) => pizza.spicy == 1).toList();
    } else if (event.spicyFilter == SpicyFilter.balance) {
      filteredList = filteredList.where((pizza) => pizza.spicy == 2).toList();
    } else if (event.spicyFilter == SpicyFilter.spicy) {
      filteredList = filteredList.where((pizza) => pizza.spicy == 3).toList();
    }

    emit(GetPizzaSuccess(
      allPizzas: _masterPizzaList,
      filteredPizzas: filteredList,
      activeDietaryFilter: event.dietaryFilter,
      activeSpicyFilter: event.spicyFilter,
    ));
  }
}
