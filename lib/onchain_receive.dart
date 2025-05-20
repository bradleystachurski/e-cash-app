import 'package:carbine/lib.dart';
import 'package:flutter/material.dart';

class OnChainReceive extends StatefulWidget {
  final FederationSelector fed;

  const OnChainReceive({super.key, required this.fed});

  @override
  State<OnChainReceive> createState() => _OnChainReceiveState();
}

class _OnChainReceiveState extends State<OnChainReceive> {
  String? _address;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final address = await allocateDepositAddress(
      federationId: widget.fed.federationId,
    );
    setState(() {
      _address = address;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receive On-Chain'),
          centerTitle: true,
          automaticallyImplyLeading: true, // shows back arrow
        ),
        body: Center(
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SelectableText(
                      _address!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
