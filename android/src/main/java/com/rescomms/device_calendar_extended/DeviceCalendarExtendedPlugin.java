package com.rescomms.device_calendar_extended;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;

import com.rescomms.device_calendar_extended.devicecalendar.DeviceCalendarPlugin;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static com.rescomms.device_calendar_extended.devicecalendar.DeviceCalendarPluginKt.STREAM_NAME;

/** DeviceCalendarExtendedPlugin */
public class DeviceCalendarExtendedPlugin implements FlutterPlugin {
  static EventChannel.EventSink events;
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "device_calendar_extended");
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterPluginBinding.getFlutterEngine());
    Registrar registrar = shimPluginRegistry.registrarFor("com.rescomms.device_calendar_extended.devicecalendar.DeviceCalendarPlugin");
//
//    CalendarReceiver receiver = new CalendarReceiver();
//    IntentFilter filter = new IntentFilter(Intent.ACTION_PROVIDER_CHANGED);
//    filter.addDataScheme("content");
//    filter.addDataAuthority("com.android.calendar", null);
//    registrar.activity().registerReceiver(receiver, filter);
//    new EventChannel(flutterPluginBinding.getBinaryMessenger(), STREAM_NAME).setStreamHandler(receiver);
    channel.setMethodCallHandler(DeviceCalendarPlugin.registerWith(registrar));
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "device_calendar_extended");
    channel.setMethodCallHandler(DeviceCalendarPlugin.registerWith(registrar));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
