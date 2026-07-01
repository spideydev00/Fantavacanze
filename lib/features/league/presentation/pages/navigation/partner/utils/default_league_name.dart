String defaultLeagueName({
  required String? gender,
  required String destination,
}) {
  return switch (gender) {
    'male' => 'I tori di $destination',
    'female' => 'Le baddies di $destination',
    _ => 'La lega di $destination',
  };
}
