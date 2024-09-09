import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

/// Screen for updating an existing training session.
///
/// Provides a form to modify the session's start time, end time, coach, and comment.
/// Validates input and submits updates to the backend API upon submission.
class UpdateTrainingSessionScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic> users;

  const UpdateTrainingSessionScreen({
    super.key,
    required this.session,
    required this.users,
  });

  @override
  UpdateTrainingSessionScreenState createState() =>
      UpdateTrainingSessionScreenState();
}

class UpdateTrainingSessionScreenState
    extends State<UpdateTrainingSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime;
  late DateTime _endTime;
  String? _selectedCoachId;
  String? _comment;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = widget.session['coach'];
    _comment = widget.session['comment'];
    _startTime =
        DateTime.fromMillisecondsSinceEpoch(widget.session['start_time'] * 1000);
    _endTime =
        DateTime.fromMillisecondsSinceEpoch(widget.session['end_time'] * 1000);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_endTime.isBefore(_startTime)) {
        _showError('End time must be after start time.');
        return;
      }
      _formKey.currentState!.save();
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final authToken = dataProvider.authToken;
        final startTime = _startTime.millisecondsSinceEpoch ~/ 1000;
        final endTime = _endTime.millisecondsSinceEpoch ~/ 1000;
        final selectedCoachId = _selectedCoachId!;
        final comment = _comment ?? '';

        await ApiService().coachUpdateTrainingSession(
          authToken,
          widget.session['session_id'],
          startTime,
          endTime,
          selectedCoachId,
          comment,
        );

        // Refresh data in the DataProvider
        await dataProvider.refreshData();

        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getCoachDropdownItems() {
    return widget.users.entries
        .where((entry) =>
    entry.value['role'] == 'Coach' || entry.value['role'] == 'Admin')
        .map((entry) => DropdownMenuItem(
      value: entry.key,
      child: Text(entry.value['name']),
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains largely the same
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Training Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Start Time:'),
              ListTile(
                title: Text(
                    '${_startTime.year}-${_padZero(_startTime.month)}-${_padZero(_startTime.day)} ${_padZero(_startTime.hour)}:${_padZero(_startTime.minute)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartTime,
              ),
              const Text('End Time:'),
              ListTile(
                title: Text(
                    '${_endTime.year}-${_padZero(_endTime.month)}-${_padZero(_endTime.day)} ${_endTime.hour}:${_padZero(_endTime.minute)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndTime,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCoachId,
                decoration: const InputDecoration(labelText: 'Coach'),
                items: _getCoachDropdownItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedCoachId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a coach.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _comment,
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 3,
                onSaved: (value) {
                  _comment = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Update Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (time == null) return;
      if (!mounted) return;
      setState(() {
        _startTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        // If end time is not set, set it to start time plus 1.5 hours
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(minutes: 90));
        }
      });
    }
  }

  void _pickEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: _startTime,
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (time == null) return;
      if (!mounted) return;
      setState(() {
        _endTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
