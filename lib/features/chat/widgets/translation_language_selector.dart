import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/translation/translation_preferences.dart';
import '../cubit/chat/chat_cubit.dart';
import '../cubit/chat/chat_state.dart';

class TranslationLanguageSelector extends StatelessWidget {
  const TranslationLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        TranslationLanguage selectedLanguage = TranslationLanguage.none;
        if (state is ChatConnected) {
          selectedLanguage = state.translationLanguage;
        }

        return PopupMenuButton<TranslationLanguage>(
          initialValue: selectedLanguage,
          onSelected: (TranslationLanguage language) {
            context.read<ChatCubit>().setTranslationLanguage(language);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<TranslationLanguage>>[
            const PopupMenuItem<TranslationLanguage>(
              value: TranslationLanguage.none,
              child: Text('Không dịch'),
            ),
            const PopupMenuItem<TranslationLanguage>(
              value: TranslationLanguage.english,
              child: Text('Tiếng Anh'),
            ),
            const PopupMenuItem<TranslationLanguage>(
              value: TranslationLanguage.vietnamese,
              child: Text('Tiếng Việt'),
            ),
            const PopupMenuItem<TranslationLanguage>(
              value: TranslationLanguage.japanese,
              child: Text('Tiếng Nhật'),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate),
                const SizedBox(width: 8),
                Text(TranslationPreferences.getLanguageName(selectedLanguage)),
              ],
            ),
          ),
        );
      },
    );
  }
} 