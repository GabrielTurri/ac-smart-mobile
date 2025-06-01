import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:ac_smart/views/atividade/ui/app_bar.dart';
import 'package:ac_smart/views/atividade/ui/app_drawer.dart';
import 'package:ac_smart/viewmodels/login_viewmodel.dart';
import 'package:ac_smart/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late HomepageProvider homepageProvider;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load user data when the dashboard is first displayed
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      homepageProvider = Provider.of<HomepageProvider>(context, listen: false);
      await homepageProvider.lerNomeUsuario();

      // Load user data from API
      final userData = await UserService().fetchUserData(context);

      // If no user data was loaded, try to create a minimal user object from SharedPreferences
      if (userData == null) {
        await homepageProvider.loadUserFromPrefs();
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the user object from the provider
    final user = context.watch<HomepageProvider>().user;
    final nomeUsuario = context.watch<HomepageProvider>().nomeUsuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () {
            context.go('/login');
          },
        ),
        backgroundColor: const Color(0xff043565),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                const Color(0xff496F93).withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xff496F93),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            nomeUsuario,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user != null
                                ? user.course.courseName
                                : 'Nome do curso',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          if (user?.email != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              user!.email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Horas complementares',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildHoursCard(
                                    'Entregues',
                                    user != null
                                        ? '${user.totalApprovedHours}h'
                                        : '0h',
                                    Colors.green.shade50,
                                    Colors.green),
                                _buildHoursCard(
                                    'Pendentes',
                                    user != null
                                        ? '${user.totalPendingHours}h'
                                        : '0h',
                                    Colors.amber.shade50,
                                    Colors.amber),
                                _buildHoursCard(
                                    'Rejeitadas',
                                    user != null
                                        ? '${user.totalRejectedHours}h'
                                        : '0h',
                                    Colors.red.shade50,
                                    Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  BoxDecoration dashboardPanelDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 1,
        color: const Color(0xff496F93),
      ),
      color: const Color(0xffF7FBFF),
      borderRadius: BorderRadius.circular(24),
    );
  }

  Widget _buildHoursCard(
      String title, String hours, Color backgroundColor, Color textColor) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            hours,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}
