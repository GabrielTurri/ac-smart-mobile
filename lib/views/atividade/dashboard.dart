import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:ac_smart/viewmodels/homepage_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load user data when the dashboard is first displayed
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      context.read<HomepageProvider>().loadUserData(context);
    } catch (e) {
      debugPrint('Error loading user data: $e');
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
    final homepageProvider = context.watch<HomepageProvider>();
    final atividadeProvider = context.watch<AtividadeProvider>();
    // Get the user object from the provider
    final user = homepageProvider.user;
    final nomeUsuario = homepageProvider.nomeUsuario;

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
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color.fromARGB(
                                51, 73, 111, 147), // 0.2 opacity = 51/255 alpha
                            child: Icon(
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Suas horas complementares:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildHoursCard(
                                    'Horas Totais',
                                    user != null
                                        ? '${user.course.requiredHours}h'
                                        : '0h',
                                    Colors.black),
                                const Divider(),
                                _buildHoursCard(
                                    'Entregues',
                                    user != null
                                        ? '${user.totalApprovedHours}h'
                                        : '0h',
                                    Colors.green),
                                const Divider(),
                                _buildHoursCard(
                                    'Pendentes',
                                    user != null
                                        ? '${atividadeProvider.horasPedentes}h'
                                        : '0h',
                                    Colors.amber),
                                const Divider(),
                                _buildHoursCard(
                                    'Rejeitadas',
                                    user != null
                                        ? '${user.totalRejectedHours}h'
                                        : '0h',
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

  Widget _buildHoursCard(String title, String hours, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
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
