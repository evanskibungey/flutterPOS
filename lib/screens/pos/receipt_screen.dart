import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/theme/app_theme.dart'; // Import the AppTheme

class ReceiptScreen extends StatelessWidget {
  final String receiptNumber;
  final Map<String, dynamic> receiptData;
  final VoidCallback onClose;
  
  const ReceiptScreen({
    Key? key,
    required this.receiptNumber,
    required this.receiptData,
    required this.onClose,
  }) : super(key: key);

  // Helper method to safely format numeric values
  String formatNumber(dynamic value) {
    if (value == null) return '0.00';
    
    // If value is already a string, convert it to double first
    if (value is String) {
      try {
        return double.parse(value).toStringAsFixed(2);
      } catch (e) {
        // If parsing fails, return the original string
        return value;
      }
    }
    
    // If value is numeric, format it
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    
    // Fallback for unknown types
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    
    // Format date
    final date = receiptData['date'] != null
        ? DateTime.parse(receiptData['date'])
        : DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    
    // Extract items
    final items = List<Map<String, dynamic>>.from(receiptData['items'] ?? []);
    
    // Calculate total
    final dynamic total = receiptData['total'] ?? 0.0;
    
    // Extract payment method
    final paymentMethod = receiptData['payment_method'] ?? 'cash';
    
    // Extract customer details
    final customer = receiptData['customer'] ?? {'name': 'Walk-in Customer', 'phone': '-'};
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Receipt',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              // TODO: Implement printing functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Printing is not implemented in this demo'),
                  backgroundColor: AppColors.infoColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Print Receipt',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Receipt wrapper with subtle shadow
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        offset: Offset(0, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Receipt header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receipt #$receiptNumber',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                paymentMethod == 'cash' ? 'Cash' : 'Credit',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Company info
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'EldoGas',
                              style: AppTheme.sectionTitle,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tel: +254700123456',
                              style: TextStyle(
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(color: AppColors.dividerColor),
                      
                      // Customer info (for credit)
                      if (paymentMethod == 'credit')
                        Container(
                          padding: EdgeInsets.all(16),
                          color: AppColors.primaryColor.withOpacity(0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.secondaryColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Name:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      customer['name'] ?? 'Walk-in Customer',
                                      style: TextStyle(
                                        color: AppColors.textPrimaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: AppColors.secondaryColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Phone:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      customer['phone'] ?? '-',
                                      style: TextStyle(
                                        color: AppColors.textPrimaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      if (paymentMethod == 'credit')
                        Divider(color: AppColors.dividerColor),
                      
                      // Items header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Item',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Qty',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Price',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryColor,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryColor,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(color: AppColors.dividerColor),
                      
                      // Items list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: AppColors.dividerColor,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item name and serial
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Unknown Item',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      if (item['serial_number'] != null) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          'S/N: ${item['serial_number']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondaryColor,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                // Quantity
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${item['quantity'] ?? 0}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                
                                // Price
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'KSh ${formatNumber(item['price'])}',
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                
                                // Subtotal
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'KSh ${formatNumber(item['subtotal'])}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryColor,
                                    ),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      Divider(color: AppColors.dividerColor),
                      
                      // Totals
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal:',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  'KSh ${formatNumber(total)}',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tax (0%):',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  'KSh 0.00',
                                  style: TextStyle(
                                    color: AppColors.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Divider(color: AppColors.dividerColor),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimaryColor,
                                  ),
                                ),
                                Text(
                                  'KSh ${formatNumber(total)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      Divider(color: AppColors.dividerColor),
                      
                      // Footer
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Thank you for your business!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Keep this receipt for any returns or exchanges.',
                              style: TextStyle(
                                color: AppColors.textSecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Eldogas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Copy receipt number to clipboard
                          Clipboard.setData(ClipboardData(text: receiptNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Receipt number copied to clipboard'),
                              backgroundColor: AppColors.infoColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: AppColors.textPrimaryColor,
                        ),
                        icon: Icon(Icons.copy),
                        label: Text('Copy Number'),
                      ),
                      ElevatedButton.icon(
                        onPressed: onClose,
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text('New Sale'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}