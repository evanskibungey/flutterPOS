import 'package:flutter/material.dart';
import 'package:pos_app/models/category.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/screens/admin/product/stock_movement_screen.dart';
import 'package:pos_app/screens/admin/product/stock_update_dialog.dart';
import 'package:pos_app/services/category_service.dart';
import 'package:pos_app/services/product_service.dart';
import 'package:pos_app/theme/app_theme.dart';

import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter and sort state
  String? _statusFilter;
  int? _categoryFilter;
  String? _stockStatusFilter;
  String _sortBy = 'name';
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  // Settings
  String _currencySymbol = '\$';
  int _lowStockThreshold = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load app settings
  Future<void> _loadSettings() async {
    // In a real app, you'd load these from a settings service or API
    setState(() {
      _currencySymbol = '\$'; // Default currency symbol
      _lowStockThreshold = 5; // Default low stock threshold
    });
  }

  // Load categories for filter dropdown
  Future<void> _loadCategories() async {
    try {
      final result = await _categoryService.getCategories(status: 'active');
      if (mounted) {
        setState(() {
          _categories = result['categories'] ?? [];
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Set empty categories list to prevent dropdown errors
      if (mounted) {
        setState(() {
          _categories = [];
        });
      }
    }
  }

  // Load products with current filters
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _productService.getProducts(
        search: _searchController.text,
        categoryId: _categoryFilter,
        status: _statusFilter,
        stockStatus: _stockStatusFilter,
        sort: _sortBy,
        sortDirection: 'desc', // Always show newest first
        page: _currentPage,
      );

      setState(() {
        _products = result['products'];
        _currentPage = result['current_page'];
        _lastPage = result['last_page'];
        _totalItems = result['total'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products: $e';
        _isLoading = false;
      });
    }
  }

  // Handler for search
  void _handleSearch() {
    _currentPage = 1; // Reset to first page on new search
    _loadProducts();
  }

  // Handler for status filter change
  void _handleStatusFilterChange(String? newValue) {
    setState(() {
      _statusFilter = newValue;
      _currentPage = 1; // Reset to first page on filter change
    });
    _loadProducts();
  }

  // Handler for category filter change
  void _handleCategoryFilterChange(int? newValue) {
    setState(() {
      _categoryFilter = newValue;
      _currentPage = 1; // Reset to first page on filter change
    });
    _loadProducts();
  }

  // Handler for stock status filter change
  void _handleStockStatusFilterChange(String? newValue) {
    setState(() {
      _stockStatusFilter = newValue;
      _currentPage = 1; // Reset to first page on filter change
    });
    _loadProducts();
  }

  // Handler for sort change
  void _handleSortChange(String newValue) {
    setState(() {
      _sortBy = newValue;
      _currentPage = 1; // Reset to first page on sort change
    });
    _loadProducts();
  }

  // Navigate to edit product
  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductFormScreen(
              product: product,
              categories: _categories,
              currencySymbol: _currencySymbol,
            ),
      ),
    ).then((_) => _loadProducts()); // Refresh list after returning
  }

  // Navigate to add product
  void _addProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductFormScreen(
              categories: _categories,
              currencySymbol: _currencySymbol,
            ),
      ),
    ).then((_) => _loadProducts()); // Refresh list after returning
  }

  // Delete product
  Future<void> _deleteProduct(Product product) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text(
              'Are you sure you want to delete "${product.name}"? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );

    // If user confirmed deletion
    if (confirm == true) {
      try {
        await _productService.deleteProduct(product.id);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: AppColors.successColor,
          ),
        );

        // Refresh list
        _loadProducts();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.errorColor),
        );
      }
    }
  }

  // Update product stock
  Future<void> _updateStock(Product product) async {
    // Show the enhanced stock update dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => StockUpdateDialog(
            product: product,
            currencySymbol: _currencySymbol,
          ),
    );

    // If user submitted stock update
    if (result != null) {
      try {
        // Construct notes with operation info for better tracking
        String notes = result['notes'] ?? '';
        if (result['operation'] != 'Set to') {
          String operationInfo =
              result['operation'] == 'Add'
                  ? 'Added ${result['input_value']} to stock'
                  : 'Removed ${result['input_value']} from stock';

          notes = notes.isEmpty ? operationInfo : '$operationInfo - $notes';
        }

        await _productService.updateStock(
          product.id,
          result['stock'],
          notes.isNotEmpty ? notes : null,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock updated successfully'),
            backgroundColor: AppColors.successColor,
          ),
        );

        // Refresh list
        _loadProducts();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating stock: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar and filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: AppColors.secondaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: AppColors.secondaryColor),
                      onPressed: () {
                        _searchController.clear();
                        _handleSearch();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.secondaryColor, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _handleSearch(),
                ),
                const SizedBox(height: 16),

                // First row of filters
                Row(
                  children: [
                    // Category filter
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int?>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _categoryFilter,
                        isExpanded: true, // Prevent overflow
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Categories', overflow: TextOverflow.ellipsis),
                          ),
                          ..._categories
                              .map(
                                (category) => DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(
                                    category.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                        onChanged: _handleCategoryFilterChange,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Status filter
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String?>(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _statusFilter,
                        isExpanded: true, // Prevent overflow
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: _handleStatusFilterChange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Second row of filters
                Row(
                  children: [
                    // Stock status filter
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String?>(
                        decoration: InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _stockStatusFilter,
                        isExpanded: true, // Prevent overflow
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'in_stock',
                            child: Text('In Stock'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'low_stock',
                            child: Text('Low Stock'),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'out_of_stock',
                            child: Text('Out of Stock'),
                          ),
                        ],
                        onChanged: _handleStockStatusFilterChange,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Sort by dropdown
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _sortBy,
                        isExpanded: true, // Prevent overflow
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'created_at',
                            child: Text('Newest'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'name',
                            child: Text('Name'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'price',
                            child: Text('Price'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'stock',
                            child: Text('Stock'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _handleSortChange(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List header with count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: $_totalItems products',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                // Pagination info
                if (!_isLoading && _lastPage > 1)
                  Text(
                    'Page $_currentPage of $_lastPage',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),

          // Main content - product list or loading indicator
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _products.isEmpty
                    ? const Center(child: Text('No products found'))
                    : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final bool isLowStock = product.isLowStock();
                          final Color stockStatusColor = AppTheme.getStockStatusColor(
                            product.stock, 
                            product.minStock,
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side:
                                  isLowStock
                                      ? BorderSide(
                                        color: stockStatusColor.withOpacity(0.5),
                                        width: 1,
                                      )
                                      : BorderSide.none,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading:
                                      product.image != null
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              '${product.image}', // Adjust URL as needed
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                          : Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2_outlined,
                                            ),
                                          ),
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    product.category != null
                                        ? product.category['name'] ??
                                            'Unknown Category'
                                        : 'Unknown Category',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          product.status == 'active'
                                              ? AppColors.successColor
                                              : Colors.grey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      product.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                                ),
                                child: Row(
                                children: [
                                // SKU and price
                                  Expanded(
                                  flex: 2,
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                    'SKU: ${product.sku}',
                                  style: TextStyle(
                                    fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                  'Price: $_currencySymbol${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                  ),
                                    overflow: TextOverflow.ellipsis,
                                    ),
                                    ],
                          ),
                                ),
                                const SizedBox(width: 8),

                                // Stock
                                Expanded(
                                flex: 1,
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory,
                                  size: 16,
                                  color: stockStatusColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                      'Stock: ${product.stock}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: stockStatusColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ],
                                  ),
                                    const SizedBox(height: 4),
                                      Text(
                                          'Min: ${product.minStock}',
                                            style: TextStyle(
                                                fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                                ButtonBar(
                                  alignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                    onPressed: () => _editProduct(product),
                                      style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryColor,
                                  ),
                                ),
                                    PopupMenuButton<String>(
                                    icon: Icon(Icons.inventory_2, color: AppColors.primaryColor),
                                    tooltip: 'Stock Management',
                                    onSelected: (value) {
                                    if (value == 'update') {
                                    _updateStock(product);
                                    } else if (value == 'history') {
                                    Navigator.of(context).push(
                                    MaterialPageRoute(
                                    builder:
                                    (_) => StockMovementScreen(
                                    product: product,
                                    currencySymbol:
                                    _currencySymbol,
                                    ),
                                    ),
                                    );
                                    }
                                    },
                                      itemBuilder:
                                          (context) => [
                                            const PopupMenuItem(
                                              value: 'update',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 20, color: AppColors.secondaryColor),
                                                  SizedBox(width: 8),
                                                  Text('Update Stock'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'history',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.history, size: 20, color: AppColors.secondaryColor),
                                                  SizedBox(width: 8),
                                                  Text('Stock History'),
                                                ],
                                              ),
                                            ),
                                          ],
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Delete'),
                                      onPressed: () => _deleteProduct(product),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),

          // Pagination controls
          if (!_isLoading && _lastPage > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        _currentPage > 1
                            ? () {
                              setState(() {
                                _currentPage--;
                              });
                              _loadProducts();
                            }
                            : null,
                    color: _currentPage > 1 ? AppColors.primaryColor : Colors.grey,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_currentPage / $_lastPage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        _currentPage < _lastPage
                            ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _loadProducts();
                            }
                            : null,
                    color: _currentPage < _lastPage ? AppColors.primaryColor : Colors.grey,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: AppColors.secondaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}
