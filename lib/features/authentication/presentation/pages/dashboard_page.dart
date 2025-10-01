import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../shared/data/datasources/local/database_helper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../student_management/presentation/pages/students_list_page.dart';
import '../../../student_management/presentation/pages/add_student_page.dart';
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

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSyncing = false;
  SyncResult? _lastSyncResult;
  String? _userId;
  String? _schoolId;
  String? _userRole;
  late AnimationController _rotationController;

  List<Widget> get _pages => [
        DashboardHomePage(
            userId: _userId,
            schoolId: _schoolId,
            userRole: _userRole,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            }),
        StudentsPage(userId: _userId, schoolId: _schoolId, userRole: _userRole),
        AttendancePage(
            userId: _userId, schoolId: _schoolId, userRole: _userRole),
        FeeCollectionTab(
            userId: _userId, schoolId: _schoolId, userRole: _userRole),
        ReportsPage(userId: _userId, schoolId: _schoolId, userRole: _userRole),
      ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _listenToSyncStatus();
    _checkInitialSyncStatus();
    _loadUserContext();
  }

  void _checkInitialSyncStatus() {
    // Check if sync is already in progress when dashboard loads
    final syncEngine = GetIt.instance<SyncEngine>();
    if (syncEngine.isSyncing) {
      setState(() {
        _isSyncing = true;
      });
      _rotationController.repeat();
      print('🔄 Dashboard detected sync already in progress');
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserContext() async {
    try {
      final onboardingService = GetIt.instance<OnboardingService>();

      // Get current user from auth state
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _userId = authState.user.id;

        // Get school and role information
        _schoolId = await onboardingService.getUserSchool(_userId!);
        _userRole = await onboardingService.getUserRole(_userId!);

        if (mounted) {
          setState(() {});
        }

        print('✅ Dashboard loaded with context:');
        print('   User ID: $_userId');
        print('   School ID: $_schoolId');
        print('   User Role: $_userRole');

        // Trigger sync in background after dashboard is displayed (don't wait for it)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _triggerManualSync();
          }
        });
      }
    } catch (e) {
      print('❌ Error loading user context: $e');
    }
  }

  Future<void> _triggerManualSync() async {
    try {
      final syncEngine = GetIt.instance<SyncEngine>();
      print('🔄 Triggering manual sync from dashboard...');
      await syncEngine.sync(SyncDirection.bidirectional);
    } catch (e) {
      print('❌ Error triggering manual sync: $e');
    }
  }

  void _listenToSyncStatus() {
    final syncEngine = GetIt.instance<SyncEngine>();
    syncEngine.syncStream.listen((result) {
      if (mounted) {
        print('🔄 Sync status update: ${result.status}');

        setState(() {
          final wasSyncing = _isSyncing;
          _isSyncing = result.status == SyncStatus.syncing;

          if (result.status == SyncStatus.syncing) {
            // Start spinning animation if not already spinning
            if (!wasSyncing) {
              _rotationController.repeat();
              print('🔄 Starting sync animation');
            }

            // Show "Syncing..." banner temporarily (1 second)
            _lastSyncResult = result;
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted && _isSyncing) {
                setState(() {
                  _lastSyncResult = null; // Hide banner while still syncing
                });
              }
            });
          } else {
            // Stop spinning animation
            if (wasSyncing) {
              _rotationController.stop();
              _rotationController.reset();
              print('🔄 Stopping sync animation');
            }

            // Show result (success/error) banner
            _lastSyncResult = result;
            // Clear the result after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
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
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
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
              // Smart Sync Button - Icon spins during sync
              AnimatedBuilder(
                animation: _isSyncing
                    ? _rotationController
                    : const AlwaysStoppedAnimation(0),
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _isSyncing
                        ? _rotationController.value * 2 * 3.14159
                        : 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.cloud_sync,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _isSyncing ? null : () => _smartSync(context),
                      tooltip: _isSyncing ? 'Syncing...' : 'Smart Sync',
                    ),
                  );
                },
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
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // If not on the dashboard home tab, navigate to it first
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Don't exit the app
    }

    // If on dashboard home tab, show exit confirmation dialog
    return await _showExitConfirmationDialog() ?? false;
  }

  Future<bool?> _showExitConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit Skuupay?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isSyncing && _lastSyncResult?.status == SyncStatus.syncing) {
      // Only show syncing banner if we have a syncing result (first 1 second)
      backgroundColor = isDarkMode
          ? Colors.blue.shade900.withOpacity(0.3)
          : Colors.blue.shade50;
      icon = Icons.sync;
      message = 'Syncing data...';
      textColor = isDarkMode ? Colors.blue.shade200 : Colors.blue.shade900;
    } else if (_lastSyncResult != null &&
        _lastSyncResult!.status != SyncStatus.syncing) {
      switch (_lastSyncResult!.status) {
        case SyncStatus.success:
          backgroundColor = isDarkMode
              ? Colors.green.shade900.withOpacity(0.3)
              : Colors.green.shade50;
          icon = Icons.check_circle;
          message =
              'Sync complete! ${_lastSyncResult!.recordsProcessed ?? 0} new records processed.';
          textColor =
              isDarkMode ? Colors.green.shade200 : Colors.green.shade900;
          break;
        case SyncStatus.failed:
          backgroundColor = isDarkMode
              ? Colors.red.shade900.withOpacity(0.3)
              : Colors.red.shade50;
          icon = Icons.error;
          message = 'Sync failed: ${_lastSyncResult!.message}';
          textColor = isDarkMode ? Colors.red.shade200 : Colors.red.shade900;
          break;
        default:
          backgroundColor = isDarkMode
              ? Colors.orange.shade900.withOpacity(0.3)
              : Colors.orange.shade50;
          icon = Icons.warning;
          message = _lastSyncResult!.message ?? 'Sync status unknown';
          textColor =
              isDarkMode ? Colors.orange.shade200 : Colors.orange.shade900;
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
          if (_lastSyncResult != null)
            IconButton(
              icon: Icon(Icons.close, color: textColor, size: 18),
              onPressed: () {
                setState(() {
                  _lastSyncResult = null;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Dismiss',
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
            duration: const Duration(seconds: 3),
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

class DashboardHomePage extends StatefulWidget {
  final String? userId;
  final String? schoolId;
  final String? userRole;
  final Function(int)? onTabChange;

  const DashboardHomePage({
    super.key,
    this.userId,
    this.schoolId,
    this.userRole,
    this.onTabChange,
  });

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  int _totalStudents = 0;
  int _presentToday = 0;
  double _totalFeesCollected = 0.0;
  int _attendanceRate = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _listenToSyncUpdates();
    _listenToSyncStatus();
  }

  @override
  void didUpdateWidget(DashboardHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when schoolId changes from null to a value
    if (oldWidget.schoolId != widget.schoolId && widget.schoolId != null) {
      _loadDashboardData();
    }
  }

  void _listenToSyncUpdates() {
    // Listen to sync status changes to refresh data
    final syncEngine = GetIt.instance<SyncEngine>();
    syncEngine.syncStream.listen((result) {
      if (result.status == SyncStatus.success && mounted) {
        // Refresh dashboard data after successful sync
        _loadDashboardData();
      }
    });
  }

  // Add sync status tracking for pulsing indicator
  bool _isSyncingInBackground = false;

  void _listenToSyncStatus() {
    final syncEngine = GetIt.instance<SyncEngine>();
    syncEngine.syncStream.listen((result) {
      if (mounted) {
        setState(() {
          _isSyncingInBackground = result.status == SyncStatus.syncing;
        });
      }
    });
  }

  Future<void> _loadDashboardData() async {
    if (widget.schoolId == null) {
      return;
    }

    try {
      final database = GetIt.instance<Database>();

      // Load student count
      final studentResults = await database.query(
        DatabaseHelper.tableStudents,
        where: 'school_id = ? AND is_active = ?',
        whereArgs: [widget.schoolId, 1],
      );
      _totalStudents = studentResults.length;

      // Load today's attendance
      final today = DateTime.now();
      final startOfDay =
          DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
      final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;

      final attendanceResults = await database.query(
        DatabaseHelper.tableAttendanceRecords,
        where:
            'school_id = ? AND attendance_date >= ? AND attendance_date <= ? AND status = ?',
        whereArgs: [widget.schoolId, startOfDay, endOfDay, 'present'],
      );
      _presentToday = attendanceResults.length;

      // Load total fees collected this month
      final monthStart =
          DateTime(today.year, today.month, 1).millisecondsSinceEpoch;
      final monthEnd =
          DateTime(today.year, today.month + 1, 0).millisecondsSinceEpoch;

      final feeResults = await database.rawQuery(
        'SELECT SUM(amount_paid) as total FROM ${DatabaseHelper.tableFeeCollections} WHERE school_id = ? AND payment_date >= ? AND payment_date <= ?',
        [widget.schoolId, monthStart, monthEnd],
      );

      _totalFeesCollected = (feeResults.first['total'] as double?) ?? 0.0;

      // Calculate attendance rate
      if (_totalStudents > 0) {
        _attendanceRate = ((_presentToday / _totalStudents) * 100).round();
      }

      setState(() {}); // Update UI with new data

      print('✅ Dashboard data loaded:');
      print('   Total Students: $_totalStudents');
      print('   Present Today: $_presentToday');
      print('   Total Fees: $_totalFeesCollected');
      print('   Attendance Rate: $_attendanceRate%');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      setState(() {}); // Update UI even on error
    }
  }

  Future<List<Map<String, dynamic>>> _loadRecentActivity() async {
    if (widget.schoolId == null) return [];

    try {
      final database = GetIt.instance<Database>();
      final activities = <Map<String, dynamic>>[];

      // Get recent fee collections (last 5)
      final recentFees = await database.query(
        DatabaseHelper.tableFeeCollections,
        where: 'school_id = ?',
        whereArgs: [widget.schoolId],
        orderBy: 'collected_at DESC',
        limit: 5,
      );

      for (final fee in recentFees) {
        // Get student name
        final student = await database.query(
          DatabaseHelper.tableStudents,
          where: 'id = ?',
          whereArgs: [fee['student_id']],
          limit: 1,
        );

        if (student.isNotEmpty) {
          final studentName =
              '${student.first['first_name']} ${student.first['last_name']}';
          final feeType = fee['fee_type'] as String;
          final amount = fee['amount_paid'] as double;
          final timestamp = fee['collected_at'] as int;

          activities.add({
            'title':
                '$studentName paid $feeType fee (₵${amount.toStringAsFixed(0)})',
            'time': _formatTimeAgo(timestamp),
            'icon': Icons.payment,
            'color': Colors.green,
            'timestamp': timestamp,
          });
        }
      }

      // Get recent attendance records (last 5)
      final recentAttendance = await database.query(
        DatabaseHelper.tableAttendanceRecords,
        where: 'school_id = ? AND status = ?',
        whereArgs: [widget.schoolId, 'present'],
        orderBy: 'recorded_at DESC',
        limit: 5,
      );

      for (final attendance in recentAttendance) {
        // Get student name
        final student = await database.query(
          DatabaseHelper.tableStudents,
          where: 'id = ?',
          whereArgs: [attendance['student_id']],
          limit: 1,
        );

        if (student.isNotEmpty) {
          final studentName =
              '${student.first['first_name']} ${student.first['last_name']}';
          final timestamp = attendance['recorded_at'] as int;

          activities.add({
            'title': '$studentName marked present',
            'time': _formatTimeAgo(timestamp),
            'icon': Icons.check_circle,
            'color': Colors.blue,
            'timestamp': timestamp,
          });
        }
      }

      // Sort all activities by timestamp (most recent first)
      activities.sort(
          (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

      // Return only the 5 most recent activities
      return activities.take(5).toList();
    } catch (e) {
      print('❌ Error loading recent activity: $e');
      return [];
    }
  }

  String _formatTimeAgo(int timestamp) {
    final now = DateTime.now();
    final activityTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(activityTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${activityTime.day}/${activityTime.month}/${activityTime.year}';
    }
  }

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
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Students',
                    '$_totalStudents',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Present Today',
                    '$_presentToday',
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
                    '₵${_totalFeesCollected.toStringAsFixed(0)}',
                    Icons.payment,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Attendance',
                    '$_attendanceRate%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingStats(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard(context, 'Total Students', '...',
                    Icons.people, Colors.blue)),
            SizedBox(width: 16.w),
            Expanded(
                child: _buildStatCard(context, 'Present Today', '...',
                    Icons.check_circle, Colors.green)),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(context, 'Fees Collected', '...',
                    Icons.payment, Colors.orange)),
            SizedBox(width: 16.w),
            Expanded(
                child: _buildStatCard(context, 'Attendance', '...',
                    Icons.trending_up, Colors.purple)),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isSyncingInBackground
              ? color.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: _isSyncingInBackground ? 2 : 1,
        ),
        boxShadow: _isSyncingInBackground
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _isSyncingInBackground
                      ? color.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              if (_isSyncingInBackground)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.2),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Icon(
                        Icons.cloud_sync,
                        color: color.withOpacity(0.7),
                        size: 16.sp,
                      ),
                    );
                  },
                  onEnd: () {
                    if (_isSyncingInBackground && mounted) {
                      // Restart animation by rebuilding
                      setState(() {});
                    }
                  },
                ),
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
                  // Switch to Attendance tab (index 2)
                  widget.onTabChange?.call(2);
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
                  // Switch to Fees tab (index 3)
                  widget.onTabChange?.call(3);
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
                  // Open Add Student form
                  if (widget.schoolId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStudentPage(
                          schoolId: widget.schoolId!,
                        ),
                      ),
                    );
                  }
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
                  // Switch to Reports tab (index 4)
                  widget.onTabChange?.call(4);
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
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadRecentActivity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final activities = snapshot.data ?? [];

            if (activities.isEmpty) {
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              );
            }

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
                children: activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;

                  return Column(
                    children: [
                      _buildActivityItem(
                        context,
                        activity['title'] as String,
                        activity['time'] as String,
                        activity['icon'] as IconData,
                        activity['color'] as Color,
                      ),
                      if (index < activities.length - 1)
                        Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
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
  final String? userId;
  final String? schoolId;
  final String? userRole;

  const StudentsPage({
    super.key,
    this.userId,
    this.schoolId,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    if (schoolId == null) {
      return const Center(
        child: Text('Loading school information...'),
      );
    }

    return BlocProvider.value(
      value: GetIt.instance<StudentBloc>(),
      child: StudentsListPage(schoolId: schoolId!),
    );
  }
}

class AttendancePage extends StatelessWidget {
  final String? userId;
  final String? schoolId;
  final String? userRole;

  const AttendancePage({
    super.key,
    this.userId,
    this.schoolId,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    if (schoolId == null) {
      return const Center(
        child: Text('Loading school information...'),
      );
    }

    return BlocProvider.value(
      value: GetIt.instance<AttendanceBloc>(),
      child: ClassSelectionPage(schoolId: schoolId!),
    );
  }
}

class FeeCollectionTab extends StatelessWidget {
  final String? userId;
  final String? schoolId;
  final String? userRole;

  const FeeCollectionTab({
    super.key,
    this.userId,
    this.schoolId,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    if (schoolId == null) {
      return const Center(
        child: Text('Loading school information...'),
      );
    }

    return BlocProvider.value(
      value: GetIt.instance<FeeCollectionBloc>(),
      child: FeeCollectionPage(schoolId: schoolId!),
    );
  }
}

class ReportsPage extends StatelessWidget {
  final String? userId;
  final String? schoolId;
  final String? userRole;

  const ReportsPage({
    super.key,
    this.userId,
    this.schoolId,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports Page - Coming Soon'),
    );
  }
}
