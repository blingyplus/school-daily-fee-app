import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/fee_collection.dart';

class FeeCollectionList extends StatelessWidget {
  final List<FeeCollection> collections;
  final VoidCallback onRefresh;

  const FeeCollectionList({
    super.key,
    required this.collections,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding.w,
          vertical: AppConstants.smallPadding.h,
        ),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _buildCollectionCard(context, collection),
          );
        },
      ),
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

  Widget _buildCollectionCard(BuildContext context, FeeCollection collection) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          // TODO: Show fee collection details
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
                          collection.receiptNumber,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'ID: ${collection.studentId}',
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
                  Text(
                    '${_formatDate(collection.paymentDate)} • ${collection.feeType.name} • ${collection.paymentMethod.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}
