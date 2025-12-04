import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Customer Service'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 48,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'re here to assist you',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Contact Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    context,
                    icon: Icons.phone,
                    title: 'Call Us',
                    subtitle: '+63 XXX XXX XXXX',
                    color: Colors.green,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening phone dialer...'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    icon: Icons.email,
                    title: 'Email Us',
                    subtitle: 'support@fkkenterprise.com',
                    color: Colors.blue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening email app...')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    icon: Icons.chat_bubble,
                    title: 'Live Chat',
                    subtitle: 'Chat with our support team',
                    color: const Color(0xFF7E57C2),
                    onTap: () {
                      _showChatDialog(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    context,
                    icon: Icons.facebook,
                    title: 'Facebook',
                    subtitle: 'Message us on Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Facebook...')),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // FAQ Section
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQCard(
                    'How do I track my order?',
                    'Go to My Orders section in your profile to view order status and tracking information.',
                  ),
                  const SizedBox(height: 12),
                  _buildFAQCard(
                    'What payment methods do you accept?',
                    'We accept cash on delivery, bank transfer, and major credit/debit cards.',
                  ),
                  const SizedBox(height: 12),
                  _buildFAQCard(
                    'How long is the delivery time?',
                    'Standard delivery takes 3-5 business days. Express delivery is also available.',
                  ),
                  const SizedBox(height: 12),
                  _buildFAQCard(
                    'What is your return policy?',
                    'We offer 7-day return for defective items. Please contact us for return authorization.',
                  ),
                  const SizedBox(height: 24),

                  // Operating Hours
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: AppTheme.accentColor,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Operating Hours',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Monday - Friday: 8:00 AM - 6:00 PM',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Saturday: 9:00 AM - 5:00 PM',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sunday: Closed',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Chat feature is coming soon!\n\nFor now, please contact us via phone or email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
