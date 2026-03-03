import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';
import 'package:fai_dashboard_sales/models/query.dart';

class ExcelService {
  static Future<void> exportSalesQueries(List<SalesQuery> queries) async {
    final excel = Excel.createExcel();
    
    // The default Excel object comes with one sheet called Sheet1
    // We can rename it or use it.
    final String sheetName = 'Sales Queries';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // Header styling
    // Note: Excel package styling can be limited depending on the platform/viewer
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    final dataStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Left,
    );

    // Headings
    final headers = [
      'Date', 'Employee Name', 'Profile Name', 'Client Name', 'Source',
      'Service Line', 'Country', 'Quote URL', 'Status', 'F1', 'F2', 'F3',
      'Conv. Status', 'Sold By', 'Monitoring Remark'
    ];

    // Add headers to the first row
    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Add data rows
    for (var i = 0; i < queries.length; i++) {
      final q = queries[i];
      final rowIndex = i + 1;
      
      _addCell(sheet, 0, rowIndex, DateFormat('MM/dd/yyyy').format(q.date), dataStyle);
      _addCell(sheet, 1, rowIndex, q.employeeName, dataStyle);
      _addCell(sheet, 2, rowIndex, q.profileName, dataStyle);
      _addCell(sheet, 3, rowIndex, q.clientName, dataStyle);
      _addCell(sheet, 4, rowIndex, q.source, dataStyle);
      _addCell(sheet, 5, rowIndex, q.serviceLine, dataStyle);
      _addCell(sheet, 6, rowIndex, q.country, dataStyle);
      _addCell(sheet, 7, rowIndex, q.quote ?? "-", dataStyle);
      _addCell(sheet, 8, rowIndex, _formatEnum(q.status.name), dataStyle);
      _addCell(sheet, 9, rowIndex, q.followUp1Done ? "Yes" : "No", dataStyle);
      _addCell(sheet, 10, rowIndex, q.followUp2Done ? "Yes" : "No", dataStyle);
      _addCell(sheet, 11, rowIndex, q.followUp3Done ? "Yes" : "No", dataStyle);
      _addCell(sheet, 12, rowIndex, _formatEnum(q.conversationStatus.name), dataStyle);
      _addCell(sheet, 13, rowIndex, q.soldBy ?? "None", dataStyle);
      _addCell(sheet, 14, rowIndex, q.monitoringRemark ?? "-", dataStyle);
    }

    // Generate bytes
    final bytes = excel.save();
    if (bytes == null) return;

    final fileName = "Sales_Queries_Export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx";

    if (kIsWeb) {
      final content = base64Encode(bytes);
      html.AnchorElement(
          href: "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", fileName)
        ..click();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/$fileName";
      final file = File(path);
      await file.writeAsBytes(bytes);
      await OpenFile.open(path);
    }
  }

  static void _addCell(Sheet sheet, int col, int row, String value, CellStyle style) {
    var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value);
    cell.cellStyle = style;
  }

  static String _formatEnum(String name) {
    // Convert camelCase to Space Separated
    final result = name.replaceAllMapped(RegExp(r'(?=[A-Z])'), (Match m) => ' ${m[0]}');
    return result[0].toUpperCase() + result.substring(1);
  }
}
