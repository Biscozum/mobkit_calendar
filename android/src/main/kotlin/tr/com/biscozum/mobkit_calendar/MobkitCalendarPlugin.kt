package tr.com.biscozum.mobkit_calendar

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.provider.CalendarContract
import android.provider.CalendarContract.CALLER_IS_SYNCADAPTER
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONObject
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.util.*


/** MobkitCalendarPlugin */
class MobkitCalendarPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,  PluginRegistry.RequestPermissionsResultListener{
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private val MY_CAL_REQ = 101
    private var permissionResult: MethodChannel.Result? = null

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mobkit_calendar")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }



    @SuppressLint("SimpleDateFormat")
    @RequiresApi(Build.VERSION_CODES.O)
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "addCalendar") {
            if (hasPermissions()) {
                result.success(createCalendar(
                    call.argument("calendarName")!!,
                    call.argument("calendarColor"),
                    call.argument("localAccountName")!!,
                ) != null)
            }else{
                result.success(false)
            }
        }else if (call.method == "getPlatformVersion") {
            result.success("Android ${Build.VERSION.RELEASE}")
        }else if (call.method == "requestPermissions") {
            permissionResult = result
            if (!hasPermissions()) {
                requestPermissions ()
            }else{
                result.success(hasPermissions())
            }
        }
        else if (call.method == "addNativeEvent") {
            if (!hasPermissions()) {
                result.success(false)
            }else{
                val cr: ContentResolver = context.contentResolver
                val currentTimeZone = Calendar.getInstance().timeZone.displayName
                var eventId: String? = call.argument("eventId") as String?
                val values = ContentValues()
                values.put(CalendarContract.Events.DTSTART, call.argument("startDate") as Long?)
                values.put(CalendarContract.Events.DTEND, call.argument("endDate") as Long?)
                values.put(CalendarContract.Events.TITLE, call.argument("title") as String?)
                values.put(CalendarContract.Events.DESCRIPTION, call.argument("desc") as String?)
                values.put(CalendarContract.Events.CALENDAR_ID, call.argument("calendarId") as String?)
                values.put(CalendarContract.Events.EVENT_TIMEZONE, currentTimeZone)
                values.put(CalendarContract.Events.ALL_DAY, call.argument("allDay") as Boolean?)
                if (call.argument("location") as String? != null) {
                    values.put(CalendarContract.Events.EVENT_LOCATION, call.argument("location") as String?)
                }
                if (call.argument("url") as String? != null) {
                    values.put(CalendarContract.Events.CUSTOM_APP_URI, call.argument("url") as String?)
                }
                try {
                    val uri: Uri? = cr.insert(CalendarContract.Events.CONTENT_URI, values)
                    // get the event ID that is the last element in the Uri
                    eventId = uri?.lastPathSegment!!.toLong().toString() + ""
                } catch (e: Exception) {
                    Log.e("EVENT", e.message.toString())
                }
                result.success(eventId != null)
            }

        }
        else if(call.method == "openEventDetail"){
            val intent = Intent(Intent.ACTION_VIEW)
            val uri: Uri.Builder = CalendarContract.Events.CONTENT_URI.buildUpon()
            var eventId: String = ((call.arguments as HashMap<*, *>)["eventId"] as String);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            uri.appendPath(eventId)
            intent.setData(uri.build())
            startActivity(this.context, intent, null);
        }
        else if (call.method == "getAccountList") {
            val calendarsProjection: Array<String> = arrayOf<String>(
                CalendarContract.Calendars._ID,
                CalendarContract.Calendars.ACCOUNT_NAME,
                CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
                CalendarContract.Calendars.CALENDAR_COLOR
            );
            var accounts: MutableMap<Any?, Any?> =
                mutableMapOf<Any?, Any?>();
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
                    var model: HashMap<String, Any> = HashMap<String, Any>();
                    model.put(
                        "groupName",
                        if (cur.getString(0) == "1") "Phone" else cur.getString(1),
                    )
                    model.put("accountId", cur.getString(0))
                    model.put(
                        "accountName",
                        if (cur.getString(0) == "1") "Local Calendar" else cur.getString(
                            2
                        )
                    )
                    model.put("isChecked", false)
                    accountGroupModelList.add(model);
                    accounts.put(
                        "accounts", accountGroupModelList
                    );
                }
            }
            cur?.close()
            result.success(JSONObject(accounts).toString());
        }
        else if (call.method == "getEventList") {
            val eventsProjection: Array<String> = arrayOf<String>(
                CalendarContract.Events._ID,
                CalendarContract.Events.TITLE,
                CalendarContract.Events.DTSTART,
                CalendarContract.Events.DTEND,
                CalendarContract.Events.DESCRIPTION,
                CalendarContract.Events.ALL_DAY,
                CalendarContract.Events.CALENDAR_COLOR
            );

            var eventModelList: MutableList<HashMap<String, Any>> =
                mutableListOf<HashMap<String, Any>>();
            var events: MutableMap<Any?, Any?> =
                mutableMapOf<Any?, Any?>();
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
                        var eventModel: HashMap<String, Any> = HashMap<String, Any>();
                        val startDate = cur.getLong(2);
                        val endDate = cur.getLong(3);
                        eventModel.put(
                            "nativeEventId", cur.getString(0)
                        )
                        eventModel.put(
                            "fullName", cur.getString(1)
                        )
                        eventModel.put(
                            "startDate",
                            startDate,
                        )
                        eventModel.put(
                            "endDate", endDate,
                        )
                        eventModel.put(
                            "description", cur.getString(4)
                        )
                        eventModel.put(
                            "isFullDayEvent", cur.getInt(5) != 0,
                        )
                        eventModelList.add(
                            eventModel
                        )
                    }
                }
                events.put(
                    "events", eventModelList
                )
                result.success(JSONObject(events).toString());
                cur?.close();
            } else {
                result.success(JSONObject(events).toString());
            }
        }
        else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    private fun hasPermissions(): Boolean {
        if (23 <= Build.VERSION.SDK_INT) {
            val writeCalendarPermissionGranted = (context.checkSelfPermission(Manifest.permission.WRITE_CALENDAR)
                    === PackageManager.PERMISSION_GRANTED)
            val readCalendarPermissionGranted = (context.checkSelfPermission(Manifest.permission.READ_CALENDAR)
                    === PackageManager.PERMISSION_GRANTED)
            return writeCalendarPermissionGranted && readCalendarPermissionGranted
        }
        return true
    }

    private fun requestPermissions(){
        if (23 <= Build.VERSION.SDK_INT) {
            val permissions = arrayOf<String>(
                Manifest.permission.WRITE_CALENDAR,
                Manifest.permission.READ_CALENDAR
            )
            if (ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_CALENDAR) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_CALENDAR) == PackageManager.PERMISSION_GRANTED) {

            } else {
                ActivityCompat.requestPermissions(activity, permissions, MY_CAL_REQ)
            }
        }
    }



    fun createCalendar(
        calendarName: String,
        calendarColor: String?,
        localAccountName: String,
    ): String? {
        val contentResolver: ContentResolver? = context?.contentResolver

        var uri = CalendarContract.Calendars.CONTENT_URI
        uri = uri.buildUpon()
            .appendQueryParameter(CALLER_IS_SYNCADAPTER, "true")
            .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_NAME, localAccountName)
            .appendQueryParameter(
                CalendarContract.Calendars.ACCOUNT_TYPE,
                CalendarContract.ACCOUNT_TYPE_LOCAL
            )
            .build()
        val values = ContentValues()
        values.put(CalendarContract.Calendars.NAME, calendarName)
        values.put(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, calendarName)
        values.put(CalendarContract.Calendars.ACCOUNT_NAME, localAccountName)
        values.put(CalendarContract.Calendars.ACCOUNT_TYPE, CalendarContract.ACCOUNT_TYPE_LOCAL)
        values.put(
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
            CalendarContract.Calendars.CAL_ACCESS_OWNER
        )
        values.put(
            CalendarContract.Calendars.CALENDAR_COLOR, Color.parseColor(
                (calendarColor
                    ?: "0xFFFF0000").replace("0x", "#")
            )
        ) // Red colour as a default
        values.put(CalendarContract.Calendars.OWNER_ACCOUNT, localAccountName)
        values.put(
            CalendarContract.Calendars.CALENDAR_TIME_ZONE,
            java.util.Calendar.getInstance().timeZone.id
        )

        val result = contentResolver?.insert(uri, values)
        // Get the calendar ID that is the last element in the Uri
        val calendarId = java.lang.Long.parseLong(result?.lastPathSegment!!)

        return calendarId.toString()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (requestCode == MY_CAL_REQ) {
            if (grantResults.isNotEmpty() && !(grantResults.filter { s ->  s ==  PackageManager.PERMISSION_GRANTED}.isEmpty()) ) {
                permissionResult?.success(true)
            } else {
                permissionResult?.success(false)
            }
            return true
        }
        return false
    }
}