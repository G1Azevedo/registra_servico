import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../database/database_helper.dart';
import 'adicionar_servico_screen.dart';
import 'relatorio_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Servico> servicos = [];
  Map<String, List<Servico>> servicosAgrupados = {};
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    List<Servico> servicosCarregados = await dbHelper.getServicos();
    setState(() {
      servicos = servicosCarregados;
      _agruparServicosPorMes();
    });
  }

  void _agruparServicosPorMes() {
    servicosAgrupados.clear();
    for (Servico servico in servicos) {
      String chave = _obterChaveMesAno(servico.dataServico);
      if (!servicosAgrupados.containsKey(chave)) {
        servicosAgrupados[chave] = [];
      }
      servicosAgrupados[chave]!.add(servico);
    }
  }

  String _obterChaveMesAno(DateTime data) {
    List<String> meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${meses[data.month - 1]} de ${data.year}';
  }

  Future<void> _confirmarExclusao(Servico servico) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja realmente excluir este serviço?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await dbHelper.deleteServico(servico.id!);
      _carregarServicos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serviço excluído com sucesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registra Serviço'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.description),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RelatorioScreen()),
              );
            },
          ),
        ],
      ),
      body: servicos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum serviço registrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar um novo serviço',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: servicosAgrupados.keys.length,
              itemBuilder: (context, index) {
                String mesAno = servicosAgrupados.keys.elementAt(index);
                List<Servico> servicosDoMes = servicosAgrupados[mesAno]!;
                double totalMes = servicosDoMes.fold(0.0, (sum, servico) => sum + servico.valorTotal);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      mesAno,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${servicosDoMes.length} serviço${servicosDoMes.length != 1 ? 's' : ''} - Total: R\$ ${totalMes.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    children: servicosDoMes.map((servico) {
                      return Dismissible(
                        key: Key(servico.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          await _confirmarExclusao(servico);
                          return false; // Não remove automaticamente, pois já tratamos a exclusão
                        },
                        child: ListTile(
                          title: Text(
                            servico.nomeCliente,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                '${servico.dataServico.day.toString().padLeft(2, '0')}/${servico.dataServico.month.toString().padLeft(2, '0')}/${servico.dataServico.year}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text(
                                servico.descricaoServico,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Text(
                            'R\$ ${servico.valorTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdicionarServicoScreen(servico: servico),
                              ),
                            ).then((_) => _carregarServicos());
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdicionarServicoScreen()),
          ).then((_) => _carregarServicos());
        },
        icon: Icon(Icons.add),
        label: Text('Adicionar Novo Serviço'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

