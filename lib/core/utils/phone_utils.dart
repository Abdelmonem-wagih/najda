/// Normalizes an Egyptian mobile number to E.164 (+20XXXXXXXXXX).
///
/// Accepts (all map to the same E.164 result for the same number):
///   - `01XXXXXXXXX`      (local format, 11 digits)
///   - `+201XXXXXXXXX`    (already E.164)
///   - `201XXXXXXXXX`     (E.164 without the leading +)
///   - `00201XXXXXXXXX`   (international dialing prefix)
///
/// Returns null if the input isn't a valid Egyptian mobile number (starts
/// with 010/011/012/015 after normalization, 10 digits total after the
/// leading 0/country code is stripped) — callers should treat null as
/// "reject this input" rather than guessing.
String? normalizeEgyptianPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
  digits = digits.replaceFirst(RegExp(r'^\+'), '');

  if (digits.startsWith('0020')) {
    digits = digits.substring(4);
  } else if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }

  if (digits.startsWith('20') && digits.length == 12) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0') && digits.length == 11) {
    digits = digits.substring(1);
  }

  if (RegExp(r'^1[0125]\d{8}$').hasMatch(digits)) {
    return '+20$digits';
  }
  return null;
}

/// True if [raw] is a valid Egyptian mobile number in any of the accepted
/// input formats — use as a form field validator.
bool isValidEgyptianPhone(String raw) => normalizeEgyptianPhone(raw) != null;
