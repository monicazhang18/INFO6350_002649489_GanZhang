import 'package:flutter/material.dart';
import 'app_state.dart';
import 'src/widgets.dart';

class YesNoSelection extends StatelessWidget {
  const YesNoSelection({
    super.key,
    required this.state,
    required this.onSelection,
  });
  final Attending state;
  final void Function(Attending) onSelection;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case Attending.yes:
        return Row(
          children: [
            FilledButton(
              onPressed: () => onSelection(Attending.yes),
              child: const Text('YES'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => onSelection(Attending.no),
              child: const Text('NO'),
            ),
          ],
        );
      case Attending.no:
        return Row(
          children: [
            TextButton(
              onPressed: () => onSelection(Attending.yes),
              child: const Text('YES'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => onSelection(Attending.no),
              child: const Text('NO'),
            ),
          ],
        );
      default:
        return Row(
          children: [
            StyledButton(
              onPressed: () => onSelection(Attending.yes),
              child: const Text('YES'),
            ),
            const SizedBox(width: 8),
            StyledButton(
              onPressed: () => onSelection(Attending.no),
              child: const Text('NO'),
            ),
          ],
        );
    }
  }
}
