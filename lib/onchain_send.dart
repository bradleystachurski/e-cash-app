import 'dart:async';
import 'package:carbine/lib.dart';
import 'package:carbine/multimint.dart';
import 'package:carbine/success.dart';
import 'package:carbine/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnchainSend extends StatefulWidget {
  final FederationSelector fed;
  final BigInt amountSats;

  const OnchainSend({super.key, required this.fed, required this.amountSats});

  @override
  State<OnchainSend> createState() => _OnchainSendState();
}

class _OnchainSendState extends State<OnchainSend> {
  final TextEditingController _addressController = TextEditingController();
  String? _feeQuote;
  BigInt? _feeAmountSats;
  bool _loadingFees = false;
  bool _withdrawing = false;
  DateTime? _quoteExpiry;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _quoteTimer?.cancel();
    super.dispose();
  }

  void _onAddressChanged() {
    if (_feeQuote != null) {
      setState(() {
        _feeQuote = null;
        _feeAmountSats = null;
        _quoteExpiry = null;
      });
      _quoteTimer?.cancel();
    }
  }

  Future<void> _calculateFees() async {
    if (_addressController.text.isEmpty) return;

    setState(() => _loadingFees = true);

    try {
      final fees = await calculateWithdrawFees(
        federationId: widget.fed.federationId,
        address: _addressController.text.trim(),
        amountSats: widget.amountSats,
      );

      setState(() {
        _feeAmountSats = fees;
        _feeQuote = 'Fee: $fees sats';
        _quoteExpiry = DateTime.now().add(const Duration(seconds: 60));
      });

      _startQuoteTimer();
    } catch (e) {
      AppLogger.instance.error('Failed to calculate fees: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to calculate fees: $e')));
    } finally {
      setState(() => _loadingFees = false);
    }
  }

  void _startQuoteTimer() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_quoteExpiry != null && DateTime.now().isAfter(_quoteExpiry!)) {
        setState(() {
          _feeQuote = null;
          _feeAmountSats = null;
          _quoteExpiry = null;
        });
        timer.cancel();
      } else {
        setState(() {}); // Refresh to update countdown
      }
    });
  }

  String _getQuoteTimeRemaining() {
    if (_quoteExpiry == null) return '';
    final remaining = _quoteExpiry!.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) return 'Expired';
    return '${remaining}s remaining';
  }

  Future<void> _withdraw() async {
    if (_addressController.text.isEmpty || _feeAmountSats == null) return;

    setState(() => _withdrawing = true);

    try {
      final operationId = await withdrawToAddress(
        federationId: widget.fed.federationId,
        address: _addressController.text.trim(),
        amountSats: widget.amountSats,
      );

      final txid = await awaitWithdraw(
        federationId: widget.fed.federationId,
        operationId: operationId,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => Success(
                  lightning: false,
                  received: false,
                  amountMsats: widget.amountSats * BigInt.from(1000),
                  txid: txid,
                ),
          ),
        );
      }
    } catch (e) {
      AppLogger.instance.error('Failed to withdraw: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Withdrawal failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _withdrawing = false);
      }
    }
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _addressController.text = clipboardData!.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canWithdraw =
        _feeQuote != null &&
        _quoteExpiry != null &&
        DateTime.now().isBefore(_quoteExpiry!) &&
        !_withdrawing;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.outbound, size: 48),
            const SizedBox(height: 12),
            Text(
              "Withdraw On-chain",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Withdrawing ${widget.amountSats} sats",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Address input
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Bitcoin Address',
                hintText: 'Enter destination address',
                prefixIcon: const Icon(Icons.account_balance_wallet),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: _pasteFromClipboard,
                  tooltip: 'Paste',
                ),
              ),
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: 16),

            // Calculate fees button
            if (_feeQuote == null)
              ElevatedButton.icon(
                onPressed: _loadingFees ? null : _calculateFees,
                icon:
                    _loadingFees
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.calculate),
                label: Text(_loadingFees ? 'Calculating...' : 'Calculate Fees'),
              ),

            // Fee quote display
            if (_feeQuote != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdrawal Quote',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Amount: ${widget.amountSats} sats'),
                      Text('Fee: $_feeAmountSats sats'),
                      Text(
                        'Total: ${widget.amountSats + _feeAmountSats!} sats',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getQuoteTimeRemaining(),
                        style: TextStyle(
                          color:
                              _quoteExpiry != null &&
                                      DateTime.now().isAfter(_quoteExpiry!)
                                  ? Colors.red
                                  : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                if (_feeQuote != null)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _feeQuote = null;
                          _feeAmountSats = null;
                          _quoteExpiry = null;
                        });
                        _quoteTimer?.cancel();
                      },
                      child: const Text('Recalculate'),
                    ),
                  ),
                if (_feeQuote != null) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canWithdraw ? _withdraw : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _withdrawing
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              _feeQuote == null
                                  ? 'Calculate Fees First'
                                  : 'Confirm Withdrawal',
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
