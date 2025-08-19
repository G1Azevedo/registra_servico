import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/servico.dart';
import '../database/database_helper.dart';

class PdfService {
  static Future<String> gerarRelatorioPdf(DateTime dataInicio, DateTime dataFim) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    
    // Buscar todos os serviços
    List<Servico> todosServicos = await dbHelper.getServicos();
    
    // Filtrar serviços por período
    List<Servico> servicosFiltrados = todosServicos.where((servico) {
      return servico.dataServico.isAfter(dataInicio.subtract(Duration(days: 1))) &&
             servico.dataServico.isBefore(dataFim.add(Duration(days: 1)));
    }).toList();

    // Ordenar por data
    servicosFiltrados.sort((a, b) => a.dataServico.compareTo(b.dataServico));

    // Criar o documento PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'RELATÓRIO DE SERVIÇOS',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Período: ${_formatarData(dataInicio)} a ${_formatarData(dataFim)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      'Gerado em: ${_formatarData(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),

              // Lista de serviços
              ...servicosFiltrados.asMap().entries.map((entry) {
                int index = entry.key;
                Servico servico = entry.value;
                
                return pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 15),
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${index + 1}. ${servico.nomeCliente.toUpperCase()}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue700,
                            ),
                          ),
                          pw.Text(
                            _formatarData(servico.dataServico),
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        servico.descricaoServico,
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green100,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(
                              'R\$ ${servico.valorTotal.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 20),

              // Total geral
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 2),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL GERAL:',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'R\$ ${servicosFiltrados.fold(0.0, (total, servico) => total + servico.valorTotal).toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Rodapé
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Relatório gerado pelo aplicativo Registra Serviço',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Salvar o arquivo
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/relatorio_servicos_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}

