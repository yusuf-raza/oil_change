import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/sign_in_view_model.dart';
import 'widgets/sign_in_view.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignInViewModel(),
      child: const SignInView(),
    );
  }
}
