import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? suffixicon;
  final IconData? prefeixicons;
  final TextInputType keyboradtype;
  final bool obsecure;
  final String? Function(String?)? validator;
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.suffixicon,
    this.prefeixicons,
    required this.keyboradtype,
    required this.obsecure,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboradtype,
      obscureText: obsecure,
      textInputAction: TextInputAction.next, // Better keyboard navigation
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        prefixIcon: prefeixicons != null
            ? Icon(prefeixicons, color: Colors.grey[600])
            : null,
        suffixIcon: suffixicon != null
            ? Icon(suffixicon, color: Colors.grey[600])
            : null,
        // Remove all borders
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        // Add background
        filled: true,
        fillColor: Colors.grey[100],
        // Add padding
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
        // Error text styling
        errorStyle: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
