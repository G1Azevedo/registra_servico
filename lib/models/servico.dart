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
      'nomeCliente': nomeCliente,
      'dataServico': dataServico.toIso8601String(),
      'descricaoServico': descricaoServico,
      'valorTotal': valorTotal,
    };
  }

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'],
      nomeCliente: map['nomeCliente'],
      dataServico: DateTime.parse(map['dataServico']),
      descricaoServico: map['descricaoServico'],
      valorTotal: map['valorTotal'],
    );
  }
}


