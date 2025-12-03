import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_details_screen_controller.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  // final String orderId;
  //
  // OrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final OrderDetailsScreenController controller = 
        Get.put(OrderDetailsScreenController(/*orderId: orderId*/));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Order Details'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.orderList.value == null) {
          return Center(
            child: Text('No order details found'),
          );
        }

        final order = controller.orderList.value!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      'Order #${order.orderId/*orderNo*/ ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildStatusChip(order.orderStatus?.toString()/*status*/ ?? 'pending'),
                    SizedBox(height: 10),
                    Text(
                      'Placed on ${order.createdAt ?? ''}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Delivery Address
              _buildSection(
                context,
                'Delivery Address',
                Icons.location_on,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.address/*shippingAddress?.name*/ ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // SizedBox(height: 5),
                    // Text(order.shippingAddress?.address ?? ''),
                    // Text(
                    //   '${order.shippingAddress?.city ?? ''}, ${order.shippingAddress?.state ?? ''} - ${order.shippingAddress?.pincode ?? ''}',
                    // ),
                    SizedBox(height: 5),
                    Text('Phone: ${order.phoneNo/*shippingAddress?.phone*/ ?? ''}'),
                  ],
                ),
              ),

              // Order Items
              _buildSection(
                context,
                'Order Items',
                Icons.shopping_bag,
                Column(
                  children: order.products/*items*/?.map((item) {
                        return _buildOrderItem(context, item);
                      }).toList() ??
                      [],
                ),
              ),

              // Payment Summary
              _buildSection(
                context,
                'Payment Summary',
                Icons.payment,
                Column(
                  children: [
                    // _buildPriceRow('Subtotal', '₹${order./*subtotal*/ ?? '0'}'),
                    // _buildPriceRow('Delivery Charges', '₹${order./*deliveryCharges*/ ?? '0'}'),
                    // _buildPriceRow('Tax', '₹${order./*tax*/ ?? '0'}'),
                    // if (order./*discount*/ != null && order./*discount*/ != '0')
                    //   _buildPriceRow('Discount', '-₹${order./*discount*/}',
                    //       isDiscount: true),
                    // Divider(height: 20),
                    _buildPriceRow('Total Amount', '₹${order.totalAmount ?? '0'}',
                        isTotal: true),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.payment, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          'Payment Method: ${order.payMode/*paymentMethod*/ ?? 'N/A'}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, Widget child) {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.image ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'N/A',
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  'Qty: ${item.quantity ?? 0}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.price ?? '0'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        displayStatus = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        displayStatus = 'Confirmed';
        break;
      case 'processing':
        color = Colors.purple;
        displayStatus = 'Processing';
        break;
      case 'shipped':
        color = Colors.teal;
        displayStatus = 'Shipped';
        break;
      case 'delivered':
        color = Colors.green;
        displayStatus = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        displayStatus = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        displayStatus = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}