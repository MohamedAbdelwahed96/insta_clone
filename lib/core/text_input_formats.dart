import 'package:flutter/services.dart';

class TextManager {
  /// Allows only letters (A-Z, a-z)
  static List<TextInputFormatter> onlyLetters = [
    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z]+$')),
  ];

  /// Allows only letters and spaces
  static List<TextInputFormatter> onlyLettersWithSpace = [
    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
  ];

  /// Allows only numbers (0-9)
  static List<TextInputFormatter> onlyNumbers = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Allows only letters and numbers (No special characters)
  static List<TextInputFormatter> lettersAndNumbers = [
    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
  ];

  /// Allows only email characters (letters, numbers, "@", ".", "_", and "-")
  static List<TextInputFormatter> emailFormat = [
    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9@._-]+$')),
  ];

  /// Blocks spaces (Useful for username or passwords)
  static List<TextInputFormatter> noSpaces = [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];

  /// Blocks special characters (Allows only letters, numbers, and spaces)
  static List<TextInputFormatter> noSpecialCharacters = [
    FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9\s]')),
  ];

  /// Blocks numbers (Allows only letters and spaces)
  static List<TextInputFormatter> noNumbers = [
    FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
  ];

  /// Blocks emojis
  static List<TextInputFormatter> noEmojis = [
    FilteringTextInputFormatter.deny(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true)),
  ];
}











class TextValidate {
  /// Validates if the field is not empty
  static String? isRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field cannot be empty";
    }
    return null;
  }

  /// Validates an email format
  static String? isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email cannot be empty";
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  /// Validates a phone number (Only digits, length 10-15)
  static String? isValidPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number cannot be empty";
    }
    if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
      return "Enter a valid phone number (10-15 digits)";
    }
    return null;
  }

  /// Validates a strong password (At least 8 characters, 1 uppercase, 1 lowercase, 1 number)
  static String? isStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(value)) {
      return "Password must include uppercase, lowercase, and a number";
    }
    return null;
  }

  /// Validates if a username contains only letters and numbers
  static String? isValidUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username cannot be empty";
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return "Username must contain only letters and numbers";
    }
    return null;
  }
}
