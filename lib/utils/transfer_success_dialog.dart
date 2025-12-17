import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:payrupya/controllers/dmt_wallet_controller.dart';
import '../models/transfer_money_response_model.dart';

class TransferSuccessDialog extends StatefulWidget {
  final TransferData transferData;
  final VoidCallback onClose;

  const TransferSuccessDialog({
    super.key,
    required this.transferData,
    required this.onClose,
  });

  @override
  State<TransferSuccessDialog> createState() => _TransferSuccessDialogState();
}

class _TransferSuccessDialogState extends State<TransferSuccessDialog> {
  DmtWalletController dmtController = Get.put(DmtWalletController());
  bool _isDialogActive = true;
  @override
  void dispose() {
    _isDialogActive = false;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Still allow done button to work
        return false;
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(  // Main Column (not scrollable)
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Success Title
                      Text(
                        'Transfer Successful!',
                        style: GoogleFonts.albertSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),

                      // // Transaction Description
                      // Text(
                      //   transferData.txnDesc ?? 'Transaction completed successfully',
                      //   textAlign: TextAlign.center,
                      //   style: GoogleFonts.albertSans(
                      //     fontSize: 14,
                      //     color: Colors.grey[600],
                      //   ),
                      // ),
                      // SizedBox(height: 20),

                      // Transaction Details Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Details',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                            SizedBox(height: 12),

                            buildDetailRow('Transaction ID', widget.transferData.txnid ?? 'N/A'),
                            buildDetailRow('Beneficiary', widget.transferData.benename ?? 'N/A'),
                            buildDetailRow('Amount', '₹${double.parse(widget.transferData.trasamt.toString()) ?? 0.toString()}'),
                            buildDetailRow('Charges', '₹${widget.transferData.totalcharge ?? 0}'),
                            buildDetailRow('Total Amount', '₹${double.parse(widget.transferData.chargedamt.toString())+double.parse(widget.transferData.totalcharge.toString())}'),
                            buildDetailRow('Status', widget.transferData.txnStatus ?? 'N/A',
                                statusColor: widget.transferData.txnStatus == 'SUCCESS' ? Colors.green : Colors.orange),
                            buildDetailRow('Date & Time', widget.transferData.datetext ?? widget.transferData.date ?? 'N/A'),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),

                      // Print Receipt and Share to WhatsApp Buttons
                      Row(
                        children: [
                          // Print Receipt Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                dmtController.printReceipt(
                                    context,
                                    // "W251216105122UBFT"
                                    widget.transferData.txnid ?? ''
                                ).then((_) {
                                  // Optional: Show toast when done
                                  if (_isDialogActive && mounted) {
                                    // PDF opened successfully
                                  }
                                }).catchError((error) {
                                  // Handle error silently
                                });
                                // Call Print Receipt API
                                // await dmtController.printReceipt(
                                //     context,
                                //     transferData.txnid ?? ''
                                // );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Color(0xFF0054D3), width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.print,
                                      color: Color(0xFF0054D3),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Print Receipt',
                                      style: GoogleFonts.albertSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0054D3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Share to WhatsApp Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                dmtController.shareToWhatsApp(
                                  context,
                                  // "W251216105122UBFT",
                                  // "7728869247",
                                  widget.transferData.txnid ?? '',
                                  dmtController.senderMobileNo.value,
                                ).then((_) {
                                  // Optional: Show toast when done
                                  if (_isDialogActive && mounted) {
                                    // Share completed successfully
                                  }
                                }).catchError((error) {
                                  // Handle error silently
                                });
                                // Call Share to WhatsApp API
                                // await dmtController.shareToWhatsApp(
                                //   context,
                                //   transferData.txnid ?? '',
                                //   dmtController.senderMobileNo.value,
                                // );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Color(0xFF25D366), // WhatsApp Green
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.share,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Share',
                                      style: GoogleFonts.albertSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // // Wallet Balance Section
                      // if (transferData.availableLimit != null)
                      //   Container(
                      //     decoration: BoxDecoration(
                      //       color: Color(0xFFE3F2FD),
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     padding: EdgeInsets.all(16),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //       children: [
                      //         // Column(
                      //         //   crossAxisAlignment: CrossAxisAlignment.start,
                      //         //   children: [
                      //         //     Text(
                      //         //       'Available Limit',
                      //         //       style: GoogleFonts.albertSans(
                      //         //         fontSize: 12,
                      //         //         color: Colors.grey[600],
                      //         //       ),
                      //         //     ),
                      //         //     SizedBox(height: 4),
                      //         //     Text(
                      //         //       '₹${transferData.availableLimit}',
                      //         //       style: GoogleFonts.albertSans(
                      //         //         fontSize: 20,
                      //         //         fontWeight: FontWeight.bold,
                      //         //         color: Color(0xFF0054D3),
                      //         //       ),
                      //         //     ),
                      //         //   ],
                      //         // ),
                      //         // Column(
                      //         //   crossAxisAlignment: CrossAxisAlignment.end,
                      //         //   children: [
                      //         //     Text(
                      //         //       'Monthly Limit',
                      //         //       style: GoogleFonts.albertSans(
                      //         //         fontSize: 12,
                      //         //         color: Colors.grey[600],
                      //         //       ),
                      //         //     ),
                      //         //     SizedBox(height: 4),
                      //         //     Text(
                      //         //       '₹${transferData.monthlyLimit}',
                      //         //       style: GoogleFonts.albertSans(
                      //         //         fontSize: 16,
                      //         //         fontWeight: FontWeight.w600,
                      //         //         color: Color(0xff1B1C1C),
                      //         //       ),
                      //         //     ),
                      //         //   ],
                      //         // ),
                      //       ],
                      //     ),
                      //   ),
                      SizedBox(height: 10),  // Reduced spacing before button
                    ],
                  ),
                ),
              ),
            ),

            // button (outside scroll)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                      'Done',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.albertSans(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.albertSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusColor ?? Color(0xff1B1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}