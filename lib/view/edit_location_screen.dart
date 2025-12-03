// import 'package:e_commerce_app/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/global_utils.dart';
import 'home_screen.dart';

class AddressModel {
  String address;
  String pincode;
  bool isSelected;

  AddressModel({
    required this.address,
    required this.pincode,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() => {
    'address': address,
    'pincode': pincode,
    'isSelected': isSelected,
  };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    address: json['address'],
    pincode: json['pincode'],
    isSelected: json['isSelected'] ?? false,
  );
}

class EditLocationScreen extends StatefulWidget {
  final String? currentAddress;
  final String? currentPincode;
  final TextEditingController homeScreenAddressController;
  final TextEditingController homeScreenPincodeController;

  const EditLocationScreen({
    super.key,
    required this.currentAddress,
    required this.currentPincode,
    required this.homeScreenAddressController,
    required this.homeScreenPincodeController,
  });

  @override
  State<EditLocationScreen> createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  List<AddressModel> savedAddresses = [];
  int selectedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  // Saved addresses ko load karenge
  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? addressesJson = prefs.getString('saved_addresses');

    if (addressesJson != null) {
      final List<dynamic> decoded = json.decode(addressesJson);
      setState(() {
        savedAddresses =
            decoded.map((item) => AddressModel.fromJson(item)).toList();

        // Selected address ko find karenge
        for (int i = 0; i < savedAddresses.length; i++) {
          if (savedAddresses[i].isSelected) {
            selectedIndex = i;
            break;
          }
        }
      });
    }

    // Agar current address hai aur list me nahi hai, to use add karenge
    if (widget.currentAddress!.isNotEmpty && widget.currentPincode!.isNotEmpty) {
      bool addressExists = savedAddresses.any((addr) =>
      addr.address == widget.currentAddress &&
          addr.pincode == widget.currentPincode);

      if (!addressExists) {
        setState(() {
          // Pehle sab addresses ko deselect karenge
          for (var address in savedAddresses) {
            address.isSelected = false;
          }

          // Current address ko list me add karenge aur select karenge
          savedAddresses.insert(
              0,
              AddressModel(
                address: widget.currentAddress!,
                pincode: widget.currentPincode!,
                isSelected: true,
              ));
          selectedIndex = 0;
        });

        // Storage me save karenge
        _saveAddressesToStorage();
      } else {
        // Agar address already exist karta hai, to use select kar denge
        int existingIndex = savedAddresses.indexWhere((addr) =>
        addr.address == widget.currentAddress &&
            addr.pincode == widget.currentPincode);

        if (existingIndex != -1 && selectedIndex == -1) {
          setState(() {
            for (var address in savedAddresses) {
              address.isSelected = false;
            }
            savedAddresses[existingIndex].isSelected = true;
            selectedIndex = existingIndex;
          });
          _saveAddressesToStorage();
        }
      }
    }
  }

  // Addresses ko save karenge
  Future<void> _saveAddressesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      savedAddresses.map((address) => address.toJson()).toList(),
    );
    await prefs.setString('saved_addresses', encodedData);
  }

  // Naya address add karenge
  void _addNewAddress() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Pehle sab addresses ko deselect karenge
        for (var address in savedAddresses) {
          address.isSelected = false;
        }

        // Naya address add karenge
        savedAddresses.add(AddressModel(
          address: addressController.text.trim(),
          pincode: pincodeController.text.trim(),
          isSelected: true,
        ));

        selectedIndex = savedAddresses.length - 1;
      });

      _saveAddressesToStorage();
      addressController.clear();
      pincodeController.clear();

      // Keyboard band karenge
      FocusScope.of(context).unfocus();

      Get.snackbar(
        'Success',
        'Address added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }

  // Address edit karenge
  void _editAddress(int index) {
    final TextEditingController editAddressController = TextEditingController(
      text: savedAddresses[index].address,
    );
    final TextEditingController editPincodeController = TextEditingController(
      text: savedAddresses[index].pincode,
    );
    final editFormKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        title: Row(
          children: [
            Icon(Icons.edit, color: /*Color(0xFF836653)*/isDark ? Colors.white : Color(0xff1a1a1a)),
            SizedBox(width: 8),
            Text('Edit Address', style: TextStyle(color: isDark ? Colors.white : Color(0xff1a1a1a)),),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Address Field
                TextFormField(
                  controller: editAddressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: isDark ? Colors.white : Color(0xff1a1a1a)),
                    hintText: 'Enter complete address',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: isDark ? Colors.white : Color(0xff1a1a1a),
                      // color: Color(0xF0836653),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: /*Color(0xF0836653)*/isDark ? Colors.white : Color(0xff1a1a1a),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter address';
                    }
                    if (value.trim().length < 10) {
                      return 'Address should be at least 10 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Pincode Field
                TextFormField(
                  controller: editPincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Pincode',
                    labelStyle: TextStyle(color: isDark ? Colors.white : Color(0xff1a1a1a)),
                    hintText: 'Enter 6-digit pincode',
                    prefixIcon: Icon(
                      Icons.pin_drop,
                      color: isDark ? Colors.white : Color(0xff1a1a1a),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: /*Color(0xF0836653)*/isDark ? Colors.white : Color(0xff1a1a1a),
                        width: 2,
                      ),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter pincode';
                    }
                    if (value.trim().length != 6) {
                      return 'Pincode must be 6 digits';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                      return 'Only numbers allowed';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.grey : Color(0xff1a1a1a)),
            ),
          ),
          ElevatedButton(
            onPressed: () async  {
              if (editFormKey.currentState!.validate()) {
                final newAddress = editAddressController.text.trim();
                final newPincode = editPincodeController.text.trim();

                Get.back();

                await Future.delayed(Duration(milliseconds: 200), () async {
                  if (!mounted) return;
                  setState(() {
                    savedAddresses[index].address = newAddress;
                    savedAddresses[index].pincode = newPincode;
                  });
                  await _saveAddressesToStorage();

                  Get.snackbar(
                    'Success',
                    'Address updated successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 2),
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: Color(0xFF836653),
              backgroundColor: isDark ? Colors.white : Color(0xff1a1a1a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Update',
              style: TextStyle(color: /*Colors.white*/isDark ? Color(0xff1a1a1a) : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Address select karenge
  void _selectAddress(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Address delete karenge
  void _deleteAddress(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        title: Text('Delete Address', style: TextStyle(color: isDark ? Colors.white : Color(0xff1a1a1a)),),
        content: Text('Are you sure you want to delete this address?', style: TextStyle(color: isDark ? Colors.white : Color(0xff1a1a1a))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey : Color(0xff1a1a1a)),),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (savedAddresses[index].isSelected &&
                    savedAddresses.length > 1) {
                  savedAddresses.removeAt(index);
                  savedAddresses[0].isSelected = true;
                  selectedIndex = 0;
                } else if (savedAddresses.length == 1) {
                  savedAddresses.removeAt(index);
                  selectedIndex = -1;
                } else {
                  savedAddresses.removeAt(index);
                  if (selectedIndex > index) {
                    selectedIndex--;
                  }
                }
              });

              _saveAddressesToStorage();
              Navigator.pop(context);

              Get.snackbar(
                'Deleted',
                'Address deleted successfully',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Selected address ko return karenge aur save karenge
  void _useSelectedAddress() {
    if (selectedIndex >= 0 && selectedIndex < savedAddresses.length) {
      setState(() {
        for (var address in savedAddresses) {
          address.isSelected = false;
        }
        savedAddresses[selectedIndex].isSelected = true;
      });

      _saveAddressesToStorage();

      Map<String, String> locationData = {
        'address': savedAddresses[selectedIndex].address,
        'pincode': savedAddresses[selectedIndex].pincode,
      };
      Get.back(result: locationData);
    } else {
      Get.snackbar(
        'Error',
        'Please select an address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    pincodeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalUtils.init(context);
    final festival = themeController.getCurrentFestival();
    final festivalData = themeController.festivalThemes[festival];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff1a1a1a) : Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if(savedAddresses.isEmpty){
              Map<String, String> locationData = {
                'address': "Add address details!",
                'pincode': "",
              };
              Get.back(result: locationData);
            }else{
              Get.back();
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: festival != 'default' && festivalData != null
                ? LinearGradient(
              colors: festivalData['colors'] as List<Color>,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: GlobalUtils.getBackgroundColor(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Manage Addresses',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Add New Address Form - Always scrollable
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Add New Address Form
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Address',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xff1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Address Field
                            TextFormField(
                              controller: addressController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Enter complete address',
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: isDark ? Colors.white : Color(0xff1a1a1a),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? Colors.white : Color(0xff1a1a1a),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff5f5f5),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter address';
                                }
                                if (value.trim().length < 10) {
                                  return 'Address should be at least 10 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Pincode Field
                            TextFormField(
                              controller: pincodeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                hintText: 'Enter 6-digit pincode',
                                prefixIcon: Icon(
                                  Icons.pin_drop,
                                  color: isDark ? Colors.white : Color(0xff1a1a1a),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? Colors.white : Color(0xff1a1a1a),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff5f5f5),
                                counterText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter pincode';
                                }
                                if (value.trim().length != 6) {
                                  return 'Pincode must be 6 digits';
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                                  return 'Only numbers allowed';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Add Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _addNewAddress,
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text(
                                  'Add Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ).decorated(
                                gradient: festival != 'default' && festivalData != null
                                    ? LinearGradient(
                                  colors: festivalData['colors'] as List<Color>,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                    : LinearGradient(
                                  colors: GlobalUtils.getBackgroundColor(),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(thickness: 8, color: isDark ? Colors.grey : Color(0xffe0e0e0)),

                    // Saved Addresses List
                    savedAddresses.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No saved addresses',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first address above',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Saved Addresses (${savedAddresses.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Color(0xFF333333),
                            ),
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = savedAddresses[index];
                            return Card(
                              color: isDark ? const Color(0xff2a2a2a) : Colors.white,
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: selectedIndex == index
                                      ? isDark ? Colors.white : Color(0xff1a1a1a)
                                      // ? const Color(0xFF836653)
                                      : Colors.grey.shade300,
                                  width: selectedIndex == index ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _selectAddress(index),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                        value: index,
                                        groupValue: selectedIndex,
                                        onChanged: (value) {
                                          if (value != null) {
                                            _selectAddress(value);
                                          }
                                        },
                                        // activeColor: const Color(0xFF836653),
                                        activeColor: isDark ? Colors.white : Color(0xff1a1a1a),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 20,
                                                  // color: Color(0xFF836653),
                                                  color: isDark ? Colors.white : Color(0xff1a1a1a),
                                                ),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    address.address,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: selectedIndex == index
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isDark ? Colors.white : Colors.black,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.fiber_pin,
                                                  size: 16,
                                                  // color: Colors.grey,
                                                  color: isDark ? Colors.white : Color(0xff1a1a1a),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Pincode: ${address.pincode}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    // color: Colors.grey.shade700,
                                                    color: isDark ? Colors.white.withAlpha(150) : Color(0xff1a1a1a).withAlpha(150),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _editAddress(index),
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          // color: Color(0xFF836653),
                                          color: isDark ? Colors.white : Color(0xff1a1a1a),
                                        ),
                                        tooltip: 'Edit Address',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteAddress(index),
                                        icon: Icon(
                                          Icons.delete_forever_outlined,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Delete Address',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Use Selected Address Button - Always visible when addresses exist
            if (savedAddresses.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1a1a1a) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _useSelectedAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: festival != 'default' && festivalData != null
                            ? LinearGradient(
                          colors: festivalData['colors'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : LinearGradient(
                          colors: GlobalUtils.getBackgroundColor(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Use This Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Extension for gradient decoration
extension WidgetModifier on Widget {
  Widget decorated({
    Gradient? gradient,
    BorderRadius? borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }
}
