import 'package:vertical_scrolling_calendar/src/model/calendar_model.dart';

class MonthModel {
  int index;
  String title;
  int month,year;
  List<CalendarModel> sequentialDates;

  MonthModel({this.index, this.title, this.sequentialDates, this.month, this.year});
}