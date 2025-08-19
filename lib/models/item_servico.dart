class ItemServico {
  int? id;
  int servicoId;
  int quantidade;
  double valorUnitario;

  ItemServico({
    this.id,
    required this.servicoId,
    required this.quantidade,
    required this.valorUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'servico_id': servicoId,
      'quantidade': quantidade,
      'valor_unitario': valorUnitario,
    };
  }

  factory ItemServico.fromMap(Map<String, dynamic> map) {
    return ItemServico(
      id: map['id'],
      servicoId: map['servico_id'],
      quantidade: map['quantidade'],
      valorUnitario: map['valor_unitario'],
    );
  }
}

