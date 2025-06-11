import 'package:carbine/dashboard.dart';
import 'package:carbine/lib.dart';
import 'package:carbine/multimint.dart';
import 'package:carbine/scan.dart';
import 'package:carbine/setttings.dart';
import 'package:carbine/sidebar.dart';
import 'package:carbine/theme.dart';
import 'package:carbine/utils.dart';
import 'package:carbine/welcome.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  final List<(FederationSelector, bool)> initialFederations;
  const MyApp({super.key, required this.initialFederations});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<(FederationSelector, bool)> _feds;
  int _refreshTrigger = 0;
  FederationSelector? _selectedFederation;
  bool? _isRecovering;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _feds = widget.initialFederations;

    if (_feds.isNotEmpty) {
      _selectedFederation = _feds.first.$1;
      _isRecovering = _feds.first.$2;
    }
  }

  void _onJoinPressed(FederationSelector fed, bool recovering) {
    _setSelectedFederation(fed, recovering);
    _refreshFederations();
  }

  void _setSelectedFederation(FederationSelector fed, bool recovering) {
    setState(() {
      _selectedFederation = fed;
      _isRecovering = recovering;
      _currentIndex = 0;
    });
  }

  void _refreshFederations() async {
    final feds = await federations();
    setState(() {
      _feds = feds;
      _refreshTrigger++;
    });
  }

  void _onScanPressed(BuildContext context) async {
    final result = await Navigator.push<(FederationSelector, bool)>(
      context,
      MaterialPageRoute(builder: (context) => const ScanQRPage()),
    );

    if (result != null) {
      _setSelectedFederation(result.$1, result.$2);
      _refreshFederations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Joined ${result.$1.federationName}")),
      );
    } else {
      AppLogger.instance.w('Scan result is null, not updating federations');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_selectedFederation != null) {
      bodyContent = Dashboard(
        key: ValueKey(_selectedFederation!.federationId),
        fed: _selectedFederation!,
        recovering: _isRecovering!,
      );
    } else {
      if (_currentIndex == 1) {
        bodyContent = SettingsScreen(onJoin: _onJoinPressed);
      } else {
        bodyContent = WelcomeWidget(onJoin: _onJoinPressed);
      }
    }

    return MaterialApp(
      title: 'Carbine',
      debugShowCheckedModeBanner: false,
      theme: cypherpunkNinjaTheme,
      home: Builder(
        builder:
            (innerContext) => Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scan',
                    onPressed: () => _onScanPressed(innerContext),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1;
                        _selectedFederation = null;
                      });
                    },
                  ),
                ],
              ),
              drawer: SafeArea(
                child: FederationSidebar(
                  key: ValueKey(_refreshTrigger),
                  initialFederations: _feds,
                  onFederationSelected: _setSelectedFederation,
                ),
              ),
              body: SafeArea(child: bodyContent),
            ),
      ),
    );
  }
}
