part of 'get_pizza_bloc.dart';

sealed class GetPizzaEvent extends Equatable {
  const GetPizzaEvent();

  @override
  List<Object?> get props => [];
}

enum DietaryFilter { all, veg, nonVeg }
enum SpicyFilter { all, bland, balance, spicy }

class LoadPizzas extends GetPizzaEvent {
  final DietaryFilter dietaryFilter;
  final SpicyFilter spicyFilter;

  const LoadPizzas({
    this.dietaryFilter = DietaryFilter.all,
    this.spicyFilter = SpicyFilter.all,
  });

  @override
  List<Object?> get props => [dietaryFilter, spicyFilter];
}

class GetPizza extends GetPizzaEvent{}