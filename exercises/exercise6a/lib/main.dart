
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4-Function Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onPressed(String value) {
    setState(() {
      if (_isDigit(value)) {
        if (_display == '0' || _shouldResetDisplay) {
          _display = value;
        } else {
          _display += value;
        }
        _shouldResetDisplay = false;
      } else if (_isOperator(value)) {
        _firstOperand = double.tryParse(_display);
        _operator = value;
        _shouldResetDisplay = true;
      } else if (value == '=') {
        if (_firstOperand != null && _operator != null) {
          final secondOperand = double.tryParse(_display) ?? 0;
          final result = _calculate(_firstOperand!, secondOperand, _operator!);
          _display = _formatResult(result);
          _firstOperand = null;
          _operator = null;
          _shouldResetDisplay = true;
        }
      } else if (value == 'C') {
        _reset();
      }
    });
  }

  bool _isDigit(String val) => '0123456789'.contains(val);
  bool _isOperator(String val) => ['+', '-', '×', '÷'].contains(val);

  double _calculate(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '×': return a * b;
      case '÷': return b == 0 ? 0 : a / b;
    }
    return 0;
  }

  String _formatResult(double result) {
    if (result % 1 == 0) return result.toInt().toString();
    return result.toStringAsFixed(6).replaceFirst(RegExp(r'0+\$'), '').replaceFirst(RegExp(r'\.\$'), '');
  }

  void _reset() {
    _display = '0';
    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = false;
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <String>[
      '7', '8', '9', '÷',
      '4', '5', '6', '×',
      '1', '2', '3', '-',
      'C', '0', '=', '+',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('4-Function Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                final label = buttons[index];
                final isOp = _isOperator(label) || label == '=' || label == 'C';
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOp ? Colors.blueAccent : Colors.grey[200],
                    foregroundColor: isOp ? Colors.white      : Colors.black,
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _onPressed(label),
                  child: Text(label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
