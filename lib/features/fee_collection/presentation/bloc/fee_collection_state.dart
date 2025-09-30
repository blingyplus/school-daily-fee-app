import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/fee_collection.dart';

abstract class FeeCollectionState extends Equatable {
  const FeeCollectionState();

  @override
  List<Object?> get props => [];
}

class FeeCollectionInitial extends FeeCollectionState {}

class FeeCollectionLoading extends FeeCollectionState {}

class FeeCollectionLoaded extends FeeCollectionState {
  final List<FeeCollection> collections;
  final DateTime date;
  final String? studentId;

  const FeeCollectionLoaded({
    required this.collections,
    required this.date,
    this.studentId,
  });

  @override
  List<Object?> get props => [collections, date, studentId];

  FeeCollectionLoaded copyWith({
    List<FeeCollection>? collections,
    DateTime? date,
    String? studentId,
  }) {
    return FeeCollectionLoaded(
      collections: collections ?? this.collections,
      date: date ?? this.date,
      studentId: studentId ?? this.studentId,
    );
  }
}

class FeeCollectionError extends FeeCollectionState {
  final String message;

  const FeeCollectionError(this.message);

  @override
  List<Object?> get props => [message];
}

class FeeCollectionOperationSuccess extends FeeCollectionState {
  final String message;
  final List<FeeCollection> collections;

  const FeeCollectionOperationSuccess({
    required this.message,
    required this.collections,
  });

  @override
  List<Object?> get props => [message, collections];
}

class FeeCollectionOperationLoading extends FeeCollectionState {}

class ReceiptNumberGenerated extends FeeCollectionState {
  final String receiptNumber;

  const ReceiptNumberGenerated(this.receiptNumber);

  @override
  List<Object?> get props => [receiptNumber];
}
