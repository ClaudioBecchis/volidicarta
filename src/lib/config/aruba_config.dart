/// Configurazione backend Aruba (sostituisce Supabase)
///
/// L'URL punta al file api.php hostato su Aruba.
/// Cambia baseUrl quando hai il dominio definitivo.
class ArubaConfig {
  /// URL base dell'API — cambia con il dominio Aruba reale
  static const String baseUrl = 'https://www.polariscore.it/volidicarta/api.php';

  /// Restituisce true se la configurazione è valida
  static bool get isConfigured =>
      baseUrl.isNotEmpty && baseUrl.startsWith('https://');
}
