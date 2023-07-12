package tr.com.biscozum.mobkit_calendar

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.graphics.Color
import android.os.Build
import android.provider.CalendarContract
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.text.SimpleDateFormat
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.util.*


/** MobkitCalendarPlugin */
class MobkitCalendarPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mobkit_calendar")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${Build.VERSION.RELEASE}")
        } else if (call.method == "getAccountList") {
            val calendarsProjection: Array<String> = arrayOf<String>(
                CalendarContract.Calendars._ID,
                CalendarContract.Calendars.ACCOUNT_NAME,
                CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
                CalendarContract.Calendars.CALENDAR_COLOR
            );
            var accounts: HashMap<String, MutableList<HashMap<String,
                    Any>>> =
                HashMap<String, MutableList<HashMap<String,
                        Any>>>();
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_CALENDAR)
                != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.READ_CALENDAR), 1)
            } else {
                if(ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_CALENDAR)
                    != PackageManager.PERMISSION_GRANTED){
                    ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.WRITE_CALENDAR), 2)
                }else{
                    val cur: Cursor? = context.contentResolver.query(
                        CalendarContract.Calendars.CONTENT_URI,
                        calendarsProjection,
                        null,
                        null,
                        null
                    );
                    if (cur != null && cur.count > 0
                    ) {
                        var accountGroupModelList: MutableList<HashMap<String, Any>> =
                            mutableListOf<HashMap<String, Any>>();

                        while (cur.moveToNext()) {
                            if (accounts["accountGroupModels"] != null && accounts["accountGroupModels"]!!.any {
                                    it["groupName"] == cur.getString(
                                        1
                                    )
                                }) {
                                var model: HashMap<String, Any> = HashMap<String, Any>();
                                var modelList: MutableList<HashMap<String, Any>> =
                                    mutableListOf<HashMap<String, Any>>();
                                model.put("accountId", cur.getString(0));
                                model.put(
                                    "accountName",
                                    if (cur.getString(0) == "1") "Yerel Takvim" else cur.getString(
                                        2
                                    )
                                );
                                model.put("isChecked", false);
                                model.put(
                                    "accountColor",
                                    Color.parseColor("#7209b7")
                                );
                                modelList.add(model)
                                ((accounts["accountGroupModels"]!!.first {
                                    it["groupName"] == cur.getString(
                                        1
                                    )
                                } as HashMap<String, Any>)["accountModels"] as MutableList<HashMap<String, Any>>).add(
                                    model
                                );

                            } else {
                                var groupModel: HashMap<String, Any> = HashMap<String, Any>();
                                var modelList: MutableList<HashMap<String, Any>> =
                                    mutableListOf<HashMap<String, Any>>();
                                var model: HashMap<String, Any> = HashMap<String, Any>();
                                groupModel.put(
                                    "groupName",
                                    if (cur.getString(0) == "1") "Telefon" else cur.getString(1),
                                )
                                model.put("accountId", cur.getString(0))
                                model.put(
                                    "accountName",
                                    if (cur.getString(0) == "1") "Yerel Takvim" else cur.getString(
                                        2
                                    )
                                )
                                model.put("isChecked", false)
                                model.put("accountColor", Color.parseColor("#7209b7"))
                                modelList.add(model);
                                groupModel.put(
                                    "accountModels",
                                    modelList
                                )
                                accountGroupModelList.add(groupModel);
                                accounts.put(
                                    "accountGroupModels", accountGroupModelList
                                );
                            }

                        }
                    }
                    cur?.close()
                }
            }
            result.success(accounts);
        } else if (call.method == "getEventList") {
            val eventsProjection: Array<String> = arrayOf<String>(
                CalendarContract.Events._ID,
                CalendarContract.Events.TITLE,
                CalendarContract.Events.DTSTART,
                CalendarContract.Events.DTEND,
                CalendarContract.Events.DESCRIPTION,
                CalendarContract.Events.ALL_DAY,
                CalendarContract.Events.CALENDAR_COLOR
            );
            val format = SimpleDateFormat("dd/MM/yyyy HH:mm:ss")

            var eventModelList: HashMap<String, MutableList<HashMap<String,
                    Any>>> =
                HashMap<String, MutableList<HashMap<String,
                        Any>>>();
            var events: MutableList<HashMap<String, Any>> =
                mutableListOf<HashMap<String, Any>>();

            var idListJson: MutableList<String>? = mutableListOf<String>();
            idListJson =
                ((call.arguments as HashMap<*, *>)["idlist"] as MutableList<String>?);
            var calendarStartDate: LocalDateTime =
                LocalDateTime.parse(
                    (call.arguments as HashMap<*, *>)["startDate"] as String,
                    DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")
                );
            var calendarEndDate: LocalDateTime =
                LocalDateTime.parse(
                    (call.arguments as HashMap<*, *>)["endDate"] as String,
                    DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")
                );
            if (idListJson != null && idListJson.isNotEmpty()) {
                var selection: String =
                    "((" + CalendarContract.Events.DTSTART + " >= ?) AND" + "(" + CalendarContract.Events.DTEND + " <= ?)" + "AND" + "(";
                var selectionargs: Array<String> = Array<String>(idListJson.count() + 2) { "" }
                selectionargs[0] =
                    calendarStartDate.atZone(ZoneOffset.UTC)?.toInstant()
                        ?.toEpochMilli().toString();
                selectionargs[1] =
                    calendarEndDate.atZone(ZoneOffset.UTC)?.toInstant()
                        ?.toEpochMilli().toString();
                for (i in 0 until (idListJson.count() - 1)) {
                    selection += "(" + CalendarContract.Events.CALENDAR_ID + " == ?) OR";
                    selectionargs[i + 2] = idListJson[i];
                }

                selection += "(" + CalendarContract.Events.CALENDAR_ID + " == ?)))";
                selectionargs[idListJson.count() - 1 + 2] =
                    idListJson[
                            idListJson.count() - 1
                    ]

                val cur: Cursor? = context.contentResolver.query(
                    CalendarContract.Events.CONTENT_URI,
                    eventsProjection,
                    selection,
                    selectionargs,
                    null
                );
                if (cur != null && cur.count > 0) {
                    while (cur.moveToNext()) {
                        var customCalendarModel: HashMap<String, Any> =
                            HashMap<String, Any>();
                        val startDate = format.format(Date(cur.getLong(2)))
                        val endDate = format.format(Date(cur.getLong(3)))

                        customCalendarModel.put(
                            "nativeEventId", cur.getString(0)
                        )
                        customCalendarModel.put(
                            "fullName", cur.getString(1)
                        )
                        customCalendarModel.put(
                            "startDate", startDate.toString()
                        )
                        customCalendarModel.put(
                            "endDate", endDate.toString()
                        )
                        customCalendarModel.put(
                            "description", cur.getString(4)
                        )
                        customCalendarModel.put(
                            "isFullDayEvent", cur.getInt(5) != 0,
                        )
                        customCalendarModel.put(
                            "nativeEventColor", Color.parseColor("#7209b7"),
                        )
                        events.add(
                            customCalendarModel
                        )
                    }
                }
                eventModelList.put(
                    "eventList", events
                )
                result.success(eventModelList);
                cur?.close();
            } else {
                result.success(eventModelList)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
