import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/models/credit_sale.dart';
import 'package:pos_app/models/payment.dart';
import '../../models/customer.dart';
import '../../services/credit_service.dart';
import '../../utils/format_utils.dart';
import '../../theme/app_theme.dart'; // Import the AppTheme
import 'record_payment_screen.dart';

class CustomerCreditDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerCreditDetailScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  _CustomerCreditDetailScreenState createState() => _CustomerCreditDetailScreenState();
}

class _CustomerCreditDetailScreenState extends State<CustomerCreditDetailScreen>
    with SingleTickerProviderStateMixin {
  final CreditService _creditService = CreditService();
  late TabController _tabController;
  Customer? _customer;
  List<CreditSale> _creditSales = [];
  List<Payment> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomerDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _creditService.getCustomerCreditDetails(widget.customerId);
      setState(() {
        _customer = data['customer'];
        _creditSales = data['creditSales'];
        _payments = data['payments'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          _customer?.name ?? 'Customer Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomerDetails,
          ),
        ],
        bottom: _isLoading || _error != null
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Credit Sales'),
                  Tab(text: 'Payments'),
                ],
              ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.errorColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadCustomerDetails,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
      floatingActionButton: !_isLoading && _error == null && _customer != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordPaymentScreen(customer: _customer!),
                  ),
                );
                if (result == true) {
                  _loadCustomerDetails();
                }
              },
              label: const Text('Record Payment'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.secondaryColor,
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_customer == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: AppColors.textTertiaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Customer information not available',
              style: AppTheme.sectionTitle,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Customer Summary Card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shadowColor: AppColors.shadowColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        radius: 24,
                        child: Text(
                          _customer?.name != null && _customer!.name.isNotEmpty 
                              ? _customer!.name.substring(0, 1).toUpperCase() 
                              : '?',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customer?.name ?? 'Unknown Customer',
                              style: AppTheme.cardTitle.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${_customer?.phone ?? 'N/A'}',
                              style: AppTheme.cardSubtitle,
                            ),
                            if (_customer?.email != null && _customer!.email!.isNotEmpty)
                              Text(
                                'Email: ${_customer!.email}',
                                style: AppTheme.cardSubtitle,
                              ),
                            if (_customer?.address != null && _customer!.address!.isNotEmpty)
                              Text(
                                'Address: ${_customer!.address}',
                                style: AppTheme.cardSubtitle,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 32, color: AppColors.dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Outstanding Balance:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'KSh ${formatCurrency(_customer?.balance ?? 0.0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCreditSalesTab(),
              _buildPaymentsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditSalesTab() {
    if (_creditSales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textTertiaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No credit sales found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _creditSales.length,
      itemBuilder: (context, index) {
        final creditSale = _creditSales[index];
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sale #${creditSale.referenceNo}',
                      style: AppTheme.cardTitle,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: creditSale.paymentStatus == 'paid'
                            ? AppColors.successColor.withOpacity(0.1)
                            : AppColors.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        creditSale.paymentStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: creditSale.paymentStatus == 'paid'
                              ? AppColors.successColor
                              : AppColors.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(creditSale.createdAt)}',
                  style: TextStyle(
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                Divider(height: 24, color: AppColors.dividerColor),
                
                // Sale Items
                ...creditSale.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.product?['name'] ?? 'Product'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                      Text(
                        'KSh ${formatCurrency(item.subtotal)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                )),
                
                Divider(height: 24, color: AppColors.dividerColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'KSh ${formatCurrency(creditSale.finalAmount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payments_outlined,
              size: 64,
              color: AppColors.textTertiaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No payments recorded yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment #${payment.id}',
                  style: AppTheme.cardTitle,
                ),
                Text(
                  'KSh ${formatCurrency(payment.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(payment.createdAt)}',
                  style: AppTheme.cardSubtitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Method: ${payment.paymentMethod.replaceAll('_', ' ').toUpperCase()}',
                  style: AppTheme.cardSubtitle,
                ),
                if (payment.referenceNumber != null && payment.referenceNumber!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Reference: ${payment.referenceNumber}',
                    style: AppTheme.cardSubtitle,
                  ),
                ],
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes: ${payment.notes}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}