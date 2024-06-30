import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  PasswordField({required this.controller});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  String _passwordError = '';
  bool _passwordFocused = false;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  void _checkPassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigit = password.contains(RegExp(r'\d'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~]'));

      _passwordError = !_hasMinLength || !_hasUppercase || !_hasLowercase || !_hasDigit || !_hasSpecialChar
          ? 'Le mot de passe ne respecte pas tous les critères.'
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _passwordFocused = hasFocus;
        });
      },
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              errorText: _passwordError.isNotEmpty ? _passwordError : null,
            ),
            obscureText: true,
            onChanged: (value) {
              _checkPassword(value);
            },
          ),
          SizedBox(height: 8.0),
          if (_passwordFocused)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le mot de passe doit contenir :',
                  style: TextStyle(color: Colors.red),
                ),
                Text(
                  '- Au moins 8 caractères',
                  style: TextStyle(color: _hasMinLength ? Colors.green : Colors.red),
                ),
                Text(
                  '- Une majuscule',
                  style: TextStyle(color: _hasUppercase ? Colors.green : Colors.red),
                ),
                Text(
                  '- Une minuscule',
                  style: TextStyle(color: _hasLowercase ? Colors.green : Colors.red),
                ),
                Text(
                  '- Un chiffre',
                  style: TextStyle(color: _hasDigit ? Colors.green : Colors.red),
                ),
                Text(
                  '- Un symbole (!@#\$&*~)',
                  style: TextStyle(color: _hasSpecialChar ? Colors.green : Colors.red),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
