import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  final String whatsappNumber = '919876543210';

  const HelpSupportScreen({super.key}); // Replace with actual number

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Help & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Get in touch with us for any queries or support',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),

            _buildActionCard(
              context,
              icon: Icons.chat,
              title: 'Chat with us',
              subtitle: 'Connect via WhatsApp',
              color: Colors.green,
              onTap: () => _launchWhatsApp(''),
            ),

            SizedBox(height: 15),

            _buildActionCard(
              context,
              icon: Icons.report_problem,
              title: 'Report an Issue',
              subtitle: 'Tell us about your problem',
              color: Colors.orange,
              onTap: () => _launchWhatsApp('I want to report an issue: '),
            ),

            SizedBox(height: 15),

            _buildActionCard(
              context,
              icon: Icons.delivery_dining,
              title: 'Track Order',
              subtitle: 'Check your order status',
              color: Colors.blue,
              onTap: () => _launchWhatsApp('I want to track my order: '),
            ),

            SizedBox(height: 15),

            _buildActionCard(
              context,
              icon: Icons.help_outline,
              title: 'General Query',
              subtitle: 'Ask us anything',
              color: Colors.purple,
              onTap: () => _launchWhatsApp('I have a question: '),
            ),

            SizedBox(height: 30),

            // FAQs Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),

            _buildFAQItem(
              'How do I track my order?',
              'Go to My Orders section and click on the order to see detailed tracking information.',
            ),
            _buildFAQItem(
              'What is the return policy?',
              'You can return products within 7 days of delivery. Contact support for return requests.',
            ),
            _buildFAQItem(
              'How can I change my delivery address?',
              'You can update your delivery address in the Account section under Manage Addresses.',
            ),
            _buildFAQItem(
              'What payment methods are accepted?',
              'We accept Cash on Delivery and Online Payments (UPI, Cards, Net Banking).',
            ),

            SizedBox(height: 30),

            // Contact Information
            Container(
              padding: EdgeInsets.all(20),
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
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Text(
                        'Call us: +91 98765 43210',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.email, color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Text(
                        'Email: support@ecommerce.com',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                      SizedBox(width: 10),
                      Text(
                        'Mon - Sat: 9:00 AM - 6:00 PM',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _launchWhatsApp(String prefilledMessage) async {
    final url = 'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(prefilledMessage)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open WhatsApp. Please make sure WhatsApp is installed.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open WhatsApp: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}