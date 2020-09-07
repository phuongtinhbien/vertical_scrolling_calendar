import 'package:flutter/material.dart';
import 'package:vertical_scrolling_calendar/src/calendar_utils.dart';
import 'package:vertical_scrolling_calendar/src/model/calendar_model.dart';

import 'calendar_type.dart';
import 'model/month_model.dart';

class VerticalCalendar extends StatefulWidget {
  final DateTime startTime, endTime;
  final Function(DateTime) onDateSelected;
  final Function(DateTime, DateTime) onRangeDateSelected;
  final DateTime initialDate;
  final Color unselectedColor,
      selectedColor,
      todayColor,
      titleColor,
      rangDateColor;
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
      this.calendarType,
      this.titleColor,
      this.rangDateColor = const Color(0xFFFFD180)})
      : super(key: key);

  factory VerticalCalendar.single(
      {Key key,
      Function(DateTime) onDateSelected,
      DateTime initialDate,
      Color unselectedColor,
      Color selectedColor,
      Color todayColor,
      Color titleColor,
      TextStyle textStyleDate,
      CalendarType calendarType}) {
    return VerticalCalendar(
      key: key,
      calendarType: CalendarType.CALENDAR_SINGLE_DAY,
      onDateSelected: onDateSelected,
      initialDate: initialDate ?? DateTime.now(),
      unselectedColor: unselectedColor,
      selectedColor: selectedColor,
      todayColor: todayColor,
      titleColor: titleColor,
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
      Color titleColor,
      Color rangDateColor,
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
      titleColor: titleColor,
      rangDateColor: rangDateColor ?? Color(0xFFFFD180),
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
  DateTime _currentStartDateTime;
  DateTime _selectedDateTime;

  DateTime startRangeTime, endRangeTime;
  int stepDo;
  List<CalendarModel> _sequentialDates;
  List<MonthModel> _sequentialMonths;
  int midYear;
  CalendarViews _currentView = CalendarViews.dates;
  ScrollController _scrollController;
  int scrollIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    stepDo = 0;
    scrollIndex = 1;
    _sequentialMonths = [];
    _currentStartDateTime = DateTime(DateTime.now().year - 4, DateTime.january);

    if (widget.startTime != null && widget.endTime != null) {
      if (widget.startTime != null) {
        startRangeTime = widget.startTime;
      }
      if (widget.endTime != null) {
        endRangeTime = widget.endTime;
      }
    }

    _selectedDateTime = DateTime(widget.initialDate.year,
        widget.initialDate.month, widget.initialDate.day);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        for (int i = 0; i < 96; i++) {
          _getCalendar(index: i);
          if (startRangeTime != null) {
            if (_currentStartDateTime.year == startRangeTime.year &&
                _currentStartDateTime.month == startRangeTime.month) {
              scrollIndex = i;
            }
          } else {
            if (_currentStartDateTime.year == DateTime.now().year &&
                _currentStartDateTime.month == DateTime.now().month) {
              scrollIndex = i;
            }
          }
          _currentStartDateTime = DateTime(
              _currentStartDateTime.year, _currentStartDateTime.month + 1);
        }
      });
      double offset = scrollIndex * MediaQuery.of(context).size.width;

      _scrollController.jumpTo(offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: (_currentView == CalendarViews.dates)
                ? _datesView()
                : (_currentView == CalendarViews.months)
                    ? _showMonthsList()
                    : _yearsView(midYear ?? _currentStartDateTime.year)),
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
          controller: _scrollController,
          itemBuilder: (itemContext, index) {
            int currentMonth = _sequentialMonths[index].month - 1;
            int currentYear = _sequentialMonths[index].year;
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                _calendarBody(_sequentialMonths[index].sequentialDates),
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
            midYear = (midYear == null)
                ? _currentStartDateTime.year + 9
                : midYear + 9;
          } else {
            midYear = (midYear == null)
                ? _currentStartDateTime.year - 9
                : midYear - 9;
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
      padding: EdgeInsets.symmetric(vertical: 12),
      itemCount: _sequentialDates.length + 7,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        if (index < 7) return _weekDayTitle(index);
        if (widget.calendarType == CalendarType.CALENDAR_RANGE_DAY) {
          if ((CalendarUtils.calculateDifference(
                          _sequentialDates[index - 7].date, startRangeTime) ==
                      0 ||
                  CalendarUtils.calculateDifference(
                          _sequentialDates[index - 7].date, endRangeTime) ==
                      0) &&
              _sequentialDates[index - 7].thisMonth)
            return _selector(_sequentialDates[index - 7]);
          return _calendarDates(_sequentialDates[index - 7]);
        } else {
          if (_sequentialDates[index - 7].date == _selectedDateTime &&
              _sequentialDates[index - 7].thisMonth)
            return _selector(_sequentialDates[index - 7]);
          return _calendarDates(_sequentialDates[index - 7]);
        }
      },
    );
  }

  // calendar header
  Widget _weekDayTitle(int index) {
    return Center(
      child: Text(
        CalendarUtils.weekDays[index],
        style: TextStyle(
            color: widget.titleColor ?? Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  // calendar element
  Widget _calendarDates(CalendarModel calendarDate) {
    Color backgroundColor = Colors.transparent;
    if (widget.calendarType == CalendarType.CALENDAR_RANGE_DAY &&
        startRangeTime != null &&
        endRangeTime != null) {
      if (calendarDate.thisMonth &&
          calendarDate.date.isAfter(startRangeTime) &&
          calendarDate.date.isBefore(endRangeTime)) {
        backgroundColor = widget.rangDateColor;
      }
    }

    return InkWell(
      onTap: calendarDate.thisMonth ? () => onDateSelect(calendarDate) : null,
      radius: 40,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        color: backgroundColor,
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
      ),
    );
  }

  //onDateSelected
  void onDateSelect(CalendarModel calendarDate) {
    if (widget.calendarType == CalendarType.CALENDAR_SINGLE_DAY) {
      if (_selectedDateTime != calendarDate.date) {
        if (calendarDate.nextMonth) {
          _getNextMonth();
        } else if (calendarDate.prevMonth) {
          _getPrevMonth();
        }
        setState(() => _selectedDateTime = calendarDate.date);
      }
      if (widget.onDateSelected != null) {
        widget.onDateSelected(_selectedDateTime);
      }
    } else if (widget.calendarType == CalendarType.CALENDAR_RANGE_DAY) {
      if (stepDo == 1) {
        setState(() {
          startRangeTime = calendarDate.date;
          stepDo++;
        });
      } else if (stepDo == 2) {
        if (startRangeTime != calendarDate.date &&
            startRangeTime.isBefore(calendarDate.date)) {
          setState(() {
            endRangeTime = calendarDate.date;
            stepDo++;
          });
          widget.onRangeDateSelected(startRangeTime, endRangeTime);
        } else {
          setState(() {
            startRangeTime = calendarDate.date;
            stepDo = 2;
          });
        }
      } else {
        setState(() {
          setState(() {
            startRangeTime = calendarDate.date;
            endRangeTime = null;
            stepDo = 2;
          });
        });
      }
    }
  }

  // date selector
  Widget _selector(CalendarModel calendarDate) {
    var borderRadius;
    if (startRangeTime != null && endRangeTime != null) {
      if (CalendarUtils.calculateDifference(
              calendarDate.date, startRangeTime) ==
          0) {
        borderRadius = BorderRadius.only(
            topLeft: Radius.circular(50), bottomLeft: Radius.circular(50));
      } else if (CalendarUtils.calculateDifference(
              calendarDate.date, endRangeTime) ==
          0) {
        borderRadius = BorderRadius.only(
            topRight: Radius.circular(50), bottomRight: Radius.circular(50));
      }
    } else {
      borderRadius = BorderRadius.all(Radius.circular(50));
    }
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: widget.rangDateColor,
        borderRadius: borderRadius,
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
    if (_currentStartDateTime.month == 12) {
      _currentStartDateTime = DateTime(_currentStartDateTime.year + 1, 1);
    } else {
      _currentStartDateTime =
          DateTime(_currentStartDateTime.year, _currentStartDateTime.month + 1);
    }
    _getCalendar();
  }

  // get previous month calendar
  void _getPrevMonth() {
    if (_currentStartDateTime.month == 1) {
      _currentStartDateTime = DateTime(_currentStartDateTime.year - 1, 12);
    } else {
      _currentStartDateTime =
          DateTime(_currentStartDateTime.year, _currentStartDateTime.month - 1);
    }
    _getCalendar();
  }

  // get calendar for current month
  void _getCalendar({int index}) {
    _sequentialDates = CalendarUtils().getMonthCalendar(
        _currentStartDateTime.month, _currentStartDateTime.year,
        startWeekDay: StartWeekDay.monday);
    _sequentialMonths.add(MonthModel(
        index: index,
        sequentialDates: _sequentialDates,
        month: _currentStartDateTime.month,
        year: _currentStartDateTime.year));
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
              '${_currentStartDateTime.year}',
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
                _currentStartDateTime =
                    DateTime(_currentStartDateTime.year, index + 1);
                _getCalendar();
                setState(() => _currentView = CalendarViews.dates);
              },
              title: Center(
                child: Text(
                  CalendarUtils.monthNames[index],
                  style: TextStyle(
                      fontSize: 18,
                      color: (index == _currentStartDateTime.month - 1)
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

  void changeInitRangeDate(DateTime startDay, DateTime endDay) {
    setState(() {
      startRangeTime = startDay;
      endRangeTime = endDay;
    });
    int currentMonth = _sequentialMonths.indexWhere((element) =>
        element.month == startDay.month && element.year == startDay.year);
    int currentDay = _sequentialMonths[currentMonth].sequentialDates.indexWhere(
        (element) => element.date.day == startDay.day && element.thisMonth);
    double offset = currentMonth * MediaQuery.of(context).size.width;
    offset += (currentDay / 6) * (MediaQuery.of(context).size.width / 7);
    _scrollController.animateTo(offset,
        duration: Duration(
          milliseconds: 300,
        ),
        curve: Curves.linear);
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
                    fontWeight: FontWeight.w400),
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
                    _currentStartDateTime =
                        DateTime(thisYear, _currentStartDateTime.month);
                    _getCalendar();
                    setState(() => _currentView = CalendarViews.months);
                  },
                  title: Center(
                    child: Text(
                      '$thisYear',
                      style: TextStyle(
                          fontSize: 18,
                          color: (thisYear == _currentStartDateTime.year)
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
