import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile_title'))),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          switch (state.status) {
            case ProfileStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProfileStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case ProfileStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    ProfileCard(entity: state.items[index]),
              );
            case ProfileStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
