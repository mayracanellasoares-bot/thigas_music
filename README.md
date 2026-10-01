# THIGAS Music

Aplicativo Android em Flutter, personalizado a partir de [Musify](https://github.com/gokadzev/Musify).
Código de origem: `bddc68d307f82a2f359d7394fded4c20318c904b`.

## O que foi implementado

- Nome THIGAS Music, identidade verde suave e superfícies escuras.
- Tema claro e escuro; cores do sistema continuam opcionais.
- Fonte Outfit local, com pesos regular, medium, semibold e bold e licença incluída.
- Logo original, launcher adaptativo, ícone monocromático e ícone de notificação.
- Pacote Dart `thigas_music` e ID Android `com.thigas.music`.
- Português como idioma inicial. Preferências continuam editáveis.
- Modo foco: 25/50/90 minutos ou duração de 1 a 180 minutos, pausa, retomada,
  cancelamento, progresso e opção de pausar música ao concluir.
- Sessão de foco persistida no dispositivo. O contador usa prazo absoluto;
  abrir outra tela não reinicia a sessão.
- Reprodução, playlists, downloads, rádio, letras e equalizador do upstream preservados.
- Atualizador original desativado enquanto não houver endpoints próprios configurados.
- Scripts de build para Windows/Linux e workflow de APK de teste no GitHub Actions.

Last.fm e fade-out do timer não fazem parte desta primeira versão. Não há login,
chaves Last.fm nem serviço de scrobbling configurados.

## Abrir no Android Studio

1. Instale Flutter compatível com `pubspec.yaml` (versão fixada no CI: **3.47.4**),
   Dart >=3.13.0 <4.0.0 e os plugins Flutter/Dart do Android Studio.
2. Abra **esta pasta inteira**, onde está `pubspec.yaml`, e não apenas `android/`.
3. Configure JDK 17, Android SDK 36 e NDK 28.2.13676358.
4. Execute `flutter doctor -v` e resolva as dependências locais apontadas pelo comando.
5. Conecte seu Android com depuração USB ou use um emulador.
6. Rode os comandos:

```bash
flutter pub get
flutter gen-l10n
flutter run --flavor github -t lib/main.dart
```

O mínimo Android declarado é API 24. Esta entrega não muda o projeto para web ou iOS.
Flutter/Android SDK devem ser instalados no computador; o Termux não é o ambiente
de compilação suportado por estes scripts.

## Gerar APK para instalar

No Windows, abra um terminal nesta pasta:

```bat
build-apk.bat
```

No Linux/macOS:

```bash
bash build-apk.sh
```

Resultado esperado, se as verificações e a compilação passarem:
`build/app/outputs/flutter-apk/app-github-debug.apk`.
O APK debug usa ID `com.thigas.music.debug` e pode ser instalado ao lado do Musify.

## Gerar APK pelo GitHub

Envie **todo o conteúdo desta pasta** para um repositório seu, incluindo `packages/`,
`android/` e `.github/`. Em **Actions**, execute **THIGAS Music - verificar e gerar APK**.
Quando o job concluir, baixe o artefato **THIGAS-Music-debug**, extraia o ZIP
e instale o APK. O workflow não cria release nem publica em loja automaticamente.

## Versão release

Crie sua própria chave e preserve um backup:

```bash
keytool -genkeypair -v -keystore android/app/key.jks -alias thigas -keyalg RSA -keysize 2048 -validity 10000
```

Copie `android/key.properties.example` para `android/key.properties` e preencha
as senhas. Para `storeFile=key.jks`, a chave fica em `android/app/key.jks`.
Depois execute `build-apk.bat release` ou `bash build-apk.sh release`.
Nunca envie chaves ou senhas para o GitHub. Preserve a mesma assinatura para atualizações.

## Usar o modo foco

Abra **Início → Modo foco** ou **Configurações → Modo foco**. Escolha uma faixa ou
playlist nos controles existentes antes de iniciar. O modo foco não toca música
automaticamente. Pausar o contador não pausa o áudio. Iniciar foco cancela o timer
para dormir; iniciar o timer para dormir cancela o foco.

Com o processo e serviço de reprodução ativos, a sessão não depende da tela aberta.
Ao reabrir, o estado salvo é restaurado; uma sessão já vencida aparece concluída e
não dispara uma pausa atrasada. Remover o app da lista de recentes encerra a sessão,
seguindo o comportamento de parada do áudio herdado. Forçar parada ou o sistema
encerrar o processo impede execução de timers; não há alarme independente do processo.

## Alterar a marca

- Nome e links: `lib/branding/app_brand.dart`.
- ID Android: `android/app/build.gradle.kts`, Manifest e package nativo.
- Paleta e texto: `lib/theme/app_themes.dart` e `lib/theme/app_colors.dart`.
- Fontes e assets: `pubspec.yaml` e `assets/`.
- Links de playlist: Manifest, `lib/main.dart` e `lib/screens/playlist_page.dart`.
- Versão: `pubspec.yaml`; rode `bash update.sh` para sincronizar `version.dart`.

Depois de publicar releases próprias, configure os dois parâmetros de build
`THIGAS_UPDATE_CHECK_URL` e `THIGAS_RELEASES_API_URL` via `--dart-define`.
Use o formato de resposta esperado em `lib/services/update_manager.dart`.
Não aponte o atualizador para os APKs do Musify original.

## Validação

O relatório da entrega está em `docs/VALIDACAO.md`.
Para executar novamente no ambiente Flutter:

```bash
dart run tools/focus_checks.dart
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Warnings e infos herdados são mostrados, mas não bloqueiam o build; erros bloqueiam.
Teste também busca/reprodução reais, downloads em modo avião, notificações,
Bluetooth, fontes ampliadas e TalkBack em um aparelho Android.

## Créditos e licença

Musify é de Valeri Gokadze e colaboradores. Os copyrights originais permanecem
nos arquivos e `LICENSE` é preservado. Consulte `docs/ALTERACOES.md` para as mudanças.
Fontes Outfit/Paytone incluem seus avisos de licença em `assets/licenses/`.
Distribua o código correspondente junto à versão modificada sob os termos aplicáveis.
O README original foi preservado em `docs/README_UPSTREAM.md`, incluindo a divergência
entre sua nota de restrição comercial e o texto GPL. Esclareça isso antes de monetizar.

As fontes externas e downloads do upstream continuam sujeitos à disponibilidade,
permissões e condições dos respectivos provedores. Este fork não hospeda músicas.
