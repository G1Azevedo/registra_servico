import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/servico.dart';
import '../models/item_servico.dart';
import '../models/servico_com_itens.dart';

class PdfService {
  static Future<String> gerarRelatorioPdf(List<ServicoComItens> servicosComItens, DateTime dataInicio, DateTime dataFim) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'RELATÓRIO DE SERVIÇOS',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Data de geração: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Período: ${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year} a ${dataFim.day.toString().padLeft(2, '0')}/${dataFim.month.toString().padLeft(2, '0')}/${dataFim.year}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: pw.TextStyle(fontSize: 10)),
              pw.Text('Registra Serviço App', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
        build: (pw.Context context) {
          List<pw.Widget> content = [];

          for (ServicoComItens servicoComItens in servicosComItens) {
            Servico servico = servicoComItens.servico;
            List<ItemServico> itens = servicoComItens.itens;

            content.add(
              pw.Container(
                margin: pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${servicosComItens.indexOf(servicoComItens) + 1}. ${servico.descricaoServico}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Cliente: ${servico.nomeCliente}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Data: ${servico.dataServico.day.toString().padLeft(2, '0')}/${servico.dataServico.month.toString().padLeft(2, '0')}/${servico.dataServico.year}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 5),
                    ...itens.map((item) => pw.Text(
                      '${item.quantidade} x R\$ ${item.valorUnitario.toStringAsFixed(2)} = R\$ ${(item.quantidade * item.valorUnitario).toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 11),
                    )).toList(),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Total do Serviço: R\$ ${servico.valorTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Divider(),
                  ],
                ),
              ),
            );
          }

          content.add(
            pw.SizedBox(height: 20),
          );
          content.add(
            pw.Container(
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Text(
                'TOTAL: R\$ ${servicosComItens.fold(0.0, (total, item) => total + item.servico.valorTotal).toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          );

          return content;
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/relatorio_servicos_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}


