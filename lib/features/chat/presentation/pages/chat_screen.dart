import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_card.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('chat_title'))),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          switch (state.status) {
            case ChatStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ChatStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case ChatStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    ChatCard(entity: state.items[index]),
              );
            case ChatStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
