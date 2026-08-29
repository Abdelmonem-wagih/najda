import 'package:equatable/equatable.dart';
import '../../domain/entities/first_aid_item.dart';

abstract class FirstAidState extends Equatable {
  const FirstAidState();

  @override
  List<Object?> get props => [];
}

class FirstAidInitial extends FirstAidState {}

class FirstAidLoading extends FirstAidState {}

class FirstAidLoaded extends FirstAidState {
  final List<FirstAidItem> items;
  final String query;

  const FirstAidLoaded({required this.items, this.query = ''});

  List<FirstAidItem> get filteredItems => items
      .where((e) => e.title.contains(query) || e.subtitle.contains(query))
      .toList();

  @override
  List<Object?> get props => [items, query];
}

class FirstAidError extends FirstAidState {
  final String message;

  const FirstAidError(this.message);

  @override
  List<Object?> get props => [message];
}
