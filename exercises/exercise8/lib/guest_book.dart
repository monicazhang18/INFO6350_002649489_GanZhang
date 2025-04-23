import 'package:flutter/material.dart';
import 'guest_book_message.dart';

class GuestBook extends StatefulWidget {
  const GuestBook({
    super.key,
    required this.addMessage,
    required this.messages,
  });

  final Future<void> Function(String message) addMessage;
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
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Leave a message',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a message' : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await widget.addMessage(_controller.text);
                    _controller.clear();
                  }
                },
                child: const Icon(Icons.send),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final message in widget.messages)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('${message.name}: ${message.message}'),
          ),
      ],
    );
  }
}
