import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import './login_screen.dart';
import './participants_tab.dart';
import './coach_tab.dart';
import './admin_tab.dart';
import './theory_tab.dart';
import './links_tab.dart';

/// Main home screen displayed after user login.
///
/// Sets up the available tabs based on the user's role (Participant, Coach, Admin).
/// Tabs may include Participation, Coach, Admin, Theory, and Links.
/// Also handles user logout and data refresh actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    // Defer the data loading until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.loadUserData();
    if (!mounted) return;
    _setupTabs();
  }

  void _setupTabs() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final role = dataProvider.role;

    _tabs = [
      const ParticipationTab(),
    ];
    if (role == 'Coach' || role == 'Admin') {
      _tabs.add(const CoachTab());
    }
    if (role == 'Admin') {
      _tabs.add(const AdminTab());
    }
    _tabs.add(const TheoryTab());
    _tabs.add(const LinksTab());

    if (_selectedIndex >= _tabs.length) {
      _selectedIndex = 0;
    }

    setState(() {});
  }

  void _refreshData() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.refreshData();
    _setupTabs();
  }

  void _logout() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.logout();
    _setupTabs();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    if (dataProvider.isLoading || _tabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Struer Taekwondo'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struer Taekwondo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(dataProvider.authToken.isEmpty ? Icons.login : Icons.logout),
            onPressed: () {
              if (dataProvider.authToken.isEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                _logout();
              }
            },
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _getBottomNavBarItems(dataProvider.role),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavBarItems(String role) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Participants',
      ),
    ];
    if (role == 'Coach' || role == 'Admin') {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Coach',
        ),
      );
    }
    if (role == 'Admin') {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Theory',
      ),
    );
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.info_outline),
        label: 'Links',
      ),
    );
    return items;
  }
}
