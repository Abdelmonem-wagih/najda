import 'package:equatable/equatable.dart';

class FirstAidItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String heroImage;
  final List<FirstAidStep> steps;
  final String urgencyLevel;

  const FirstAidItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.heroImage,
    required this.steps,
    required this.urgencyLevel,
  });

  @override
  List<Object?> get props => [id, title, subtitle, heroImage, steps, urgencyLevel];
}

class FirstAidStep extends Equatable {
  final int number;
  final String instruction;
  final String? imageUrl;

  const FirstAidStep({
    required this.number,
    required this.instruction,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [number, instruction, imageUrl];
}
