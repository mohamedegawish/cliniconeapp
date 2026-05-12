import 'package:flutter/material.dart';

class ScheduleManagerScreen extends StatefulWidget {
  const ScheduleManagerScreen({super.key});

  @override
  State<ScheduleManagerScreen> createState() => _ScheduleManagerScreenState();
}

class _ScheduleManagerScreenState extends State<ScheduleManagerScreen> {
  final List<Map<String, dynamic>> _days = [
    {'name': 'الأحد', 'active': true, 'start': '09:00 AM', 'end': '05:00 PM', 'duration': '30'},
    {'name': 'الإثنين', 'active': true, 'start': '09:00 AM', 'end': '05:00 PM', 'duration': '30'},
    {'name': 'الثلاثاء', 'active': true, 'start': '09:00 AM', 'end': '05:00 PM', 'duration': '30'},
    {'name': 'الأربعاء', 'active': true, 'start': '09:00 AM', 'end': '05:00 PM', 'duration': '30'},
    {'name': 'الخميس', 'active': true, 'start': '09:00 AM', 'end': '05:00 PM', 'duration': '30'},
    {'name': 'الجمعة', 'active': true, 'start': '09:00 AM', 'end': '05:00 PM', 'duration': '30'},
    {'name': 'السبت', 'active': true, 'start': '09:00 AM', 'end': '05:00 PM', 'duration': '30'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية \\ مواعيد العمل')),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                  columns: const [
                    DataColumn(label: Text('اليوم', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text('يوم عمل؟', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text('وقت البدء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text('وقت الانتهاء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text('مدة الكشف (دقائق)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                  ],
                  rows: _days.map((day) => _buildRow(day)).toList(),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ مواعيد العمل بنجاح ✅'), backgroundColor: Colors.green));
                      },
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('حفظ مواعيد العمل', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF194A6E),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(Map<String, dynamic> day) {
    return DataRow(
      cells: [
        DataCell(Text(day['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Switch(
          value: day['active'],
          onChanged: (v) => setState(() => day['active'] = v),
          activeColor: Colors.teal.shade200,
        )),
        DataCell(SizedBox(
          width: 100,
          child: TextField(
            controller: TextEditingController(text: day['start']),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        )),
        DataCell(SizedBox(
          width: 100,
          child: TextField(
            controller: TextEditingController(text: day['end']),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        )),
        DataCell(SizedBox(
          width: 80,
          child: TextField(
            controller: TextEditingController(text: day['duration']),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        )),
      ],
    );
  }
}
