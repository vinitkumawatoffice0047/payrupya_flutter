import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../utils/ConsoleLog.dart';
import '../utils/custom_loading.dart';
import '../utils/CustomDialog.dart';
import '../utils/global_utils.dart';

class MyCommercialsController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();

  // Observable variables
  RxList<Map<String, dynamic>> serviceTypeList = <Map<String, dynamic>>[].obs;
  RxList<String> selectedServices = <String>[].obs;
  RxList<Map<String, dynamic>> marginList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredMarginList = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxBool isServiceTypeLoading = false.obs;

  // Filter variables
  TextEditingController serviceNameFilterController = TextEditingController();
  TextEditingController serviceTypeFilterController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ConsoleLog.printColor("========== MyCommercialsController onInit CALLED ==========", color: "green");
    // Load service type list on init
    getServiceTypeList();
  }

  @override
  void onClose() {
    serviceNameFilterController.dispose();
    serviceTypeFilterController.dispose();
    super.onClose();
  }

  //region generateRequestId
  String generateRequestId() {
    return GlobalUtils.generateRandomId(6);
  }
  //endregion

  //region getServiceTypeList
  /// Fetch service type list for dropdown
  Future<void> getServiceTypeList() async {
    try {
      isServiceTypeLoading.value = true;

      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        isServiceTypeLoading.value = false;
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      ConsoleLog.printColor("GET SERVICE TYPE LIST REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      // Try getServiceTypeList endpoint (as per Angular code)
      // If this endpoint returns 404, fallback to getAllowedServiceByType
      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_GET_SERVICE_TYPE_LIST,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      isServiceTypeLoading.value = false;

      // Handle 404 or other errors - fallback to getAllowedServiceByType
      if (response == null || response.statusCode != 200 || response.statusCode == 404) {
        ConsoleLog.printWarning("getServiceTypeList endpoint not found (${response?.statusCode}), trying getAllowedServiceByType as fallback");
        await _getServiceTypeListFallback();
        return;
      }

      Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

      ConsoleLog.printColor("GET SERVICE TYPE LIST RESPONSE: ${jsonEncode(result)}", color: "green");

      if (result['Resp_code'] == 'RCS' && result['data'] != null) {
        if (result['data'] is List) {
          List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(result['data']);
          serviceTypeList.assignAll(dataList);
          ConsoleLog.printSuccess("✅ Service types loaded: ${serviceTypeList.length} items");
        } else {
          ConsoleLog.printWarning("No service types found in response, trying fallback");
          await _getServiceTypeListFallback();
        }
      } else {
        ConsoleLog.printWarning("Response code: ${result['Resp_code']}, trying fallback");
        await _getServiceTypeListFallback();
      }
    } catch (e) {
      isServiceTypeLoading.value = false;
      ConsoleLog.printError('Error in getServiceTypeList: $e');
    }
  }
  //endregion

  //region _getServiceTypeListFallback
  /// Fallback method to get service types using getAllowedServiceByType
  Future<void> _getServiceTypeListFallback() async {
    try {
      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
        'type': 'REMITTANCE', // Default type for getAllowedServiceByType
      };

      ConsoleLog.printColor("GET SERVICE TYPE FALLBACK REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_GET_SERVICE_TYPE, // getAllowedServiceByType
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS' && result['data'] != null && result['data'] is List) {
          List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(result['data']);
          // Extract service_type from each service item
          List<Map<String, dynamic>> serviceTypesList = [];
          for (var item in dataList) {
            String? serviceType = item['service_type']?.toString();
            if (serviceType != null && serviceType.isNotEmpty) {
              serviceTypesList.add({'service_type': serviceType});
            }
          }
          // Remove duplicates
          Set<String> uniqueTypes = {};
          serviceTypesList.removeWhere((item) {
            String type = item['service_type'] ?? '';
            if (uniqueTypes.contains(type)) {
              return true;
            }
            uniqueTypes.add(type);
            return false;
          });
          
          serviceTypeList.assignAll(serviceTypesList);
          ConsoleLog.printSuccess("✅ Service types loaded via fallback: ${serviceTypeList.length} items");
        }
      }
    } catch (e) {
      ConsoleLog.printError('Error in _getServiceTypeListFallback: $e');
    }
  }
  //endregion

  //region getCommercials
  /// Fetch commercials/margins based on selected service types
  Future<void> getCommercials() async {
    try {
      if (selectedServices.isEmpty) {
        CustomDialog.error(message: "Please select at least one service type");
        return;
      }

      isLoading.value = true;
      CustomLoading.showLoading();

      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        isLoading.value = false;
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      List<String> servicesList = List.from(selectedServices);
      
      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'service_type': servicesList, // Array of selected service types
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      ConsoleLog.printColor("GET COMMERCIALS REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_GET_MYSERVICE_FOR_COMMERCIALS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();
      isLoading.value = false;

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("GET COMMERCIALS RESPONSE: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS' && result['data'] != null) {
          if (result['data'] is List) {
            List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(result['data']);
            marginList.assignAll(dataList);
            filteredMarginList.assignAll(dataList);
            ConsoleLog.printSuccess("✅ Commercials fetched successfully: ${marginList.length} items");
          }
        } else {
          marginList.clear();
          filteredMarginList.clear();
          CustomDialog.error(message: result['Resp_desc'] ?? 'No commercials found');
          ConsoleLog.printWarning("No commercials found or error in response");
        }
      } else {
        marginList.clear();
        filteredMarginList.clear();
        ConsoleLog.printError("Failed to fetch commercials: ${response?.statusCode}");
        CustomDialog.error(message: 'Failed to fetch commercials. Please try again.');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      isLoading.value = false;
      marginList.clear();
      filteredMarginList.clear();
      ConsoleLog.printError('Error in getCommercials: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region filterCommercials
  /// Filter commercials based on service name and service type inputs
  Future<void> filterCommercials() async {
    try {
      CustomLoading.showLoading();

      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomLoading.hideLoading();
        CustomDialog.error(message: "Session expired. Please login again.");
        return;
      }

      // First fetch all commercials
      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
      };

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_GET_MYSERVICE_FOR_COMMERCIALS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      CustomLoading.hideLoading();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        if (result['Resp_code'] == 'RCS' && result['data'] != null && result['data'] is List) {
          List<Map<String, dynamic>> allCommercials = List<Map<String, dynamic>>.from(result['data']);
          
          List<Map<String, dynamic>> matchesData = [];

          String serviceNameFilter = serviceNameFilterController.text.trim().toLowerCase();
          String serviceTypeFilter = serviceTypeFilterController.text.trim().toLowerCase();

          // Filter data
          for (var item in allCommercials) {
            bool matchServiceName = false;
            bool matchServiceType = false;

            if (serviceNameFilter.isNotEmpty) {
              String serviceName = (item['service_name'] ?? '').toString().toLowerCase();
              matchServiceName = serviceName.contains(serviceNameFilter);
            }

            if (serviceTypeFilter.isNotEmpty) {
              String serviceType = (item['service_type'] ?? '').toString().toLowerCase();
              matchServiceType = serviceType.contains(serviceTypeFilter);
            }

            // Push if both match, or only one filter is provided
            if ((serviceNameFilter.isNotEmpty && serviceTypeFilter.isNotEmpty && matchServiceName && matchServiceType) ||
                (serviceNameFilter.isEmpty && matchServiceType) ||
                (serviceTypeFilter.isEmpty && matchServiceName)) {
              matchesData.add(item);
            }
          }

          if (matchesData.isNotEmpty) {
            filteredMarginList.assignAll(matchesData);
            marginList.assignAll(matchesData);
            ConsoleLog.printSuccess("✅ Filtered commercials: ${matchesData.length} items");
          } else {
            marginList.clear();
            filteredMarginList.clear();
            CustomDialog.error(message: 'No results found for the given filters.');
          }
        } else {
          CustomDialog.error(message: result['Resp_desc'] ?? 'Failed to fetch data. Please try again.');
        }
      } else {
        CustomDialog.error(message: 'Failed to fetch data. Please try again.');
      }
    } catch (e) {
      CustomLoading.hideLoading();
      ConsoleLog.printError('Error in filterCommercials: $e');
      CustomDialog.error(
        message: 'Technical issue, please try again!',
      );
    }
  }
  //endregion

  //region toggleServiceType
  /// Toggle service type selection (for multiple select)
  void toggleServiceType(String serviceType) {
    // Check current state
    if (selectedServices.contains(serviceType)) {
      // Remove if exists
      selectedServices.remove(serviceType);
    } else {
      // Add if doesn't exist
      selectedServices.add(serviceType);
    }
    // Force rebuild by creating a new list reference
    final updatedList = List<String>.from(selectedServices);
    selectedServices.value = updatedList;
  }
  //endregion

  //region clearFilters
  /// Clear filter inputs
  void clearFilters() {
    serviceNameFilterController.clear();
    serviceTypeFilterController.clear();
    filteredMarginList.value = List.from(marginList);
  }
  //endregion

  //region fetchSpecialMargins
  /// Fetch special margins based on standard plan service types
  Future<List<Map<String, dynamic>>> fetchSpecialMargins(List<Map<String, dynamic>> standardPlanList) async {
    try {
      // Extract unique service types from standard plan list
      Set<String> uniqueServiceTypes = {};
      for (var plan in standardPlanList) {
        String? serviceType = plan['service_type']?.toString();
        if (serviceType != null && serviceType.isNotEmpty) {
          uniqueServiceTypes.add(serviceType);
        }
      }

      // Create service_type object with index keys (as per Angular code)
      Map<String, dynamic> serviceTypeObj = {};
      int index = 0;
      for (String type in uniqueServiceTypes) {
        serviceTypeObj[index.toString()] = type;
        index++;
      }

      await _apiProvider.loadAuthCredentials();

      if (!await _apiProvider.isTokenValid()) {
        CustomDialog.error(message: "Session expired. Please login again.");
        return [];
      }

      Map<String, dynamic> requestBody = {
        'request_id': generateRequestId(),
        'lat': _apiProvider.loginController.latitude.value,
        'long': _apiProvider.loginController.longitude.value,
        'service_type': serviceTypeObj,
      };

      ConsoleLog.printColor("FETCH SPECIAL MARGINS REQUEST: ${jsonEncode(requestBody)}", color: "yellow");

      final response = await _apiProvider.requestPostForApi(
        WebApiConstant.API_URL_FETCH_SPECIAL_MARGINS,
        requestBody,
        _apiProvider.userAuthToken.value,
        _apiProvider.userSignature.value,
      );

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> result = Map<String, dynamic>.from(response.data);

        ConsoleLog.printColor("FETCH SPECIAL MARGINS RESPONSE: ${jsonEncode(result)}", color: "green");

        if (result['Resp_code'] == 'RCS' && result['data'] != null && result['data'] is List) {
          List<Map<String, dynamic>> specialList = List<Map<String, dynamic>>.from(result['data']);
          ConsoleLog.printSuccess("✅ Special margins loaded: ${specialList.length} items");
          return specialList;
        } else {
          ConsoleLog.printWarning("No special margins found");
          return [];
        }
      } else {
        ConsoleLog.printError("Failed to fetch special margins: ${response?.statusCode}");
        return [];
      }
    } catch (e) {
      ConsoleLog.printError('Error in fetchSpecialMargins: $e');
      return [];
    }
  }
  //endregion
}
