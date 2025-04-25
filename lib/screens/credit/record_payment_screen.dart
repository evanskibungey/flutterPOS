// screens/credit/record_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/customer.dart';
import '../../services/credit_service.dart';
import '../../utils/format_utils.dart';
import '../../theme/app_theme.dart'; // Import the AppTheme

class RecordPaymentScreen extends StatefulWidget {
  final Customer customer;

  const RecordPaymentScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isProcessing = false;
  String? _error;

  final CreditService _creditService = CreditService();

  @override
  void initState() {
    super.initState();
    // Pre-fill amount with the full balance if needed
    _amountController.text = widget.customer.balance.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final amount = double.parse(_amountController.text);
      
      await _creditService.recordPayment(
        widget.customer.id,
        amount,
        _paymentMethod,
        _referenceController.text.isEmpty ? null : _referenceController.text,
        _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of KSh ${formatCurrency(amount)} recorded successfully'),
          backgroundColor: AppColors.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context, true); // Return true to refresh the previous screen
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_error'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Record Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Summary Card
              Card(
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
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            radius: 20,
                            child: Text(
                              widget.customer.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.customer.name,
                                  style: AppTheme.cardTitle,
                                ),
                                Text(
                                  widget.customer.phone,
                                  style: AppTheme.cardSubtitle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24, color: AppColors.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Outstanding Balance:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                          Text(
                            'KSh ${formatCurrency(widget.customer.balance)}',
                            style: TextStyle(
                              fontSize: 16,
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
              
              const SizedBox(height: 24),
              Text(
                'Payment Details',
                style: AppTheme.sectionTitle,
              ),
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: AppColors.textSecondaryColor),
                  prefixText: 'KSh ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid amount';
                  }
                  if (amount <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  if (amount > widget.customer.balance) {
                    return 'Amount cannot exceed the outstanding balance';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Payment Method
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodOption('cash', 'Cash'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethodOption('mobile_money', 'Mobile Money'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethodOption('bank_transfer', 'Bank Transfer'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Reference Number
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'Reference Number (Optional)',
                  labelStyle: TextStyle(color: AppColors.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  hintText: 'e.g., M-Pesa code or bank reference',
                  hintStyle: TextStyle(color: AppColors.textTertiaryColor),
                ),
                validator: (value) {
                  if (_paymentMethod != 'cash' && (value == null || value.isEmpty)) {
                    return 'Reference number is required for this payment method';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle: TextStyle(color: AppColors.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  hintText: 'Any additional information about this payment',
                  hintStyle: TextStyle(color: AppColors.textTertiaryColor),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : const Text(
                          'Record Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.errorColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: AppColors.errorColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label) {
    final isSelected = _paymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}