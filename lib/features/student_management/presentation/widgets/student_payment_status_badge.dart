import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/domain/entities/fee_collection.dart';

/// Badge showing if student has already paid for today
class StudentPaymentStatusBadge extends StatelessWidget {
  final Map<FeeType, bool> paymentStatus;

  const StudentPaymentStatusBadge({
    super.key,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final canteenPaid = paymentStatus[FeeType.canteen] ?? false;
    final transportPaid = paymentStatus[FeeType.transport] ?? false;

    if (!canteenPaid && !transportPaid) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4.w,
      children: [
        if (canteenPaid)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant, size: 10.sp, color: Colors.orange),
                SizedBox(width: 2.w),
                Icon(Icons.check, size: 10.sp, color: Colors.orange),
              ],
            ),
          ),
        if (transportPaid)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_bus, size: 10.sp, color: Colors.blue),
                SizedBox(width: 2.w),
                Icon(Icons.check, size: 10.sp, color: Colors.blue),
              ],
            ),
          ),
      ],
    );
  }
}
