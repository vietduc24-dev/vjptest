import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('vi'); // Default language is Vietnamese

  void changeLanguage(String language) {
    emit(language);
  }
} 