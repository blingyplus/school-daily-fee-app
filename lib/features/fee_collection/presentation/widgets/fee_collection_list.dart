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
        padding: EdgeInsets.all(AppConstants.defaultPadding.w),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
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
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt: ${collection.receiptNumber}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Student ID: ${collection.studentId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₵${collection.amountPaid.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Fee Type',
                    collection.feeType.name.toUpperCase(),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Payment Method',
                    collection.paymentMethod.name.toUpperCase(),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Coverage',
                    '${_formatDate(collection.coverageStartDate)} - ${_formatDate(collection.coverageEndDate)}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Days',
                    '${collection.coverageDays}',
                  ),
                ),
              ],
            ),

            if (collection.notes != null && collection.notes!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildDetailItem(
                context,
                'Notes',
                collection.notes!,
              ),
            ],

            SizedBox(height: 16.h),

            // Footer
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Collected at ${_formatTime(collection.collectedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getSyncStatusColor(collection.syncStatus)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    collection.syncStatus.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getSyncStatusColor(collection.syncStatus),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
