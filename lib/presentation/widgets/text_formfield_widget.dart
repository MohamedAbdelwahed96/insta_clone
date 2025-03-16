import 'package:flutter/material.dart';

class TextFormfieldWidget extends StatefulWidget {
  final bool obsecure;
  final String hintText;
  final TextEditingController controller;

  const TextFormfieldWidget({super.key, this.obsecure=false,required this.hintText, required this.controller});

  @override
  State<TextFormfieldWidget> createState() => _TextFormfieldWidgetState();
}

class _TextFormfieldWidgetState extends State<TextFormfieldWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      style: TextStyle(color: theme.primary),
      obscureText: widget.obsecure,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.inversePrimary,
        hintText: widget.hintText,
        hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: theme.secondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
