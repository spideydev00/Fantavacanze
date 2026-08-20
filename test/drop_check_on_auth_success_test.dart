import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/drop/drop_cubit.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockDropCubit extends MockCubit<DropState> implements DropCubit {}

class MockUser extends Mock implements User {}

void main() {
  testWidgets('controlla il drop dopo un login riuscito', (tester) async {
    final authBloc = MockAuthBloc();
    final dropCubit = MockDropCubit();
    final states = StreamController<AuthState>();
    addTearDown(states.close);

    whenListen(authBloc, states.stream, initialState: AuthInitial());
    when(() => dropCubit.state).thenReturn(const DropHidden());
    when(() => dropCubit.check()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<DropCubit>.value(value: dropCubit),
        ],
        child: const MaterialApp(
          home: DropCheckOnAuthSuccess(child: SizedBox()),
        ),
      ),
    );

    states.add(AuthSuccess(MockUser()));
    await tester.pump();

    verify(() => dropCubit.check()).called(1);
  });
}
