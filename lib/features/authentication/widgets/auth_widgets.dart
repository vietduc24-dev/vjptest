import 'package:flutter/material.dart';
import '../../../common/colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: UIColors.grayText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: UIColors.gray0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: UIColors.primaryColor,
          ),
        ),
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, right: 16),
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 211, 79),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageFlag(
            flag: '🇻🇳',
            isSelected: currentLanguage == 'vi',
            onTap: () => onLanguageChanged('vi'),
          ),
          _LanguageFlag(
            flag: '🇯🇵',
            isSelected: currentLanguage == 'ja',
            onTap: () => onLanguageChanged('ja'),
          ),
          _LanguageFlag(
            flag: '🇬🇧',
            isSelected: currentLanguage == 'en',
            onTap: () => onLanguageChanged('en'),
          ),
        ],
      ),
    );
  }
}

class _LanguageFlag extends StatelessWidget {
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageFlag({
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? UIColors.redLight : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          flag,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class AuthBottomContainer extends StatelessWidget {
  final String welcomeText;
  final String switchText;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const AuthBottomContainer({
    super.key,
    required this.welcomeText,
    required this.switchText,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: UIColors.redGradient,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            welcomeText,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            switchText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onButtonPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 