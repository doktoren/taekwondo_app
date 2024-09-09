import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/api_service.dart';

/// Screen for adding a new training session.
///
/// This screen allows coaches to create a new training session by providing a form
/// to input the start time, end time, coach, and an optional comment.
/// Upon submission, the data is sent to the backend API to create the session.
class AddTrainingSessionScreen extends StatefulWidget {
  final Map<String, dynamic> users;
  final String defaultCoachId;

  const AddTrainingSessionScreen({
    super.key,
    required this.users,
    required this.defaultCoachId,
  });

  @override
  AddTrainingSessionScreenState createState() =>
      AddTrainingSessionScreenState();
}

class AddTrainingSessionScreenState extends State<AddTrainingSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startTime;
  DateTime? _endTime;
  String? _selectedCoachId;
  String? _comment;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = widget.defaultCoachId;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        _showError('Please select both start and end times.');
        return;
      }
      if (_endTime!.isBefore(_startTime!)) {
        _showError('End time must be after start time.');
        return;
      }
      _formKey.currentState!.save();
      try {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        final authToken = dataProvider.authToken;
        final startTime = _startTime!.millisecondsSinceEpoch ~/ 1000;
        final endTime = _endTime!.millisecondsSinceEpoch ~/ 1000;
        final selectedCoachId = _selectedCoachId!;
        final comment = _comment ?? '';

        await ApiService().coachAddTrainingSession(
          authToken,
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
        title: const Text('Add Training Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Start Time:'),
              ListTile(
                title: Text(_startTime == null
                    ? 'Select Start Time'
                    : '${_startTime!.year}-${_padZero(_startTime!.month)}-${_padZero(_startTime!.day)} ${_padZero(_startTime!.hour)}:${_padZero(_startTime!.minute)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartTime,
              ),
              const Text('End Time:'),
              ListTile(
                title: Text(_endTime == null
                    ? 'Select End Time'
                    : '${_endTime!.year}-${_padZero(_endTime!.month)}-${_padZero(_endTime!.day)} ${_padZero(_endTime!.hour)}:${_padZero(_endTime!.minute)}'),
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
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 3,
                onSaved: (value) {
                  _comment = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Session'),
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
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 19, minute: 0),
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
        _endTime ??= _startTime!.add(const Duration(minutes: 90));
      });
    }
  }

  void _pickEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime ?? (_startTime ?? DateTime.now()),
      firstDate: _startTime ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            _endTime ?? (_startTime ?? DateTime.now())),
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
