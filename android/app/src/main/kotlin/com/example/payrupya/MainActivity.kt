////package com.example.payrupya
////
////import io.flutter.embedding.android.FlutterFragmentActivity
////
////class MainActivity : FlutterFragmentActivity()
//
//package com.example.payrupya
//
//import android.app.Activity
//import android.content.Intent
//import android.os.Bundle
//import android.util.Log
//import io.flutter.embedding.android.FlutterFragmentActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
///**
// * MainActivity with AEPS Biometric Device Integration
// *
// * Supports 8 different biometric devices:
// * 1. MANTRA - com.mantra.rdservice
// * 2. MFS110 (Mantra S1) - com.mantra.mfs110.rdservice
// * 3. MORPHO - com.scl.rdservice
// * 4. Secugen - com.secugen.rdservice
// * 5. ACPL - com.acpl.registersdk
// * 6. Idemia (Morpho L1) - com.idemia.l1rdservice
// * 7. ACPL_L1 - com.acpl.registersdk_l1
// * 8. STARTEK - com.acpl.registersdk (uses ACPL)
// * 9. TATVIK - com.aborygen.rdservice
// * 10. MIS100V2 (Mantra Iris) - com.mantra.mis100v2.rdservice
// */
//class MainActivity : FlutterFragmentActivity() {
//
//    companion object {
//        private const val TAG = "MainActivity_AEPS"
//        private const val CHANNEL = "aeps_biometric_channel"
//        private const val REQUEST_CODE_BIOMETRIC = 1001
//
//        // Device Package Names
//        private val DEVICE_PACKAGES = mapOf(
//            "MANTRA" to "com.mantra.rdservice",
//            "MFS110" to "com.mantra.mfs110.rdservice",
//            "MIS100V2" to "com.mantra.mis100v2.rdservice",
//            "MORPHO" to "com.scl.rdservice",
//            "Idemia" to "com.idemia.l1rdservice",
//            "SecuGen Corp." to "com.secugen.rdservice",
//            "STARTEK" to "com.acpl.registersdk",
//            "TATVIK" to "com.aborygen.rdservice",
//            "ACPL" to "com.acpl.registersdk",
//            "ACPL_L1" to "com.acpl.registersdk_l1"
//        )
//
//        // Intent Action
//        private const val RD_SERVICE_ACTION = "in.gov.uidai.rdservice.fp.CAPTURE"
//        private const val RD_SERVICE_IRIS_ACTION = "in.gov.uidai.rdservice.iris.CAPTURE"
//    }
//
//    private var methodChannelResult: MethodChannel.Result? = null
//    private var currentDevice: String = ""
//    private var currentWadh: String = ""
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            when (call.method) {
//                "openBiometric" -> {
//                    val device = call.argument<String>("device") ?: ""
//                    val wadh = call.argument<String>("wadh") ?: ""
//                    val aadhaar = call.argument<String>("aadhaar") ?: ""
//
//                    Log.d(TAG, "Opening biometric for device: $device, wadh: $wadh")
//
//                    methodChannelResult = result
//                    currentDevice = device
//                    currentWadh = wadh
//
//                    openBiometricDevice(device, wadh, aadhaar)
//                }
//                "checkDeviceAvailability" -> {
//                    val device = call.argument<String>("device") ?: ""
//                    val isAvailable = checkDeviceAvailability(device)
//                    result.success(isAvailable)
//                }
//                "getAvailableDevices" -> {
//                    val availableDevices = getAvailableDevices()
//                    result.success(availableDevices)
//                }
//                else -> {
//                    result.notImplemented()
//                }
//            }
//        }
//    }
//
//    /**
//     * Open biometric device for fingerprint capture
//     */
//    private fun openBiometricDevice(device: String, wadh: String, aadhaar: String) {
//        try {
//            val packageName = DEVICE_PACKAGES[device]
//
//            if (packageName == null) {
//                Log.e(TAG, "Unknown device: $device")
//                methodChannelResult?.error("UNKNOWN_DEVICE", "Unknown device: $device", null)
//                methodChannelResult = null
//                return
//            }
//
//            // Check if device app is installed
//            if (!isPackageInstalled(packageName)) {
//                Log.e(TAG, "Device app not installed: $packageName")
//                methodChannelResult?.error(
//                    "DEVICE_NOT_INSTALLED",
//                    "Please install $device RD Service app from Play Store",
//                    mapOf("device" to device, "package" to packageName)
//                )
//                methodChannelResult = null
//                return
//            }
//
//            // Generate PID Options XML
//            val pidOptions = generatePidOptionsXml(wadh)
//
//            Log.d(TAG, "PID Options: $pidOptions")
//
//            // Create intent for RD Service
//            val intent = Intent()
//            intent.action = if (device == "MIS100V2") RD_SERVICE_IRIS_ACTION else RD_SERVICE_ACTION
//            intent.setPackage(packageName)
//            intent.putExtra("PID_OPTIONS", pidOptions)
//
//            // Start activity for result
//            startActivityForResult(intent, REQUEST_CODE_BIOMETRIC)
//
//        } catch (e: Exception) {
//            Log.e(TAG, "Error opening biometric device: ${e.message}", e)
//            methodChannelResult?.error("BIOMETRIC_ERROR", e.message, null)
//            methodChannelResult = null
//        }
//    }
//
//    /**
//     * Generate PID_OPTIONS XML for biometric capture
//     *
//     * @param wadh - WADH hash for eKYC (empty for 2FA and transactions)
//     */
//    private fun generatePidOptionsXml(wadh: String): String {
//        // Format options based on wadh presence
//        val format = if (wadh.isNotEmpty()) "1" else "0"
//        val pidVer = "2.0"
//        val timeout = "20000"
//        val pTimeout = "20000"
//        val env = "P"  // P = Production, PP = Pre-Production
//        val wadAttr = if (wadh.isNotEmpty()) """wadh="$wadh"""" else ""
//
//        return """<?xml version="1.0" encoding="UTF-8"?>
//<PidOptions ver="$pidVer">
//    <Opts
//        fCount="1"
//        fType="2"
//        iCount="0"
//        iType="0"
//        pCount="0"
//        pType="0"
//        format="$format"
//        pidVer="$pidVer"
//        timeout="$timeout"
//        pTimeout="$pTimeout"
//        $wadAttr
//        env="$env"
//    />
//    <CustOpts>
//        <Param name="mantrakey" value="" />
//    </CustOpts>
//</PidOptions>"""
//    }
//
//    /**
//     * Handle activity result from RD Service
//     */
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//
//        if (requestCode == AEPS_CAPTURE_REQUEST) {
//            if (resultCode == Activity.RESULT_OK && data != null) {
//                val pidData = data.getStringExtra("PID_DATA")
//                if (!pidData.isNullOrEmpty()) {
//                    // XML parsing logic to ensure we send clean data to Flutter
//                    val cleanedData = cleanPidData(pidData)
//
//                    if (cleanedData.contains("errCode=\"0\"") || cleanedData.contains("errCode=\"00\"")) {
//                        pendingResult?.success(cleanedData)
//                    } else {
//                        // Extract error message from XML if possible
//                        pendingResult?.error("CAPTURE_FAILED", "Fingerprint scan failed or cancelled", cleanedData)
//                    }
//                } else {
//                    pendingResult?.error("NO_DATA", "No PID data received from RD Service", null)
//                }
//            } else if (resultCode == Activity.RESULT_CANCELED) {
//                pendingResult?.error("CANCELLED", "User cancelled the scan", null)
//            } else {
//                pendingResult?.error("FAILED", "Biometric capture failed", null)
//            }
//            pendingResult = null
//        }
//    }
//
//    private fun cleanPidData(pidData: String): String {
//        var cleaned = pidData.trim()
//        // Remove XML Header if present, some APIs don't like it
//        if (cleaned.startsWith("<?xml")) {
//            val endIndex = cleaned.indexOf(">")
//            if (endIndex != -1) {
//                cleaned = cleaned.substring(endIndex + 1).trim()
//            }
//        }
//        // XML clean-up: remove tabs and double newlines
//        return cleaned.replace("\n", "").replace("\r", "").replace("\t", "")
//    }
////    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
////        super.onActivityResult(requestCode, resultCode, data)
////
////        Log.d(TAG, "onActivityResult: requestCode=$requestCode, resultCode=$resultCode")
////
////        if (requestCode == REQUEST_CODE_BIOMETRIC) {
////            when (resultCode) {
////                Activity.RESULT_OK -> {
////                    val pidData = data?.getStringExtra("PID_DATA")
////
////                    if (pidData != null) {
////                        Log.d(TAG, "PID Data received, length: ${pidData.length}")
////
////                        // Clean up the PID data
////                        val cleanedPidData = cleanPidData(pidData)
////
////                        // Return success with PID data
////                        methodChannelResult?.success(mapOf(
////                            "success" to true,
////                            "pidData" to cleanedPidData,
////                            "device" to currentDevice,
////                            "message" to "Fingerprint captured successfully"
////                        ))
////                    } else {
////                        Log.e(TAG, "PID Data is null")
////                        methodChannelResult?.error(
////                            "NO_PID_DATA",
////                            "No fingerprint data received from device",
////                            null
////                        )
////                    }
////                }
////                Activity.RESULT_CANCELED -> {
////                    Log.w(TAG, "Biometric capture cancelled by user")
////                    methodChannelResult?.error(
////                        "CANCELLED",
////                        "Fingerprint capture cancelled",
////                        null
////                    )
////                }
////                else -> {
////                    // Check for error in result
////                    val errorCode = data?.getStringExtra("ERROR_CODE")
////                    val errorMessage = data?.getStringExtra("ERROR_MESSAGE")
////                        ?: data?.getStringExtra("dnc")
////                        ?: "Unknown error from biometric device"
////
////                    Log.e(TAG, "Biometric error: $errorCode - $errorMessage")
////                    methodChannelResult?.error(
////                        errorCode ?: "BIOMETRIC_ERROR",
////                        errorMessage,
////                        null
////                    )
////                }
////            }
////
////            methodChannelResult = null
////            currentDevice = ""
////            currentWadh = ""
////        }
////    }
////
////    /**
////     * Clean PID data - remove XML declaration and extra whitespace
////     */
////    private fun cleanPidData(pidData: String): String {
////        var cleaned = pidData.trim()
////
////        // Remove XML declaration if present
////        if (cleaned.startsWith("<?xml")) {
////            val endIndex = cleaned.indexOf("?>")
////            if (endIndex != -1) {
////                cleaned = cleaned.substring(endIndex + 2).trim()
////            }
////        }
////
////        // Remove extra whitespace and newlines
////        cleaned = cleaned.replace("\\s+".toRegex(), " ")
////
////        return cleaned
////    }
//
//    /**
//     * Check if a package (RD Service app) is installed
//     */
//    private fun isPackageInstalled(packageName: String): Boolean {
//        return try {
//            packageManager.getPackageInfo(packageName, 0)
//            true
//        } catch (e: Exception) {
//            false
//        }
//    }
//
//    /**
//     * Check if specific device is available
//     */
//    private fun checkDeviceAvailability(device: String): Boolean {
//        val packageName = DEVICE_PACKAGES[device] ?: return false
//        return isPackageInstalled(packageName)
//    }
//
//    /**
//     * Get list of available (installed) devices
//     */
//    private fun getAvailableDevices(): List<Map<String, Any>> {
//        val availableDevices = mutableListOf<Map<String, Any>>()
//
//        for ((device, packageName) in DEVICE_PACKAGES) {
//            val isInstalled = isPackageInstalled(packageName)
//            availableDevices.add(mapOf(
//                "device" to device,
//                "package" to packageName,
//                "isInstalled" to isInstalled
//            ))
//        }
//
//        return availableDevices
//    }
//}

package com.example.payrupya

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity  // ✅ CHANGED from FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Random

/**
 * MainActivity.kt - AEPS Biometric Integration
 *
 * ✅ Uses FlutterFragmentActivity for local_auth compatibility
 *
 * Handles:
 * 1. Local Auth (Fingerprint/Face for Login) - via local_auth plugin
 * 2. AEPS Biometric (RD Service devices) - via MethodChannel
 */
class MainActivity : FlutterFragmentActivity() {  // ✅ CHANGED from FlutterActivity

    companion object {
        private const val TAG = "AepsBiometric"
        private const val CHANNEL = "aeps_biometric_channel"
        private const val REQUEST_CODE_BIOMETRIC = 1001
        private const val REQUEST_CODE_FACE_AUTH = 1002

        // ✅ UPDATED: Only 4 devices as per Fingpay requirement
        private val DEVICE_PACKAGES = mapOf(
            "Idemia" to "com.idemia.l1rdservice",           // Morpho L1
            "MFS110" to "com.mantra.mfs110.rdservice",                   // Mantra MFS110
            "MIS100V2" to "com.mantra.mis100v2.rdservice",       // Mantra IRIS
            "FACE_AUTH" to "in.gov.uidai.facerd"                 // Face Authentication
        )
//        // Device Package Names for AEPS RD Services
//        private val DEVICE_PACKAGES = mapOf(
//            "MANTRA" to "com.mantra.rdservice",
//            "MFS110" to "com.mantra.mfs110.rdservice",
//            "MIS100V2" to "com.mantra.mis100v2.rdservice",
//            "MORPHO" to "com.scl.rdservice",
//            "Idemia" to "com.idemia.l1rdservice",
//            "SecuGen Corp." to "com.secugen.rdservice",
//            "STARTEK" to "com.acpl.registersdk",
//            "TATVIK" to "com.aborygen.rdservice"
//        )

        // Intent Actions for each device type
        private val DEVICE_INTENTS = mapOf(
            "Idemia" to "in.gov.uidai.rdservice.fp.CAPTURE",
            "MFS110" to "in.gov.uidai.rdservice.fp.CAPTURE",
            "MIS100V2" to "in.gov.uidai.rdservice.iris.CAPTURE",
            "FACE_AUTH" to "in.gov.uidai.rdservice.face.CAPTURE"
        )

        // Play Store URLs for installation
        private val PLAY_STORE_URLS = mapOf(
            "Idemia" to "https://play.google.com/store/apps/details?id=com.idemia.l1rdservice",
            "MFS110" to "https://play.google.com/store/apps/details?id=com.mantra.mfs110.rdservice",
            "MIS100V2" to "https://play.google.com/store/apps/details?id=com.mantra.mis100v2.rdservice",
            "FACE_AUTH" to "https://play.google.com/store/apps/details?id=in.gov.uidai.facerd"
        )

        // RD Service Error Codes and Messages
        private val RD_ERROR_MESSAGES = mapOf(
            "0" to "Success",
            "100" to "Device not found",
            "110" to "Device not ready",
            "120" to "Device busy",
            "130" to "Device not registered",
            "140" to "Invalid PID options",
            "150" to "Capture timeout",
            "500" to "Internal error",
            "700" to "Device not connected",
            "710" to "Device not ready",
            "720" to "Device not connected - Please connect your biometric device",
            "730" to "Capture failed - Poor quality fingerprint",
            "740" to "Capture timeout",
            "999" to "Unknown error"
        )
    }

    private var pendingResult: MethodChannel.Result? = null
    private var currentDevice: String = ""

    // ✅ NEW: Activity Result Launcher
    private val biometricLauncher = registerForActivityResult(
        ActivityResultContracts. StartActivityForResult()
    ) { result ->
        handleBiometricResult(result. resultCode, result.data)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "✅ Configuring Flutter Engine with MethodChannel: $CHANNEL")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "📥 Method called: ${call.method}")

            when (call.method) {
                "scanFingerprint" -> {
                    val device = call.argument<String>("device") ?: ""
//                    val wadh = call.argument<String>("wadh") ?: ""
//                    Log.d(TAG, "📱 scanFingerprint - Device: $device, WADH: ${if (wadh.isEmpty()) "Empty" else "Present"}")
                    scanFingerprint(device, result)
                }
                "openBiometric" -> {
                    val device = call.argument<String>("device") ?: ""
//                    val wadh = call.argument<String>("wadh") ?: ""
//                    Log.d(TAG, "📱 openBiometric - Device: $device")
                    scanFingerprint(device, result)
                }
                "checkDeviceInstalled" -> {
                    val device = call.argument<String>("device") ?: ""
                    val isInstalled = isDeviceInstalled(device)
                    Log.d(TAG, "🔍 checkDeviceInstalled - Device: $device, Installed: $isInstalled")
                    result.success(isInstalled)
                }
                "checkDeviceAvailability" -> {
                    val device = call.argument<String>("device") ?: ""
                    val isInstalled = isDeviceInstalled(device)
                    result.success(isInstalled)
                }
                "getAvailableDevices" -> {
                    val devices = getAvailableDevices()
                    Log.d(TAG, "📋 getAvailableDevices - Found: ${devices.size} devices")
                    result.success(devices)
                }
                "openPlayStore" -> {
                    val device = call.argument<String>("device") ?: ""
                    openPlayStore(device)
                    result.success(true)
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("package") ?: ""
                    Log.d(TAG, "🚀 launchApp - Package: $packageName")
                    val launched = launchApp(packageName)
                    result.success(launched)
                }
                else -> {
                    Log.w(TAG, "⚠️ Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Scan fingerprint using RD Service for AEPS transactions
     */
    private fun scanFingerprint(device: String, /*wadh: String,*/ result: MethodChannel.Result) {
        Log.d(TAG, "🔵 Starting fingerprint scan for device: $device")

        if (device.isEmpty()) {
            Log.e(TAG, "❌ No device specified")
            result.error("NO_DEVICE", "Device name is required", null)
            return
        }

        val packageName = DEVICE_PACKAGES[device]
        if (packageName == null) {
            Log.e(TAG, "❌ Unknown device: $device")
            result.error("UNKNOWN_DEVICE", "Unknown device: $device. Supported: ${DEVICE_PACKAGES.keys}", null)
            return
        }

        if (!isPackageInstalled(packageName)) {
            Log.e(TAG, "❌ RD Service not installed: $packageName")
            result.error(
                "DEVICE_NOT_INSTALLED",
                "Please install $device RD Service from Play Store",
                mapOf(
                    "package" to packageName,
                    "device" to device,
                    "playStoreUrl" to (PLAY_STORE_URLS[device] ?: "")
                )
            )
            return
        }

        pendingResult = result
        currentDevice = device

        try {
            val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
            val pidOptions = buildPidOptions(device, wadh)
            Log.d(TAG, "📝 PID Options:\n$pidOptions")

            // Get correct intent action for device type
            val intentAction = DEVICE_INTENTS[device] ?: "in.gov.uidai.rdservice.fp.CAPTURE"

//            val intent = Intent("in.gov.uidai.rdservice.fp.CAPTURE")
            val intent = Intent(intentAction)
            intent.setPackage(packageName)
            intent.putExtra("PID_OPTIONS", pidOptions)
            intent.putExtra("request", pidOptions)  // Some RD services use "request" instead

            val requestCode = if (device == "FACE_AUTH") REQUEST_CODE_FACE_AUTH else REQUEST_CODE_BIOMETRIC

            Log.d(TAG, "🚀 Starting RD Service: $packageName with action: $intentAction")
//            startActivityForResult(intent, requestCode)
            // ✅ USE NEW Activity Result API instead of startActivityForResult
            biometricLauncher.launch(intent)
//            Log.d(TAG, "🚀 Starting RD Service: $packageName")
//            startActivityForResult(intent, REQUEST_CODE_BIOMETRIC)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Exception: ${e.message}")
            pendingResult = null
            result.error("BIOMETRIC_ERROR", "Failed to start biometric: ${e.message}", null)
        }
    }

    /**
     * Build PID_OPTIONS XML for RD Service
     *
     * CRITICAL: fType = "0" as per Fingpay requirement
     *
     * @param device Device type for specific options
     * @param wadh WADH hash - empty for 2FA, specific value for eKYC
     */
//    private fun buildPidOptions(wadh: String): String {
//        return if (wadh.isEmpty()) {
//            // For 2FA and Transactions (No WADH)
//            """<?xml version="1.0"?><PidOptions ver="1.0"><Opts fCount="1" fType="0" iCount="0" pCount="0" format="0" pidVer="2.0" timeout="20000" otp="" wadh="" posh="UNKNOWN"/></PidOptions>"""
//        } else {
//            // For eKYC (With WADH)
//            """<?xml version="1.0"?><PidOptions ver="1.0"><Opts fCount="1" fType="0" iCount="0" pCount="0" format="0" pidVer="2.0" timeout="20000" otp="" wadh="$wadh" posh="UNKNOWN"/></PidOptions>"""
//        }
//    }


//    private fun buildPidOptions(device: String/*, wadh: String*/): String {
//        val txnId = getRandomNumber()
////        val purpose = if (wadh.isEmpty()) "auth" else "ekyc"
//        val purpose = "auth"
//        val language = "en"
//        val buildType = "P"  // P = Production
//        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        return when (device) {
//            "MIS100V2" -> {
//                // IRIS device - uses iCount and iType
//                """<?xml version="1.0" encoding="UTF-8"?>
//<PidOptions ver="1.0" env="$buildType">
//    <Opts fCount="0" fType="0" iCount="1" iType="0" pCount="0" pType="0" format="0" pidVer="2.0" timeout="20000" otp="" wadh="$wadh" posh="UNKNOWN" />
//    <CustOpts>
//        <Param name="txnId" value="$txnId"/>
//        <Param name="purpose" value="$purpose"/>
//        <Param name="language" value="$language"/>
//    </CustOpts>
//</PidOptions>"""
//            }
//            "FACE_AUTH" -> {
//                // Face Authentication - for Fingpay 2FA (mandatory)
//                """<?xml version="1.0" encoding="UTF-8"?>
//<PidOptions ver="1.0" env="$buildType">
//    <Opts fCount="0" fType="0" iCount="0" iType="0" pCount="0" pType="0" format="0" pidVer="2.0" timeout="30000" otp="" wadh="$wadh" posh="UNKNOWN" />
//    <CustOpts>
//        <Param name="txnId" value="$txnId"/>
//        <Param name="purpose" value="$purpose"/>
//        <Param name="language" value="$language"/>
//    </CustOpts>
//</PidOptions>"""
//            }
//            else -> {
//                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
//                        "<PidOptions ver=\"1.0\" env=\"$buildType\">\n" +
//                        "   <Opts fCount=\"\" fType=\"\" iCount=\"\" iType=\"\" pCount=\"\" pType=\"\" " +
//                        "format=\"\" pidVer=\"2.0\" timeout=\"\" otp=\"\" wadh=\"$wadh\" posh=\"\" />\n" +
//                        "   <CustOpts>\n" +
//                        "      <Param name=\"txnId\" value=\"$txnId\" />\n" +
//                        "      <Param name=\"purpose\" value=\"$purpose\" />\n" +
//                        "      <Param name=\"language\" value=\"$language\" />\n" +
//                        "   </CustOpts>\n" +
//                        "</PidOptions>"
//            }
//
//
//        }
//    }

    private fun buildPidOptions(device: String, wadh: String): String {
        val txnId = getRandomNumber()
        val purpose = "auth"
        val language = "en"
        val env = "P"

        return when (device) {

            "MIS100V2" -> // IRIS
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                        "<PidOptions ver=\"1.0\">" +
                        "<Opts fCount=\"0\" fType=\"0\" iCount=\"1\" iType=\"0\" pCount=\"0\" pType=\"0\" format=\"0\" pidVer=\"2.0\" timeout=\"20000\" otp=\"\" wadh=\"$wadh\" posh=\"UNKNOWN\" env=\"$env\"/>" +
                        "<CustOpts>" +
                        "<Param name=\"txnId\" value=\"$txnId\"/>" +
                        "<Param name=\"purpose\" value=\"$purpose\"/>" +
                        "<Param name=\"language\" value=\"$language\"/>" +
                        "</CustOpts>" +
                        "</PidOptions>"

            "FACE_AUTH" -> {
                // Face Authentication - for Fingpay 2FA (mandatory)
                """<?xml version="1.0" encoding="UTF-8"?>
                <PidOptions ver="1.0" env="$env">
                    <Opts fCount="0" fType="0" iCount="0" iType="0" pCount="0" pType="0" format="0" pidVer="2.0" timeout="30000" otp="" wadh="$wadh" posh="UNKNOWN" />
                    <CustOpts>
                        <Param name="txnId" value="$txnId"/>
                        <Param name="purpose" value="$purpose"/>
                        <Param name="language" value="$language"/>
                    </CustOpts>
                </PidOptions>"""
            }
//                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
//                        "<PidOptions ver=\"1.0\">" +
//                        "<Opts fCount=\"0\" fType=\"0\" iCount=\"0\" iType=\"0\" pCount=\"1\" pType=\"0\" format=\"0\" pidVer=\"2.0\" timeout=\"30000\" otp=\"\" wadh=\"$wadh\" posh=\"UNKNOWN\" env=\"$env\"/>" +
//                        "<CustOpts>" +
//                        "<Param name=\"txnId\" value=\"$txnId\"/>" +
//                        "<Param name=\"purpose\" value=\"$purpose\"/>" +
//                        "<Param name=\"language\" value=\"$language\"/>" +
//                        "</CustOpts>" +
//                        "</PidOptions>"

            else -> // Fingerprint
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                        "<PidOptions ver=\"1.0\">" +
                        "<Opts fCount=\"1\" fType=\"0\" iCount=\"0\" iType=\"0\" pCount=\"0\" pType=\"0\" format=\"0\" pidVer=\"2.0\" timeout=\"20000\" otp=\"\" wadh=\"$wadh\" posh=\"UNKNOWN\" env=\"$env\"/>" +
                        "<CustOpts>" +
                        "<Param name=\"txnId\" value=\"$txnId\"/>" +
                        "<Param name=\"purpose\" value=\"$purpose\"/>" +
                        "<Param name=\"language\" value=\"$language\"/>" +
                        "</CustOpts>" +
                        "</PidOptions>"
        }
    }
//    private fun buildPidOptions(device: String, wadh: String): String {
//        val txnId = getRandomNumber()
//        val purpose = "auth"
//        val language = "en"
//        val buildType = "P"
////        val wadh = "sgydIC09zzy6f8Lb3xaAqzKquKe9lFcNR9uTvYxFp+A="
//        val wadhValue = wadh
//
//        return when (device) {
//
//            "MIS100V2" ->
//                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
//                        "<PidOptions ver=\"1.0\" env=\"$buildType\">" +
//                        "<Opts fCount=\"0\" fType=\"0\" iCount=\"1\" iType=\"0\" pCount=\"0\" pType=\"0\" format=\"0\" pidVer=\"2.0\" timeout=\"20000\" otp=\"\" wadh=\"$wadhValue\" posh=\"UNKNOWN\" />" +
//                        "<CustOpts>" +
//                        "<Param name=\"txnId\" value=\"$txnId\"/>" +
//                        "<Param name=\"purpose\" value=\"$purpose\"/>" +
//                        "<Param name=\"language\" value=\"$language\"/>" +
//                        "</CustOpts>" +
//                        "</PidOptions>"
//
//            "FACE_AUTH" ->
//                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
//                        "<PidOptions ver=\"1.0\" env=\"$buildType\">" +
//                        "<Opts fCount=\"0\" fType=\"0\" iCount=\"0\" iType=\"0\" pCount=\"0\" pType=\"0\" format=\"0\" pidVer=\"2.0\" timeout=\"30000\" otp=\"\" wadh=\"$wadhValue\" posh=\"UNKNOWN\" />" +
//                        "<CustOpts>" +
//                        "<Param name=\"txnId\" value=\"$txnId\"/>" +
//                        "<Param name=\"purpose\" value=\"$purpose\"/>" +
//                        "<Param name=\"language\" value=\"$language\"/>" +
//                        "</CustOpts>" +
//                        "</PidOptions>"
//
//            else ->
//                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
//                        "<PidOptions ver=\"1.0\" env=\"$buildType\">" +
//                        "<Opts fCount=\"\" fType=\"\" iCount=\"\" iType=\"\" pCount=\"\" pType=\"\" format=\"\" pidVer=\"2.0\" timeout=\"\" otp=\"\" wadh=\"$wadhValue\" posh=\"\" />" +
//                        "<CustOpts>" +
//                        "<Param name=\"txnId\" value=\"$txnId\"/>" +
//                        "<Param name=\"purpose\" value=\"$purpose\"/>" +
//                        "<Param name=\"language\" value=\"$language\"/>" +
//                        "</CustOpts>" +
//                        "</PidOptions>"
//        }
//    }


    /**
     * Generate random 8-digit transaction ID
     */
    private fun getRandomNumber(): String {
        val start = 10000000
        val end = 99999999
        val number = Random(System.nanoTime()).nextInt(end - start + 1) + start
        return number.toString()
    }

    /**
     * Handle result from RD Service
     */
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//
//        Log.d(TAG, "📥 onActivityResult - requestCode: $requestCode, resultCode: $resultCode")
//
//        if (requestCode == REQUEST_CODE_BIOMETRIC) {
//            val result = pendingResult
//            pendingResult = null
//
//            if (result == null) {
//                Log.w(TAG, "⚠️ No pending result")
//                return
//            }
//
//            when (resultCode) {
//                Activity.RESULT_OK -> {
//                    val pidData = data?.getStringExtra("PID_DATA")
//                    Log.d(TAG, "✅ RESULT_OK - PID length: ${pidData?.length ?: 0}")
//
//                    if (pidData.isNullOrEmpty()) {
//                        Log.e(TAG, "❌ No PID data received")
//                        result.error("NO_DATA", "No fingerprint data received", null)
//                        return
//                    } /*else {
//                        val cleanedPidData = cleanPidData(pidData)
//                        Log.d(TAG, "✅ Success - Cleaned length: ${cleanedPidData.length}")
//
//                        result.success(mapOf(
//                            "success" to true,
//                            "pidData" to cleanedPidData,
//                            "device" to currentDevice,
//                            "message" to "Fingerprint captured successfully"
//                        ))
//                    }*/
//                    // ✅ CRITICAL: Validate PID_DATA for RD Service errors
//                    val validationResult = validatePidData(pidData)
//
//                    if (!validationResult.isValid) {
//                        Log.e(TAG, "❌ PID validation failed: ${validationResult.errorCode} - ${validationResult.errorMessage}")
//                        result.error(
//                            validationResult.errorCode,
//                            validationResult.errorMessage,
//                            mapOf(
//                                "device" to currentDevice,
//                                "rdErrorCode" to validationResult.rdErrorCode,
//                                "rdErrorInfo" to validationResult.rdErrorInfo
//                            )
//                        )
//                        return
//                    }
//                    // ✅ SUCCESS: Valid fingerprint data
//                    val cleanedPidData = cleanPidData(pidData)
//                    Log.d(TAG, "✅ Valid fingerprint captured - Length: ${cleanedPidData.length}")
//
//                    result.success(mapOf(
//                        "success" to true,
//                        "pidData" to cleanedPidData,
//                        "device" to currentDevice,
//                        "message" to "Fingerprint captured successfully"
//                    ))
//                }
//                Activity.RESULT_CANCELED -> {
//                    Log.w(TAG, "⚠️ Cancelled by user")
//                    result.error("CANCELLED", "Fingerprint capture was cancelled", null)
//                }
//                else -> {
//                    val errorCode = data?.getStringExtra("ERROR_CODE") ?: "UNKNOWN"
//                    val errorMessage = data?.getStringExtra("ERROR_MESSAGE") ?: "Fingerprint capture failed"
//                    Log.e(TAG, "❌ Error: $errorCode - $errorMessage")
//                    result.error(errorCode, errorMessage, null)
//                }
//            }
//        }
//    }

    /**
     * Handle result from RD Service (NEW:  replaces onActivityResult)
     */
    private fun handleBiometricResult(resultCode: Int, data:  Intent?) {
        Log.d(TAG, "📥 handleBiometricResult - resultCode: $resultCode")

        val result = pendingResult
        pendingResult = null

        if (result == null) {
            Log.w(TAG, "⚠️ No pending result")
            return
        }

        when (resultCode) {
            android.app.Activity.RESULT_OK -> {
                val pidData = data?.getStringExtra("PID_DATA")
                    ?: data?.getStringExtra("response")
                    ?: data?.getStringExtra("data")

                Log.d(TAG, "✅ RESULT_OK - PID length: ${pidData?.length ?:  0}")

                if (pidData. isNullOrEmpty()) {
                    Log.e(TAG, "❌ No PID data received")
                    result.error("NO_DATA", "No biometric data received", null)
                    return
                }

                val validationResult = validatePidData(pidData)

                if (! validationResult.isValid) {
                    Log.e(TAG, "❌ PID validation failed: ${validationResult.errorCode} - ${validationResult.errorMessage}")
                    result.error(
                        validationResult.errorCode,
                        validationResult.errorMessage,
                        mapOf(
                            "device" to currentDevice,
                            "rdErrorCode" to validationResult.rdErrorCode,
                            "rdErrorInfo" to validationResult.rdErrorInfo
                        )
                    )
                    return
                }

                val cleanedPidData = cleanPidData(pidData)
                Log.d(TAG, "✅ Valid biometric captured - Length: ${cleanedPidData. length}")

                result.success(mapOf(
                    "success" to true,
                    "pidData" to cleanedPidData,
                    "device" to currentDevice,
                    "message" to "Biometric captured successfully"
                ))
            }
            android.app.Activity. RESULT_CANCELED -> {
                Log.w(TAG, "⚠️ Cancelled by user")
                result.error("CANCELLED", "Biometric capture was cancelled", null)
            }
            else -> {
                val errorCode = data?.getStringExtra("ERROR_CODE") ?: "UNKNOWN"
                val errorMessage = data?. getStringExtra("ERROR_MESSAGE") ?: "Biometric capture failed"
                Log.e(TAG, "❌ Error:  $errorCode - $errorMessage")
                result.error(errorCode, errorMessage, null)
            }
        }
    }
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//
//        Log.d(TAG, "📥 onActivityResult - requestCode: $requestCode, resultCode: $resultCode")
//
//        if (requestCode != REQUEST_CODE_BIOMETRIC && requestCode != REQUEST_CODE_FACE_AUTH) {
//            return
//        }
//
//        val result = pendingResult
//        pendingResult = null
//
//        if (result == null) {
//            Log.w(TAG, "⚠️ No pending result")
//            return
//        }
//
//        when (resultCode) {
//            Activity.RESULT_OK -> {
//                // Try multiple keys for PID data
//                val pidData = data?.getStringExtra("PID_DATA")
//                    ?: data?.getStringExtra("response")
//                    ?: data?.getStringExtra("data")
//
//                Log.d(TAG, "✅ RESULT_OK - PID length: ${pidData?.length ?: 0}")
//
//                if (pidData.isNullOrEmpty()) {
//                    Log.e(TAG, "❌ No PID data received")
//                    result.error("NO_DATA", "No biometric data received", null)
//                    return
//                }
//
//                // Validate PID data for errors
//                val validationResult = validatePidData(pidData)
//
//                if (!validationResult.isValid) {
//                    Log.e(TAG, "❌ PID validation failed: ${validationResult.errorCode} - ${validationResult.errorMessage}")
//                    result.error(
//                        validationResult.errorCode,
//                        validationResult.errorMessage,
//                        mapOf(
//                            "device" to currentDevice,
//                            "rdErrorCode" to validationResult.rdErrorCode,
//                            "rdErrorInfo" to validationResult.rdErrorInfo
//                        )
//                    )
//                    return
//                }
//
//                // SUCCESS: Valid biometric data
//                val cleanedPidData = cleanPidData(pidData)
//                Log.d(TAG, "✅ Valid biometric captured - Length: ${cleanedPidData.length}")
//
//                result.success(mapOf(
//                    "success" to true,
//                    "pidData" to cleanedPidData,
//                    "device" to currentDevice,
//                    "message" to "Biometric captured successfully"
//                ))
//            }
//            Activity.RESULT_CANCELED -> {
//                Log.w(TAG, "⚠️ Cancelled by user")
//                result.error("CANCELLED", "Biometric capture was cancelled", null)
//            }
//            else -> {
//                val errorCode = data?.getStringExtra("ERROR_CODE") ?: "UNKNOWN"
//                val errorMessage = data?.getStringExtra("ERROR_MESSAGE") ?: "Biometric capture failed"
//                Log.e(TAG, "❌ Error: $errorCode - $errorMessage")
//                result.error(errorCode, errorMessage, null)
//            }
//        }
//    }

    /**
     * Validate PID_DATA for RD Service errors
     *
     * RD Service can return RESULT_OK but with error in PID_DATA XML
     */
    private fun validatePidData(pidData: String): PidValidationResult {
        Log.d(TAG, "🔍 Validating PID data...")

        try {
            val errCodeRegex = """errCode\s*=\s*["'](\d+)["']""".toRegex()
            val errInfoRegex = """errInfo\s*=\s*["']([^"']+)["']""".toRegex()

            val errCodeMatch = errCodeRegex.find(pidData)
            val errInfoMatch = errInfoRegex.find(pidData)

            val errCode = errCodeMatch?.groupValues?.get(1) ?: "0"
            val errInfo = errInfoMatch?.groupValues?.get(1) ?: ""

            Log.d(TAG, "📋 RD Response - errCode: $errCode, errInfo: $errInfo")

            // errCode "0" means success
            if (errCode != "0") {
                val errorMessage = RD_ERROR_MESSAGES[errCode] ?: errInfo.ifEmpty { "Capture failed (Error: $errCode)" }

                val flutterErrorCode = when (errCode) {
                    "100", "700", "710", "720" -> "DEVICE_NOT_CONNECTED"
                    "110", "120" -> "DEVICE_NOT_READY"
                    "130" -> "DEVICE_NOT_REGISTERED"
                    "150", "740" -> "CAPTURE_TIMEOUT"
                    "730" -> "POOR_QUALITY"
                    else -> "CAPTURE_FAILED"
                }

                return PidValidationResult(
                    isValid = false,
                    errorCode = flutterErrorCode,
                    errorMessage = errorMessage,
                    rdErrorCode = errCode,
                    rdErrorInfo = errInfo
                )
            }

            // Check if DeviceInfo is populated
            val deviceInfoRegex = """<DeviceInfo[^>]*dc\s*=\s*["']([^"']*)["']""".toRegex()
            val dcMatch = deviceInfoRegex.find(pidData)
            val dcValue = dcMatch?.groupValues?.get(1) ?: ""

            if (dcValue.isEmpty()) {
                Log.e(TAG, "❌ DeviceInfo is empty - No device connected")
                return PidValidationResult(
                    isValid = false,
                    errorCode = "DEVICE_NOT_CONNECTED",
                    errorMessage = "Biometric device not connected. Please connect your device and try again.",
                    rdErrorCode = errCode,
                    rdErrorInfo = "DeviceInfo empty"
                )
            }

            // Check if Data element has actual content
            val dataRegex = """<Data[^>]*>([^<]*)</Data>""".toRegex()
            val dataMatch = dataRegex.find(pidData)
            val dataContent = dataMatch?.groupValues?.get(1) ?: ""

            if (dataContent.isEmpty()) {
                Log.e(TAG, "❌ Data element is empty - Capture failed")
                return PidValidationResult(
                    isValid = false,
                    errorCode = "CAPTURE_FAILED",
                    errorMessage = "Biometric capture failed. Please try again.",
                    rdErrorCode = errCode,
                    rdErrorInfo = "Data empty"
                )
            }

            Log.d(TAG, "✅ PID validation passed")
            return PidValidationResult(isValid = true)

        } catch (e: Exception) {
            Log.e(TAG, "❌ PID validation exception: ${e.message}")
            return PidValidationResult(
                isValid = false,
                errorCode = "VALIDATION_ERROR",
                errorMessage = "Failed to validate biometric data: ${e.message}",
                rdErrorCode = "",
                rdErrorInfo = e.message ?: ""
            )
        }
    }

    /**
     * Data class for PID validation result
     */
    data class PidValidationResult(
        val isValid: Boolean,
        val errorCode: String = "",
        val errorMessage: String = "",
        val rdErrorCode: String = "",
        val rdErrorInfo: String = ""
    )

    /**
     * Clean PID data - remove XML declaration and extra whitespace
     */
    private fun cleanPidData(pidData: String): String {
        var cleaned = pidData.trim()
        if (cleaned.startsWith("<?xml")) {
            val index = cleaned.indexOf("?>")
            if (index != -1) {
                cleaned = cleaned.substring(index + 2).trim()
            }
        }
        return cleaned
    }

    /**
     * Check if a package is installed
     */
    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            Log.d(TAG, "📦 Package not found: $packageName")
            false
        }
    }

    /**
     * Check if specific device RD Service is installed
     */
    private fun isDeviceInstalled(device: String): Boolean {
        val packageName = DEVICE_PACKAGES[device] ?: return false
        return isPackageInstalled(packageName)
    }

    /**
     * Get list of available devices with installation status
     */
    private fun getAvailableDevices(): List<Map<String, Any>> {
        return DEVICE_PACKAGES.map { (device, packageName) ->
            mapOf(
                "device" to device,
                "package" to packageName,
                "isInstalled" to isPackageInstalled(packageName),
                "playStoreUrl" to (PLAY_STORE_URLS[device] ?: "")
            )
        }
    }

    /**
     * Open Play Store to install RD Service
     */
    private fun openPlayStore(device: String) {
        val url = PLAY_STORE_URLS[device]

        if (url.isNullOrEmpty()) {
            Log.e(TAG, "❌ No Play Store URL for device: $device")
            return
        }

        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.setPackage("com.android.vending")
            startActivity(intent)
            Log.d(TAG, "✅ Opening Play Store for: $device")
        } catch (e: Exception) {
            // Fallback to browser
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                startActivity(intent)
                Log.d(TAG, "✅ Opening browser for: $device")
            } catch (e2: Exception) {
                Log.e(TAG, "❌ Failed to open Play Store: ${e2.message}")
            }
        }
    }

    /**
     * Launch an app by package name
     */
    private fun launchApp(packageName: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                Log.d(TAG, "✅ App launched: $packageName")
                true
            } else {
                Log.e(TAG, "❌ No launch intent for: $packageName")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to launch app: ${e.message}")
            false
        }
    }
}
//    /**
//     * ✅ CRITICAL: Validate PID_DATA for RD Service errors
//     *
//     * RD Service can return RESULT_OK but with error in PID_DATA XML
//     * We need to parse and check for errors before treating as success
//     */
//    private fun validatePidData(pidData: String): PidValidationResult {
//        Log.d(TAG, "🔍 Validating PID data...")
//
//        try {
//            // Check for error response in PID_DATA
//            // Format: <Resp errCode="720" errInfo="Device not ready"/>
//
//            val errCodeRegex = """errCode\s*=\s*["'](\d+)["']""".toRegex()
//            val errInfoRegex = """errInfo\s*=\s*["']([^"']+)["']""".toRegex()
//
//            val errCodeMatch = errCodeRegex.find(pidData)
//            val errInfoMatch = errInfoRegex.find(pidData)
//
//            val errCode = errCodeMatch?.groupValues?.get(1) ?: "0"
//            val errInfo = errInfoMatch?.groupValues?.get(1) ?: ""
//
//            Log.d(TAG, "📋 RD Response - errCode: $errCode, errInfo: $errInfo")
//
//            // errCode "0" means success, anything else is an error
//            if (errCode != "0") {
//                val errorMessage = RD_ERROR_MESSAGES[errCode] ?: errInfo.ifEmpty { "Capture failed (Error: $errCode)" }
//
//                // Map RD error codes to user-friendly error codes
//                val flutterErrorCode = when (errCode) {
//                    "100", "700", "710", "720" -> "DEVICE_NOT_CONNECTED"
//                    "110", "120" -> "DEVICE_NOT_READY"
//                    "130" -> "DEVICE_NOT_REGISTERED"
//                    "150", "740" -> "CAPTURE_TIMEOUT"
//                    "730" -> "POOR_QUALITY"
//                    else -> "CAPTURE_FAILED"
//                }
//
//                return PidValidationResult(
//                    isValid = false,
//                    errorCode = flutterErrorCode,
//                    errorMessage = errorMessage,
//                    rdErrorCode = errCode,
//                    rdErrorInfo = errInfo
//                )
//            }
//
//            // ✅ Additional validation: Check if actual biometric data exists
//            // Valid PID should have non-empty Data and DeviceInfo
//            val hasValidData = pidData.contains("<Data") &&
//                    !pidData.contains("<Data type=\"\"></Data>") &&
//                    pidData.contains("dc=\"") &&
//                    pidData.contains("dpId=\"")
//
//            // Check if DeviceInfo is populated (not empty)
//            val deviceInfoRegex = """<DeviceInfo[^>]*dc\s*=\s*["']([^"']*)["']""".toRegex()
//            val dcMatch = deviceInfoRegex.find(pidData)
//            val dcValue = dcMatch?.groupValues?.get(1) ?: ""
//
//            if (dcValue.isEmpty()) {
//                Log.e(TAG, "❌ DeviceInfo is empty - No device connected")
//                return PidValidationResult(
//                    isValid = false,
//                    errorCode = "DEVICE_NOT_CONNECTED",
//                    errorMessage = "Biometric device not connected. Please connect your device and try again.",
//                    rdErrorCode = errCode,
//                    rdErrorInfo = "DeviceInfo empty"
//                )
//            }
//
//            // Check if Data element has actual content
//            val dataRegex = """<Data[^>]*>([^<]*)</Data>""".toRegex()
//            val dataMatch = dataRegex.find(pidData)
//            val dataContent = dataMatch?.groupValues?.get(1) ?: ""
//
//            if (dataContent.isEmpty()) {
//                Log.e(TAG, "❌ Data element is empty - Capture failed")
//                return PidValidationResult(
//                    isValid = false,
//                    errorCode = "CAPTURE_FAILED",
//                    errorMessage = "Fingerprint capture failed. Please try again.",
//                    rdErrorCode = errCode,
//                    rdErrorInfo = "Data empty"
//                )
//            }
//
//            Log.d(TAG, "✅ PID validation passed")
//            return PidValidationResult(isValid = true)
//
//        } catch (e: Exception) {
//            Log.e(TAG, "❌ PID validation exception: ${e.message}")
//            return PidValidationResult(
//                isValid = false,
//                errorCode = "VALIDATION_ERROR",
//                errorMessage = "Failed to validate fingerprint data: ${e.message}",
//                rdErrorCode = "",
//                rdErrorInfo = e.message ?: ""
//            )
//        }
//    }
//
//    /**
//     * Data class for PID validation result
//     */
//    data class PidValidationResult(
//        val isValid: Boolean,
//        val errorCode: String = "",
//        val errorMessage: String = "",
//        val rdErrorCode: String = "",
//        val rdErrorInfo: String = ""
//    )
//
//    /**
//     * Clean PID data - remove XML declaration and extra whitespace
//     */
//    private fun cleanPidData(pidData: String): String {
//        var cleaned = pidData.trim()
//        if (cleaned.startsWith("<?xml")) {
//            val index = cleaned.indexOf("?>")
//            if (index != -1) {
//                cleaned = cleaned.substring(index + 2).trim()
//            }
//        }
//        return cleaned
//    }
//
//    /**
//     * Check if a package is installed
//     */
//    private fun isPackageInstalled(packageName: String): Boolean {
//        return try {
//            packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
//            true
//        } catch (e: PackageManager.NameNotFoundException) {
//            false
//        }
//    }
//
//    /**
//     * Check if specific device RD Service is installed
//     */
//    private fun isDeviceInstalled(device: String): Boolean {
//        val packageName = DEVICE_PACKAGES[device] ?: return false
//        return isPackageInstalled(packageName)
//    }
//
//    /**
//     * Get list of available devices with installation status
//     */
//    private fun getAvailableDevices(): List<Map<String, Any>> {
//        return DEVICE_PACKAGES.map { (device, packageName) ->
//            mapOf(
//                "device" to device,
//                "package" to packageName,
//                "isInstalled" to isPackageInstalled(packageName)
//            )
//        }
//    }
//
//    /**
//     * Launch an app by package name
//     */
//    private fun launchApp(packageName: String): Boolean {
//        return try {
//            val intent = packageManager.getLaunchIntentForPackage(packageName)
//            if (intent != null) {
//                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                startActivity(intent)
//                Log.d(TAG, "✅ App launched: $packageName")
//                true
//            } else {
//                Log.e(TAG, "❌ No launch intent for: $packageName")
//                false
//            }
//        } catch (e: Exception) {
//            Log.e(TAG, "❌ Failed to launch app: ${e.message}")
//            false
//        }
//    }
//}