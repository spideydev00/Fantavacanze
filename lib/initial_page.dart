import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit_cubit.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, state) {
        if (state is AppUserIsLoggedIn) {
          return HomePage();
        }
        return SocialLoginPage();
      },
    );
  }
}
