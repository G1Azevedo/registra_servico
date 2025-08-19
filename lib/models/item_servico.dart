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
      'servicoId': servicoId,
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
    };
  }

  factory ItemServico.fromMap(Map<String, dynamic> map) {
    return ItemServico(
      id: map['id'],
      servicoId: map['servicoId'],
      quantidade: map['quantidade'],
      valorUnitario: map['valorUnitario'],
    );
  }
}


