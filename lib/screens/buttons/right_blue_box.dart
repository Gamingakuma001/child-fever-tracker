import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RightBlueBoxPage extends StatefulWidget {
  const RightBlueBoxPage({super.key});

  @override
  State<RightBlueBoxPage> createState() => _RightBlueBoxPageState();
}

class _RightBlueBoxPageState extends State<RightBlueBoxPage> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _breakfastDosage = TextEditingController();
  final TextEditingController _lunchDosage = TextEditingController();
  final TextEditingController _dinnerDosage = TextEditingController();

  String _breakfastTime = 'before';
  String _lunchTime = 'before';
  String _dinnerTime = 'before';

  final List<String> _timingOptions = ['before', 'after', 'no'];
  final List<Map<String, dynamic>> _medicineDataList = [];
  final List<String> _docIds = [];

  @override
  void initState() {
    super.initState();
    _loadMedicineData();
  }

  Future<void> _loadMedicineData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .get();

    setState(() {
      _medicineDataList.clear();
      _docIds.clear();
      for (var doc in querySnapshot.docs) {
        _medicineDataList.add(doc.data());
        _docIds.add(doc.id);
      }
    });
  }

  void _showInputDialog({int? editIndex}) {
    if (editIndex != null) {
      final data = _medicineDataList[editIndex];
      _medicineController.text = data['medicine'];
      _breakfastTime = data['breakfast']['time'];
      _breakfastDosage.text = data['breakfast']['dosage'];
      _lunchTime = data['lunch']['time'];
      _lunchDosage.text = data['lunch']['dosage'];
      _dinnerTime = data['dinner']['time'];
      _dinnerDosage.text = data['dinner']['dosage'];
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                editIndex == null ? 'Add Medicine Schedule' : 'Edit Medicine Schedule',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medicine Name:'),
                    TextField(
                      controller: _medicineController,
                      decoration: const InputDecoration(hintText: 'Enter medicine name'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Breakfast:'),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _breakfastTime,
                            items: _timingOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setStateDialog(() => _breakfastTime = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _breakfastDosage,
                            decoration: const InputDecoration(hintText: 'Dosage'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Lunch:'),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _lunchTime,
                            items: _timingOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setStateDialog(() => _lunchTime = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _lunchDosage,
                            decoration: const InputDecoration(hintText: 'Dosage'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Dinner:'),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _dinnerTime,
                            items: _timingOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setStateDialog(() => _dinnerTime = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _dinnerDosage,
                            decoration: const InputDecoration(hintText: 'Dosage'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearInputs();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final entry = {
                      'medicine': _medicineController.text,
                      'breakfast': {
                        'time': _breakfastTime,
                        'dosage': _breakfastDosage.text
                      },
                      'lunch': {
                        'time': _lunchTime,
                        'dosage': _lunchDosage.text
                      },
                      'dinner': {
                        'time': _dinnerTime,
                        'dosage': _dinnerDosage.text
                      },
                    };

                    final uid = FirebaseAuth.instance.currentUser?.uid;

                    if (editIndex == null) {
                      final docRef = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('medicines')
                          .add(entry);
                      setState(() {
                        _medicineDataList.add(entry);
                        _docIds.add(docRef.id);
                      });
                    } else {
                      final docId = _docIds[editIndex];
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('medicines')
                          .doc(docId)
                          .set(entry);
                      setState(() {
                        _medicineDataList[editIndex] = entry;
                      });
                    }

                    _clearInputs();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D8DFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearInputs() {
    _medicineController.clear();
    _breakfastDosage.clear();
    _lunchDosage.clear();
    _dinnerDosage.clear();
    _breakfastTime = 'before';
    _lunchTime = 'before';
    _dinnerTime = 'before';
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _breakfastDosage.dispose();
    _lunchDosage.dispose();
    _dinnerDosage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        title: Text('Medication', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFF4D8DFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _medicineDataList.isEmpty
            ? const Center(child: Text("No medicines added yet."))
            : ListView.builder(
                itemCount: _medicineDataList.length,
                itemBuilder: (context, index) {
                  final med = _medicineDataList[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      title: Text("Medicine: ${med['medicine']}",
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Breakfast: ${med['breakfast']['time']} — ${med['breakfast']['dosage']}"),
                          Text("Lunch: ${med['lunch']['time']} — ${med['lunch']['dosage']}"),
                          Text("Dinner: ${med['dinner']['time']} — ${med['dinner']['dosage']}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showInputDialog(editIndex: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this entry?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final uid = FirebaseAuth.instance.currentUser?.uid;
                                        final docId = _docIds[index];
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('medicines')
                                            .doc(docId)
                                            .delete();
                                        setState(() {
                                          _medicineDataList.removeAt(index);
                                          _docIds.removeAt(index);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
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
