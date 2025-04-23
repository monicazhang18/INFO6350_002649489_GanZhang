import 'package:flutter/material.dart';

class YesNoSelection extends StatelessWidget {
  const YesNoSelection({
    super.key,
    required this.state,
    required this.onSelection,
  });

  final bool? state;
  final void Function(bool) onSelection;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => onSelection(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: state == true ? Colors.green : null,
          ),
          child: const Text('Yes'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => onSelection(false),
          style: ElevatedButton.styleFrom(
            backgroundColor: state == false ? Colors.red : null,
          ),
          child: const Text('No'),
        ),
      ],
    );
  }
}
