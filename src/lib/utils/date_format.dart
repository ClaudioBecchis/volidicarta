/// Utility per la formattazione delle date.
///
/// Storage interno e Supabase usano ISO 8601 (YYYY-MM-DD).
/// La UI mostra il formato italiano (dd/MM/yyyy).
String formatDateForDisplay(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  } catch (_) {
    return iso; // fallback per date già in altro formato
  }
}
