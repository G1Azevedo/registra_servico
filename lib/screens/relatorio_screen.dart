import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../models/servico.dart';
import '../models/item_servico.dart';
import '../database/database_helper.dart';
import '../services/pdf_service.dart';
import '../models/servico_com_itens.dart';

class RelatorioScreen extends StatefulWidget {
  @override
  _RelatorioScreenState createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  DateTime _dataInicio = DateTime.now().subtract(Duration(days: 15));
  DateTime _dataFim = DateTime.now();
  DatabaseHelper dbHelper = DatabaseHelper();
  bool _gerandoRelatorio = false;

  Future<void> _gerarRelatorio() async {
    setState(() {
      _gerandoRelatorio = true;
    });

    try {
      List<Servico> todosServicos = await dbHelper.getServicos();
      List<Servico> servicosPeriodo = todosServicos.where((servico) {
        return servico.dataServico.isAfter(_dataInicio.subtract(Duration(days: 1))) &&
               servico.dataServico.isBefore(_dataFim.add(Duration(days: 1)));
      }).toList();

      if (servicosPeriodo.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhum serviço encontrado no período selecionado')),
        );
        setState(() {
          _gerandoRelatorio = false;
        });
        return;
      }

      List<ServicoComItens> servicosComItens = [];
      for (Servico servico in servicosPeriodo) {
        List<ItemServico> itens = await dbHelper.getItensServico(servico.id!);
        servicosComItens.add(ServicoComItens(servico: servico, itens: itens));
      }

      final caminho = await PdfService.gerarRelatorioPdf(servicosComItens, _dataInicio, _dataFim);
      await OpenFilex.open(caminho);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar relatório: $e')),
      );
    } finally {
      setState(() {
        _gerandoRelatorio = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerar Relatório'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione o período para o relatório:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dataInicio,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _dataInicio) {
                  setState(() {
                    _dataInicio = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Início',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_dataInicio.day.toString().padLeft(2, '0')}/${_dataInicio.month.toString().padLeft(2, '0')}/${_dataInicio.year}',
                ),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dataFim,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _dataFim) {
                  setState(() {
                    _dataFim = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Fim',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_dataFim.day.toString().padLeft(2, '0')}/${_dataFim.month.toString().padLeft(2, '0')}/${_dataFim.year}',
                ),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _gerandoRelatorio ? null : _gerarRelatorio,
                child: _gerandoRelatorio
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Gerando Relatório...'),
                        ],
                      )
                    : Text(
                        'Gerar Relatório',
                        style: TextStyle(fontSize: 18),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Informações',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'O relatório será gerado e aberto automaticamente com o aplicativo de PDF padrão do seu dispositivo.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


