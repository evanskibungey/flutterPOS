import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';
import '../../theme/app_theme.dart'; // Import the AppTheme
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter and sort state
  String? _statusFilter;
  String _sortBy = 'name';
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load categories with current filters
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _categoryService.getCategories(
        search: _searchController.text,
        status: _statusFilter,
        sort: _sortBy,
        page: _currentPage,
      );
      
      setState(() {
        _categories = result['categories'];
        _currentPage = result['current_page'];
        _lastPage = result['last_page'];
        _totalItems = result['total'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: $e';
        _isLoading = false;
      });
    }
  }

  // Handler for search
  void _handleSearch() {
    _currentPage = 1; // Reset to first page on new search
    _loadCategories();
  }

  // Handler for status filter change
  void _handleStatusFilterChange(String? newValue) {
    setState(() {
      _statusFilter = newValue;
      _currentPage = 1; // Reset to first page on filter change
    });
    _loadCategories();
  }

  // Handler for sort change
  void _handleSortChange(String newValue) {
    setState(() {
      _sortBy = newValue;
      _currentPage = 1; // Reset to first page on sort change
    });
    _loadCategories();
  }

  // Navigate to edit category
  void _editCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(category: category),
      ),
    ).then((_) => _loadCategories()); // Refresh list after returning
  }

  // Navigate to add category
  void _addCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(),
      ),
    ).then((_) => _loadCategories()); // Refresh list after returning
  }

  // Delete category
  Future<void> _deleteCategory(Category category) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('DELETE'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    // If user confirmed deletion
    if (confirm == true) {
      try {
        await _categoryService.deleteCategory(category.id);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Refresh list
        _loadCategories();
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
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
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
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(color: AppColors.textTertiaryColor),
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textTertiaryColor),
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
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: AppColors.textPrimaryColor),
                  onSubmitted: (_) => _handleSearch(),
                ),
                const SizedBox(height: 16),
                
                // Filters row
                Row(
                  children: [
                    // Status filter
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(color: AppColors.textSecondaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _statusFilter,
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All', style: TextStyle(color: AppColors.textPrimaryColor)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'active',
                            child: Text('Active', style: TextStyle(color: AppColors.textPrimaryColor)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'inactive',
                            child: Text('Inactive', style: TextStyle(color: AppColors.textPrimaryColor)),
                          ),
                        ],
                        onChanged: _handleStatusFilterChange,
                        dropdownColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Sort by dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Sort By',
                          labelStyle: TextStyle(color: AppColors.textSecondaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _sortBy,
                        items: [
                          DropdownMenuItem<String>(
                            value: 'name',
                            child: Text('Name', style: TextStyle(color: AppColors.textPrimaryColor)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'created_at',
                            child: Text('Newest', style: TextStyle(color: AppColors.textPrimaryColor)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _handleSortChange(value);
                          }
                        },
                        dropdownColor: Colors.white,
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
                  'Total: $_totalItems categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                // Pagination info
                if (!_isLoading && _lastPage > 1)
                  Text(
                    'Page $_currentPage of $_lastPage',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),
          
          // Main content - category list or loading indicator
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : _errorMessage != null
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
                                _errorMessage!,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadCategories,
                              icon: Icon(Icons.refresh),
                              label: Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _categories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 80,
                                  color: AppColors.textTertiaryColor,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No categories found',
                                  style: AppTheme.sectionTitle,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try a different search or add a new category',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryColor,
                                  ),
                                ),
                                SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _addCategory,
                                  icon: Icon(Icons.add),
                                  label: Text('Add Category'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCategories,
                            color: AppColors.primaryColor,
                            child: ListView.builder(
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  shadowColor: AppColors.shadowColor,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      category.name,
                                      style: AppTheme.cardTitle,
                                    ),
                                    subtitle: Text(
                                      category.description ?? 'No description',
                                      style: AppTheme.cardSubtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Status chip
                                        Chip(
                                          label: Text(
                                            category.status.toUpperCase(),
                                            style: TextStyle(
                                              color: category.status == 'active'
                                                  ? Colors.white
                                                  : AppColors.textSecondaryColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor: category.status == 'active'
                                              ? AppColors.successColor
                                              : Colors.grey.shade300,
                                          padding: EdgeInsets.zero,
                                        ),
                                        const SizedBox(width: 8),
                                        
                                        // Product count
                                        Chip(
                                          label: Text(
                                            '${category.productsCount} products',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: AppColors.infoColor,
                                          padding: EdgeInsets.zero,
                                        ),
                                        
                                        // Edit button
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editCategory(category),
                                          color: AppColors.infoColor,
                                        ),
                                        
                                        // Delete button
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteCategory(category),
                                          color: AppColors.errorColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
          
          // Pagination controls
          if (!_isLoading && _lastPage > 1)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                            _loadCategories();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                    child: Icon(Icons.chevron_left),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Page $_currentPage of $_lastPage',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _currentPage < _lastPage
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                            _loadCategories();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                    child: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: AppColors.secondaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }
}