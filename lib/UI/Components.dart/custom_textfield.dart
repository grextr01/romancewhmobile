// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../UX/Theme.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {super.key,
      required this.controller,
      required this.focusNode,
      this.inputType,
      this.onEditingComplete,
      this.inputFormatters,
      this.onChanged,
      this.labelText,
      this.suffixIconText = '',
      this.textInputAction,
      this.autofocus = false,
      this.enabled = true,
      this.prefixIconText = '',
      this.onTap,
      this.prefix,
      this.obscureText = false,
      this.errorText,
      this.suffix,
      this.readOnly = false,
      this.showCursor = true,
      this.suffixIcon,
      this.prefixIcon,
      this.hintText,
      this.errorColor = secondaryColor,
      this.error = false,
      this.autofillHints,
      this.enableInteractiveSelection = true});
  final String? labelText;
  final String suffixIconText;
  Widget? suffix;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType? inputType;
  final Function()? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final String prefixIconText;
  final Icon? prefixIcon;
  final Function()? onTap;
  final Widget? prefix;
  final Widget? suffixIcon;
  final bool obscureText;
  late String? errorText;
  late bool error;
  late bool readOnly;
  late bool showCursor;
  final String? hintText;
  final Color errorColor;
  final List<String>? autofillHints;
  final bool enableInteractiveSelection;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: const Color.fromRGBO(237, 237, 237, 1),
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: error ? secondaryColor : Colors.transparent)),
      child: TextField(
        enabled: enabled,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        controller: controller,
        focusNode: focusNode,
        keyboardType: inputType,
        autofocus: autofocus,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        obscureText: obscureText,
        onTap: onTap,
        readOnly: readOnly,
        showCursor: showCursor,
        cursorColor: primaryColor,
        enableInteractiveSelection: enableInteractiveSelection,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
            errorText: errorText,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black),
            errorStyle: const TextStyle(fontSize: 0),
            labelText: labelText,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
            suffix: suffix != null
                ? Container(
                    // height: 0,
                    child: suffix,
                  )
                : Text(
                    suffixIconText,
                    style: TextStyle(
                        fontSize: 17,
                        color: enabled ? Colors.black : Colors.grey),
                  ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            prefix: Container(
              padding: EdgeInsets.only(right: prefixIconText != '' ? 10 : 0),
              child: prefix != null
                  ? Container(
                      padding: const EdgeInsets.only(right: 10),
                      child: prefix,
                    )
                  : Text(
                      prefixIconText,
                      style:
                          const TextStyle(fontSize: 17, color: secondaryColor),
                    ),
            )),
        onChanged: (text) {
          if (onChanged != null) {
            onChanged!(text);
          }
        },
      ),
    );
  }
}
