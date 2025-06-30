import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:carbine/multimint.dart';
import 'package:carbine/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailModal extends StatelessWidget {
  final Transaction transaction;
  final String? network;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    this.network,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.received;
    final date = DateTime.fromMillisecondsSinceEpoch(
      transaction.timestamp.toInt(),
    );
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
    final formattedAmount = formatBalance(transaction.amount, false);

    IconData moduleIcon;
    String paymentType;
    switch (transaction.module) {
      case 'ln':
      case 'lnv2':
        moduleIcon = Icons.flash_on;
        paymentType = 'Lightning';
        break;
      case 'wallet':
        moduleIcon = Icons.link;
        paymentType = 'On-chain';
        break;
      case 'mint':
        moduleIcon = Icons.currency_bitcoin;
        paymentType = 'E-cash';
        break;
      default:
        moduleIcon = Icons.help_outline;
        paymentType = 'Unknown';
    }

    final amountColor = isIncoming ? Colors.greenAccent : Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header matching RFQ style
          CircleAvatar(
            radius: 30,
            backgroundColor: amountColor.withOpacity(0.2),
            child: Icon(moduleIcon, color: amountColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            formattedAmount,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            paymentType,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // Transaction details matching RFQ table style
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                _buildTableRow(
                  context,
                  transaction.module == 'wallet' && isIncoming
                      ? 'Deposit Address Created'
                      : transaction.module == 'wallet' && !isIncoming
                      ? 'Withdrawal Initiated'
                      : 'Created',
                  formattedDate,
                  showDivider:
                      transaction.blockTime != null || transaction.txid != null,
                ),
                // Show block inclusion time if available (for on-chain transactions)
                if (transaction.txid != null && transaction.blockTime != null)
                  _buildTableRow(
                    context,
                    'Block Inclusion Time',
                    _formatBlockTime(transaction.blockTime!),
                    showDivider: transaction.txid != null,
                  ),
                // Show transaction hash for on-chain transactions
                if (transaction.txid != null)
                  _buildTxidTableRow(
                    context,
                    'Transaction Hash',
                    transaction.txid!,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    String label,
    String value, {
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }

  String? _getExplorerUrl(String txid) {
    if (network == null) return null;
    switch (network) {
      case 'bitcoin':
        return 'https://mempool.space/tx/$txid';
      case 'signet':
        return 'https://mutinynet.com/tx/$txid';
      default:
        return null;
    }
  }

  String _formatTxid(String txid) {
    if (txid.length > 16) {
      return '${txid.substring(0, 8)}...${txid.substring(txid.length - 8)}';
    }
    return txid;
  }

  String _formatBlockTime(BigInt blockTime) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      blockTime.toInt() * 1000,
    );
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  Widget _buildTxidTableRow(BuildContext context, String label, String txid) {
    final explorerUrl = _getExplorerUrl(txid);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTxid(txid),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: txid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction hash copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    tooltip: 'Copy to clipboard',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    splashRadius: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (explorerUrl != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  final uri = Uri.parse(explorerUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  'View on blockchain explorer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
