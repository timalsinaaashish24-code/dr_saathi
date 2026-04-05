/// Utility functions for converting numbers to Nepali numerals
class NepaliNumberUtils {
  // Map of English digits to Nepali digits (Devanagari)
  static const Map<String, String> _digitMap = {
    '0': '०',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९',
  };

  /// Convert English numerals to Nepali numerals (Devanagari script)
  /// Example: "123" -> "१२३"
  static String toNepaliNumber(String number) {
    String result = number;
    _digitMap.forEach((english, nepali) {
      result = result.replaceAll(english, nepali);
    });
    return result;
  }

  /// Convert integer to Nepali number string
  /// Example: 123 -> "१२३"
  static String intToNepali(int number) {
    return toNepaliNumber(number.toString());
  }

  /// Convert double to Nepali number string
  /// Example: 123.45 -> "१२३.४५"
  static String doubleToNepali(double number) {
    return toNepaliNumber(number.toString());
  }

  /// Format number with Nepali numerals based on locale preference
  /// If isNepali is true, returns Nepali numerals, otherwise English
  static String formatNumber(dynamic number, bool isNepali) {
    if (!isNepali) return number.toString();
    return toNepaliNumber(number.toString());
  }

  /// Convert Nepali numerals back to English numerals
  /// Example: "१२३" -> "123"
  static String toEnglishNumber(String nepaliNumber) {
    String result = nepaliNumber;
    _digitMap.forEach((english, nepali) {
      result = result.replaceAll(nepali, english);
    });
    return result;
  }
}
