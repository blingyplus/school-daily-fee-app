import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/fee_collection.dart';
import '../bloc/fee_collection_bloc.dart';
import '../bloc/fee_collection_event.dart';
import '../bloc/fee_collection_state.dart';
import '../widgets/fee_collection_form.dart';
import '../widgets/fee_collection_list.dart';

class FeeCollectionPage extends StatefulWidget {
  final String schoolId;

  const FeeCollectionPage({
    super.key,
    required this.schoolId,
  });

  @override
  State<FeeCollectionPage> createState() => _FeeCollectionPageState();
}

class _FeeCollectionPageState extends State<FeeCollectionPage> {
  DateTime _selectedDate = DateTime.now();
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadFeeCollections();
  }

  void _loadFeeCollections() {
    context
        .read<FeeCollectionBloc>()
        .add(LoadFeeCollections(widget.schoolId, _selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Collection'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.list : Icons.add),
            onPressed: () {
              setState(() {
                _showForm = !_showForm;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          _buildDateSelector(),

          // Content
          Expanded(
            child: _showForm ? _buildForm() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collection Date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                GestureDetector(
                  onTap: _selectDate,
                  child: Text(
                    _formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _selectDate,
            icon: const Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return FeeCollectionForm(
      schoolId: widget.schoolId,
      paymentDate: _selectedDate,
      onFeeCollected: () {
        setState(() {
          _showForm = false;
        });
        _loadFeeCollections();
      },
    );
  }

  Widget _buildList() {
    return BlocConsumer<FeeCollectionBloc, FeeCollectionState>(
      listener: (context, state) {
        if (state is FeeCollectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is FeeCollectionOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FeeCollectionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FeeCollectionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _loadFeeCollections,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is FeeCollectionLoaded) {
          return FeeCollectionList(
            collections: state.collections,
            onRefresh: _loadFeeCollections,
          );
        }

        return const Center(
          child: Text('No fee collections found'),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, $month ${date.day}, ${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadFeeCollections();
    }
  }
}
