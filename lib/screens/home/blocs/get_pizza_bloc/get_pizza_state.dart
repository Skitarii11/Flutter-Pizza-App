part of 'get_pizza_bloc.dart';

abstract class GetPizzaState extends Equatable {
  const GetPizzaState();

  @override
  List<Object?> get props => [];
}

class GetPizzaInitial extends GetPizzaState {}

class GetPizzaLoading extends GetPizzaState {}

class GetPizzaSuccess extends GetPizzaState {
  final List<Pizza> allPizzas;
  final List<Pizza> filteredPizzas;
  final DietaryFilter activeDietaryFilter;
  final SpicyFilter activeSpicyFilter;

  const GetPizzaSuccess({
    required this.allPizzas,
    required this.filteredPizzas,
    this.activeDietaryFilter = DietaryFilter.all,
    this.activeSpicyFilter = SpicyFilter.all,
  });

  GetPizzaSuccess copyWith({
    List<Pizza>? allPizzas,
    List<Pizza>? filteredPizzas,
    DietaryFilter? activeDietaryFilter,
    SpicyFilter? activeSpicyFilter,
  }) {
    return GetPizzaSuccess(
      allPizzas: allPizzas ?? this.allPizzas,
      filteredPizzas: filteredPizzas ?? this.filteredPizzas,
      activeDietaryFilter: activeDietaryFilter ?? this.activeDietaryFilter,
      activeSpicyFilter: activeSpicyFilter ?? this.activeSpicyFilter,
    );
  }

  @override
  List<Object?> get props => [allPizzas, filteredPizzas, activeDietaryFilter, activeSpicyFilter];
}

class GetPizzaFailure extends GetPizzaState {
  final String? error;
  const GetPizzaFailure([this.error]);

  @override
  List<Object?> get props => [error];
}