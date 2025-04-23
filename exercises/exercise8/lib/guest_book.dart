import 'dart:async';
import 'package:flutter/material.dart';
import 'src/widgets.dart';
import 'guest_book_message.dart';

class GuestBook extends StatefulWidget {
  const GuestBook({
    super.key,
    required this.addMessage,
    required this.messages,
  });

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;

  @override
  State<GuestBook> createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 输入行
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Leave a message',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your message' : null,
                  ),
                ),
                const SizedBox(width: 8),
                StyledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Row(
                    children: const [Icon(Icons.send), Text(' SEND')],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 留言列表
        for (final msg in widget.messages)
          Paragraph('${msg.name}: ${msg.message}'),
        const SizedBox(height: 8),
      ],
    );
  }
}
