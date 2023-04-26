import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_celo_composer/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:flutter_celo_composer/module/auth/service/cubit/auth_cubit.dart';
import 'package:flutter_celo_composer/module/home/interfaces/widgets/send_bottomsheet.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:jazzicon/jazziconshape.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.session,
    required this.connector,
    required this.uri,
    Key? key,
  }) : super(key: key);

  final dynamic session;
  final WalletConnect connector;
  final String uri;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String accountAddress = '';
  String networkName = '';
  TextEditingController addressTextController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  JazziconData? jazz;

  ButtonStyle buttonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all(
      Colors.white.withAlpha(60),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );

  // void updateGreeting() {
  //   launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

  //   context.read<Web3Cubit>().updateGreeting(greetingTextController.text);
  //   greetingTextController.text = '';
  // }

  @override
  void initState() {
    super.initState();

    /// Execute after frame is rendered to get the emit state of InitializeProviderSuccess
    WidgetsBinding.instance.addPostFrameCallback((_) {
      accountAddress = widget.connector.session.accounts[0];
      jazz = Jazzicon.getJazziconData(40,
          address: widget.connector.session.accounts[0]);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is SessionDisconnected) {
          Future<void>.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const AuthenticationScreen(),
              ),
            );
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFF52),
          elevation: 0,
          // ignore: use_decorated_box

          toolbarHeight: 0,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Form(
          key: formKey,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 70,
                  color: const Color(0xFFFCFF52),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (jazz != null) ...<Widget>[
                          Jazzicon.getIconWidget(jazz!),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                        Text(
                          'Address: ${accountAddress.substring(0, 8)}...${accountAddress.substring(accountAddress.length - 8, accountAddress.length)}',
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(Icons.power_settings_new,
                              color: Colors.black),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: addressTextController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Field is required';
                          }

                          return null;
                        },
                        cursorColor: Colors.black,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),

                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.2),
                                  width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          focusedErrorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          hintText: 'Send to wallet address',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.black),
                          errorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          errorStyle: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              // ignore: inference_failure_on_function_invocation
                              showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                  ),
                                  constraints:
                                      BoxConstraints(maxHeight: height * 0.3),
                                  builder: (BuildContext builder) {
                                    // final Wallet wallet;
                                    return SendBottomSheet(
                                        connector: widget.connector,
                                        session: widget.session,
                                        address:
                                            addressTextController.text.trim());
                                  });
                            },
                            child: const Icon(
                              Icons.send,
                              color: Colors.black,
                            ),
                          ),
                          // prefixIcon: prefixIcon,
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // conditionally print the address
                      if (accountAddress.isNotEmpty) const SizedBox(height: 10),
                      Text(
                        'Network: $networkName',
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
