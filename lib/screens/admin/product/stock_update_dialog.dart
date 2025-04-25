import 'package:flutter/material.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/theme/app_theme.dart';

class StockUpdateDialog extends StatefulWidget {
  final Product product;
  final String currencySymbol;

  const StockUpdateDialog({
    Key? key,
    required this.product,
    required this.currencySymbol,
  }) : super(key: key);

  @override
  _StockUpdateDialogState createState() => _StockUpdateDialogState();
}

class _StockUpdateDialogState extends State<StockUpdateDialog> {
  late TextEditingController _stockController;
  final TextEditingController _notesController = TextEditingController();
  final List<String> _stockOperations = ['Set to', 'Add', 'Remove'];
  String _selectedOperation = 'Set to';
  int _calculatedStock = 0;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _calculatedStock = widget.product.stock;
    _updateCalculatedStock();
  }

  @override
  void dispose() {
    _stockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCalculatedStock() {
    final int inputValue = int.tryParse(_stockController.text) ?? 0;
    
    setState(() {
      switch (_selectedOperation) {
        case 'Set to':
          _calculatedStock = inputValue;
          break;
        case 'Add':
          _calculatedStock = widget.product.stock + inputValue;
          break;
        case 'Remove':
          _calculatedStock = widget.product.stock - inputValue;
          // Ensure stock doesn't go negative
          if (_calculatedStock < 0) _calculatedStock = 0;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          Icon(Icons.inventory_2, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          const Text('Update Stock'),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product: ${widget.product.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${widget.product.sku}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current stock: ${widget.product.stock}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Min stock level: ${widget.product.minStock}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 24),
              
              // Operation type selector
              Row(
                children: [
                  Text('Operation:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedOperation,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondaryColor, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      items: _stockOperations.map((operation) {
                        return DropdownMenuItem<String>(
                          value: operation,
                          child: Text(operation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedOperation = value;
                            // Reset input value to make it more intuitive
                            if (value == 'Set to') {
                              _stockController.text = widget.product.stock.toString();
                            } else {
                              _stockController.text = '0';
                            }
                            _updateCalculatedStock();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stock input
              TextField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: _selectedOperation == 'Set to' 
                    ? 'New Stock Value' 
                    : (_selectedOperation == 'Add' ? 'Add to Stock' : 'Remove from Stock'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondaryColor, width: 2),
                  ),
                  helperText: _selectedOperation == 'Set to'
                    ? 'Enter the total new stock value'
                    : (_selectedOperation == 'Add' 
                      ? 'Enter amount to add to current stock'
                      : 'Enter amount to remove from current stock'),
                  helperStyle: TextStyle(color: AppColors.textSecondaryColor),
                  prefixIcon: Icon(Icons.inventory, color: AppColors.secondaryColor),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateCalculatedStock(),
              ),
              const SizedBox(height: 8),
              
              // Calculated result
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _calculatedStock < widget.product.minStock 
                    ? AppColors.errorColor.withOpacity(0.1) 
                    : AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _calculatedStock < widget.product.minStock 
                      ? AppColors.errorColor.withOpacity(0.3) 
                      : AppColors.successColor.withOpacity(0.3)
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Resulting stock:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      '$_calculatedStock',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _calculatedStock < widget.product.minStock 
                          ? AppColors.errorColor 
                          : AppColors.successColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.secondaryColor, width: 2),
                  ),
                  hintText: 'Reason for adjustment',
                  prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.secondaryColor),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondaryColor,
          ),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'stock': _calculatedStock,
              'notes': _notesController.text,
              'operation': _selectedOperation,
              'input_value': int.tryParse(_stockController.text) ?? 0,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('UPDATE STOCK'),
        ),
      ],
    );
  }
}