# Registra Serviço

Aplicativo Flutter para registro de serviços elétricos, desenvolvido especificamente para eletricistas autônomos que precisam de uma ferramenta simples e que funcione offline.

## Características Principais

- **100% Offline**: Funciona completamente sem conexão à internet
- **Interface Simples**: Projetada para usuários com pouca familiaridade tecnológica
- **Persistência Local**: Todos os dados são salvos no dispositivo
- **Geração de PDF**: Relatórios profissionais em dois formatos (simples e premium)

## Funcionalidades

### Tela Principal
- Lista dos últimos serviços registrados (mais recente primeiro)
- Botão flutuante para adicionar novo serviço
- Botão na barra superior para gerar relatórios

### Adicionar/Editar Serviço
- Nome do cliente (obrigatório)
- Data do serviço (pré-preenchida com data atual)
- Descrição do serviço
- Múltiplos itens de cobrança com:
  - Quantidade
  - Valor unitário (padrão R$ 20,00)
  - Cálculo automático do subtotal
- Valor total calculado automaticamente

### Geração de Relatórios
- Seleção de período (data início e fim)
- Dois formatos de PDF:
  - **Simples**: Layout básico similar ao modelo original
  - **Premium**: Layout profissional com estatísticas e design aprimorado

## Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada do aplicativo
├── models/
│   ├── servico.dart            # Modelo de dados para Serviço
│   └── item_servico.dart       # Modelo de dados para Item de Serviço
├── database/
│   └── database_helper.dart    # Gerenciamento do banco de dados SQLite
├── screens/
│   ├── home_screen.dart        # Tela principal
│   ├── add_edit_servico_screen.dart # Tela de adicionar/editar serviço
│   └── relatorio_screen.dart   # Tela de geração de relatórios
└── services/
    ├── pdf_service.dart        # Geração de PDF simples
    └── pdf_service_premium.dart # Geração de PDF premium
```

## Dependências

- `sqflite`: Banco de dados SQLite local
- `path_provider`: Acesso aos diretórios do dispositivo
- `pdf`: Geração de documentos PDF
- `path`: Manipulação de caminhos de arquivo

## Como Executar

1. Certifique-se de ter o Flutter instalado
2. Clone ou baixe o projeto
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o aplicativo

## Banco de Dados

O aplicativo utiliza SQLite para armazenamento local com duas tabelas:

### Tabela `servicos`
- `id`: Identificador único (chave primária)
- `nomeCliente`: Nome do cliente
- `dataServico`: Data do serviço
- `descricaoServico`: Descrição do trabalho realizado
- `valorTotal`: Valor total do serviço

### Tabela `item_servicos`
- `id`: Identificador único (chave primária)
- `servicoId`: Referência ao serviço (chave estrangeira)
- `quantidade`: Quantidade do item
- `valorUnitario`: Valor unitário do item

## Relatórios PDF

### PDF Simples
- Layout básico e funcional
- Lista numerada dos serviços
- Cálculos individuais e total geral
- Formato similar ao modelo original fornecido

### PDF Premium
- Design profissional com gradientes e cores
- Resumo executivo com estatísticas
- Layout organizado com cards para cada serviço
- Formatação de datas por extenso
- Cabeçalho e rodapé estilizados

## Requisitos Atendidos

✅ **Operação 100% Offline**: Todos os dados são armazenados localmente  
✅ **Interface Simples**: Design minimalista e intuitivo  
✅ **Persistência de Dados**: Dados não são perdidos ao fechar o app  
✅ **Geração de PDF**: Relatórios profissionais com layout aprimorado  
✅ **Cálculo Automático**: Valores calculados em tempo real  
✅ **Filtro por Período**: Relatórios por data de início e fim  

## Funcionalidades Não Incluídas (Conforme Especificação)

❌ Cadastro prévio de clientes (CRM)  
❌ Controle de status de pagamento  
❌ Controle de custos de materiais  
❌ Login de usuário ou sincronização na nuvem  
❌ Dashboards ou gráficos complexos  

## Desenvolvido por

Manus AI - Sistema de Gestão de Serviços Elétricos v1.0

---

**Nota**: Este aplicativo foi desenvolvido seguindo rigorosamente as especificações fornecidas, priorizando simplicidade, funcionalidade offline e facilidade de uso para eletricistas autônomos.

