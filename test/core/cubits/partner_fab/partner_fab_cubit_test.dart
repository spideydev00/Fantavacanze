import 'package:fantavacanze_official/core/cubits/partner_fab/partner_fab_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadFor defaults to true when nothing saved', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = PartnerFabCubit(prefs: prefs);

    cubit.loadFor('user-1');

    expect(cubit.state, isTrue);
  });

  test('loadFor reads the saved per-user value', () async {
    SharedPreferences.setMockInitialValues({
      'partner_fab_enabled_user-1': false,
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = PartnerFabCubit(prefs: prefs);

    cubit.loadFor('user-1');

    expect(cubit.state, isFalse);
  });

  test('toggle flips and persists per-user', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = PartnerFabCubit(prefs: prefs);
    cubit.loadFor('user-1');

    await cubit.toggle();

    expect(cubit.state, isFalse);
    expect(prefs.getBool('partner_fab_enabled_user-1'), isFalse);
  });

  test('values are isolated per user', () async {
    SharedPreferences.setMockInitialValues({
      'partner_fab_enabled_user-1': false,
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = PartnerFabCubit(prefs: prefs);

    cubit.loadFor('user-2');

    expect(cubit.state, isTrue);
  });
}
