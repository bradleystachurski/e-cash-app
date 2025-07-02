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

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Amount section with icon
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: amountColor.withOpacity(0.15),
                  child: Icon(moduleIcon, color: amountColor, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  formattedAmount,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
          ),

          const SizedBox(height: 32),

          // Transaction details with unified container styling
          _buildDetailSection(context, isIncoming, formattedDate),

          // Explorer button (outside container if transaction hash exists)
          if (transaction.txid != null) ...[
            const SizedBox(height: 16),
            _buildExplorerButton(context, transaction.txid!),
          ],
        ],
      ),
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

  String _formatBlockTime(BigInt blockTime) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      blockTime.toInt() * 1000,
    );
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  Widget _buildDetailSection(
    BuildContext context,
    bool isIncoming,
    String formattedDate,
  ) {
    final theme = Theme.of(context);
    final List<Widget> detailRows = [];

    // Deposit address for on-chain deposits
    if (transaction.module == 'wallet' &&
        isIncoming &&
        transaction.depositAddress != null) {
      detailRows.add(
        _buildDetailRowWithCopy(
          context,
          theme,
          'Deposit Address',
          _formatAddressTruncated(transaction.depositAddress!),
          transaction.depositAddress!,
          'Deposit address copied',
        ),
      );
    }

    // Withdrawal address for on-chain withdrawals
    if (transaction.module == 'wallet' &&
        !isIncoming &&
        transaction.withdrawalAddress != null) {
      detailRows.add(
        _buildDetailRowWithCopy(
          context,
          theme,
          'Withdrawal Address',
          _formatAddressTruncated(transaction.withdrawalAddress!),
          transaction.withdrawalAddress!,
          'Withdrawal address copied',
        ),
      );
    }

    // Fee Rate
    if (transaction.feeRateSatsPerVb != null) {
      detailRows.add(
        buildDetailRow(
          theme,
          'Fee Rate',
          '${transaction.feeRateSatsPerVb!.toStringAsFixed(1)} sats/vB',
        ),
      );
    }

    // Transaction Size
    if (transaction.txSizeVb != null) {
      detailRows.add(
        buildDetailRow(theme, 'Tx Size', '${transaction.txSizeVb!} vB'),
      );
    }

    // Fee Amount
    if (transaction.feeSats != null) {
      detailRows.add(
        buildDetailRow(
          theme,
          'Fee',
          formatBalance(transaction.feeSats! * BigInt.from(1000), false),
        ),
      );
    }

    // Total Amount
    if (transaction.totalSats != null) {
      detailRows.add(
        buildDetailRow(
          theme,
          'Total',
          formatBalance(transaction.totalSats! * BigInt.from(1000), false),
        ),
      );
    }

    // Created/Initiated timestamp
    detailRows.add(
      buildDetailRow(
        theme,
        transaction.module == 'wallet' && isIncoming
            ? 'Deposit Created'
            : transaction.module == 'wallet' && !isIncoming
            ? 'Withdrawal Initiated'
            : 'Created',
        formattedDate,
      ),
    );

    // Block inclusion time if available
    if (transaction.txid != null && transaction.blockTime != null) {
      detailRows.add(
        buildDetailRow(
          theme,
          'Block Inclusion',
          _formatBlockTime(transaction.blockTime!),
        ),
      );
    }

    // Transaction hash if available
    if (transaction.txid != null) {
      detailRows.add(
        _buildDetailRowWithCopy(
          context,
          theme,
          'Transaction Hash',
          _formatTxidTruncated(transaction.txid!),
          transaction.txid!,
          'Transaction hash copied',
        ),
      );
    }

    // Unified container with invoice screen styling
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: detailRows,
      ),
    );
  }

  String _formatTxidTruncated(String txid) {
    if (txid.length > 12) {
      return '${txid.substring(0, 6)}...${txid.substring(txid.length - 6)}';
    }
    return txid;
  }

  Widget _buildDetailRowWithCopy(
    BuildContext context,
    ThemeData theme,
    String label,
    String displayValue,
    String copyValue,
    String snackBarMessage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width to align values nicely
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            height: 20,
            width: 2,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Tooltip(
                    message: copyValue,
                    child: Text(
                      displayValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      softWrap: true,
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: copyValue));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(snackBarMessage),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined),
                  iconSize: 16,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerButton(BuildContext context, String txid) {
    final explorerUrl = _getExplorerUrl(txid);
    if (explorerUrl == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: () async {
          final uri = Uri.parse(explorerUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.open_in_new, size: 16),
        label: const Text('View on Explorer'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  String _formatAddressTruncated(String address) {
    if (address.length > 12) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
    }
    return address;
  }
}
