import 'package:carbine/lib.dart';
import 'package:carbine/main.dart';
import 'package:carbine/number_pad.dart';
import 'package:carbine/payment_selector.dart';
import 'package:carbine/onchain_receive.dart';
import 'package:carbine/scan.dart';
import 'package:carbine/theme.dart';
import 'package:carbine/refund.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  final FederationSelector fed;

  const Dashboard({super.key, required this.fed});

  @override
  State<Dashboard> createState() => _DashboardState();
}

enum PaymentType { lightning, onchain, ecash }

class _DashboardState extends State<Dashboard> {
  BigInt? balanceMsats;
  bool isLoadingBalance = true;
  bool isLoadingTransactions = true;
  final List<Transaction> _transactions = [];
  bool showMsats = false;

  Transaction? _lastTransaction;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  PaymentType _selectedPaymentType = PaymentType.lightning;

  VoidCallback? _pendingAction;

  late Stream<DepositEvent> depositEvents;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBalance();
    _loadTransactions();
    depositEvents =
        debugWalletStream(
          federationId: widget.fed.federationId,
        ).asBroadcastStream();
    depositEvents.listen((event) {
      if (event.eventKind is DepositEventKind_Confirmed) {
        final confirmedEvt =
            (event.eventKind as DepositEventKind_Confirmed).field0;
        print('pattern match confirmed: ${confirmedEvt.txid}');
        _loadBalance();
        _loadTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleAction(VoidCallback action) {
    setState(() {
      _pendingAction = action;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isFetchingMore &&
        _hasMore) {
      _loadTransactions(loadMore: true);
    }
  }

  List<String> _getKindsForSelectedPaymentType() {
    switch (_selectedPaymentType) {
      case PaymentType.lightning:
        return ['ln', 'lnv2'];
      case PaymentType.onchain:
        return ['wallet'];
      case PaymentType.ecash:
        return ['mint'];
    }
  }

  String _getNoTransactionsMessage() {
    switch (_selectedPaymentType) {
      case PaymentType.lightning:
        return "No lightning transactions yet";
      case PaymentType.onchain:
        return "No onchain transactions yet";
      case PaymentType.ecash:
        return "No ecash transactions yet";
    }
  }

  Future<void> _loadBalance() async {
    final bal = await balance(federationId: widget.fed.federationId);
    setState(() {
      balanceMsats = bal;
      isLoadingBalance = false;
    });
  }

  Future<void> _loadTransactions({bool loadMore = false}) async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;

    if (!loadMore) {
      setState(() {
        isLoadingTransactions = true;
        _transactions.clear();
        _hasMore = true;
        _lastTransaction = null;
      });
    }

    final newTxs = await transactions(
      federationId: widget.fed.federationId,
      timestamp: loadMore ? _lastTransaction?.timestamp : null,
      operationId: loadMore ? _lastTransaction?.operationId : null,
      modules: _getKindsForSelectedPaymentType(),
    );

    setState(() {
      _transactions.addAll(newTxs);
      if (newTxs.length < 10) {
        _hasMore = false;
      }
      if (newTxs.isNotEmpty) {
        _lastTransaction = newTxs.last;
      }
      isLoadingTransactions = false;
      _isFetchingMore = false;
    });
  }

  void _onSendPressed() async {
    if (_selectedPaymentType == PaymentType.lightning) {
      //await Navigator.push(context, MaterialPageRoute(builder: (context) => ScanQRPage(selectedFed: widget.fed)));
      await showCarbineModalBottomSheet(
        context: context,
        child: PaymentMethodSelector(fed: widget.fed),
      );
    } else if (_selectedPaymentType == PaymentType.ecash) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  NumberPad(fed: widget.fed, paymentType: _selectedPaymentType),
        ),
      );
    }
    _loadBalance();
    _loadTransactions();
  }

  void _onReceivePressed() async {
    if (_selectedPaymentType == PaymentType.lightning) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  NumberPad(fed: widget.fed, paymentType: _selectedPaymentType),
        ),
      );
    } else if (_selectedPaymentType == PaymentType.onchain) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnChainReceive(fed: widget.fed),
        ),
      );
    } else if (_selectedPaymentType == PaymentType.ecash) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanQRPage(selectedFed: widget.fed),
        ),
      );
    }

    _loadBalance();
    _loadTransactions();
  }

  void _onRefundPressed() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => RefundConfirmationPage(
              fed: widget.fed,
              balanceMsats: balanceMsats!,
            ),
      ),
    );

    _loadBalance();
    _loadTransactions();
  }

  void _onDebugPressed() async {
    print("something works");
    debugWalletStream(federationId: widget.fed.federationId);
    print("past call to debug wallet");
    _loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.fed.federationName;

    return Scaffold(
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onClose: () async {
          if (_pendingAction != null) {
            await Future.delayed(const Duration(milliseconds: 200));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pendingAction!();
              _pendingAction = null;
            });
          }
        },
        children: [
          SpeedDialChild(
            child: const Icon(Icons.download),
            label: 'Receive',
            backgroundColor: Colors.green,
            onTap: () => _scheduleAction(_onReceivePressed),
          ),
          if (balanceMsats != null && balanceMsats! > BigInt.zero)
            if (_selectedPaymentType == PaymentType.onchain)
              SpeedDialChild(
                child: const Icon(Icons.reply),
                label: 'Refund',
                backgroundColor: Colors.orange,
                onTap: () => _scheduleAction(_onRefundPressed),
              )
            else
              SpeedDialChild(
                child: const Icon(Icons.upload),
                label: 'Send',
                backgroundColor: Colors.blue,
                onTap: () => _scheduleAction(_onSendPressed),
              ),
          if (_selectedPaymentType == PaymentType.onchain)
            SpeedDialChild(
              child: const Icon(Icons.bug_report),
              label: 'Debug',
              backgroundColor: Colors.indigo,
              onTap: () => _scheduleAction(_onDebugPressed),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
              child: Column(
                children: [
                  Text(
                    name.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.5),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.fed.network.toLowerCase() != 'bitcoin')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "This is a test network and is not worth anything.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amberAccent,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 48),
            if (isLoadingBalance)
              const CircularProgressIndicator()
            else
              GestureDetector(
                onTap: () {
                  setState(() {
                    showMsats = !showMsats;
                  });
                },
                child: Text(
                  formatBalance(balanceMsats, showMsats),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 48),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Transactions",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // --- On‐chain deposit as a single row ---
                  StreamBuilder<DepositEvent>(
                    stream: depositEvents,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final event = snapshot.data!;

                      String msg;
                      BigInt amount;
                      switch (event.eventKind) {
                        case DepositEventKind_Mempool(field0: final mempoolEvt):
                          print('pattern match mempool: ${mempoolEvt.amount}');
                          msg = 'Tx seen in mempool';
                          amount = mempoolEvt.amount;
                          break;
                        case DepositEventKind_AwaitingConfs(
                          field0: final awaitEvt,
                        ):
                          print('pattern matcch awaiting: ${awaitEvt.needed}');
                          msg =
                              'Tx included in block ${awaitEvt.blockHeight}. Awaiting confs, needed: ${awaitEvt.needed}';
                          amount = awaitEvt.amount;
                          break;
                        case DepositEventKind_Confirmed(
                          field0: final confirmedEvt,
                        ):
                          return const SizedBox();
                      }

                      final amountStyle = TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      );
                      print('amount to format: ${amount}');
                      final formattedAmount = formatBalance(amount, false);

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        color: Theme.of(context).colorScheme.surface,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.greenAccent.withOpacity(
                              0.1,
                            ),
                            child: Icon(Icons.link, color: Colors.yellowAccent),
                          ),
                          title: Text(
                            "Received",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            msg,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          // subtitle: Text(
                          // TODO: get date
                          //   formattedDate,
                          //   style: Theme.of(context).textTheme.bodyMedium,
                          // ),
                          trailing: Text(formattedAmount, style: amountStyle),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            isLoadingTransactions
                ? const CircularProgressIndicator()
                : _transactions.isEmpty
                ? Text(_getNoTransactionsMessage())
                : SizedBox(
                  height: 300,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _transactions.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _transactions.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final tx = _transactions[index];
                      final isIncoming = tx.received;
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        tx.timestamp.toInt(),
                      );
                      final formattedDate = DateFormat.yMMMd().add_jm().format(
                        date,
                      );
                      final formattedAmount = formatBalance(tx.amount, false);

                      IconData moduleIcon;
                      switch (tx.module) {
                        case 'ln':
                        case 'lnv2':
                          moduleIcon = Icons.flash_on;
                          break;
                        case 'wallet':
                          moduleIcon = Icons.link;
                          break;
                        case 'mint':
                          moduleIcon = Icons.currency_bitcoin;
                          break;
                        default:
                          moduleIcon = Icons.help_outline;
                      }

                      final amountStyle = TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isIncoming ? Colors.greenAccent : Colors.redAccent,
                      );

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        color: Theme.of(context).colorScheme.surface,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isIncoming
                                    ? Colors.greenAccent.withOpacity(0.1)
                                    : Colors.redAccent.withOpacity(0.1),
                            child: Icon(
                              moduleIcon,
                              color:
                                  isIncoming
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                            ),
                          ),
                          title: Text(
                            isIncoming ? "Received" : "Sent",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Text(formattedAmount, style: amountStyle),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPaymentType.index,
        onTap: (index) {
          setState(() {
            _selectedPaymentType = PaymentType.values[index];
          });
          _loadTransactions();
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Lightning',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Onchain'),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Ecash',
          ),
        ],
      ),
    );
  }
}
