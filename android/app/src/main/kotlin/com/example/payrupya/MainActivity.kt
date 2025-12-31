//package com.example.payrupya
//
//import io.flutter.embedding.android.FlutterFragmentActivity
//
//class MainActivity : FlutterFragmentActivity()

package com.example.payrupya

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity with AEPS Biometric Device Integration
 *
 * Supports 8 different biometric devices:
 * 1. MANTRA - com.mantra.rdservice
 * 2. MFS110 (Mantra S1) - com.mantra.mfs110.rdservice
 * 3. MORPHO - com.scl.rdservice
 * 4. Secugen - com.secugen.rdservice
 * 5. ACPL - com.acpl.registersdk
 * 6. Idemia (Morpho L1) - com.idemia.l1rdservice
 * 7. ACPL_L1 - com.acpl.registersdk_l1
 * 8. STARTEK - com.acpl.registersdk (uses ACPL)
 * 9. TATVIK - com.aborygen.rdservice
 * 10. MIS100V2 (Mantra Iris) - com.mantra.mis100v2.rdservice
 */
class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val TAG = "MainActivity_AEPS"
        private const val CHANNEL = "aeps_biometric_channel"
        private const val REQUEST_CODE_BIOMETRIC = 1001

        // Device Package Names
        private val DEVICE_PACKAGES = mapOf(
            "MANTRA" to "com.mantra.rdservice",
            "MFS110" to "com.mantra.mfs110.rdservice",
            "MIS100V2" to "com.mantra.mis100v2.rdservice",
            "MORPHO" to "com.scl.rdservice",
            "Idemia" to "com.idemia.l1rdservice",
            "SecuGen Corp." to "com.secugen.rdservice",
            "STARTEK" to "com.acpl.registersdk",
            "TATVIK" to "com.aborygen.rdservice",
            "ACPL" to "com.acpl.registersdk",
            "ACPL_L1" to "com.acpl.registersdk_l1"
        )

        // Intent Action
        private const val RD_SERVICE_ACTION = "in.gov.uidai.rdservice.fp.CAPTURE"
        private const val RD_SERVICE_IRIS_ACTION = "in.gov.uidai.rdservice.iris.CAPTURE"
    }

    private var methodChannelResult: MethodChannel.Result? = null
    private var currentDevice: String = ""
    private var currentWadh: String = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openBiometric" -> {
                    val device = call.argument<String>("device") ?: ""
                    val wadh = call.argument<String>("wadh") ?: ""
                    val aadhaar = call.argument<String>("aadhaar") ?: ""

                    Log.d(TAG, "Opening biometric for device: $device, wadh: $wadh")

                    methodChannelResult = result
                    currentDevice = device
                    currentWadh = wadh

                    openBiometricDevice(device, wadh, aadhaar)
                }
                "checkDeviceAvailability" -> {
                    val device = call.argument<String>("device") ?: ""
                    val isAvailable = checkDeviceAvailability(device)
                    result.success(isAvailable)
                }
                "getAvailableDevices" -> {
                    val availableDevices = getAvailableDevices()
                    result.success(availableDevices)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Open biometric device for fingerprint capture
     */
    private fun openBiometricDevice(device: String, wadh: String, aadhaar: String) {
        try {
            val packageName = DEVICE_PACKAGES[device]

            if (packageName == null) {
                Log.e(TAG, "Unknown device: $device")
                methodChannelResult?.error("UNKNOWN_DEVICE", "Unknown device: $device", null)
                methodChannelResult = null
                return
            }

            // Check if device app is installed
            if (!isPackageInstalled(packageName)) {
                Log.e(TAG, "Device app not installed: $packageName")
                methodChannelResult?.error(
                    "DEVICE_NOT_INSTALLED",
                    "Please install $device RD Service app from Play Store",
                    mapOf("device" to device, "package" to packageName)
                )
                methodChannelResult = null
                return
            }

            // Generate PID Options XML
            val pidOptions = generatePidOptionsXml(wadh)

            Log.d(TAG, "PID Options: $pidOptions")

            // Create intent for RD Service
            val intent = Intent()
            intent.action = if (device == "MIS100V2") RD_SERVICE_IRIS_ACTION else RD_SERVICE_ACTION
            intent.setPackage(packageName)
            intent.putExtra("PID_OPTIONS", pidOptions)

            // Start activity for result
            startActivityForResult(intent, REQUEST_CODE_BIOMETRIC)

        } catch (e: Exception) {
            Log.e(TAG, "Error opening biometric device: ${e.message}", e)
            methodChannelResult?.error("BIOMETRIC_ERROR", e.message, null)
            methodChannelResult = null
        }
    }

    /**
     * Generate PID_OPTIONS XML for biometric capture
     *
     * @param wadh - WADH hash for eKYC (empty for 2FA and transactions)
     */
    private fun generatePidOptionsXml(wadh: String): String {
        // Format options based on wadh presence
        val format = if (wadh.isNotEmpty()) "1" else "0"
        val pidVer = "2.0"
        val timeout = "20000"
        val pTimeout = "20000"
        val env = "P"  // P = Production, PP = Pre-Production
        val wadAttr = if (wadh.isNotEmpty()) """wadh="$wadh"""" else ""

        return """<?xml version="1.0" encoding="UTF-8"?>
<PidOptions ver="$pidVer">
    <Opts 
        fCount="1" 
        fType="2" 
        iCount="0" 
        iType="0" 
        pCount="0" 
        pType="0" 
        format="$format" 
        pidVer="$pidVer" 
        timeout="$timeout" 
        pTimeout="$pTimeout" 
        $wadAttr
        env="$env" 
    />
    <CustOpts>
        <Param name="mantrakey" value="" />
    </CustOpts>
</PidOptions>"""
    }

    /**
     * Handle activity result from RD Service
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        Log.d(TAG, "onActivityResult: requestCode=$requestCode, resultCode=$resultCode")

        if (requestCode == REQUEST_CODE_BIOMETRIC) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    val pidData = data?.getStringExtra("PID_DATA")

                    if (pidData != null) {
                        Log.d(TAG, "PID Data received, length: ${pidData.length}")

                        // Clean up the PID data
                        val cleanedPidData = cleanPidData(pidData)

                        // Return success with PID data
                        methodChannelResult?.success(mapOf(
                            "success" to true,
                            "pidData" to cleanedPidData,
                            "device" to currentDevice,
                            "message" to "Fingerprint captured successfully"
                        ))
                    } else {
                        Log.e(TAG, "PID Data is null")
                        methodChannelResult?.error(
                            "NO_PID_DATA",
                            "No fingerprint data received from device",
                            null
                        )
                    }
                }
                Activity.RESULT_CANCELED -> {
                    Log.w(TAG, "Biometric capture cancelled by user")
                    methodChannelResult?.error(
                        "CANCELLED",
                        "Fingerprint capture cancelled",
                        null
                    )
                }
                else -> {
                    // Check for error in result
                    val errorCode = data?.getStringExtra("ERROR_CODE")
                    val errorMessage = data?.getStringExtra("ERROR_MESSAGE")
                        ?: data?.getStringExtra("dnc")
                        ?: "Unknown error from biometric device"

                    Log.e(TAG, "Biometric error: $errorCode - $errorMessage")
                    methodChannelResult?.error(
                        errorCode ?: "BIOMETRIC_ERROR",
                        errorMessage,
                        null
                    )
                }
            }

            methodChannelResult = null
            currentDevice = ""
            currentWadh = ""
        }
    }

    /**
     * Clean PID data - remove XML declaration and extra whitespace
     */
    private fun cleanPidData(pidData: String): String {
        var cleaned = pidData.trim()

        // Remove XML declaration if present
        if (cleaned.startsWith("<?xml")) {
            val endIndex = cleaned.indexOf("?>")
            if (endIndex != -1) {
                cleaned = cleaned.substring(endIndex + 2).trim()
            }
        }

        // Remove extra whitespace and newlines
        cleaned = cleaned.replace("\\s+".toRegex(), " ")

        return cleaned
    }

    /**
     * Check if a package (RD Service app) is installed
     */
    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Check if specific device is available
     */
    private fun checkDeviceAvailability(device: String): Boolean {
        val packageName = DEVICE_PACKAGES[device] ?: return false
        return isPackageInstalled(packageName)
    }

    /**
     * Get list of available (installed) devices
     */
    private fun getAvailableDevices(): List<Map<String, Any>> {
        val availableDevices = mutableListOf<Map<String, Any>>()

        for ((device, packageName) in DEVICE_PACKAGES) {
            val isInstalled = isPackageInstalled(packageName)
            availableDevices.add(mapOf(
                "device" to device,
                "package" to packageName,
                "isInstalled" to isInstalled
            ))
        }

        return availableDevices
    }
}