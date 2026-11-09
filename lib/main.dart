// Snaply Agent — Flutter example.
//
// The SDK itself is started natively (ios/Runner/AppDelegate.swift and
// android/.../MainActivity.kt). Flutter paints this whole screen itself into one native view, so
// the native SDK sees no text fields here: this file is the surface the checks in the README are
// run against.

import 'package:flutter/material.dart';

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

              // A Flutter password field: obscureText, with no native secure field underneath —
              // the SDK does not hide it on its own.
              _label('Account password'),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: _box(),
              ),

              // The in-code mark ("snaply-redact") has no native view to sit on in Flutter: not hidden.
              _label('Card number'),
              Semantics(
                identifier: 'snaply-redact-card',
                child: TextField(
                  controller: _card,
                  keyboardType: TextInputType.number,
                  decoration: _box(),
                ),
              ),

              // Hidden from the dashboard on iOS: Products → Hidden fields → identifier "ibanField"
              // matches a Semantics identifier. Not on Android.
              _label('IBAN'),
              Semantics(
                identifier: 'ibanField',
                child: TextField(controller: _iban, decoration: _box()),
              ),

              // Hidden from the dashboard on iOS: a text rule containing "passport" matches the
              // semantics label. Not on Android.
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
              Semantics(
                identifier: 'snaply-redact-address',
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
