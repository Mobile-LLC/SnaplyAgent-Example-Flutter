// Snaply Agent — Flutter example.
//
// The whole integration is in this file: `Snaply.on` and `Snaply.configure` in `_startSnaply`, and
// `SnaplyRedact` around what must never leave the phone. There is no Snaply code in the iOS or
// Android folders.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snaply_agent/snaply_agent.dart';

// Replace with your own keys from the Snaply console (Products → your product → API key). An iOS
// product and an Android product each have their own. A key is not a secret: it ships inside every
// copy of your app and is checked server-side against the product's allowed app identifier.
const _iosKey = 'snap_live_REPLACE_WITH_YOUR_IOS_KEY';
const _androidKey = 'snap_live_REPLACE_WITH_YOUR_ANDROID_KEY';

// Development only: `flutter run --dart-define=SNAPLY_KEY=… --dart-define=SNAPLY_HOST=http://…`
// points this build at another key, or at a backend on your own machine.
const _keyOverride = String.fromEnvironment('SNAPLY_KEY');
const _hostOverride = String.fromEnvironment('SNAPLY_HOST');

void main() => runApp(const SnaplyExampleApp());

class SnaplyExampleApp extends StatelessWidget {
  const SnaplyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snaply Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6F4A)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CheckoutScreen(),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _items = 2;

  final _password = TextEditingController(text: 'hunter2-secret');
  final _card = TextEditingController(text: '4242 4242 4242 4242');
  final _iban = TextEditingController(text: 'DE89 3704 0044 0532');
  final _passport = TextEditingController(text: 'AB1234567');
  final _note = TextEditingController(text: 'Leave at the door');
  String _status = 'Connecting…';

  @override
  void initState() {
    super.initState();
    _startSnaply();
  }

  // 1. Listen before you configure: a request can arrive as soon as the device is registered.
  // 2. Configure once, with the key of this platform's product.
  Future<void> _startSnaply() async {
    Snaply.on(
      SnaplyCallbacks(
        onRequestShown: () => _show('Support asked to see your screen…'),
        onAllowed: (_) => _show('Screenshot shared ✓'),
        onDenied: () => _show('You declined the request.'),
        onExpired: () => _show('The request expired.'),
        onRemoteControl: (active) => _show(
          active ? 'Support can control this screen.' : 'Remote control ended.',
        ),
        onLiveEnded: (_) => _show('Live session ended.'),
        onError: (error) => _show('Snaply error: ${error.code}'),
      ),
    );
    try {
      await Snaply.configure(
        key: _keyOverride.isNotEmpty
            ? _keyOverride
            : (defaultTargetPlatform == TargetPlatform.iOS
                  ? _iosKey
                  : _androidKey),
        environment: _hostOverride.isNotEmpty
            ? const SnaplyEnvironment.custom(_hostOverride)
            : SnaplyEnvironment.live,
        // Optional — without it the device stays anonymous and support finds it by the support
        // code.
        user: const SnaplyUser(id: 'usr_20481', name: 'Maya Kowalski'),
      );
      _show('Ready — support can ask to see this screen.');
    } on SnaplyException catch (error) {
      _show('Could not connect: ${error.code}');
    }
  }

  // When someone signs in after launch.
  Future<void> _signIn() async {
    await Snaply.identify(id: 'usr_20481', name: 'Maya Kowalski');
    _show('Signed in as Maya Kowalski.');
  }

  // On sign-out: detaches the person and gives the device a new support code.
  Future<void> _signOut() async {
    await Snaply.reset();
    final code = await Snaply.supportCode();
    _show('Signed out · support code ${code ?? '—'}');
  }

  void _show(String text) {
    if (mounted) setState(() => _status = text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Acme Delivery',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              Text(
                'Order #8412 · Margherita pizza · $_items',
                style: const TextStyle(fontSize: 13, color: Color(0xFF5B665E)),
              ),

              // Hidden on its own: every field with obscureText.
              _label('Account password'),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: _box(),
              ),

              // Hidden by you: wrap the widget in SnaplyRedact.
              _label('Card number'),
              SnaplyRedact(
                child: TextField(
                  controller: _card,
                  keyboardType: TextInputType.number,
                  decoration: _box(),
                ),
              ),

              // Hidden from the dashboard, with no app release: Products → Hidden fields → a rule
              // by identifier "ibanField" matches a Semantics identifier (or a ValueKey<String>).
              _label('IBAN'),
              Semantics(
                identifier: 'ibanField',
                child: TextField(controller: _iban, decoration: _box()),
              ),

              // Hidden from the dashboard: a rule by text containing "passport" matches the
              // semantics label, and a field's label or hint.
              _label('Passport'),
              Semantics(
                label: 'Passport number',
                child: TextField(
                  controller: _passport,
                  decoration: _box(hint: 'Passport number'),
                ),
              ),

              // Not marked: captured as it is.
              _label('Delivery note'),
              TextField(controller: _note, decoration: _box()),

              _label('Delivery address'),
              SnaplyRedact(
                label: 'ADDRESS',
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '12 Rue des Lilas, Paris',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Semantics(
                identifier: 'addItem',
                child: FilledButton(
                  onPressed: () => setState(() => _items++),
                  child: const Text('Add one more'),
                ),
              ),

              Row(
                children: [
                  TextButton(
                    onPressed: _signOut,
                    child: const Text('Sign out'),
                  ),
                  TextButton(onPressed: _signIn, child: const Text('Sign in')),
                  TextButton(
                    onPressed: Snaply.showSupportCode,
                    child: const Text('Support code'),
                  ),
                ],
              ),
              Text(
                _status,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5B665E)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 3),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: Color(0xFF5B665E)),
    ),
  );

  InputDecoration _box({String? hint}) => InputDecoration(
    hintText: hint,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}
