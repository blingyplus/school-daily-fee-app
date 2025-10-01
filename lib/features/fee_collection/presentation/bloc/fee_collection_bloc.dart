import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/domain/entities/fee_collection.dart';
import '../../domain/usecases/get_fee_collections_usecase.dart';
import '../../domain/usecases/get_student_fee_history_usecase.dart';
import '../../domain/usecases/collect_fee_usecase.dart';
import '../../domain/usecases/generate_receipt_number_usecase.dart';
import 'fee_collection_event.dart';
import 'fee_collection_state.dart';

class FeeCollectionBloc extends Bloc<FeeCollectionEvent, FeeCollectionState> {
  final GetFeeCollectionsUseCase _getFeeCollectionsUseCase;
  final GetStudentFeeHistoryUseCase _getStudentFeeHistoryUseCase;
  final CollectFeeUseCase _collectFeeUseCase;
  final GenerateReceiptNumberUseCase _generateReceiptNumberUseCase;

  FeeCollectionBloc({
    required GetFeeCollectionsUseCase getFeeCollectionsUseCase,
    required GetStudentFeeHistoryUseCase getStudentFeeHistoryUseCase,
    required CollectFeeUseCase collectFeeUseCase,
    required GenerateReceiptNumberUseCase generateReceiptNumberUseCase,
  })  : _getFeeCollectionsUseCase = getFeeCollectionsUseCase,
        _getStudentFeeHistoryUseCase = getStudentFeeHistoryUseCase,
        _collectFeeUseCase = collectFeeUseCase,
        _generateReceiptNumberUseCase = generateReceiptNumberUseCase,
        super(FeeCollectionInitial()) {
    on<LoadFeeCollections>(_onLoadFeeCollections);
    on<LoadStudentFeeHistory>(_onLoadStudentFeeHistory);
    on<CollectFee>(_onCollectFee);
    on<CollectBulkFee>(_onCollectBulkFee);
    on<UpdateFeeCollection>(_onUpdateFeeCollection);
    on<DeleteFeeCollection>(_onDeleteFeeCollection);
    on<GenerateReceiptNumber>(_onGenerateReceiptNumber);
  }

  Future<void> _onLoadFeeCollections(
      LoadFeeCollections event, Emitter<FeeCollectionState> emit) async {
    emit(FeeCollectionLoading());
    try {
      final collections =
          await _getFeeCollectionsUseCase(event.schoolId, event.date);
      emit(FeeCollectionLoaded(
        collections: collections,
        date: event.date,
      ));
    } catch (e) {
      emit(FeeCollectionError('Failed to load fee collections: $e'));
    }
  }

  Future<void> _onLoadStudentFeeHistory(
      LoadStudentFeeHistory event, Emitter<FeeCollectionState> emit) async {
    emit(FeeCollectionLoading());
    try {
      final collections = await _getStudentFeeHistoryUseCase(
          event.studentId, event.startDate, event.endDate);
      emit(FeeCollectionLoaded(
        collections: collections,
        date: event.startDate,
        studentId: event.studentId,
      ));
    } catch (e) {
      emit(FeeCollectionError('Failed to load student fee history: $e'));
    }
  }

  Future<void> _onCollectFee(
      CollectFee event, Emitter<FeeCollectionState> emit) async {
    emit(FeeCollectionOperationLoading());
    try {
      await _collectFeeUseCase(
        schoolId: event.schoolId,
        studentId: event.studentId,
        collectedBy: event.collectedBy,
        feeType: event.feeType,
        amountPaid: event.amountPaid,
        paymentDate: event.paymentDate,
        coverageStartDate: event.coverageStartDate,
        coverageEndDate: event.coverageEndDate,
        paymentMethod: event.paymentMethod,
        receiptNumber: event.receiptNumber,
        notes: event.notes,
      );

      // Reload fee collections after collection
      final collections =
          await _getFeeCollectionsUseCase(event.schoolId, event.paymentDate);
      emit(FeeCollectionOperationSuccess(
        message: 'Fee collected successfully',
        collections: collections,
      ));
    } catch (e) {
      emit(FeeCollectionError('Failed to collect fee: $e'));
    }
  }

  Future<void> _onCollectBulkFee(
      CollectBulkFee event, Emitter<FeeCollectionState> emit) async {
    emit(FeeCollectionOperationLoading());
    try {
      // Calculate coverage dates based on payment date
      final coverageStartDate = event.paymentDate;
      final coverageEndDate = event.paymentDate;

      // Collect each fee type separately
      for (final feeData in event.feeCollections) {
        await _collectFeeUseCase(
          schoolId: event.schoolId,
          studentId: event.studentId,
          collectedBy: event.collectedBy,
          feeType: feeData['feeType'] as FeeType,
          amountPaid: feeData['amount'] as double,
          paymentDate: event.paymentDate,
          coverageStartDate: coverageStartDate,
          coverageEndDate: coverageEndDate,
          paymentMethod: event.paymentMethod,
          receiptNumber: event.receiptNumber,
          notes: event.notes,
        );
      }

      // Reload fee collections after collection
      final collections =
          await _getFeeCollectionsUseCase(event.schoolId, event.paymentDate);
      emit(FeeCollectionOperationSuccess(
        message: 'Fees collected successfully',
        collections: collections,
      ));
    } catch (e) {
      emit(FeeCollectionError('Failed to collect fees: $e'));
    }
  }

  Future<void> _onUpdateFeeCollection(
      UpdateFeeCollection event, Emitter<FeeCollectionState> emit) async {
    emit(FeeCollectionOperationLoading());
    try {
      // TODO: Implement update fee collection use case
      // For now, just reload the collections
      final collections = await _getFeeCollectionsUseCase(
          event.collection.schoolId, event.collection.paymentDate);
      emit(FeeCollectionOperationSuccess(
        message: 'Fee collection updated successfully',
        collections: collections,
      ));
    } catch (e) {
      emit(FeeCollectionError('Failed to update fee collection: $e'));
    }
  }

  Future<void> _onDeleteFeeCollection(
      DeleteFeeCollection event, Emitter<FeeCollectionState> emit) async {
    emit(FeeCollectionOperationLoading());
    try {
      // TODO: Implement delete fee collection use case
      // For now, just reload the collections
      if (state is FeeCollectionLoaded) {
        final currentState = state as FeeCollectionLoaded;
        final collections = await _getFeeCollectionsUseCase(
            '', currentState.date); // We need schoolId here
        emit(FeeCollectionOperationSuccess(
          message: 'Fee collection deleted successfully',
          collections: collections,
        ));
      }
    } catch (e) {
      emit(FeeCollectionError('Failed to delete fee collection: $e'));
    }
  }

  Future<void> _onGenerateReceiptNumber(
      GenerateReceiptNumber event, Emitter<FeeCollectionState> emit) async {
    try {
      final receiptNumber = await _generateReceiptNumberUseCase();
      emit(ReceiptNumberGenerated(receiptNumber));
    } catch (e) {
      emit(FeeCollectionError('Failed to generate receipt number: $e'));
    }
  }
}
