import 'package:registra_servico_app/models/item_servico.dart';
import 'package:registra_servico_app/models/servico.dart';

class ServicoComItens {
  final Servico servico;
  final List<ItemServico> itens;

  ServicoComItens({required this.servico, required this.itens});
}

