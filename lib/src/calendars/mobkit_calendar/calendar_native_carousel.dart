import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import '../../../mobkit_calendar.dart';

class NativeCarousel extends StatefulWidget {
  const NativeCarousel({
    Key? key,
    required this.listAppointmentModel,
    required this.calendarDate,
    required this.minDate,
    this.onPopupChange,
    this.onSelectionChange,
    required this.customCalendarModel,
    this.config,
  }) : super(key: key);
  final ValueNotifier<DateTime?> calendarDate;
  final DateTime minDate;
  final List<MobkitCalendarAppointmentModel> listAppointmentModel;
  final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime, bool isSameMonth)? onPopupChange;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final MobkitCalendarConfigModel? config;

  @override
  State<NativeCarousel> createState() => _CarouselState();
}

class _CarouselState extends State<NativeCarousel> {
  late PageController _pageController;
  Timer? timer;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = (widget.calendarDate.value ?? DateTime.now()).difference(widget.minDate).inDays.abs();
    _pageController = PageController(
      viewportFraction: widget.config?.calendarPopupConfigModel?.viewportFraction ?? 1.0,
      initialPage: (widget.calendarDate.value ?? DateTime.now()).difference(widget.minDate).inDays.abs(),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pageController.position.isScrollingNotifier.addListener(() {
        timer?.cancel();
        if (!_pageController.position.isScrollingNotifier.value) {
          timer = Timer(const Duration(milliseconds: 500), () {
            widget.onSelectionChange?.call([], widget.calendarDate.value!);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  int calculateMonth(DateTime today) {
    final DateTime firstDayOfMonth = DateTime(today.year, today.month);
    return calculateWeekCount(firstDayOfMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: widget.config?.calendarPopupConfigModel?.popupHeight ?? MediaQuery.of(context).size.height * 0.6,
          child: PageView.builder(
              pageSnapping: true,
              controller: _pageController,
              onPageChanged: (page) {
                widget.calendarDate.value = widget.minDate.add(Duration(days: page));
                _currentPage = page;
              },
              itemBuilder: (context, index) {
                DateTime currentDate = widget.minDate.add(Duration(days: index));
                bool active = currentDate == widget.calendarDate.value;
                return AnimatedContainer(
                  duration: Duration(milliseconds: widget.config?.calendarPopupConfigModel?.animateDuration ?? 500),
                  margin: EdgeInsets.symmetric(
                      horizontal: widget.config?.calendarPopupConfigModel?.popupSpace ?? 10,
                      vertical: active ? 0 : widget.config?.calendarPopupConfigModel?.verticalPadding ?? 30),
                  decoration: active
                      ? widget.config?.calendarPopupConfigModel?.popUpBoxDecoration
                      : widget.config?.calendarPopupConfigModel?.popUpBoxDecoration?.copyWith(
                          color: widget.config?.calendarPopupConfigModel?.popUpBoxDecoration?.color?.withOpacity(0.6)),
                  child: widget.onPopupChange?.call(
                      findCustomModel(widget.customCalendarModel, currentDate),
                      currentDate,
                      (widget.calendarDate.value != null &&
                          !widget.calendarDate.value!.isSameMonth(widget.minDate.add(Duration(days: _currentPage))))),
                );
              }),
        ),
      ],
    );
  }
}
