import 'package:equatable/equatable.dart';

/// Base entity class for domain layer
/// All domain entities should extend this class
abstract class Entity extends Equatable {
  const Entity();

  @override
  List<Object?> get props => [];
}









