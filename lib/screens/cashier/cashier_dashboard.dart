import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_models.dart';
import '../../screens/login_screen.dart';
import '../../theme/app_theme.dart'; // Import the AppTheme

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({Key? key}) : super(key: key);

  @override
  _CashierDashboardState createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  final AuthService _authService = AuthService();
  final DashboardService _dashboardService = DashboardService();
  bool _isLoading = true;
  CashierDashboardData? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dashboardData = await _dashboardService.getCashierDashboardData();
      setState(() {
        _dashboardData = dashboardData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Cashier Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
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
                        onPressed: _loadDashboardData,
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to new sale screen
        },
        backgroundColor: AppColors.secondaryColor,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New Sale'),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.secondaryColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Cashier Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: AppColors.primaryColor),
            title: Text(
              'Dashboard',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
            selected: true,
            selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.point_of_sale, color: AppColors.primaryColor),
            title: Text(
              'New Sale',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigate to new sale screen
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long, color: AppColors.primaryColor),
            title: Text(
              'Sales History',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigate to sales history screen
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory, color: AppColors.primaryColor),
            title: Text(
              'Products',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigate to products screen
            },
          ),
          Divider(color: AppColors.dividerColor),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.primaryColor),
            title: Text(
              'Settings',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.errorColor),
            title: Text(
              'Logout',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_dashboardData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppColors.textTertiaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: AppTheme.sectionTitle,
            ),
            SizedBox(height: 8),
            Text(
              'There is no dashboard data to display',
              style: TextStyle(
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    final currencySymbol = _dashboardData!.settings['currency_symbol'];

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Summary',
              style: AppTheme.pageTitle,
            ),
            const SizedBox(height: 24),
            
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Sales Today',
                    value: _dashboardData!.todaySalesCount.toString(),
                    icon: Icons.receipt,
                    color: AppColors.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Revenue',
                    value: '$currencySymbol ${_dashboardData!.todayRevenue.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: AppColors.infoColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Low stock alert
            if (_dashboardData!.lowStockAlert)
              _buildLowStockAlert(),
              
            const SizedBox(height: 24),
            
            // Quick actions
            Text(
              'Quick Actions',
              style: AppTheme.sectionTitle,
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(
                  title: 'New Sale',
                  icon: Icons.add_shopping_cart,
                  color: AppColors.primaryColor,
                  onTap: () {
                    // Navigate to new sale
                  },
                ),
                _buildActionCard(
                  title: 'View Products',
                  icon: Icons.search,
                  color: AppColors.secondaryColor,
                  onTap: () {
                    // Navigate to products
                  },
                ),
                _buildActionCard(
                  title: 'My Sales',
                  icon: Icons.history,
                  color: AppColors.tertiaryColor,
                  onTap: () {
                    // Navigate to sales history
                  },
                ),
                _buildActionCard(
                  title: 'Daily Report',
                  icon: Icons.bar_chart,
                  color: AppColors.infoColor,
                  onTap: () {
                    // Navigate to reports
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent sales section
            Text(
              'Recent Sales',
              style: AppTheme.sectionTitle,
            ),
            const SizedBox(height: 16),
            
            // If dashboard contains recent sales data
            _dashboardData!.recentSales.isEmpty
                ? Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    shadowColor: AppColors.shadowColor,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No recent sales data available',
                        style: TextStyle(color: AppColors.textSecondaryColor),
                      ),
                    ),
                  )
                : Column(
                    children: _dashboardData!.recentSales.map((sale) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: AppColors.shadowColor,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            child: Icon(Icons.receipt, color: AppColors.primaryColor),
                          ),
                          title: Text(
                            'Invoice #${sale.receiptNumber}',
                            style: AppTheme.cardTitle,
                          ),
                          subtitle: Text(
                            '${sale.items} items • ${sale.time}',
                            style: AppTheme.cardSubtitle,
                          ),
                          trailing: Text(
                            '$currencySymbol ${sale.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          onTap: () {
                            // View sale details
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title, 
    required String value, 
    required IconData icon, 
    required Color color
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: AppColors.shadowColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: AppColors.shadowColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockAlert() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.errorColor.withOpacity(0.1),
      shadowColor: AppColors.shadowColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.errorColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Low Stock Alert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.errorColor,
                    ),
                  ),
                  Text(
                    '${_dashboardData!.lowStockCount} products are running low on stock',
                    style: TextStyle(
                      color: AppColors.errorColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to low stock page
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.errorColor),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'View',
                style: TextStyle(
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