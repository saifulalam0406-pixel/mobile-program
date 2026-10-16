import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../data/auth_state.dart';
import '../features/home/home_screen.dart';
import '../features/tasks/screens/task_form_screen.dart';
import '../features/tasks/screens/task_list_screen.dart';
import '../features/tasks/task_controller.dart';
import '../screens/login_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AuthController _authController = AuthController();
  TaskController? _taskController;

  @override
  void initState() {
    super.initState();
    _authController.addListener(_handleAuthChanged);
    _authController.initialize();
  }

  @override
  void dispose() {
    _authController.removeListener(_handleAuthChanged);
    _taskController?.dispose();
    super.dispose();
  }

  void _handleAuthChanged() {
    final user = _authController.currentUser;
    final taskController = _taskController;

    if (user == null) {
      if (taskController != null) {
        taskController.dispose();
        _taskController = null;
      }
    } else if (taskController == null || taskController.userId != user.id) {
      _taskController = TaskController(userId: user.id);
      _taskController!.loadTasks();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser;

    if (_authController.isLoadingSession) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Catatan Tugas Kuliah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: user == null
          ? LoginScreen(authController: _authController)
          : _AuthenticatedShell(
              controller: _taskController ?? TaskController(userId: user.id),
              authController: _authController,
            ),
    );
  }
}

class _AuthenticatedShell extends StatefulWidget {
  const _AuthenticatedShell({
    required this.controller,
    required this.authController,
  });

  final TaskController controller;
  final AuthController authController;

  @override
  State<_AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<_AuthenticatedShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(controller: widget.controller),
      TaskListScreen(controller: widget.controller),
    ];

    final userName =
        widget.authController.currentUser?.fullName.split(' ').first ??
        'Pengguna';

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $userName'),
        actions: [
          IconButton(
            onPressed: () async {
              await widget.authController.logout();
            },
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(controller: widget.controller),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('+ Tugas'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Tugas',
          ),
        ],
      ),
    );
  }
}
