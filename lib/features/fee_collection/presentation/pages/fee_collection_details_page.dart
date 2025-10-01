import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/domain/entities/fee_collection.dart';
import '../../../../core/constants/app_constants.dart';

class FeeCollectionDetailsPage extends StatelessWidget {
  final FeeCollection collection;

  const FeeCollectionDetailsPage({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Collection Details'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt Header
            _buildReceiptHeader(context),
            SizedBox(height: 24.h),

            // Amount Card
            _buildAmountCard(context),
            SizedBox(height: 24.h),

            // Fee Details
            _buildSectionTitle(context, 'Fee Details'),
            SizedBox(height: 12.h),
            _buildInfoCard(context, [
              _buildInfoRow(
                  context, 'Fee Type', collection.feeType.name.toUpperCase()),
              _buildInfoRow(context, 'Payment Method',
                  collection.paymentMethod.name.toUpperCase()),
              _buildInfoRow(
                  context, 'Receipt Number', collection.receiptNumber),
            ]),
            SizedBox(height: 16.h),

            // Student Details
            _buildSectionTitle(context, 'Student Information'),
            SizedBox(height: 12.h),
            _buildInfoCard(context, [
              _buildInfoRow(context, 'Student ID', collection.studentId),
            ]),
            SizedBox(height: 16.h),

            // Payment Details
            _buildSectionTitle(context, 'Payment Details'),
            SizedBox(height: 12.h),
            _buildInfoCard(context, [
              _buildInfoRow(
                  context, 'Payment Date', _formatDate(collection.paymentDate)),
              _buildInfoRow(context, 'Coverage Start',
                  _formatDate(collection.coverageStartDate)),
              _buildInfoRow(context, 'Coverage End',
                  _formatDate(collection.coverageEndDate)),
              _buildInfoRow(
                  context, 'Days Covered', '${collection.coverageDays}'),
              _buildInfoRow(context, 'Collected At',
                  _formatDateTime(collection.collectedAt)),
            ]),
            SizedBox(height: 16.h),

            // Sync Status
            _buildSectionTitle(context, 'Sync Status'),
            SizedBox(height: 12.h),
            _buildSyncStatusCard(context),
            SizedBox(height: 16.h),

            // Notes
            if (collection.notes != null && collection.notes!.isNotEmpty) ...[
              _buildSectionTitle(context, 'Notes'),
              SizedBox(height: 12.h),
              _buildInfoCard(context, [
                _buildInfoRow(context, '', collection.notes!),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 48.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            'Receipt',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            collection.receiptNumber,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Amount Paid',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            '₵ ${collection.amountPaid.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120.w,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        label.isEmpty ? FontWeight.normal : FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (collection.syncStatus) {
      case 'synced':
        statusColor = Colors.green;
        statusIcon = Icons.cloud_done;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.cloud_upload;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.cloud_off;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.cloud_queue;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 32.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.syncStatus.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                  if (collection.syncedAt != null)
                    Text(
                      'Synced at ${_formatDateTime(collection.syncedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
