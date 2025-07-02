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

          // Transaction details with clean layout
          _buildDetailSection(context, isIncoming, formattedDate),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Deposit address for on-chain deposits (first row)
        if (transaction.module == 'wallet' &&
            isIncoming &&
            transaction.depositAddress != null) ...[
          _buildDepositAddressRow(context, transaction.depositAddress!),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
        ],

        // Withdrawal details for on-chain withdrawals
        if (transaction.module == 'wallet' &&
            !isIncoming &&
            transaction.withdrawalAddress != null) ...[
          _buildWithdrawalDetailsSection(context),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
        ],

        // Created/Initiated timestamp
        _buildDetailRow(
          context,
          transaction.module == 'wallet' && isIncoming
              ? 'Deposit Created'
              : transaction.module == 'wallet' && !isIncoming
              ? 'Withdrawal Initiated'
              : 'Created',
          formattedDate,
        ),

        // Block inclusion time if available
        if (transaction.txid != null && transaction.blockTime != null) ...[
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'Block Inclusion',
            _formatBlockTime(transaction.blockTime!),
          ),
        ],

        // Transaction hash if available
        if (transaction.txid != null) ...[
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          _buildTransactionHashRow(context, transaction.txid!),
        ],
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Label only
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right column: Value
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHashRow(BuildContext context, String txid) {
    final explorerUrl = _getExplorerUrl(txid);
    final truncatedHash = _formatTxidTruncated(txid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hash row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Label only
            Expanded(
              flex: 2,
              child: Text(
                'Transaction Hash',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Right column: Hash value with copy button
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Tooltip(
                      message: txid,
                      child: Text(
                        truncatedHash,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: txid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction hash copied'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined),
                    iconSize: 18,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
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
            ),
          ],
        ),

        // Explorer button
        if (explorerUrl != null) ...[
          const SizedBox(height: 12),
          Align(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTxidTruncated(String txid) {
    if (txid.length > 12) {
      return '${txid.substring(0, 6)}...${txid.substring(txid.length - 6)}';
    }
    return txid;
  }

  Widget _buildDepositAddressRow(BuildContext context, String depositAddress) {
    final truncatedAddress = _formatAddressTruncated(depositAddress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Label only
            Expanded(
              flex: 2,
              child: Text(
                'Deposit Address',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Right column: Address value with copy button
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Tooltip(
                      message: depositAddress,
                      child: Text(
                        truncatedAddress,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: depositAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deposit address copied'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined),
                    iconSize: 18,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
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
            ),
          ],
        ),
      ],
    );
  }

  String _formatAddressTruncated(String address) {
    if (address.length > 12) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
    }
    return address;
  }

  Widget _buildWithdrawalDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Withdrawal Address
        if (transaction.withdrawalAddress != null) ...[
          _buildWithdrawalAddressRow(context, transaction.withdrawalAddress!),
          const SizedBox(height: 16),
        ],

        // Fee Rate
        if (transaction.feeRateSatsPerVb != null) ...[
          _buildDetailRow(
            context,
            'Fee Rate',
            '${transaction.feeRateSatsPerVb!.toStringAsFixed(1)} sats/vB',
          ),
          const SizedBox(height: 16),
        ],

        // Transaction Size
        if (transaction.txSizeVb != null) ...[
          _buildDetailRow(
            context,
            'Tx Size',
            '${transaction.txSizeVb!} vB',
          ),
          const SizedBox(height: 16),
        ],

        // Fee Amount
        if (transaction.feeSats != null) ...[
          _buildDetailRow(
            context,
            'Fee',
            formatBalance(transaction.feeSats! * BigInt.from(1000), false), // Convert sats to msats for formatting
          ),
          const SizedBox(height: 16),
        ],

        // Total Amount
        if (transaction.totalSats != null) ...[
          _buildDetailRow(
            context,
            'Total',
            formatBalance(transaction.totalSats! * BigInt.from(1000), false), // Convert sats to msats for formatting
          ),
        ],
      ],
    );
  }

  Widget _buildWithdrawalAddressRow(BuildContext context, String withdrawalAddress) {
    final truncatedAddress = _formatAddressTruncated(withdrawalAddress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Label only
            Expanded(
              flex: 2,
              child: Text(
                'Withdrawal Address',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Right column: Address value with copy button
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Tooltip(
                      message: withdrawalAddress,
                      child: Text(
                        truncatedAddress,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: withdrawalAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Withdrawal address copied'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined),
                    iconSize: 18,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
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
            ),
          ],
        ),
      ],
    );
  }
}
