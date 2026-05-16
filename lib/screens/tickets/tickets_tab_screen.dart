import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth_provider.dart';
import '../../models/ticket_provider.dart';
import 'my_tickets_screen.dart';

class TicketsTabScreen extends StatefulWidget {
  const TicketsTabScreen({super.key});

  @override
  State<TicketsTabScreen> createState() => _TicketsTabScreenState();
}

class _TicketsTabScreenState extends State<TicketsTabScreen> {
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (authProvider.isLoggedIn && userId != null && userId != _loadedUserId) {
      _loadedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TicketProvider>().loadUserTickets(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MyTicketsScreen();
  }
}
