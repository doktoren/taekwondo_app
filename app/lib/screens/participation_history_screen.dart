import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

/// Screen for viewing historical participation data.
///
/// Allows coaches to select a date range and filter by weekdays.
/// Displays a participation matrix showing which participants attended each session within the selected range.
class ParticipationHistoryScreen extends StatefulWidget {
  const ParticipationHistoryScreen({super.key});

  @override
  ParticipationHistoryScreenState createState() =>
      ParticipationHistoryScreenState();
}

class ParticipationHistoryScreenState
    extends State<ParticipationHistoryScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  final List<bool> _weekDaysSelected = List<bool>.filled(7, true);
  Map<String, dynamic> _historyData = {};
  List<DateTime> _filteredDates = [];
  List<String> _participantIds = [];
  Map<String, Map<String, bool>> _participationMatrix = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day);
    _startDate = _endDate.subtract(const Duration(days: 30));
  }

  void _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      int startTime = _startDate.millisecondsSinceEpoch ~/ 1000;
      int endTime =
          (_endDate.add(const Duration(days: 1))).millisecondsSinceEpoch ~/
              1000;
      final data = await ApiService().coachGetHistoricalParticipation(
        dataProvider.authToken,
        startTime,
        endTime,
      );
      _historyData = data;
      _processData(_historyData);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processData(Map<String, dynamic> data) {
    // Build a list of dates and participation
    _filteredDates = [];
    _participantIds = [];
    _participationMatrix = {};

    // Filter dates by selected weekdays
    Set<int> selectedWeekDays = {};
    for (int i = 0; i < 7; i++) {
      if (_weekDaysSelected[i]) {
        selectedWeekDays.add(i + 1); // DateTime weekday is 1-7 (Mon-Sun)
      }
    }

    // Collect all participant IDs who have participated
    Set<String> participantIdsSet = {};

    // Build list of dates and participation
    data.forEach((sessionId, sessionData) {
      Map<String, dynamic> session = sessionData['session'];
      List<dynamic> participants = sessionData['participants'];

      DateTime date = DateTime.fromMillisecondsSinceEpoch(session['start_time'] * 1000);
      if (!selectedWeekDays.contains(date.weekday)) return;

      String dateKey = _formatDateOnly(date);
      _filteredDates.add(date);
      _participationMatrix[dateKey] = {};

      for (String participantId in participants) {
        _participationMatrix[dateKey]![participantId] = true;
        participantIdsSet.add(participantId);
      }
    });

    // Remove duplicate dates and sort
    _filteredDates = _filteredDates.toSet().toList();
    _filteredDates.sort();

    _participantIds = participantIdsSet.toList();

    // Remove users who have not participated in any session
    _participantIds = _participantIds.where((participantId) {
      return _participationMatrix.values.any((dateMap) => dateMap[participantId] == true);
    }).toList();

    // Sort participants by name
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final users = dataProvider.userData['users'] ?? {};
    _participantIds.sort((a, b) => (users[a]?['name'] ?? '').compareTo(users[b]?['name'] ?? ''));

    setState(() {});
  }

  void _toggleWeekDay(int index) {
    setState(() {
      _weekDaysSelected[index] = !_weekDaysSelected[index];
      if (_historyData.isNotEmpty) {
        _processData(_historyData);
      }
    });
  }

  void _showError(String message) {
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

  String _formatDateOnly(DateTime dateTime) {
    String weekDay = _getWeekday(dateTime.weekday);
    String year = dateTime.year.toString();
    String month = _padZero(dateTime.month);
    String day = _padZero(dateTime.day);
    return '$weekDay $year-$month-$day';
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  void _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (date != null) {
      setState(() {
        _startDate = DateTime(date.year, date.month, date.day);
        if (_historyData.isNotEmpty) {
          _processData(_historyData);
        }
      });
    }
  }

  void _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = DateTime(date.year, date.month, date.day);
        if (_historyData.isNotEmpty) {
          _processData(_historyData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final users = dataProvider.userData['users'] ?? {};

    List<Widget> weekDayCheckboxes = List<Widget>.generate(7, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getWeekday(index + 1)),
            Checkbox(
              value: _weekDaysSelected[index],
              onChanged: (value) {
                _toggleWeekDay(index);
              },
            ),
          ],
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participation History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                        'Start Date: ${_startDate.year}-${_padZero(_startDate.month)}-${_padZero(_startDate.day)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickStartDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                        'End Date: ${_endDate.year}-${_padZero(_endDate.month)}-${_padZero(_endDate.day)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickEndDate,
                  ),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text('Filtering:'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: weekDayCheckboxes,
            ),
            const SizedBox(height: 16.0),
            _buildParticipationMatrix(users),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationMatrix(Map<String, dynamic> users) {
    if (_participationMatrix.isEmpty) {
      return const Center(child: Text('No data'));
    }

    List<TableRow> rows = [];

    // Build header row with participant names written vertically
    List<Widget> headerCells = [
      const SizedBox(
        width: 100,
      ), // Empty top-left cell
    ];
    for (String participantId in _participantIds) {
      String name = users[participantId]?['name'] ?? 'Unknown';
      headerCells.add(
        Container(
          padding: const EdgeInsets.all(4.0),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              name,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      );
    }
    rows.add(TableRow(children: headerCells));

    // Build data rows
    for (DateTime date in _filteredDates) {
      String dateKey = _formatDateOnly(date);
      List<Widget> cells = [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            dateKey,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 14.0),
          ),
        ),
      ];
      for (String participantId in _participantIds) {
        bool participated = _participationMatrix[dateKey]?[participantId] ?? false;
        cells.add(
          Center(child: Text(participated ? 'X' : '')),
        );
      }
      rows.add(TableRow(children: cells));
    }

    // Build total row
    List<Widget> totalCells = [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: const Text(
          'Total',
          style: TextStyle(fontFamily: 'Courier', fontSize: 14.0),
        ),
      ),
    ];
    for (String participantId in _participantIds) {
      int total = 0;
      _participationMatrix.forEach((dateKey, participantMap) {
        if (participantMap[participantId] == true) {
          total++;
        }
      });
      totalCells.add(
        Center(child: Text('$total')),
      );
    }
    rows.add(TableRow(children: totalCells));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: rows,
      ),
    );
  }
}
