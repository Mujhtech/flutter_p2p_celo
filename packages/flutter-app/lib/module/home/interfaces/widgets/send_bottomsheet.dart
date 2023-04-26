import 'package:flutter/material.dart';
import 'package:flutter_celo_composer/configs/web3_config.dart';
import 'package:flutter_celo_composer/internal/ethereum_credentials.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:jazzicon/jazziconshape.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

class SendBottomSheet extends StatefulWidget {
  const SendBottomSheet({
    required this.address,
    required this.connector,
    required this.session,
    Key? key,
  }) : super(key: key);
  final String address;
  final WalletConnect connector;
  final SessionStatus session;

  @override
  State<SendBottomSheet> createState() => _SendBottomSheetState();
}

class _SendBottomSheetState extends State<SendBottomSheet> {
  JazziconData? jazz;
  TextEditingController amountTextController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool sending = false;

  @override
  void initState() {
    super.initState();

    /// Execute after frame is rendered to get the emit state of InitializeProviderSuccess
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jazz = Jazzicon.getJazziconData(40, address: widget.address);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Send token to ',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (jazz != null) ...<Widget>[
                    Jazzicon.getIconWidget(jazz!, size: 20),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                  Text(
                    'Address: ${widget.address.substring(0, 8)}...${widget.address.substring(widget.address.length - 8, widget.address.length)}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: amountTextController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Field is required';
              }

              return null;
            },
            cursorColor: Colors.black,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.black,
                ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black.withOpacity(0.2), width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              hintText: 'Amount to send',
              hintStyle: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.black),
              errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              errorStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  color: Colors.red),

              // prefixIcon: prefixIcon,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          MaterialButton(
            hoverElevation: 0,
            elevation: 0,
            onPressed: () async {
              if (sending) {
                return;
              }
              try {
                sending = true;
                setState(() {});
                final sender = widget.connector.session.accounts[0];
                final provider =
                    EthereumWalletConnectProvider(widget.connector);
                final wcCredentials =
                    WalletConnectEthereumCredentials(provider: provider);

                final String txnHash = await web3Client.sendTransaction(
                  wcCredentials,
                  Transaction(
                      from: EthereumAddress.fromHex(sender),
                      to: EthereumAddress.fromHex(widget.address),
                      value: EtherAmount.inWei(BigInt.from(
                          int.parse(amountTextController.text.trim())))),
                  chainId: widget.session.chainId,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction sent successfully'),
                    backgroundColor: Colors.red,
                  ),
                );

                sending = false;
                setState(() {});
                Navigator.pop(context);
              } catch (e) {
                //
                sending = false;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction failed, try again'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            color: const Color(0xFFFCFF52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                    color: Color(0xFFFCFF52),
                    width: 1,
                    style: BorderStyle.solid)),
            child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(sending ? 'Please wait' : 'Send',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.black)),
                    if (!sending) ...<Widget>[
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(
                        Icons.send,
                        color: Colors.black,
                      )
                    ] else ...<Widget>[
                      const SizedBox(
                        width: 10,
                      ),
                      const Center(
                        child: SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            )),
                      )
                    ]
                  ],
                )),
          )
        ]),
      ),
    );
  }
}
