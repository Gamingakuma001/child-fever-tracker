import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LeftBlueBoxPage extends StatefulWidget {
  const LeftBlueBoxPage({super.key});

  @override
  State<LeftBlueBoxPage> createState() => _LeftBlueBoxPageState();
}

class _LeftBlueBoxPageState extends State<LeftBlueBoxPage> {
  TimeOfDay? _selectedTime;
  DateTime? selectedDate;
  String? _wholeTemp;
  String? _decimalTemp;
  final List<Map<String, dynamic>> _entries = [];
  final List<String> _docIds = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('temperatureEntries')
        .orderBy('timestamp')
        .get();

    setState(() {
      _entries.clear();
      _docIds.clear();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        dynamic tsField = data['timestamp'];
        DateTime timestamp;
        if (tsField is Timestamp) {
          timestamp = tsField.toDate();
        } else if (tsField is String) {
          timestamp = DateTime.tryParse(tsField) ?? DateTime(2000);
        } else {
          timestamp = DateTime(2000);
        }

        String formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
        String formattedTime = TimeOfDay(
          hour: timestamp.hour,
          minute: timestamp.minute,
        ).format(context);

        _entries.add({
          'temperature': data['temperature'].toString(),
          'timestamp': timestamp,
          'date': formattedDate,
          'time': formattedTime,
        });
        _docIds.add(doc.id);
      }
    });
  }

  Future<void> _checkHighTemperature(double temperature) async {
    if (temperature > 100.4) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Warning!"),
          content: const Text("The child's temperature is very high. Please consult a doctor."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _showInputDialog({int? editIndex}) {
    if (editIndex != null) {
      final entry = _entries[editIndex];
      double tempValue = double.parse(entry['temperature']);
      _wholeTemp = tempValue.floor().toString();
      _decimalTemp = ((tempValue - tempValue.floor()) * 10).round().toString();
      final timeStr = entry['time'];
      final timeParts = timeStr.split(":");
      int hour = int.parse(timeParts[0]);
      String minutePart = timeParts[1];
      int minute = int.parse(minutePart.split(' ')[0]);
      bool isPM = minutePart.contains('PM');
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);

      selectedDate = DateFormat('dd/MM/yyyy').parse(entry['date']);
    } else {
      _wholeTemp = null;
      _decimalTemp = null;
      _selectedTime = null;
      selectedDate = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(editIndex == null ? 'Add Temperature Entry' : 'Edit Temperature Entry'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text("Date: ",
                          style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D8DFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() => selectedDate = picked);
                          }
                        },
                        child: Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : "Pick Date",
                          style: GoogleFonts.lato(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Time: ",
                          style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D8DFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          DateTime tempTime = DateTime(
                            2020,
                            1,
                            1,
                            _selectedTime?.hour ?? TimeOfDay.now().hour,
                            _selectedTime?.minute ?? TimeOfDay.now().minute,
                          );

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Text("Select Time", style: GoogleFonts.lato()),
                                content: SizedBox(
                                  height: 200,
                                  width: double.maxFinite,
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.time,
                                    initialDateTime: tempTime,
                                    use24hFormat: false,
                                    onDateTimeChanged: (DateTime newTime) {
                                      tempTime = newTime;
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel", style: GoogleFonts.lato()),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setStateDialog(() {
                                        _selectedTime = TimeOfDay(
                                          hour: tempTime.hour,
                                          minute: tempTime.minute,
                                        );
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK", style: GoogleFonts.lato()),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : "Pick Time",
                          style: GoogleFonts.lato(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Temp: ",
                          style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D8DFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          int selectedWholeIndex =
                              _wholeTemp != null ? int.parse(_wholeTemp!) - 97 : 1;
                          int selectedDecimalIndex =
                              _decimalTemp != null ? int.parse(_decimalTemp!) : 0;

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: Text("Select Temperature",
                                    style: GoogleFonts.lato()),
                                content: SizedBox(
                                  height: 180,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CupertinoPicker(
                                          scrollController:
                                              FixedExtentScrollController(
                                                  initialItem:
                                                      selectedWholeIndex),
                                          itemExtent: 32,
                                          onSelectedItemChanged: (index) {
                                            selectedWholeIndex = index;
                                          },
                                          children: List.generate(14, (index) {
                                            return Center(
                                                child: Text(
                                                    (97 + index).toString()));
                                          }),
                                        ),
                                      ),
                                      Text(".", style: GoogleFonts.lato(fontSize: 24)),
                                      Expanded(
                                        child: CupertinoPicker(
                                          scrollController:
                                              FixedExtentScrollController(
                                                  initialItem:
                                                      selectedDecimalIndex),
                                          itemExtent: 32,
                                          onSelectedItemChanged: (index) {
                                            selectedDecimalIndex = index;
                                          },
                                          children: List.generate(10, (index) {
                                            return Center(
                                                child: Text(index.toString()));
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child:
                                        Text("Cancel", style: GoogleFonts.lato()),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setStateDialog(() {
                                        _wholeTemp =
                                            (97 + selectedWholeIndex).toString();
                                        _decimalTemp =
                                            selectedDecimalIndex.toString();
                                      });
                                      Navigator.pop(context);
                                    },
                                    child:
                                        Text("OK", style: GoogleFonts.lato()),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          _wholeTemp != null && _decimalTemp != null
                              ? "$_wholeTemp.${_decimalTemp!} °F"
                              : "Pick Temperature",
                          style: GoogleFonts.lato(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _wholeTemp = null;
                _decimalTemp = null;
                _selectedTime = null;
                selectedDate = null;
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.lato()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D8DFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_selectedTime != null && _wholeTemp != null && _decimalTemp != null) {
                  final tempString = "$_wholeTemp.$_decimalTemp";
                  final parsedTemp = double.tryParse(tempString);
                  if (parsedTemp != null) {
                    await _checkHighTemperature(parsedTemp);

                    final date = selectedDate ?? DateTime.now();
                    final selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    if (editIndex == null) {
                      final docRef = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('temperatureEntries')
                          .add({
                        'timestamp': Timestamp.fromDate(selectedDateTime),
                        'temperature': parsedTemp,
                      });

                      _entries.add({
                        'temperature': parsedTemp.toString(),
                        'timestamp': selectedDateTime,
                        'date': DateFormat('dd/MM/yyyy').format(selectedDateTime),
                        'time': _selectedTime!.format(context),
                      });
                      _docIds.add(docRef.id);
                    } else {
                      final docId = _docIds[editIndex];
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('temperatureEntries')
                          .doc(docId)
                          .set({
                        'timestamp': Timestamp.fromDate(selectedDateTime),
                        'temperature': parsedTemp,
                      });

                      _entries[editIndex] = {
                        'temperature': parsedTemp.toString(),
                        'timestamp': selectedDateTime,
                        'date': DateFormat('dd/MM/yyyy').format(selectedDateTime),
                        'time': _selectedTime!.format(context),
                      };
                    }

                    _wholeTemp = null;
                    _decimalTemp = null;
                    _selectedTime = null;
                    selectedDate = null;
                    setState(() {});
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid temperature format")),
                    );
                  }
                }
              },
              child: Text('Submit', style: GoogleFonts.lato()),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = _docIds[index];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('temperatureEntries')
        .doc(docId)
        .delete();

    setState(() {
      _entries.removeAt(index);
      _docIds.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: Text('Temperature', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF4D8DFF),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _entries.isEmpty
            ? Center(
                child: Text(
                  "No temperature data yet.",
                  style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[700]),
                ),
              )
            : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      title: Text(
                        "Date: ${entry['date']} | Time: ${entry['time']}",
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        "Temperature: ${entry['temperature']} °F",
                        style: GoogleFonts.lato(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Edit Entry',
                            onPressed: () => _showInputDialog(editIndex: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Entry',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                      'Are you sure you want to delete this entry?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text('Cancel',
                                          style: GoogleFonts.lato()),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteEntry(index);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Delete',
                                          style: GoogleFonts.lato(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInputDialog(),
        backgroundColor: const Color(0xFF4D8DFF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
