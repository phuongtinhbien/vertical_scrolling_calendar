import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vertical_scrolling_calendar/vertical_scrolling_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vertical Scrolling Calendar'),
        ),
        body: VerticalCalendar.range(
          startTime: DateTime.now().subtract(Duration(days: 7)),
          endTime: DateTime.now(),
          onRangeDateSelected: (start, end) {
            print(start.toString());
            print(end.toString());
          },
          initialDate: DateTime.now(),
          titleColor: Colors.grey,
          minDateTime: DateTime(DateTime.now().year -2, DateTime.january),
          maxDateTime: DateTime(DateTime.now().year +2, DateTime.december),
        ),
      ),
    );
  }
}
