class CalendarModel {
  final DateTime date;
  final bool thisMonth;
  final bool prevMonth;
  final bool nextMonth;

  CalendarModel(
      {this.date,
      this.thisMonth = false,
      this.prevMonth = false,
      this.nextMonth = false});
}
