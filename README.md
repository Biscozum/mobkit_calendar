# Mobkit Calendar

Mobkit Calendar.

## Table of contents

- [Technicial Specifications](#technicial-specifications)
- [Views](#views)
- [Parameters](#parameters)
- [Appointments](#appointments)
- [Recurrience Events](#recurrience_events)


##  Calendar features
---
####  Technicial Specifications

* **Customizable Calendar Views** - It allows you to easily achieve the look you want with its multiple views and special options of these views..


* **Appointments** - Appointments contain information about an event or meeting scheduled for a specific time. It has many customizable fields such as Start/End time, event title, event detail and what color it will appear in.

* **Recurring appointments** - Recurring Appointments can recur appointments with daily, weekly and monthly recurrence options. You can add recurrence rules to these options. In this way, you can easily spread your appointments repeatedly over long date ranges.


* **Time zone** - Mobkit Calendar allows you to configure your events according to your desired time zone, regardless of the time on your device.
---
####  Views

* **Monthly View** 

<table>
  <tr>
  <th>Fraction View</th>
  <th>Full Screen View</th>
  <th>Popup View</th>
</tr>
<tr>
  <td>
    <img src="/example/assets/images/monthly_view_fraction.png" />
  </td>
  <td>
    <img src="/example/assets/images/monthly_view_fullscreen.png" />
  </td>
   <td>
    <img src="/example/assets/images/monthly_view_popup.png" />
  </td>
</tr>
<tr>
  <td>
    <img src="/example/assets/videos/monthly_view_fraction_gf.gif" />
  </td>
  <td>
    <img src="/example/assets/videos/monthly_view_fullscreen_gf.gif" />
  </td>
  <td>
    <img src="/example/assets/videos/monthly_view_popup_gf.gif" />
  </td>
</tr>
</table>


* **Weekly View** 

<table>
  <tr>
  <th>All Day Event</th>
  <th>Short Event</th>
</tr>
<tr>
  <td>
    <img src="/example/assets/images/weekly_view.png" />
  </td>
  <td>
    <img src="/example/assets/videos/weekly_view_gf.gif" />
  </td>
</tr>

</table>


* **Daily View** 


<table>
  <tr>
  <th>All Day Event</th>
  <th>Short Event</th>
</tr>
<tr>
  <td>
    <img src="/example/assets/images/daily_view_all_day_event.png" />
  </td>
  <td>
    <img src="/example/assets/images/daily_view_short_day_event.png" />
  </td>
</tr>
<tr>
  <td colspan="2" align="center">
    <img src="/example/assets/videos/daily_view_gf.gif" />
  </td>
</tr>
</table>


* **Agenda View** 

<table>
  <tr>
  <th colspan="2" align="center">Agenda View</th>
</tr>
<tr>
  <td>
    <img src="/example/assets/images/agenda_view.png" />
  </td>
  <td>
    <img src="/example/assets/videos/agenda_view_gf.gif" />
  </td>
</tr>
</table>



##### Parameters
*   **MobkitCalendarConfigModel**
    * **`String? title`** - The title you want to appear at the top of the calendar.
    * **`String? locale`** - It determines in which locale the calendar will work.
    * **`bool showAllDays`** - Whether the calendar will show all days
    * **`bool disableOffDays`** - Turns off all dates of the calendar
    * **`bool disableWeekendsDays`** - Whether to show the bar showing the days of the week above the calendar
    * **`DateTime? disableBefore`** - The calendar closes before the specified date.
    * **`DateTime? disableAfter`** - The calendar closes after the specified date.
    * **`List<DateTime>? disabledDates`** - Specifies which types the calendar will turn off.
    * **`EdgeInsetsGeometry itemSpace`** - Space inside the cells of the calendar
    * **`Duration animationDuration`** - Animation Duration
    * **`Color enabledColor`** - The color that the active days of the calendar will have
    * **`Color disabledColor`** - The color that the inactive days of the calendar will have
    * **`Color selectedColor`** - The color that the selected days of the calendar will have
    * **`Color primaryColor`** - The main theme color of your calendar
    * **`Color gridBorderColor`** - Determines the grid border color on the calendar
    * **`BorderRadiusGeometry borderRadius`** - If non-null, the corners of this box are rounded.
    * **`Color weekDaysBarBorderColor`** - Determines the border color of the WeekDaysBar.
    * **`MobkitCalendarViewType mobkitCalendarViewType`** - Determines what appearance the calendar will have.
      * **(Enum)** monthly
      `Monthly view`
      * ***(Enum)*** weekly
      `Weekly view`
      * ***(Enum)*** daily
      `Daily view`
      * ***(Enum)*** agenda
      `Agenda view`
    * **`bool popupEnable`** - Determines whether a popup will open when the event is clicked.
    * **`CalendarPopupConfigModel calendarPopupConfigModel`** - DIt allows you to customize the Popup that will open when the event is clicked.
      * **(double)** popupHeight
      `Popup height`
      * ***(double)*** popupWidth
      `Popup width`
      * ***(BoxDecoration)*** popUpBoxDecoration
      `Popup decoration`
      * ***(bool)*** popUpOpacity
      `Popup Opacity`
      * ***(int)*** animateDuration
      `Popup animation duration`
      * ***(double)*** popupSpace
      `Popup space`
      * ***(double)*** verticalPadding
      `Padding to be applied to the popups that appear on the sides.`
      * ***(double)*** viewportFraction
      `Determines the spreading rate of the opened carousel relative to the screen.`
    * `TextStyle enableStyle` - The textstyle that the active days of the calendar will have
    * `TextStyle monthDaysStyle` - The textstyle that the days of the month will have in the calendar.
    * `TextStyle weekDaysStyle` - The textstyle that the days of the week will have in the calendar
    * `TextStyle disabledStyle` - The textstyle that the inactive days of the calendar will have
    * `TextStyle currentStyle` - The textstyle that today's date will have
    * `TextStyle selectedStyle` - The textstyle that the selected days in the calendar will have.
