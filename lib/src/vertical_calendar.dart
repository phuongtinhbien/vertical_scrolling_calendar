import 'package:flutter/material.dart';
import 'package:vertical_scrolling_calendar/src/calendar_utils.dart';
import 'package:vertical_scrolling_calendar/src/model/calendar_model.dart';

import 'calendar_type.dart';

class VerticalCalendar extends StatefulWidget {
  final DateTime startTime, endTime;
  final Function(DateTime) onDateSelected;
  final Function(DateTime, DateTime) onRangeDateSelected;
  final DateTime initialDate;
  final Color unselectedColor, selectedColor, todayColor;
  final TextStyle textStyleDate;
  final CalendarType calendarType;

  VerticalCalendar(
      {Key key,
      @required this.startTime,
      @required this.endTime,
      this.onDateSelected,
      this.onRangeDateSelected,
      this.initialDate,
      this.unselectedColor = const Color(0xFFBDBDBD),
      this.selectedColor = Colors.red,
      this.todayColor = Colors.red,
      this.textStyleDate,
      this.calendarType})
      : super(key: key);

  factory VerticalCalendar.single(
      {Key key,
      @required DateTime startTime,
      @required DateTime endTime,
      Function(DateTime) onDateSelected,
      DateTime initialDate,
      Color unselectedColor,
      Color selectedColor,
      Color todayColor,
      TextStyle textStyleDate,
      CalendarType calendarType}) {
    return VerticalCalendar(
      key: key,
      calendarType: CalendarType.CALENDAR_SINGLE_DAY,
      startTime: startTime,
      endTime: endTime,
      onDateSelected: onDateSelected,
      initialDate: initialDate ?? DateTime.now(),
      unselectedColor: unselectedColor,
      selectedColor: selectedColor,
      todayColor: todayColor,
      textStyleDate: textStyleDate,
    );
  }

  factory VerticalCalendar.range(
      {Key key,
      @required DateTime startTime,
      @required DateTime endTime,
      Function(DateTime, DateTime) onRangeDateSelected,
      DateTime initialDate,
      Color unselectedColor,
      Color selectedColor,
      Color todayColor,
      TextStyle textStyleDate,
      CalendarType calendarType}) {
    return VerticalCalendar(
      key: key,
      calendarType: CalendarType.CALENDAR_RANGE_DAY,
      startTime: startTime,
      endTime: endTime,
      onRangeDateSelected: onRangeDateSelected,
      initialDate: initialDate ?? DateTime.now(),
      unselectedColor: unselectedColor,
      selectedColor: selectedColor,
      todayColor: todayColor,
      textStyleDate: textStyleDate,
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return VerticalCalendarState();
  }
}

class VerticalCalendarState extends State<VerticalCalendar> {
  DateTime _currentDateTime;
  DateTime _selectedDateTime;
  List<CalendarModel> _sequentialDates;
  List<List<CalendarModel>> _sequentialMonths;
  int midYear;
  CalendarViews _currentView = CalendarViews.dates;

  @override
  void initState() {
    super.initState();
    _sequentialMonths = [];
    _currentDateTime = DateTime(widget.startTime.year, widget.startTime.month);
    _selectedDateTime = DateTime(widget.initialDate.year,
        widget.initialDate.month, widget.initialDate.day);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _getCalendar();
        for (int i = 1; i < 5; i++) {
          _currentDateTime =
              DateTime(widget.startTime.year, widget.startTime.month + i);
          _getCalendar();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: (_currentView == CalendarViews.dates)
                ? _datesView()
                : (_currentView == CalendarViews.months)
                    ? _showMonthsList()
                    : _yearsView(midYear ?? _currentDateTime.year)),
      ),
    );
  }

  // dates view
  Widget _datesView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // header
        Expanded(
            child: ListView.builder(
          itemBuilder: (itemContext, index) {
            int currentMonth = _sequentialMonths[index]
                    .firstWhere((element) => element.thisMonth)
                    .date
                    .month -
                1;
            int currentYear = _sequentialMonths[index]
                .firstWhere((element) => element.thisMonth)
                .date
                .year;
            return Column(
              children: <Widget>[
                InkWell(
                  onTap: () =>
                      setState(() => _currentView = CalendarViews.months),
                  child: Center(
                    child: Text(
                      '${CalendarUtils.monthNames[currentMonth]} ${currentYear}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                _calendarBody(_sequentialMonths[index]),
              ],
            );
          },
          itemCount: _sequentialMonths.length,
        )),
      ],
    );
  }

  // next / prev month buttons
  Widget _toggleBtn(bool next) {
    return InkWell(
      onTap: () {
        if (_currentView == CalendarViews.dates) {
          setState(() => (next) ? _getNextMonth() : _getPrevMonth());
        } else if (_currentView == CalendarViews.year) {
          if (next) {
            midYear =
                (midYear == null) ? _currentDateTime.year + 9 : midYear + 9;
          } else {
            midYear =
                (midYear == null) ? _currentDateTime.year - 9 : midYear - 9;
          }
          setState(() {});
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: Offset(3, 3),
              blurRadius: 3,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          (next) ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: Colors.grey,
        ),
      ),
    );
  }

  // calendar
  Widget _calendarBody(List<CalendarModel> _sequentialDates) {
    if (_sequentialDates == null) return Container();
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 20),
      itemCount: _sequentialDates.length + 7,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        if (index < 7) return _weekDayTitle(index);
        if (_sequentialDates[index - 7].date == _selectedDateTime &&
            _sequentialDates[index - 7].thisMonth)
          return _selector(_sequentialDates[index - 7]);
        return _calendarDates(_sequentialDates[index - 7]);
      },
    );
  }

  // calendar header
  Widget _weekDayTitle(int index) {
    return Center(
      child: Text(
        CalendarUtils.weekDays[index],
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  // calendar element
  Widget _calendarDates(CalendarModel calendarDate) {
    return InkWell(
      onTap: calendarDate.thisMonth
          ? () {
              if (_selectedDateTime != calendarDate.date) {
                if (calendarDate.nextMonth) {
                  _getNextMonth();
                } else if (calendarDate.prevMonth) {
                  _getPrevMonth();
                }
                setState(() => _selectedDateTime = calendarDate.date);
              }
            }
          : null,
      child: Center(
          child: Text(
        '${calendarDate.date.day}',
        style: TextStyle(
          color: (calendarDate.thisMonth)
              ? (calendarDate.date.weekday == DateTime.sunday)
                  ? Colors.red
                  : Colors.black
              : (calendarDate.date.weekday == DateTime.sunday)
                  ? Colors.red.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.5),
        ),
      )),
    );
  }

  // date selector
  Widget _selector(CalendarModel calendarDate) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.1), Colors.white],
          stops: [0.1, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            '${calendarDate.date.day}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // get next month calendar
  void _getNextMonth() {
    if (_currentDateTime.month == 12) {
      _currentDateTime = DateTime(_currentDateTime.year + 1, 1);
    } else {
      _currentDateTime =
          DateTime(_currentDateTime.year, _currentDateTime.month + 1);
    }
    _getCalendar();
  }

  // get previous month calendar
  void _getPrevMonth() {
    if (_currentDateTime.month == 1) {
      _currentDateTime = DateTime(_currentDateTime.year - 1, 12);
    } else {
      _currentDateTime =
          DateTime(_currentDateTime.year, _currentDateTime.month - 1);
    }
    _getCalendar();
  }

  // get calendar for current month
  void _getCalendar() {
    _sequentialDates = CalendarUtils().getMonthCalendar(
        _currentDateTime.month, _currentDateTime.year,
        startWeekDay: StartWeekDay.monday);
    _sequentialMonths.add(_sequentialDates);
  }

  // show months list
  Widget _showMonthsList() {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _currentView = CalendarViews.year),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '${_currentDateTime.year}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
        ),
        Divider(
          color: Colors.grey,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: CalendarUtils.monthNames.length,
            itemBuilder: (context, index) => ListTile(
              onTap: () {
                _currentDateTime = DateTime(_currentDateTime.year, index + 1);
                _getCalendar();
                setState(() => _currentView = CalendarViews.dates);
              },
              title: Center(
                child: Text(
                  CalendarUtils.monthNames[index],
                  style: TextStyle(
                      fontSize: 18,
                      color: (index == _currentDateTime.month - 1)
                          ? Colors.red
                          : Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // years list views
  Widget _yearsView(int midYear) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _toggleBtn(false),
            Expanded(
                child: Center(
              child: Text(
                "Select year",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400
                ),
              ),
            )),
            _toggleBtn(true),
          ],
        ),
        Expanded(
          child: GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                int thisYear;
                if (index < 4) {
                  thisYear = midYear - (4 - index);
                } else if (index > 4) {
                  thisYear = midYear + (index - 4);
                } else {
                  thisYear = midYear;
                }
                return ListTile(
                  onTap: () {
                    _currentDateTime =
                        DateTime(thisYear, _currentDateTime.month);
                    _getCalendar();
                    setState(() => _currentView = CalendarViews.months);
                  },
                  title: Center(
                    child: Text(
                      '$thisYear',
                      style: TextStyle(
                          fontSize: 18,
                          color: (thisYear == _currentDateTime.year)
                              ? Colors.red
                              : Colors.black),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
