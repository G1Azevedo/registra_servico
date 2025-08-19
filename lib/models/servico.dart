class Servico {
  int? id;
  String nomeCliente;
  DateTime dataServico;
  String descricaoServico;
  double valorTotal;

  Servico({
    this.id,
    required this.nomeCliente,
    required this.dataServico,
    required this.descricaoServico,
    required this.valorTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_cliente': nomeCliente,
      'data_servico': dataServico.toIso8601String(),
      'descricao_servico': descricaoServico,
      'valor_total': valorTotal,
    };
  }

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'],
      nomeCliente: map['nome_cliente'],
      dataServico: DateTime.parse(map['data_servico']),
      descricaoServico: map['descricao_servico'],
      valorTotal: map['valor_total'],
    );
  }
}

