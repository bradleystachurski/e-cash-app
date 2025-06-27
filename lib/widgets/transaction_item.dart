import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carbine/multimint.dart';
import 'package:carbine/utils.dart';
import 'package:carbine/theme.dart';
import 'package:carbine/widgets/transaction_detail_modal.dart';

class TransactionItem extends StatelessWidget {
  final Transaction tx;
  final String? network;

  const TransactionItem({super.key, required this.tx, this.network});

  @override
  Widget build(BuildContext context) {
    final isIncoming = tx.received;
    final date = DateTime.fromMillisecondsSinceEpoch(tx.timestamp.toInt());
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);
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
      color: isIncoming ? Colors.greenAccent : Colors.redAccent,
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showCarbineModalBottomSheet(
            context: context,
            child: TransactionDetailModal(transaction: tx, network: network),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                isIncoming
                    ? Colors.greenAccent.withOpacity(0.1)
                    : Colors.redAccent.withOpacity(0.1),
            child: Icon(
              moduleIcon,
              color: isIncoming ? Colors.greenAccent : Colors.redAccent,
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
      ),
    );
  }
}
