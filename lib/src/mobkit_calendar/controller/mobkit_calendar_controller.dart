import 'package:flutter/material.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';

/// Controller that allows you to use [MobkitCalendar] with all its functions
class MobkitCalendarController extends ChangeNotifier {
  DateTime _calendarDate = DateTime.now();
  DateTime? _selectedDate;
  List<MobkitCalendarAppointmentModel> _appoitnments = [];
  late PageController _pageController;
  MobkitCalendarViewType _mobkitCalendarViewType = MobkitCalendarViewType.monthly;

  List<MobkitCalendarAppointmentModel> get appoitnments {
    return _appoitnments;
  }

  set selectedDate(DateTime? selectedDate) {
    _selectedDate = selectedDate;
    notifyListeners();
  }

  DateTime? get selectedDate {
    return _selectedDate;
  }

  set appoitnments(List<MobkitCalendarAppointmentModel> newList) {
    _appoitnments = newList;
    notifyListeners();
  }

  DateTime get calendarDate {
    return _calendarDate;
  }

  set calendarDate(DateTime calendarDate) {
    _calendarDate = calendarDate;
    notifyListeners();
  }

  PageController get pageController {
    return _pageController;
  }

  setPageController(DateTime minDate, double viewportFraction) {
    _pageController = PageController(
        initialPage: mobkitCalendarViewType == MobkitCalendarViewType.monthly
            ? (((calendarDate.year * 12) + calendarDate.month) - ((minDate.year * 12) + minDate.month))
            : ((calendarDate.findFirstDateOfTheWeek().difference(minDate.findFirstDateOfTheWeek()).inDays) ~/ 7).abs(),
        viewportFraction: viewportFraction);
  }

  set mobkitCalendarViewType(MobkitCalendarViewType mobkitCalendarViewType) {
    _mobkitCalendarViewType = mobkitCalendarViewType;

    notifyListeners();
  }

  MobkitCalendarViewType get mobkitCalendarViewType {
    return _mobkitCalendarViewType;
  }

  MobkitCalendarController({
    DateTime? calendarDateTime,
    DateTime? selectedDateTime,
    List<MobkitCalendarAppointmentModel>? appoitnmentList,
    MobkitCalendarViewType? viewType,
  }) {
    calendarDate = calendarDateTime ?? DateTime.now();
    selectedDate = selectedDateTime;
    appoitnments = appoitnmentList ?? [];
    mobkitCalendarViewType = viewType ?? MobkitCalendarViewType.monthly;
  }

  void nextPage(PageController pageController, Duration duration, Curve curve) {
    pageController.nextPage(duration: duration, curve: curve);
  }

  void previousPage(PageController pageController, Duration duration, Curve curve) {
    pageController.previousPage(duration: duration, curve: curve);
  }

  void popupChanged(DateTime minDate, int page) {
    if (selectedDate!.month != minDate.add(Duration(days: page)).month) {
      if (selectedDate!.isBefore((minDate.add(Duration(days: page))))) {
        pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
      } else if (selectedDate!.isAfter((minDate.add(Duration(days: page))))) {
        pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
      }
      selectedDate = (minDate.add(Duration(days: page)));
    } else {
      selectedDate = (minDate.add(Duration(days: page)));
    }
  }
}
