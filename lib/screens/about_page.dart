/*
 * Copyright (C) 2026 Valeri Gokadze. Original Musify AboutPage.
 * Modified for THIGAS Music. Distributed under GPL-3.0-or-later.
 */
import 'package:flutter/material.dart';
import 'package:thigas_music/branding/app_brand.dart';
import 'package:thigas_music/constants/version.dart';
import 'package:thigas_music/utilities/url_launcher.dart';
import 'package:thigas_music/widgets/mini_player_bottom_space.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sobre o aplicativo')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  AppBrand.logoAsset,
                  width: 112,
                  height: 112,
                  semanticLabel: 'Logo do THIGAS Music',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppBrand.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(AppBrand.tagline, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Versão $appVersion', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Text(
                'Feito para o seu ritmo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Identidade personalizada para Thiago Fillipe Soares. '
                'Música, playlists, biblioteca offline e sessões de concentração.',
              ),
              const SizedBox(height: 24),
              Text(
                'Créditos e código aberto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Este aplicativo é uma versão modificada do Musify, '
                'de Valeri Gokadze e colaboradores. Os avisos de autoria e a '
                'licença GPL são preservados. A nova identidade não transfere '
                'a autoria do projeto original.',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchURL(Uri.parse(AppBrand.upstreamUrl)),
                icon: const Icon(Icons.code_rounded),
                label: const Text('Projeto original e colaboradores'),
              ),
              const SizedBox(height: 24),
              Text(
                'Dados e conteúdo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Preferências, biblioteca e sessões de foco ficam no dispositivo. '
                'Busca, capas e reprodução online consultam serviços externos. '
                'O THIGAS Music não hospeda um catálogo próprio de músicas. '
                'Disponibilidade e permissões de download dependem da fonte.',
              ),
              const MiniPlayerBottomSpace(),
            ],
          ),
        ),
      ),
    ),
  );
}
