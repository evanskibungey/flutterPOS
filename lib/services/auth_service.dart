import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  final storage = FlutterSecureStorage();
  User? _currentUser;
  bool _isAuthenticated = false;
  
  // Login using Laravel Sanctum authentication
  Future<User?> login(String email, String password) async {
    try {
      print('Attempting login for: $email');
      print('Using API endpoint: ${ApiConfig.baseUrl}/api/login');
      print('Request headers: {"Content-Type": "application/json", "Accept": "application/json"}');
      print('Request body: {"email": "$email", "password": "[HIDDEN]"}');
      
      // Perform login directly without CSRF token (not needed for API authentication)
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('token') && data['token'] != null) {
          // Save the token
          await storage.write(key: 'auth_token', value: data['token']);
          
          // Save user data
          await storage.write(key: 'user', value: jsonEncode(data['user']));
          
          // Update in-memory state
          _currentUser = User.fromJson(data['user']);
          _isAuthenticated = true;
          
          print('Login successful for user: ${_currentUser?.name}');
          return _currentUser;
        } else {
          throw Exception(data['message'] ?? 'Login failed - no token received');
        }
      } else if (response.statusCode == 422) {
        // Validation errors
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Login failed';
        
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors.containsKey('email')) {
            errorMessage = errors['email'][0];
          }
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
        
        throw Exception(errorMessage);
      } else {
        // Other HTTP errors
        throw Exception('Login failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow; // Re-throw the exception so the UI can handle it
    }
  }
  
  // Check if user is logged in
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    
    final userJson = await storage.read(key: 'user');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      _isAuthenticated = true;
      return _currentUser;
    }
    
    return null;
  }
  
  // Improved logout method with proper error handling and state management
  Future<bool> logout() async {
    try {
      print('Logout process started');
      final token = await storage.read(key: 'auth_token');
      
      if (token == null) {
        print('No auth token found, clearing local data only');
        await _clearLocalData();
        return true;
      }
      
      // Attempt to notify server about logout
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5)); // Add timeout
        
        print('Logout API response: ${response.statusCode}');
        
        // Even if server response is not 200, we still want to clear local data
        await _clearLocalData();
        return true;
      } catch (apiError) {
        // If API call fails, still clear local data
        print('API call failed during logout: $apiError');
        await _clearLocalData();
        return true; // Return true since we still logged out locally
      }
    } catch (e) {
      print('Logout error: $e');
      // Attempt to clear local data even if there was an error
      try {
        await _clearLocalData();
      } catch (storageError) {
        print('Failed to clear storage during logout: $storageError');
      }
      throw Exception('Logout failed: $e');
    }
  }
  
  // Helper method to clear all local authentication data
  Future<void> _clearLocalData() async {
    print('Clearing local authentication data');
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user');
    // Clear any other auth-related data you might have
    
    // Update in-memory state
    _currentUser = null;
    _isAuthenticated = false;
    print('Local authentication data cleared');
  }
  
  // Check if user is authenticated
  bool get isAuthenticated => _isAuthenticated;
  
  // Get the auth token
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }
  
  // Create a new user (for admin only)
  Future<User?> createUser(String name, String email, String password, String role) async {
    try {
      final token = await storage.read(key: 'auth_token');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
          'status': 'active',
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print('Create user error: $e');
      return null;
    }
  }
}