import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_order_screen_controller.dart';
import '../models/MyOrderApiResponseModel.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  final MyOrderScreenController controller = Get.put(MyOrderScreenController());

  MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Orders'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.orderList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'No Orders Yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Start shopping to see your orders here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyOrders,
          child: ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: controller.orderList.length,
            itemBuilder: (context, index) {
              final order = controller.orderList[index];
              return _buildOrderCard(context, order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, MyOrder order) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Get.to(() => OrderDetailsScreen(/*orderId: order.id ?? ''*/));
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderId/*orderNo*/ ?? 'N/A'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order.orderStatus?.toString()/*status*/ ?? 'pending'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(
                    order.createdAt?.toString() ?? '',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(
                    '${/*order.*//*items*/controller.orderList.length} item(s)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Spacer(),
                  Text(
                    '₹${order.totalAmount ?? '0'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              if (order.orderStatus != null)/*.toLowerCase() == 'pending' ||
                  order.status?.toLowerCase() == 'confirmed')*/
                Column(
                  children: [
                    Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showDeleteConfirmation(context, order.id.toString());
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                            ),
                            child: Text('Cancel Order'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => OrderDetailsScreen(/*orderId: order.id.toString() ?? ''*/));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text('View Details'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Order'),
          content: Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // controller.deleteOrder(orderId);
                controller.deleteOrderApi(context, int.parse(orderId),);
              },
              child: Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}