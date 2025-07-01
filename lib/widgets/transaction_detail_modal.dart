import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:carbine/multimint.dart';
import 'package:carbine/utils.dart';
import 'package:carbine/theme.dart';
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

          // Transaction details matching RFQ style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailRow(
                  Theme.of(context),
                  transaction.module == 'wallet' && isIncoming
                      ? 'Deposit Address Created'
                      : transaction.module == 'wallet' && !isIncoming
                      ? 'Withdrawal Initiated'
                      : 'Created',
                  formattedDate,
                ),
                // Show block inclusion time if available (for on-chain transactions)
                if (transaction.txid != null && transaction.blockTime != null)
                  buildDetailRow(
                    Theme.of(context),
                    'Block Inclusion Time',
                    _formatBlockTime(transaction.blockTime!),
                  ),
                // Show transaction hash for on-chain transactions
                if (transaction.txid != null)
                  _buildTxidDetailRow(
                    context,
                    'Transaction Hash',
                    transaction.txid!,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Close button matching RFQ style
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTxidDetailRow(BuildContext context, String label, String txid) {
    final explorerUrl = _getExplorerUrl(txid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transaction hash with inline copy button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                height: 20,
                width: 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _formatTxid(txid),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                          height: 1.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: txid));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Transaction hash copied to clipboard',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.copy_outlined,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Explorer link on separate line
        if (explorerUrl != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 110, bottom: 6),
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse(explorerUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View on blockchain explorer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
}
