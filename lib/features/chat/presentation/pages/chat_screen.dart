import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`chat_plan.md`). This just proves the [ChatBloc] wiring compiles
/// and renders something for each [ChatStatus].
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('chat_title'))),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          switch (state.status) {
            case ChatStatus.initial:
            case ChatStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ChatStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case ChatStatus.sending:
            case ChatStatus.loaded:
              if (state.conversations.isEmpty) {
                return const Center(child: Text('No conversations yet'));
              }
              return ListView.builder(
                itemCount: state.conversations.length,
                itemBuilder: (_, index) {
                  final conversation = state.conversations[index];
                  return ListTile(
                    title: Text(conversation.lastMessage.isEmpty
                        ? 'New conversation'
                        : conversation.lastMessage),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
