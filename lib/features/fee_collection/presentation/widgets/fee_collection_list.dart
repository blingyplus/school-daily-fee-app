import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/fee_collection.dart';
import '../../../../shared/domain/entities/student.dart';
import '../pages/fee_collection_details_page.dart';
import '../../../student_management/domain/usecases/get_students_usecase.dart';
import '../../../../core/di/injection.dart';

class FeeCollectionList extends StatefulWidget {
  final List<FeeCollection> collections;
  final VoidCallback onRefresh;
  final String schoolId;

  const FeeCollectionList({
    super.key,
    required this.collections,
    required this.onRefresh,
    required this.schoolId,
  });

  @override
  State<FeeCollectionList> createState() => _FeeCollectionListState();
}

class _FeeCollectionListState extends State<FeeCollectionList> {
  final Map<String, Student> _studentsCache = {};
  late final GetStudentsUseCase _getStudentsUseCase;
  bool _isLoadingStudents = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getStudentsUseCase = getIt<GetStudentsUseCase>();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoadingStudents = true;
    });

    try {
      final students = await _getStudentsUseCase(widget.schoolId);
      setState(() {
        _studentsCache.clear();
        for (final student in students) {
          _studentsCache[student.id] = student;
        }
        _isLoadingStudents = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStudents = false;
      });
    }
  }

  List<FeeCollection> get _filteredCollections {
    if (_searchQuery.isEmpty) return widget.collections;

    return widget.collections.where((collection) {
      final student = _studentsCache[collection.studentId];
      if (student == null) return false;

      final query = _searchQuery.toLowerCase();
      return student.fullName.toLowerCase().contains(query) ||
          student.studentId.toLowerCase().contains(query) ||
          collection.receiptNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCollections = _filteredCollections;

    return Column(
      children: [
        // Search Bar
        if (widget.collections.isNotEmpty && _studentsCache.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.defaultPadding.w,
              AppConstants.defaultPadding.h,
              AppConstants.defaultPadding.w,
              AppConstants.smallPadding.h,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by student name or receipt...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

        // Collections List
        Expanded(
          child: filteredCollections.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    widget.onRefresh();
                    await _loadStudents();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding.w,
                      vertical: AppConstants.smallPadding.h,
                    ),
                    itemCount: filteredCollections.length,
                    itemBuilder: (context, index) {
                      final collection = filteredCollections[index];
                      final student = _studentsCache[collection.studentId];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child:
                            _buildCollectionCard(context, collection, student),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'No fee collections found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Start collecting fees by tapping the + button',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(
      BuildContext context, FeeCollection collection, Student? student) {
    final coveragePeriod = _getCoveragePeriodText(collection.coverageDays);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeeCollectionDetailsPage(
                collection: collection,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color:
                          _getFeeTypeColor(collection.feeType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getFeeTypeIcon(collection.feeType),
                      color: _getFeeTypeColor(collection.feeType),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student?.fullName ?? 'Loading...',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          student != null
                              ? 'ID: ${student.studentId}'
                              : collection.receiptNumber,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₵${collection.amountPaid.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getSyncStatusColor(collection.syncStatus)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          collection.syncStatus.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    _getSyncStatusColor(collection.syncStatus),
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Compact Details Row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      '${_formatDate(collection.paymentDate)} • ${coveragePeriod} • ${collection.feeType.name}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFeeTypeColor(FeeType feeType) {
    switch (feeType) {
      case FeeType.canteen:
        return Colors.orange;
      case FeeType.transport:
        return Colors.blue;
    }
  }

  IconData _getFeeTypeIcon(FeeType feeType) {
    switch (feeType) {
      case FeeType.canteen:
        return Icons.restaurant;
      case FeeType.transport:
        return Icons.directions_bus;
    }
  }

  Color _getSyncStatusColor(String syncStatus) {
    switch (syncStatus) {
      case 'synced':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getCoveragePeriodText(int days) {
    if (days == 1) return '1 day';
    if (days == 7) return '1 week';
    if (days == 14) return '2 weeks';
    if (days >= 28 && days <= 31) return '1 month';
    return '$days days';
  }
}
