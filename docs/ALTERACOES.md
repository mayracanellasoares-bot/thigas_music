# Alterações em relação ao Musify

Origem: gokadzev/Musify, commit bddc68d307f82a2f359d7394fded4c20318c904b.

## Identidade
- Pacote Dart e imports renomeados para thigas_music.
- Classes raiz e handler renomeados para ThigasMusic e ThigasAudioHandler.
- Android namespace/applicationId: com.thigas.music; esquema de links: thigasmusic.
- Nome, ícones, recursos de splash, marca nas notificações e compartilhamento atualizados.
- Tema de marca e fonte Outfit adicionados; idioma inicial pt e tema inicial escuro.
- Tela Sobre reescrita com crédito ao upstream e descrição do armazenamento/conteúdo.

## Modo foco
- Modelo validado, controlador Dart independente de plataforma e adaptador ChangeNotifier.
- Duração 1–180 minutos, presets 25/50/90, prazo absoluto, pausa/retomada e cancelamento.
- Escritas serializadas no Hive; restauração não repete ação de áudio vencida.
- Integração ao handler de áudio; pausa da música opcional ao concluir.
- Acesso nas páginas Início e Configurações, inclusive com modo offline ativo. Atalho no player; controles quebram linha em telas estreitas.
- Exclusão mútua entre sessão de foco e timer para dormir.

## Build e atualização
- Versão do fork: 1.0.0+1. Atualizações externas só com endpoints próprios.
- Workflows upstream movidos para docs/upstream-workflows, evitando publicação no projeto original.
- Workflow de debug com SDK fixado, análise, testes e upload de APK como artefato.
- Scripts Windows/Linux, exemplo de assinatura e guia de compilação.
- Removido teste template de contador que não correspondia ao app; testes reais de foco adicionados.
- Dependências locais de packages/ preservadas, sem alterações em seus namespaces.

## Limites
Last.fm e fade-out não implementados nesta primeira entrega.
Código Flutter/UI e APK ainda precisam de análise/build e teste Android no ambiente completo.
Avisos de autoria e licença do upstream preservados; fontes incluem licenças.
