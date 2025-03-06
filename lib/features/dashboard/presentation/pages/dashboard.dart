import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';

class DashboardScreen extends StatelessWidget {
  static get route => MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      );

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: ThemeSizes.appBarHeight,
        title: _buildLogo(context),
        leading: const Padding(
          padding: EdgeInsets.only(left: ThemeSizes.xl),
          child: Icon(Icons.menu_rounded),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.darkBg,
      body: BlocBuilder<AppNavigationCubit, int>(
        builder: (context, selectedIndex) {
          return IndexedStack(
            index: selectedIndex,
            children:
                nonParticipantNavbarItems.map((item) => item.screen).toList(),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        navItems: nonParticipantNavbarItems,
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      "assets/images/logo-high-padding.png",
      width: Constants.getWidth(context) * 0.40,
    );
  }
}
