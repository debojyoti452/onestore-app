import 'package:flutter/services.dart';

class CardMonthYearFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = newValue.text;
    final String newTextFiltered = newText.replaceAll(RegExp(r'[^\d]'), '');
    final int selectionIndexFromTheRight =
        newText.length - newValue.selection.end;
    int offset = 0;

    final StringBuffer newTextBuffer = StringBuffer();
    for (int i = 0; i < newTextFiltered.length; i++) {
      if (i > 0 && i % 2 == 0) {
        newTextBuffer.write('/');
        if (newValue.selection.end >= i + offset) {
          offset++;
        }
      }
      newTextBuffer.write(newTextFiltered[i]);
    }

    return TextEditingValue(
      text: newTextBuffer.toString(),
      selection: TextSelection.collapsed(
        offset: newTextBuffer.length - selectionIndexFromTheRight,
      ),
    );
  }
}
