package com.safeet.disable_battery_optimization;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.os.Build;
import android.Manifest;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;

import android.provider.Settings;
import android.net.Uri;
import android.content.ComponentName;

import com.thelittlefireman.appkillermanager.managers.KillerManager;

import java.util.List;

import com.safeet.disable_battery_optimization.utils.BatteryOptimizationUtil;
import com.safeet.disable_battery_optimization.utils.PrefKeys;
import com.safeet.disable_battery_optimization.utils.PrefUtils;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import android.content.pm.PackageManager;

import androidx.core.content.ContextCompat;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.*;

/**
 * DisableBatteryOptimizationPlugin
 */
public class DisableBatteryOptimizationPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler,
        io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener {

    private Context mContext;
    private Activity mActivity;

    // These are null when not using v2 embedding.
    private MethodChannel channel;

    static int PERMISSION_REQUEST_POST_NOTIFICATION_CODE = 1001;
    private MethodChannel.Result resultCallback;

    private static final int REQUEST_DISABLE_BATTERY_OPTIMIZATIONS = 2244;
    private final String TAG = "DisableOptimization";
    private static final String CHANNEL_NAME = "com.safeet.disable_battery_optimization";

    private String autoStartTitle;
    private String autoStartMessage;
    private String manBatteryTitle;
    private String manBatteryMessage;


    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(new DisableBatteryOptimizationPlugin(registrar.activity(), registrar.activeContext()));
    }

    private DisableBatteryOptimizationPlugin(Activity activity, Context context) {
        if (activity != null)
            mActivity = activity;
        if (context != null)
            mContext = context;
    }

    /**
     * Default constructor for DisableBatteryOptimizationPlugin.
     *
     * <p>Use this constructor when adding this plugin to an app with v2 embedding.
     */
    public DisableBatteryOptimizationPlugin() {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        resultCallback = result;

        switch (call.method) {
            case "showEnableAutoStart":
                try {
                    List arguments = (List) call.arguments;
                    if (arguments != null) {
                        autoStartTitle = String.valueOf(arguments.get(0));
                        autoStartMessage = String.valueOf(arguments.get(1));
                        showAutoStartEnabler(null, null);
                        result.success(true);
                    } else {
                        Log.e(TAG, "Unable to request enableAutoStart. Arguments are null");
                        result.success(false);
                    }
                } catch (Exception ex) {
                    Log.e(TAG, "Exception in showEnableAutoStart. " + ex.toString());
                    result.success(false);
                }
                break;
            case "showDisableManBatteryOptimization":
                try {
                    List arguments = (List) call.arguments;
                    if (arguments != null) {
                        manBatteryTitle = String.valueOf(arguments.get(0));
                        manBatteryMessage = String.valueOf(arguments.get(1));
                        showManBatteryOptimizationDisabler(false);
                        result.success(true);
                    } else {
                        Log.e(TAG, "Unable to request disable manufacturer battery optimization. Arguments are null");
                        result.success(false);
                    }
                } catch (Exception ex) {
                    Log.e(TAG, "Exception in showDisableManBatteryOptimization. " + ex.toString());
                    result.success(false);
                }
                break;
            case "showDisableBatteryOptimization":
                try {
                    showIgnoreBatteryPermissions();
                    result.success(true);
                } catch (Exception ex) {
                    Log.e(TAG, "Exception in showDisableBatteryOptimization. " + ex.toString());
                    result.success(false);
                }
                break;
            case "disableAllOptimizations":
                //try {
                List arguments = (List) call.arguments;
                if (arguments != null) {
                    autoStartTitle = String.valueOf(arguments.get(0));
                    autoStartMessage = String.valueOf(arguments.get(1));
                    manBatteryTitle = String.valueOf(arguments.get(2));
                    manBatteryMessage = String.valueOf(arguments.get(3));
                    handleIgnoreAllBatteryPermission();
                    result.success(true);
                } else {
                    Log.e(TAG, "Unable to request disable all optimizations. Arguments are null");
                    result.success(false);
                }
                    /*
                } catch (Exception ex) {
                    Log.e(TAG, "Exception in disableAllOptimizations. " + ex.toString());
                    result.success(false);
                }
                     */
                break;
            case "isAutoStartEnabled":
                result.success(getManAutoStart());
                break;
            case "isBatteryOptimizationDisabled":
                result.success(BatteryOptimizationUtil.isIgnoringBatteryOptimizations(mContext));
                break;
            case "isManBatteryOptimizationDisabled":
                result.success(getManBatteryOptimization());
                break;
            case "isAllOptimizationsDisabled":
                result.success(getManAutoStart() && BatteryOptimizationUtil.isIgnoringBatteryOptimizations(mContext) && getManBatteryOptimization());
                break;

            case "canDrawOverlayWindow":
                result.success(Settings.canDrawOverlays(mContext));
                break;

            case "askOverlayManagePermission": {
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:" + mContext.getPackageName()));
                mActivity.startActivityForResult(intent, 10);
                result.success(null);
                break;
            }

            case "bringAppToForeground": {
                Intent intent = new Intent(Intent.ACTION_MAIN)
                        .addCategory(Intent.CATEGORY_LAUNCHER)
                        .setClassName("com.safetransportset.safe_driver", "com.safetransportset.safe_driver.MainActivity")
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        .addFlags(Intent.FLAG_FROM_BACKGROUND)
                        .setComponent(new ComponentName("com.safetransportset.safe_driver", "com.safetransportset.safe_driver.MainActivity"));
                mContext.startActivity(intent);
                result.success(null);
                break;
            }

            case "isNotificationPermissionGranted": {
                // This is only necessary for API level >= 33 (TIRAMISU)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    if (ContextCompat.checkSelfPermission(mContext, Manifest.permission.POST_NOTIFICATIONS) ==
                            PackageManager.PERMISSION_GRANTED) {
                        result.success(true);
                    } else {
                        result.success(false);
                    }
                } else {
                    result.success(true);
                }
                break;
            }

            case "askNotificationPermission": {
                // This is only necessary for API level >= 33 (TIRAMISU)
                //if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (Build.VERSION.SDK_INT >= 33) {
                    List<String> permissions = new ArrayList<>();
                    permissions.add(Manifest.permission.POST_NOTIFICATIONS);
                    ActivityCompat.requestPermissions(mActivity, permissions.toArray(new String[0]), PERMISSION_REQUEST_POST_NOTIFICATION_CODE);
                }
                break;
            }


            default:
                result.notImplemented();
        }
    }

    @Override
    public boolean onRequestPermissionsResult(
            int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode != PERMISSION_REQUEST_POST_NOTIFICATION_CODE) {
            return false;
        }

        if (this.mActivity == null) {
            //Log.e("apk_installer", "Trying to process permission result without an valid Activity instance");
            return false;
        }

        if (permissions.length != 1) {
            //Log.e("apk_installer", "Only requested 1 permission, returning multiple");
            return false;
        }

        if (permissions[0] != Manifest.permission.POST_NOTIFICATIONS) {
            Log.e("apk_installer", "Unrequested permission result returned");
            return false;
        }

        resultCallback.success(grantResults[0] == PackageManager.PERMISSION_GRANTED);
        return true;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        mContext = binding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
        mContext = mActivity.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        mActivity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        mActivity = null;
        channel.setMethodCallHandler(null);
    }

    private void showAutoStartEnabler(@NonNull final BatteryOptimizationUtil.OnBatteryOptimizationAccepted positiveCallback,
                                      @NonNull final BatteryOptimizationUtil.OnBatteryOptimizationCanceled negativeCallback) {
        BatteryOptimizationUtil.showBatteryOptimizationDialog(
                mActivity,
                KillerManager.Actions.ACTION_AUTOSTART,
                autoStartTitle,
                autoStartMessage,
                positiveCallback,
                negativeCallback
        );
    }

    private void showManBatteryOptimizationDisabler(boolean isRequestNativeBatteryOptimizationDisabler) {
        BatteryOptimizationUtil.showBatteryOptimizationDialog(
                mActivity,
                KillerManager.Actions.ACTION_POWERSAVING,
                manBatteryTitle,
                manBatteryMessage,
                () -> {
                    setManBatteryOptimization(true);
                    if (isRequestNativeBatteryOptimizationDisabler) {
                        showIgnoreBatteryPermissions();
                    }
                },
                () -> {
                    if (isRequestNativeBatteryOptimizationDisabler) {
                        showIgnoreBatteryPermissions();
                    }
                }
        );
    }

    private void showIgnoreBatteryPermissions() {
        if (!BatteryOptimizationUtil.isIgnoringBatteryOptimizations(mContext)) {
            final Intent ignoreBatteryOptimizationsIntent = BatteryOptimizationUtil.getIgnoreBatteryOptimizationsIntent(mContext);
            if (ignoreBatteryOptimizationsIntent != null) {
                mContext.startActivity(ignoreBatteryOptimizationsIntent);
            } else {
                Log.i(TAG, "Can't ignore the battery optimization as the intent is null");
            }
        } else {
            Log.i(TAG, "Battery optimization is already disabled");
        }
    }

    private void handleIgnoreAllBatteryPermission() {
        boolean isManBatteryOptimizationDisabled = getManBatteryOptimization();
        if (!getManAutoStart()) {
            showAutoStartEnabler(() -> {
                setManAutoStart(true);
                if (!isManBatteryOptimizationDisabled)
                    showManBatteryOptimizationDisabler(true);
                else
                    showIgnoreBatteryPermissions();
            }, () -> {
                if (!isManBatteryOptimizationDisabled)
                    showManBatteryOptimizationDisabler(true);
                else
                    showIgnoreBatteryPermissions();
            });
        } else {
            if (!isManBatteryOptimizationDisabled)
                showManBatteryOptimizationDisabler(true);
            else
                showIgnoreBatteryPermissions();
        }
    }

    public void setManBatteryOptimization(boolean val) {
        PrefUtils.saveToPrefs(mContext, PrefKeys.IS_MAN_BATTERY_OPTIMIZATION_ACCEPTED, val);
    }

    public boolean getManBatteryOptimization() {
        return (boolean) PrefUtils.getFromPrefs(mContext, PrefKeys.IS_MAN_BATTERY_OPTIMIZATION_ACCEPTED, false);
    }

    public void setManAutoStart(boolean val) {
        PrefUtils.saveToPrefs(mContext, PrefKeys.IS_MAN_AUTO_START_ACCEPTED, val);
    }

    public boolean getManAutoStart() {
        return (boolean) PrefUtils.getFromPrefs(mContext, PrefKeys.IS_MAN_AUTO_START_ACCEPTED, false);
    }
}
