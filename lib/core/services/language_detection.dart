/// Heuristic language detection based on distinctive Unicode characters.
/// Returns a BCP-47 locale string (e.g. 'es-ES', 'en-US').
String detectLanguageFromText(String text) {
  if (RegExp(r'[ñáéíóúüÁÉÍÓÚÜ¿¡]').hasMatch(text)) return 'es-ES';
  if (RegExp(r'[àâæçèêëîïôœùûüÿÀÂÆÇÈÊËÎÏÔŒÙÛÜŸ]').hasMatch(text)) {
    return 'fr-FR';
  }
  if (RegExp(r'[äöüßÄÖÜ]').hasMatch(text)) return 'de-DE';
  if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return 'ja-JP';
  if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return 'zh-CN';
  if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) return 'ko-KR';
  if (RegExp(r'[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]').hasMatch(text)) return 'pl-PL';
  if (RegExp(r'[ãõÃÕ]').hasMatch(text)) return 'pt-BR';
  if (RegExp(r'[а-яА-ЯёЁ]').hasMatch(text)) return 'ru-RU';
  return 'en-US';
}
