String defaultLeagueName({
  required String? gender,
  required String destination,
}) {
  return switch (gender) {
    'male' => 'I tori di $destination (scegli il tuo...)',
    'female' => 'Le baddies di $destination (scegli il tuo...)',
    _ => 'La lega di $destination (scegli il tuo...)',
  };
}
