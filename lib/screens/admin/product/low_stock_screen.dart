import 'package:flutter/material.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/services/product_service.dart';
import 'package:pos_app/theme/app_theme.dart'; // Import the AppTheme

class LowStockScreen extends StatefulWidget {
  final String currencySymbol;
  
  const LowStockScreen({
    Key? key,
    required this.currencySymbol,
  }) : super(key: key);

  @override
  _LowStockScreenState createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  final ProductService _productService = ProductService();
  
  List<Product> _lowStockProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadLowStockProducts();
  }

  Future<void> _loadLowStockProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.getLowStockProducts();
      setState(() {
        _lowStockProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load low stock products: $e';
        _isLoading = false;
      });
    }
  }

  // Update product stock
  Future<void> _updateStock(Product product) async {
    // Controller for new stock value
    final TextEditingController stockController = TextEditingController(text: product.stock.toString());
    final TextEditingController notesController = TextEditingController();
    
    // Show dialog to input new stock value
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Product: ${product.name}',
              style: TextStyle(
                color: AppColors.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current stock: ${product.stock}',
              style: TextStyle(color: AppColors.textSecondaryColor),
            ),
            Text(
              'Minimum stock: ${product.minStock}',
              style: TextStyle(color: AppColors.textSecondaryColor),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: InputDecoration(
                labelText: 'New Stock',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({
              'stock': int.tryParse(stockController.text) ?? product.stock,
              'notes': notesController.text,
            }),
            child: const Text('UPDATE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    // If user submitted new stock value
    if (result != null) {
      try {
        await _productService.updateStock(
          product.id,
          result['stock'],
          result['notes'].isNotEmpty ? result['notes'] : null,
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock updated successfully'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Refresh list
        _loadLowStockProducts();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Low Stock Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLowStockProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadLowStockProducts,
                          icon: Icon(Icons.refresh),
                          label: Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _lowStockProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: AppColors.successColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No low stock products',
                            style: AppTheme.sectionTitle,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'All products have sufficient stock levels',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_lowStockProducts.length} products need restock',
                                style: AppTheme.sectionTitle,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 18,
                                      color: AppColors.errorColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Low Stock Alert',
                                      style: TextStyle(
                                        color: AppColors.errorColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Products list
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadLowStockProducts,
                            color: AppColors.primaryColor,
                            child: ListView.builder(
                              itemCount: _lowStockProducts.length,
                              itemBuilder: (context, index) {
                                final product = _lowStockProducts[index];
                                final categoryName = product.category != null 
                                    ? product.category['name'] ?? 'Unknown Category'
                                    : 'Unknown Category';
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: AppColors.errorColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  elevation: 2,
                                  shadowColor: AppColors.shadowColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Product image or placeholder
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: product.image != null
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        product.image!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Icon(
                                                            Icons.inventory_2_outlined,
                                                            color: AppColors.textSecondaryColor,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.inventory_2_outlined,
                                                      color: AppColors.textSecondaryColor,
                                                    ),
                                            ),
                                            const SizedBox(width: 16),
                                            
                                            // Product info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: AppTheme.cardTitle,
                                                  ),
                                                  Text(
                                                    categoryName,
                                                    style: AppTheme.cardSubtitle,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'SKU: ${product.sku}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            // Price
                                            Text(
                                              '${widget.currencySymbol}${product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        // Stock info with progress bar
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Current Stock: ${product.stock}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.textPrimaryColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Min Stock: ${product.minStock}',
                                                        style: TextStyle(
                                                          color: AppColors.textSecondaryColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(4),
                                                      child: LinearProgressIndicator(
                                                        value: product.minStock > 0
                                                            ? (product.stock / product.minStock).clamp(0.0, 1.0)
                                                            : 0,
                                                        backgroundColor: Colors.grey.shade300,
                                                        color: AppColors.getStockStatusColor(product.stock, product.minStock),
                                                        minHeight: 8,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        // Action button
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _updateStock(product),
                                            icon: const Icon(Icons.add_shopping_cart),
                                            label: const Text('Restock Now'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}