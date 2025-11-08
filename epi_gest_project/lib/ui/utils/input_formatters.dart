import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    var newText = '';

    if (text.length <= 3) {
      newText = text;
    } else if (text.length <= 6) {
      newText = '${text.substring(0, 3)}.${text.substring(3)}';
    } else if (text.length <= 9) {
      newText =
          '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6)}';
    } else if (text.length <= 10){
      newText =
          '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9)}';
    } else {
      newText =
          '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9, 11)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class RgInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    var newText = '';

    if (text.length <= 2) {
      newText = text;
    } else if (text.length <= 5) {
      newText = '${text.substring(0, 2)}.${text.substring(2)}';
    } else if (text.length <= 8) {
      newText =
          '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5)}';
    } else {
      newText =
          '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5, 8)}-${text.substring(8, 9)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.length <= 2) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else if (text.length <= 6) {
      return TextEditingValue(
        text: '(${text.substring(0, 2)}) ${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 3),
      );
    } else if (text.length <= 10) {
      return TextEditingValue(
        text:
            '(${text.substring(0, 2)}) ${text.substring(2, 6)}-${text.substring(6)}',
        selection: TextSelection.collapsed(offset: text.length + 4),
      );
    } else {
      return TextEditingValue(
        text:
            '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}',
        selection: TextSelection.collapsed(offset: text.length + 5),
      );
    }
  }
}
