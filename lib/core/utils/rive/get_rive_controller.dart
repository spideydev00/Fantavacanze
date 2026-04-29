import 'package:rive/rive.dart';

RiveWidgetController getRiveController(
  File riveFile,
  String? artboardName, {
  String stateMachineName = "State Machine 1",
}) {
  return RiveWidgetController(
    riveFile,
    artboardSelector: artboardName != null
        ? ArtboardSelector.byName(artboardName)
        : ArtboardSelector.byDefault(),
    stateMachineSelector: StateMachineSelector.byName(stateMachineName),
  );
}
