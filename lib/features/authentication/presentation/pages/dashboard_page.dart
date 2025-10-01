import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/sync/sync_engine.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../student_management/presentation/pages/students_list_page.dart';
import '../../../student_management/presentation/bloc/student_bloc.dart';
import '../../../attendance/presentation/pages/class_selection_page.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../fee_collection/presentation/pages/fee_collection_page.dart';
import '../../../fee_collection/presentation/bloc/fee_collection_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _isSyncing = false;
  SyncResult? _lastSyncResult;

  final List<Widget> _pages = [
    const DashboardHomePage(),
    const StudentsPage(),
    const AttendancePage(),
    const FeeCollectionTab(),
    const ReportsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToSyncStatus();
  }

  void _listenToSyncStatus() {
    final syncEngine = GetIt.instance<SyncEngine>();
    syncEngine.syncStream.listen((result) {
      if (mounted) {
        setState(() {
          _isSyncing = result.status == SyncStatus.syncing;
          if (result.status != SyncStatus.syncing) {
            _lastSyncResult = result;
            // Clear the result after 5 seconds
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  _lastSyncResult = null;
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.login,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          actions: [
            // Smart Sync Button - Handles everything intelligently with spinning animation
            IconButton(
              icon: _isSyncing
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.cloud_sync,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onPressed: _isSyncing ? null : () => _smartSync(context),
              tooltip: _isSyncing ? 'Syncing...' : 'Smart Sync',
            ),
            // Advanced Options Menu
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'More Options',
              onSelected: (value) {
                switch (value) {
                  case 'debug':
                    _debugDatabaseState(context);
                    break;
                  case 'reset_all':
                    _resetAllSyncRecords(context);
                    break;
                  case 'logout':
                    _showLogoutDialog(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'debug',
                  child: Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Debug Database'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'reset_all',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Reset Sync (DB Cleared)'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Sync Status Banner
            if (_isSyncing || _lastSyncResult != null)
              _buildSyncBanner(context),
            // Main content
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment),
              label: 'Fees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Students';
      case 2:
        return 'Attendance';
      case 3:
        return 'Fee Collection';
      case 4:
        return 'Reports';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildSyncBanner(BuildContext context) {
    Color backgroundColor;
    IconData icon;
    String message;
    Color textColor;

    if (_isSyncing) {
      backgroundColor = Colors.blue.shade50;
      icon = Icons.sync;
      message = 'Syncing data...';
      textColor = Colors.blue.shade900;
    } else if (_lastSyncResult != null) {
      switch (_lastSyncResult!.status) {
        case SyncStatus.success:
          backgroundColor = Colors.green.shade50;
          icon = Icons.check_circle;
          message =
              'Sync complete! ${_lastSyncResult!.recordsProcessed ?? 0} new records processed.';
          textColor = Colors.green.shade900;
          break;
        case SyncStatus.failed:
          backgroundColor = Colors.red.shade50;
          icon = Icons.error;
          message = 'Sync failed: ${_lastSyncResult!.message}';
          textColor = Colors.red.shade900;
          break;
        default:
          backgroundColor = Colors.orange.shade50;
          icon = Icons.warning;
          message = _lastSyncResult!.message ?? 'Sync status unknown';
          textColor = Colors.orange.shade900;
      }
    } else {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isSyncing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!_isSyncing && _lastSyncResult != null)
            IconButton(
              icon: Icon(Icons.close, color: textColor, size: 18),
              onPressed: () {
                setState(() {
                  _lastSyncResult = null;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  void _resetFailedSyncRecords(BuildContext context) async {
    try {
      print('🔄 Reset failed sync records triggered from dashboard');
      final syncEngine = GetIt.instance<SyncEngine>();
      await syncEngine.resetFailedSyncRecords();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed sync records reset to pending'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ Reset failed sync records failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetSyncedRecords(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Synced Records?'),
          content: const Text(
            'This will mark all synced records as pending. '
            'Use this when you have cleared the remote database. '
            'Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      print('🔄 Reset synced records triggered from dashboard');
      final syncEngine = GetIt.instance<SyncEngine>();
      await syncEngine.resetSyncedRecords();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Synced records reset to pending. Trigger a sync to re-upload.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Reset synced records failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetAllSyncRecords(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Database Cleared?'),
            ],
          ),
          content: const Text(
            'Use this ONLY when the remote database has been cleared.\n\n'
            'This will mark all local data for re-sync.\n\n'
            'After resetting, click the Smart Sync button to upload everything.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset & Re-sync'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      print('🔄 Reset all sync records triggered from dashboard');
      final syncEngine = GetIt.instance<SyncEngine>();
      await syncEngine.resetAllSyncRecords();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '✅ Sync reset complete. Now tap Smart Sync to upload all data.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Sync Now',
              textColor: Colors.white,
              onPressed: () => _smartSync(context),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Reset all sync records failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Smart Sync - ONE button to handle everything (non-blocking)
  void _smartSync(BuildContext context) async {
    try {
      print('🚀 Smart Sync triggered from dashboard');
      final syncEngine = GetIt.instance<SyncEngine>();

      // No blocking dialog - just start syncing
      // The banner will show the progress automatically via stream
      syncEngine.sync(SyncDirection.bidirectional);
    } catch (e) {
      print('❌ Smart sync failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _smartSync(context),
            ),
          ),
        );
      }
    }
  }

  void _debugDatabaseState(BuildContext context) async {
    try {
      print('🔍 Debug database state triggered from dashboard');
      final syncEngine = GetIt.instance<SyncEngine>();
      await syncEngine.debugDatabaseState();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database state logged to console'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('❌ Debug database state failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _triggerManualSync(BuildContext context) async {
    try {
      print('🔄 Manual sync triggered from dashboard');
      final syncEngine = GetIt.instance<SyncEngine>();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Syncing data...'),
            ],
          ),
        ),
      );

      // Trigger sync
      final result = await syncEngine.sync(SyncDirection.upload);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.status == SyncStatus.success
                  ? 'Sync completed successfully! ${result.recordsProcessed} records processed.'
                  : 'Sync failed: ${result.message}',
            ),
            backgroundColor:
                result.status == SyncStatus.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Manual sync failed: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.largePadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(context),
          SizedBox(height: 24.h),
          _buildQuickActions(context),
          SizedBox(height: 24.h),
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Students',
                '156',
                Icons.people,
                Colors.blue,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                context,
                'Present Today',
                '142',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Fees Collected',
                '₵2,340',
                Icons.payment,
                Colors.orange,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                context,
                'Pending Fees',
                '₵890',
                Icons.pending,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Mark Attendance',
                Icons.check_circle_outline,
                () {
                  Navigator.pushNamed(context, AppRouter.attendance);
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                context,
                'Collect Fees',
                Icons.payment,
                () {
                  Navigator.pushNamed(context, AppRouter.feeCollection);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Add Student',
                Icons.person_add,
                () {
                  Navigator.pushNamed(context, AppRouter.studentsList);
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionCard(
                context,
                'View Reports',
                Icons.analytics,
                () {
                  Navigator.pushNamed(context, AppRouter.reports);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                context,
                'John Doe paid canteen fee',
                '2 minutes ago',
                Icons.payment,
                Colors.green,
              ),
              Divider(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              _buildActivityItem(
                context,
                'Mary Smith marked present',
                '5 minutes ago',
                Icons.check_circle,
                Colors.blue,
              ),
              Divider(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              _buildActivityItem(
                context,
                'New student registered',
                '10 minutes ago',
                Icons.person_add,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Students page with actual implementation
class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get schoolId from auth state
    const schoolId = 'temp-school-id'; // This should come from auth state

    return BlocProvider.value(
      value: GetIt.instance<StudentBloc>(),
      child: const StudentsListPage(schoolId: schoolId),
    );
  }
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get schoolId from auth state
    const schoolId = 'temp-school-id'; // This should come from auth state

    return BlocProvider.value(
      value: GetIt.instance<AttendanceBloc>(),
      child: const ClassSelectionPage(schoolId: schoolId),
    );
  }
}

class FeeCollectionTab extends StatelessWidget {
  const FeeCollectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get schoolId from auth state
    const schoolId = 'temp-school-id'; // This should come from auth state

    return BlocProvider.value(
      value: GetIt.instance<FeeCollectionBloc>(),
      child: const FeeCollectionPage(schoolId: schoolId),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports Page - Coming Soon'),
    );
  }
}
