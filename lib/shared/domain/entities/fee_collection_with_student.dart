import 'package:equatable/equatable.dart';
import 'fee_collection.dart';
import 'student.dart';

class FeeCollectionWithStudent extends Equatable {
  final FeeCollection feeCollection;
  final Student student;

  const FeeCollectionWithStudent({
    required this.feeCollection,
    required this.student,
  });

  String get coveragePeriodText {
    final days = feeCollection.coverageDays;
    if (days == 1) return '1 day';
    if (days == 7) return '1 week';
    if (days == 14) return '2 weeks';
    if (days >= 28 && days <= 31) return '1 month';
    return '$days days';
  }

  @override
  List<Object?> get props => [feeCollection, student];
}
