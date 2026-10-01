# THIGAS Music — Design System

Implementação real em Flutter. Nenhuma migração para Jetpack Compose foi feita.

| Token | Escuro | Claro |
|---|---|---|
| Fundo | #121614 | #F5F7F5 |
| Superfície | #1D2420 | #FFFFFF |
| Superfície elevada | #29332D | #E8EEE9 |
| Texto | #F2F5F2 | #17211B |
| Texto auxiliar | #B8C4BB | #526358 |
| Destaque | #A8D5BA | #285C3E |
| Texto no destaque | #102317 | #FFFFFF |

Fontes locais Outfit 400/500/600/700. Títulos 28/20, texto 16 e auxiliar 14.
Espaçamentos em múltiplos de 4. Margem principal 16; página foco 24.
Capas pequenas usam raios próprios; cards de foco 24; botões 16.
Área mínima interativa definida pelo MaterialTapTargetSize.padded e botões 48x52.
Capas de álbuns são o principal elemento visual variável.
Cores dinâmicas e paleta alternativa continuam opcionais nas configurações.

## Equivalência para um projeto Compose futuro
- ColorScheme → MaterialTheme.colorScheme, com lightColorScheme/darkColorScheme.
- TextTheme → Typography; importar as mesmas fontes em res/font.
- Formatos → Shapes; tokens extras de espaçamento via CompositionLocal.
- Widgets de marca → composables próprios.

Essa equivalência é documentação, não código Compose incorporado ao fork Flutter.
Valide contraste, fontes ampliadas e leitor de tela no Android antes de distribuir.
