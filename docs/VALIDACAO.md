# Validação da entrega — 01/10/2026

## Executado e aprovado

| Verificação | Resultado |
|---|---|
| Dart 3.13.5: execução de tools/focus_checks.dart | Exit 0 |
| Núcleo Dart isolado: dart analyze | No issues found, exit 0 |
| Formatação/parsing de 129 arquivos Dart do app/testes/scripts/tools | Exit 0 |
| Consistência do bundle | 17 XML, 21 ARB, 502 imports internos e fontes/assets conferidos |
| pubspec.yaml | YAML válido, assets e fontes registrados existem |
| Workflow GitHub Actions | YAML e estrutura de build/artifact conferidos |
| build-apk.sh | bash -n aprovado |
| git diff --check | Exit 0 |

O teste do núcleo exercita prazo decorrido, pausa/retomada, callback de término único,
cancelamento, restauração de sessão pausada, restauração vencida sem ação duplicada,
dados inválidos, limites de duração, ordem de escrita com armazenamento lento,
falhas de armazenamento/áudio e disparo real do agendador periódico.
A análise do núcleo usou cópias idênticas dos três arquivos sem dependências Flutter.
Não equivale à análise do aplicativo inteiro.

## Não executado / bloqueado

- flutter analyze e flutter test para o aplicativo completo.
- Compilação debug/release do APK e execução em emulador/aparelho.
- Busca e streaming reais, downloads reais, controles nativos e acessibilidade no Android.

A inicialização do SDK Flutter neste ambiente foi bloqueada pela revisão automática
porque o comando tentou consultar metadados internos da infraestrutura. O comando
não foi repetido nem executado por uma rota indireta. Foi usado um SDK Dart separado
somente para validar o núcleo independente de plataforma, sem inicializar Flutter.
Não há APK compilado nesta entrega.

O workflow e scripts inclusos executam análise, testes Flutter e compilação no ambiente
Android adequado. A aprovação desses checks ainda precisa ser obtida antes de
considerar o aplicativo pronto para distribuição.

As screenshots originais foram movidas para docs/upstream-metadata-en-US e não
representam a interface nova. Metadados de distribuição atuais incluem a marca e
ícone próprios; screenshots da nova versão devem ser capturadas no aparelho.
