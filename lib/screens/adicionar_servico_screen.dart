import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../models/item_servico.dart';
import '../database/database_helper.dart';

class AdicionarServicoScreen extends StatefulWidget {
  final Servico? servico;

  AdicionarServicoScreen({this.servico});

  @override
  _AdicionarServicoScreenState createState() => _AdicionarServicoScreenState();
}

class _AdicionarServicoScreenState extends State<AdicionarServicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeClienteController = TextEditingController();
  final _descricaoServicoController = TextEditingController();
  DateTime _dataServico = DateTime.now();
  List<ItemServicoTemp> _itens = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _nomeClienteController.text = widget.servico!.nomeCliente;
      _descricaoServicoController.text = widget.servico!.descricaoServico;
      _dataServico = widget.servico!.dataServico;
      _carregarItens();
    } else {
      _adicionarItem();
    }
  }

  Future<void> _carregarItens() async {
    if (widget.servico != null) {
      List<ItemServico> itensCarregados = await dbHelper.getItensServico(widget.servico!.id!);
      setState(() {
        _itens = itensCarregados.map((item) => ItemServicoTemp(
          quantidade: item.quantidade,
          valorUnitario: item.valorUnitario,
        )).toList();
      });
    }
  }

  void _adicionarItem() {
    setState(() {
      _itens.add(ItemServicoTemp(quantidade: 1, valorUnitario: 20.0));
    });
  }

  void _removerItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  double _calcularTotal() {
    return _itens.fold(0.0, (total, item) => total + (item.quantidade * item.valorUnitario));
  }

  Future<void> _salvarServico() async {
    if (_formKey.currentState!.validate() && _itens.isNotEmpty) {
      double valorTotal = _calcularTotal();
      
      Servico servico = Servico(
        id: widget.servico?.id,
        nomeCliente: _nomeClienteController.text,
        dataServico: _dataServico,
        descricaoServico: _descricaoServicoController.text,
        valorTotal: valorTotal,
      );

      int servicoId;
      if (widget.servico == null) {
        servicoId = await dbHelper.insertServico(servico);
      } else {
        await dbHelper.updateServico(servico);
        servicoId = widget.servico!.id!;
        // Remove itens antigos
        List<ItemServico> itensAntigos = await dbHelper.getItensServico(servicoId);
        for (ItemServico item in itensAntigos) {
          await dbHelper.deleteItemServico(item.id!);
        }
      }

      // Salva novos itens
      for (ItemServicoTemp itemTemp in _itens) {
        ItemServico item = ItemServico(
          servicoId: servicoId,
          quantidade: itemTemp.quantidade,
          valorUnitario: itemTemp.valorUnitario,
        );
        await dbHelper.insertItemServico(item);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servico == null ? 'Novo Serviço' : 'Editar Serviço'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nomeClienteController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Cliente *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do cliente';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _dataServico,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null && picked != _dataServico) {
                            setState(() {
                              _dataServico = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data do Serviço',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_dataServico.day.toString().padLeft(2, '0')}/${_dataServico.month.toString().padLeft(2, '0')}/${_dataServico.year}',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoServicoController,
                        decoration: InputDecoration(
                          labelText: 'Descrição do Serviço',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Itens',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _adicionarItem,
                            icon: Icon(Icons.add),
                            label: Text('Adicionar Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ..._itens.asMap().entries.map((entry) {
                        int index = entry.key;
                        ItemServicoTemp item = entry.value;
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: item.quantidade.toString(),
                                        decoration: InputDecoration(
                                          labelText: 'Quantidade',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            item.quantidade = int.tryParse(value) ?? 1;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: item.valorUnitario.toStringAsFixed(2),
                                        decoration: InputDecoration(
                                          labelText: 'Valor Unitário (R\$)',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (value) {
                                          setState(() {
                                            item.valorUnitario = double.tryParse(value) ?? 20.0;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (_itens.length > 1)
                                      IconButton(
                                        onPressed: () => _removerItem(index),
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Subtotal: R\$ ${(item.quantidade * item.valorUnitario).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total do Serviço:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${_calcularTotal().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarServico,
                  child: Text(
                    'Salvar Serviço',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemServicoTemp {
  int quantidade;
  double valorUnitario;

  ItemServicoTemp({required this.quantidade, required this.valorUnitario});
}

