// pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import '../widgets/dashboard_header.dart';
import '../services/user_service.dart'; // Now using UserService for user management
import '../services/mechanic_service.dart'; // Dedicated service for mechanic management
import '../services/token_manager.dart'; // To get the current user's tokens/UID
import '../models/user_profile.dart'; // User profile model
import '../models/mechanic.dart'; // Mechanic model

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading =
      false; // For overall loading states (fetching data, actions)
  bool _isCurrentUserAdmin =
      false; // Flag to control admin-specific UI elements

  // Controllers for creating a new mechanic
  final TextEditingController _mechanicNameController = TextEditingController();
  final TextEditingController _mechanicEmailController =
      TextEditingController();
  final TextEditingController _mechanicSpecializationController =
      TextEditingController();
  final TextEditingController _mechanicPhoneController =
      TextEditingController();
  final GlobalKey<FormState> _mechanicFormKey =
      GlobalKey<FormState>(); // For form validation

  // Real lists to hold fetched data, using the imported models
  List<UserProfile> _users = [];
  List<Mechanic> _mechanics = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAdminStatusAndFetchData(); // Perform initial data fetch after checking admin status
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mechanicNameController.dispose();
    _mechanicEmailController.dispose();
    _mechanicSpecializationController.dispose();
    _mechanicPhoneController.dispose();
    super.dispose();
  }

  // --- Initial Setup and Data Fetching ---
  Future<void> _checkAdminStatusAndFetchData() async {
    setState(() {
      _isLoading = true; // Start loading for initial checks and data fetch
    });
    try {
      final String? idToken = await TokenManager.getIdToken();
      if (idToken == null) {
        _showSnackBar('Authentication required. Please log in.', Colors.red);
        // Optionally, navigate back to login page
        return;
      }

      // Check admin status from backend using UserService
      final Map<String, dynamic>? roleData = await UserService.fetchUserRole(
        idToken,
      );
      if (roleData != null && roleData['isAdmin'] == true) {
        setState(() {
          _isCurrentUserAdmin = true;
        });
        await _fetchUsers(); // Fetch users only if admin
        await _fetchMechanics(); // Fetch mechanics only if admin
      } else {
        _showSnackBar('You do not have administrative privileges.', Colors.red);
        // Optionally, navigate to a non-admin page
      }
    } catch (e) {
      _showSnackBar(
        'Error initializing dashboard: ${e.toString()}',
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- User Management Actions ---
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String? idToken = await TokenManager.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }
      final List<Map<String, dynamic>>? usersData = await UserService.getUsers(
        idToken,
      );
      if (usersData != null) {
        setState(() {
          // Assuming UserProfile.fromJson can handle the structure from getUsers
          _users = usersData.map((data) => UserProfile.fromJson(data)).toList();
        });
      } else {
        setState(() {
          _users = []; // Clear list if no data or error
        });
      }
    } catch (e) {
      _showSnackBar('Failed to fetch users: ${e.toString()}', Colors.red);
      setState(() {
        _users = []; // Clear list on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editUser(UserProfile user) {
    // Changed UserData to UserProfile
    _showSnackBar(
      'Editing user: ${user.email} - Feature coming soon!',
      Colors.blue,
    );
    // In a real app, navigate to an edit user page or show a dialog
  }

  void _deleteUser(UserProfile user) async {
    // Changed UserData to UserProfile
    // Prevent deleting self
    final String? currentUserId = await TokenManager.getUid();
    if (user.uid == currentUserId) {
      _showSnackBar('You cannot delete your own admin account.', Colors.orange);
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete user "${user.email}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        final String? idToken = await TokenManager.getIdToken();
        if (idToken == null) {
          throw Exception('User not authenticated.');
        }
        await UserService.deleteUserBackend(user.uid, idToken);
        _showSnackBar('User ${user.email} deleted successfully!', Colors.green);
        await _fetchUsers(); // Refresh the list after deletion
      } catch (e) {
        _showSnackBar('Failed to delete user: ${e.toString()}', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Mechanic Management Actions ---
  Future<void> _fetchMechanics() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String? idToken = await TokenManager.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }
      _mechanics =
          await MechanicService.getAllMechanics(); // Corrected service call
    } catch (e) {
      _showSnackBar('Failed to fetch mechanics: ${e.toString()}', Colors.red);
      setState(() {
        _mechanics = []; // Clear list on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editMechanic(Mechanic mechanic) {
    // Changed MechanicData to Mechanic
    _showSnackBar(
      'Editing mechanic: ${mechanic.name} - Feature coming soon!',
      Colors.blue,
    );
    // Implement edit mechanic logic
  }

  void _deleteMechanic(Mechanic mechanic) async {
    // Changed MechanicData to Mechanic
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete mechanic "${mechanic.name}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        final String? idToken = await TokenManager.getIdToken();
        if (idToken == null) {
          throw Exception('User not authenticated.');
        }
        await MechanicService.deleteMechanicBackend(
          mechanic.id!,
          idToken,
        ); // Corrected service call
        _showSnackBar(
          'Mechanic ${mechanic.name} deleted successfully!',
          Colors.green,
        );
        await _fetchMechanics(); // Refresh the list after deletion
      } catch (e) {
        _showSnackBar('Failed to delete mechanic: ${e.toString()}', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // Dark blue background
      body: SafeArea(
        child: Column(
          children: [
            // Dashboard Header
            const DashboardHeader(),

            // Main Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Tab Bar
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: const Color(0xFF3182CE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF2D3748),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                          tabs: const [
                            Tab(text: 'Users'),
                            Tab(text: 'Mechanics'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // --- Users Management Tab Content ---
                          _buildUsersTab(),
                          // --- Mechanics Management Tab Content ---
                          _buildMechanicsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders for Tabs ---

  Widget _buildUsersTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3182CE)),
      );
    }
    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No users found.',
          style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email ??
                      'No Email', // Use null-aware operator for safety
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UID: ${user.uid}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: ${user.role}',
                  style: TextStyle(
                    fontSize: 14,
                    color: user.role == 'Admin'
                        ? Colors.deepOrange
                        : const Color(0xFF718096),
                    fontWeight: user.role == 'Admin'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF3182CE)),
                      onPressed: () => _editUser(user),
                      tooltip: 'Edit User',
                    ),
                    if (_isCurrentUserAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _isLoading ? null : () => _deleteUser(user),
                        tooltip: 'Delete User',
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

  Widget _buildMechanicsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _mechanicFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Mechanic',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Existing Mechanics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            _mechanics.isEmpty
                ? const Center(
                    child: Text(
                      'No mechanics added yet.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mechanics.length,
                    itemBuilder: (context, index) {
                      final mechanic = _mechanics[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: const Icon(
                            Icons.build_circle,
                            color: Color(0xFF3182CE),
                          ),
                          title: Text(
                            mechanic.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${mechanic.specialties}\n${mechanic.email}\n${mechanic.phone}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF718096),
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF3182CE),
                                  size: 20,
                                ),
                                onPressed: () => _editMechanic(
                                  mechanic,
                                ), // Changed to _editMechanic
                                tooltip: 'Edit Mechanic',
                              ),
                              if (_isCurrentUserAdmin)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _deleteMechanic(mechanic),
                                  tooltip: 'Delete Mechanic',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
