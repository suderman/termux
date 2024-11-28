# cp ~/.termux/permission.sh /sdcard/Android/permission.sh
# rish
# sh /sdcard/Android/permission.sh
settings put global settings_enable_monitor_phantom_procs false
pm grant net.dinglisch.android.taskerm android.permission.SET_MEDIA_KEY_LISTENER
pm grant net.dinglisch.android.taskerm android.permission.DUMP
pm grant net.dinglisch.android.taskerm android.permission.SET_VOLUME_KEY_LONG_PRESS_LISTENER
