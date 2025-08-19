# Registra Serviço - Aplicativo Flutter

## Descrição
Aplicativo móvel simples para registro de serviços de eletricistas, desenvolvido em Flutter com foco em funcionalidade offline e geração de relatórios em PDF.

## Funcionalidades Principais

### 1. Tela Principal (Home)
- Lista de serviços agrupados por mês e ano (ex: "Agosto de 2025")
- Cada mês é um item expansível que revela os serviços do período
- Funcionalidade "swipe-to-delete" para excluir serviços
- Diálogo de confirmação antes da exclusão
- Botão flutuante para adicionar novos serviços

### 2. Adicionar/Editar Serviços
- Formulário com campos obrigatórios e opcionais:
  - Nome do Cliente (obrigatório)
  - Data do Serviço (pré-preenchida com data atual)
  - Descrição do Serviço
  - Lista de itens com quantidade e valor unitário (R$ 20,00 padrão)
- Cálculo automático do valor total
- Botão de exclusão de itens só aparece quando há mais de um item

### 3. Geração de Relatórios
- Seleção de período (data início e fim)
- Geração de PDF com formatação profissional
- Abertura automática do PDF após geração
- Lista numerada dos serviços com detalhes completos
- Total geral no final do relatório

## Características Técnicas

### Armazenamento Offline
- Banco de dados SQLite local (sqflite)
- Persistência total dos dados sem necessidade de internet
- Estrutura de dados otimizada para consultas rápidas

### Dependências Principais
- `flutter`: Framework principal
- `sqflite`: Banco de dados local
- `path_provider`: Acesso a diretórios do sistema
- `pdf`: Geração de documentos PDF
- `open_filex`: Abertura automática de arquivos
- `path`: Manipulação de caminhos

### Estrutura do Projeto
```
lib/
├── main.dart                           # Ponto de entrada do app
├── models/
│   ├── servico.dart                   # Modelo de dados do serviço
│   └── item_servico.dart              # Modelo de dados do item de serviço
├── database/
│   └── database_helper.dart          # Gerenciador do banco de dados
└── screens/
    ├── home_screen.dart               # Tela principal
    ├── adicionar_servico_screen.dart  # Tela de adicionar/editar serviços
    └── relatorio_screen.dart          # Tela de geração de relatórios
```

## Requisitos do Sistema
- Flutter 3.35.1 ou superior
- Dart 3.9.0 ou superior
- Android API 21+ ou iOS 11+

## Como Executar

### Pré-requisitos
1. Instalar Flutter SDK
2. Configurar ambiente de desenvolvimento (Android Studio/VS Code)

### Comandos
```bash
# Instalar dependências
flutter pub get

# Executar em modo debug
flutter run

# Gerar APK de release
flutter build apk --release

# Gerar bundle para Play Store
flutter build appbundle --release
```

## Melhorias Implementadas

### 1. Interface Organizada
- Agrupamento de serviços por mês/ano para melhor organização
- ExpansionTile para navegação intuitiva
- Design responsivo e amigável

### 2. Funcionalidade de Exclusão
- Swipe-to-delete com confirmação
- Prevenção de exclusão acidental
- Feedback visual claro

### 3. Geração de PDF Simplificada
- Processo unificado de geração
- Abertura automática do arquivo
- Interface limpa e direta

### 4. Experiência do Usuário
- Validações em tempo real
- Feedback visual para todas as ações
- Interface otimizada para usuários com pouca familiaridade tecnológica

## Arquivos de Saída
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`
- PDFs: Salvos na pasta de documentos do dispositivo

## Suporte
Este aplicativo foi desenvolvido seguindo as especificações fornecidas, priorizando simplicidade, funcionalidade offline e facilidade de uso para eletricistas autônomos.
