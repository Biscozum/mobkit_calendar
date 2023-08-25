import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import '../../../mobkit_calendar.dart';

class NativeCarousel extends StatefulWidget {
  const NativeCarousel({
    Key? key,
    required this.listAppointmentModel,
    required this.date,
    required this.onPopupChange,
    required this.onSelectionChange,
    required this.customCalendarModel,
    this.config,
  }) : super(key: key);
  final ValueNotifier<DateTime> date;
  final List<MobkitCalendarAppointmentModel> listAppointmentModel;
  final Widget? Function(List<MobkitCalendarAppointmentModel>, DateTime datetime) onPopupChange;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final MobkitCalendarConfigModel? config;

  @override
  State<NativeCarousel> createState() => _CarouselState();
}

class _CarouselState extends State<NativeCarousel> {
  late PageController _pageController;
  late int activePage = widget.date.value.day;
  List<DateTime> showDates = [];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
        viewportFraction: widget.config?.calendarPopupConfigModel?.viewportFraction ?? 1.0,
        initialPage: widget.date.value.day);
    showDates = getDaysInBetween(DateTime(widget.date.value.year, widget.date.value.month, 0),
        DateTime(widget.date.value.year, widget.date.value.month + 1, 1));
  }

  int calculateMonth(DateTime today) {
    final DateTime firstDayOfMonth = DateTime(today.year, today.month);
    return calculateWeekCount(firstDayOfMonth);
  }

  setShowDates(bool isNext) {
    if (isNext) {
      showDates = getDaysInBetween(DateTime(widget.date.value.year, widget.date.value.month, 0),
          DateTime(widget.date.value.year, widget.date.value.month + 1, 1));
      _pageController.jumpToPage(
        1,
      );
      widget.onSelectionChange([], widget.date.value);
    } else {
      showDates = getDaysInBetween(DateTime(widget.date.value.year, widget.date.value.month, 0),
          DateTime(widget.date.value.year, widget.date.value.month + 1, 1));
      _pageController.jumpToPage(
        showDates.length - 2,
      );
      widget.onSelectionChange([], widget.date.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: widget.config?.calendarPopupConfigModel?.popupHeight ?? MediaQuery.of(context).size.height * 0.6,
          child: PageView.builder(
              itemCount: showDates.length,
              pageSnapping: true,
              controller: _pageController,
              onPageChanged: (page) {
                widget.onSelectionChange(findCustomModel(widget.customCalendarModel, showDates[page]), showDates[page]);
                widget.date.value = showDates[page];
                showDates.first == showDates[page] ? setShowDates(false) : null;
                showDates.last == showDates[page] ? setShowDates(true) : null;
                setState(() {});
              },
              itemBuilder: (context, index) {
                bool active = showDates[index] == widget.date.value;
                return AnimatedContainer(
                  duration: Duration(milliseconds: widget.config?.calendarPopupConfigModel?.animateDuration ?? 500),
                  margin: EdgeInsets.symmetric(
                      horizontal: widget.config?.calendarPopupConfigModel?.popupSpace ?? 10,
                      vertical: active ? 0 : widget.config?.calendarPopupConfigModel?.passiveVerticalPadding ?? 30),
                  decoration: active
                      ? widget.config?.calendarPopupConfigModel?.popUpBoxDecoration
                      : widget.config?.calendarPopupConfigModel?.popUpBoxDecoration?.copyWith(
                          color: widget.config?.calendarPopupConfigModel?.popUpBoxDecoration?.color?.withOpacity(0.6)),
                  child: widget.onPopupChange(
                      findCustomModel(widget.customCalendarModel, showDates[index]), showDates[index]),
                );
              }),
        ),
      ],
    );
  }
}
