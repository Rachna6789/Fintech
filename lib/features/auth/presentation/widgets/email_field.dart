import 'package:flutter/material.dart';

import '../../../../core/widgets/app_text_field.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.validator,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: validator,
    );
  }
}
