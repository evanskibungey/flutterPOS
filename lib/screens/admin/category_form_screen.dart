import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';
import '../../theme/app_theme.dart'; // Import the AppTheme

class CategoryFormScreen extends StatefulWidget {
  final Category? category; // Null for create, non-null for edit

  const CategoryFormScreen({Key? key, this.category}) : super(key: key);

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final CategoryService _categoryService = CategoryService();
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'active';
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    // If editing, populate the form with category data
    if (_isEditMode) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _status = widget.category!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      if (_isEditMode) {
        // Update existing category
        await _categoryService.updateCategory(
          widget.category!.id,
          _nameController.text,
          _descriptionController.text.isEmpty ? null : _descriptionController.text,
          _status,
        );
        
        // Show success message and return to list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category updated successfully'),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new category
        await _categoryService.createCategory(
          _nameController.text,
          _descriptionController.text.isEmpty ? null : _descriptionController.text,
          _status,
        );
        
        // Show success message and return to list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category created successfully'),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
          _isEditMode ? 'Edit Category' : 'Add Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Error message if any
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: AppColors.errorColor),
                ),
              ),
            
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                prefixIcon: Icon(Icons.category, color: AppColors.primaryColor),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter category description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                prefixIcon: Icon(Icons.description, color: AppColors.primaryColor),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Status radio buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: AppTheme.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Active radio
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Active'),
                        value: 'active',
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                        activeColor: AppColors.successColor,
                      ),
                    ),
                    
                    // Inactive radio
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Inactive'),
                        value: 'inactive',
                        groupValue: _status,
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                        activeColor: AppColors.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCategory,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Update Category' : 'Create Category',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}