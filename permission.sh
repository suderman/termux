# cp ~/.termux/permission.sh /sdcard/Android/permission.sh
# rish
# sh /sdcard/Android/permission.sh
settings put global settings_enable_monitor_phantom_procs false
pm grant net.dinglisch.android.taskerm android.permission.SET_MEDIA_KEY_LISTENER
pm grant net.dinglisch.android.taskerm android.permission.DUMP
pm grant net.dinglisch.android.taskerm android.permission.SET_VOLUME_KEY_LONG_PRESS_LISTENER
# Night Charge turns location off on the wireless pad. Granted 2026-11-17.
pm grant net.dinglisch.android.taskerm android.permission.WRITE_SECURE_SETTINGS
# Tasker asks for "Modify system settings" when it edits Location Mode.
appops set net.dinglisch.android.taskerm WRITE_SETTINGS allow
# Termux:Tasker runs ~/.termux/tasker scripts only for hosts holding this.
pm grant net.dinglisch.android.taskerm com.termux.permission.RUN_COMMAND
