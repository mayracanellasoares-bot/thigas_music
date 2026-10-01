/// Identity of this fork. Upstream attribution stays in LICENSE and source headers.
abstract final class AppBrand {
  static const name = 'THIGAS Music';
  static const tagline = 'Sua música. Seu ritmo.';
  static const androidId = 'com.thigas.music';
  static const notificationChannelId = '$androidId.playback';
  static const linkScheme = 'thigasmusic';
  static const logoAsset = 'assets/branding/thigas_music.png';
  static const upstreamUrl = 'https://github.com/gokadzev/Musify';

  // Configure only after creating releases for this fork. Never use upstream APKs.
  static const updateCheckUrl = String.fromEnvironment(
    'THIGAS_UPDATE_CHECK_URL',
  );
  static const releasesApiUrl = String.fromEnvironment(
    'THIGAS_RELEASES_API_URL',
  );
  static bool get updatesConfigured =>
      Uri.tryParse(updateCheckUrl)?.scheme == 'https' &&
      Uri.tryParse(releasesApiUrl)?.scheme == 'https';
}
