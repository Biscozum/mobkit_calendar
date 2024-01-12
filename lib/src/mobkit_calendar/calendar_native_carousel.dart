import 'dart:async';
import 'package:flutter/material.dart';
import '../../mobkit_calendar.dart';

/// When any event in the month view of [MobkitCalendarWidget] is clicked
/// (if the popupEnable value is true), it creates an event list in the form of a carousel.
class CarouselEvent extends StatefulWidget {
  const CarouselEvent({
    Key? key,
    required this.minDate,
    this.onPopupWidget,
    this.onSelectionChange,
    required this.mobkitCalendarController,
    this.config,
    this.onDateChanged,
  }) : super(key: key);
  final DateTime minDate;
  final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime)? onPopupWidget;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final MobkitCalendarConfigModel? config;
  final MobkitCalendarController mobkitCalendarController;
  final Function(DateTime datetime)? onDateChanged;

  @override
  State<CarouselEvent> createState() => _CarouselState();
}

class _CarouselState extends State<CarouselEvent> {
  late PageController _pageController;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.config?.calendarPopupConfigModel?.viewportFraction ?? 1.0,
      initialPage:
          (widget.mobkitCalendarController.selectedDate ?? DateTime.now()).difference(widget.minDate).inDays.abs(),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pageController.position.isScrollingNotifier.addListener(() {
        timer?.cancel();
        if (!_pageController.position.isScrollingNotifier.value) {
          timer = Timer(const Duration(milliseconds: 500), () {
            widget.onSelectionChange?.call([], widget.mobkitCalendarController.selectedDate!);
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
              onPageChanged: (page) => widget.mobkitCalendarController.popupChanged(widget.minDate, page),
              itemBuilder: (context, index) {
                DateTime currentDate = widget.minDate.add(Duration(days: index));
                bool active = currentDate == widget.mobkitCalendarController.selectedDate;
                return AnimatedContainer(
                  duration: Duration(milliseconds: widget.config?.calendarPopupConfigModel?.animateDuration ?? 500),
                  margin: EdgeInsets.symmetric(
                      horizontal: widget.config?.calendarPopupConfigModel?.popupSpace ?? 10,
                      vertical: active ? 0 : widget.config?.calendarPopupConfigModel?.verticalPadding ?? 30),
                  decoration: active
                      ? widget.config?.calendarPopupConfigModel?.popUpBoxDecoration
                      : widget.config?.calendarPopupConfigModel?.popUpBoxDecoration?.copyWith(
                          color: widget.config?.calendarPopupConfigModel?.popUpBoxDecoration?.color?.withOpacity(0.6)),
                  child: widget.onPopupWidget?.call(
                    findCustomModel(widget.mobkitCalendarController.appoitnments, currentDate),
                    currentDate,
                  ),
                );
              }),
        ),
      ],
    );
  }
}
