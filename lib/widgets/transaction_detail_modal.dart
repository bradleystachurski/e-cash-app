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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered header with icon and amount
          Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: amountColor.withOpacity(0.1),
                child: Icon(moduleIcon, color: amountColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                formattedAmount,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                paymentType,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Transaction details in table format
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(8),
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
                ),
                // Show block inclusion time if available (for on-chain transactions)
                if (transaction.txid != null && transaction.blockTime != null)
                  _buildTableRow(
                    context,
                    'Block Inclusion Time',
                    _formatBlockTime(transaction.blockTime!),
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

  Widget _buildTableRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableDetailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Operation ID copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatOperationId(List<int> operationId) {
    final hex = operationId
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join('');
    if (hex.length > 16) {
      return '${hex.substring(0, 8)}...${hex.substring(hex.length - 8)}';
    }
    return hex;
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        _formatTxid(txid),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
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
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'Copy to clipboard',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (explorerUrl != null) ...[
            const SizedBox(height: 8),
            Align(
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
          ],
        ],
      ),
    );
  }
}
