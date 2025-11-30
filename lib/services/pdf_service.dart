import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/models.dart';

class PdfService {
  /// Generates a PDF financial report.
  /// Option C version (optimized + paginated + formatted).
  static Future<void> generateReport({
    required List<Map<String, dynamic>> sales,
    required List<Map<String, dynamic>> expenses,
    required DateTime startDate,
    required DateTime endDate,
    required double totalSales,
    required double totalExpenses,
  }) async {
    final pdf = pw.Document();

    final BusinessOwner? businessOwner = await _getBusinessOwner();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return _buildBusinessOwnerHeader(businessOwner);
          }
          return pw.SizedBox.shrink();
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'FINANCIAL REPORT',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 16),

            // Summary section
            _buildSummarySection(totalSales, totalExpenses),
            pw.SizedBox(height: 20),

            _buildSectionTitle('SALES DETAILS'),
            pw.SizedBox(height: 6),
            _buildItemsTable(sales, isExpense: false),
            pw.SizedBox(height: 20),

            _buildSectionTitle('EXPENSES DETAILS'),
            pw.SizedBox(height: 6),
            _buildItemsTable(expenses, isExpense: true),
            pw.SizedBox(height: 20),

            _buildFinalTotals(sales, expenses),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // -------------------------------------------------------------
  // Fetch business owner
  // -------------------------------------------------------------
  static Future<BusinessOwner?> _getBusinessOwner() async {
    try {
      final dbHelper = DatabaseHelper();
      return await dbHelper.getPrimaryBusinessOwner();
    } catch (e) {
      print("Error loading business owner: $e");
      return null;
    }
  }

  // -------------------------------------------------------------
  // Header with business info
  // -------------------------------------------------------------
   static pw.Widget _buildBusinessOwnerHeader(BusinessOwner? businessOwner) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (businessOwner != null) ...[
            // Business Information when owner exists
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        businessOwner.businessName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      if (businessOwner.name.isNotEmpty)
                        pw.Text(
                          'Owner: ${businessOwner.name}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                      if (businessOwner.phone.isNotEmpty)
                        pw.Text(
                          'Phone: ${businessOwner.phone}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (businessOwner.email.isNotEmpty)
                        pw.Text(
                          'Email: ${businessOwner.email}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                      if (businessOwner.address.isNotEmpty)
                        pw.Text(
                          'Address: ${businessOwner.address}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Default header when no business owner
            pw.Center(
              child: pw.Text(
                'SALES AND EXEPENSES REPORT',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.blue, height: 1),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Report Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                'Generated by Faustian - Sales & Expenses Tracker App',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Summary section
  // -------------------------------------------------------------
  static pw.Widget _buildSummarySection(
      double totalSales, double totalExpenses) {
    final netProfit = totalSales - totalExpenses;
    final netColor = netProfit >= 0 ? PdfColors.green : PdfColors.red;

    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('FINANCIAL SUMMARY',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          _summaryRow('Total Sales:', _safeFormatAmount(totalSales),
              PdfColors.green),
          pw.SizedBox(height: 4),
          _summaryRow('Total Expenses:', _safeFormatAmount(totalExpenses),
              PdfColors.red),

          pw.SizedBox(height: 6),
          pw.Divider(),
          pw.SizedBox(height: 6),

          _summaryRow('NET PROFIT:', _safeFormatAmount(netProfit), netColor),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(value,
            style:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  // -------------------------------------------------------------
  // Section title
  // -------------------------------------------------------------
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold));
  }

  // -------------------------------------------------------------
  // Paginated Items Table
  // -------------------------------------------------------------
  static pw.Widget _buildItemsTable(List<Map<String, dynamic>> items,
      {required bool isExpense}) {
    if (items.isEmpty) {
      return pw.Container(
        padding: pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(
          child: pw.Text(
            isExpense
                ? 'No expenses recorded for this period.'
                : 'No sales recorded for this period.',
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
          ),
        ),
      );
    }

    final data = items.map((row) {
      return [
        _safeFormatDate(row['date']),
        row['description'] ?? '',
        row['category'] ?? '',
        _safeFormatAmount(row['amount']),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: ['Date', 'Description', 'Category', 'Amount'],
      data: data,
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: pw.TextStyle(fontSize: 9),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: pw.FlexColumnWidth(1.4),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(1.8),
        3: pw.FlexColumnWidth(1.2),
      },
      cellPadding: pw.EdgeInsets.all(6),
    );
  }

  // -------------------------------------------------------------
  // Final totals recalculated from lists
  // -------------------------------------------------------------
  static pw.Widget _buildFinalTotals(
      List<Map<String, dynamic>> sales, List<Map<String, dynamic>> expenses) {
    final salesTotal = sales.fold<double>(
        0, (sum, row) => sum + _safeAmountToDouble(row['amount']));
    final expensesTotal = expenses.fold<double>(
        0, (sum, row) => sum + _safeAmountToDouble(row['amount']));
    final net = salesTotal - expensesTotal;
    final netColor = net >= 0 ? PdfColors.green : PdfColors.red;

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('SUMMARY TOTALS',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          _summaryRow('Calculated Total Sales:',
              _safeFormatAmount(salesTotal), PdfColors.green),
          pw.SizedBox(height: 4),
          _summaryRow('Calculated Total Expenses:',
              _safeFormatAmount(expensesTotal), PdfColors.red),

          pw.SizedBox(height: 6),
          pw.Divider(),
          pw.SizedBox(height: 6),

          _summaryRow('NET (Sales - Expenses):',
              _safeFormatAmount(net), netColor),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Safe formatting helpers
  // -------------------------------------------------------------
  static final NumberFormat _commaFormat = NumberFormat('#,##0.00');

  static String _safeFormatAmount(dynamic value) {
    final amount = _safeAmountToDouble(value);
    return '¢${_commaFormat.format(amount)}';
  }

  static double _safeAmountToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();

    if (value is String) {
      final cleaned =
          value.replaceAll(RegExp(r'[^0-9\.\-]'), '');
      try {
        return double.parse(cleaned);
      } catch (_) {
        return 0.0;
      }
    }

    try {
      return double.parse(value.toString());
    } catch (_) {
      return 0.0;
    }
  }

  static String _safeFormatDate(dynamic value) {
    try {
      if (value is DateTime) {
        return DateFormat('MMM dd, yyyy').format(value);
      }
      if (value is int) {
        return DateFormat('MMM dd, yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(value));
      }
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value?.toString() ?? '';
    }
  }
}
//Done With PDF Service