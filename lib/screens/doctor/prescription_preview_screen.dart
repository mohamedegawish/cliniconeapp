import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../api/api_client.dart';
import '../../services/consultation_service.dart';

class PrescriptionPreviewScreen extends StatefulWidget {
  final int consultationId;

  const PrescriptionPreviewScreen({super.key, required this.consultationId});

  @override
  State<PrescriptionPreviewScreen> createState() => _PrescriptionPreviewScreenState();
}

class _PrescriptionPreviewScreenState extends State<PrescriptionPreviewScreen> {
  final _service = ConsultationService(ApiClient());
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  // ─── Color palette mirroring web design ──────────────────────────────────────
  static const _green    = Color(0xFF2A7F62);
  static const _lightGn  = Color(0xFFEAF7F2);
  static const _borderGn = Color(0xFFB7E4D4);
  static const _darkTxt  = Color(0xFF1E293B);
  static const _grayTxt  = Color(0xFF64748B);
  static const _tblAlt   = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final d = await _service.getPrintData(widget.consultationId);
      if (mounted) setState(() { _data = d; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // ─── Extract typed data from raw JSON ────────────────────────────────────────
  Map<String, dynamic> get _c       => (_data!['consultation'] as Map<String, dynamic>? ?? {});
  Map<String, dynamic> get _clinic  => (_data!['clinic']       as Map<String, dynamic>? ?? {});
  Map<String, dynamic> get _patient => (_c['patient']          as Map<String, dynamic>? ?? {});
  Map<String, dynamic> get _doctor  => (_c['doctor']           as Map<String, dynamic>? ?? {});
  Map<String, dynamic> get _vitals  => (_c['vitals']           as Map<String, dynamic>? ?? {});
  List                 get _meds    => (_c['medications']       as List? ?? []);

  String get _clinicName  => _clinic['name']        as String? ?? 'ClinicOne';
  String get _doctorName  => _doctor['name']        as String? ?? '';
  String get _doctorSpec  => _doctor['specialty']   as String? ?? 'Specialist Physician';
  String get _patientName => _patient['full_name']  as String? ?? '';
  String get _age         => _patient['age']?.toString() ?? '—';
  String get _gender      => _patient['gender']     as String? ?? '';
  String get _diagnosis   => _c['diagnosis']        as String? ?? '';
  String get _symptoms    => _c['symptoms']         as String? ?? '';
  String get _createdAt   => (_c['created_at']      as String? ?? '').length >= 10
      ? (_c['created_at'] as String).substring(0, 10) : '';
  String get _recordId    => '#${(_c['id']?.toString() ?? '0').padLeft(6, '0')}';

  bool get _hasVitals => _vitals.values.any((v) => v != null && v.toString().isNotEmpty);

  // ─── Vitals label→value map ───────────────────────────────────────────────────
  Map<String, String> get _vitalsMap {
    String? v(String k, [String? suffix]) {
      final raw = _vitals[k];
      if (raw == null || raw.toString().isEmpty) return null;
      return suffix != null ? '${raw.toString()} $suffix' : raw.toString();
    }
    final m = <String, String>{};
    if (v('bp')     != null) m['BP']     = v('bp')!;
    if (v('temp')   != null) m['Temp']   = v('temp', '°C')!;
    if (v('pulse')  != null) m['Pulse']  = v('pulse', 'bpm')!;
    if (v('hr')     != null) m['HR']     = v('hr', 'bpm')!;
    if (v('rr')     != null) m['RR']     = v('rr', '/min')!;
    if (v('spo2')   != null) m['SpO2']   = v('spo2', '%')!;
    if (v('weight') != null) m['Weight'] = v('weight', 'kg')!;
    if (v('height') != null) m['Height'] = v('height', 'cm')!;
    return m;
  }

  // ─── PDF generation ───────────────────────────────────────────────────────────
  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final doc = pw.Document();
    final pGreen      = PdfColor.fromHex('2A7F62');
    final pLightGreen = PdfColor.fromHex('EAF7F2');
    final pBorderGn   = PdfColor.fromHex('B7E4D4');
    final pDark       = PdfColor.fromHex('1E293B');
    final pGray       = PdfColor.fromHex('64748B');
    final pAlt        = PdfColor.fromHex('F8FAFC');

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Header ──
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Row(children: [
                pw.Container(
                  width: 44, height: 44,
                  decoration: pw.BoxDecoration(color: pGreen, borderRadius: pw.BorderRadius.circular(8)),
                  alignment: pw.Alignment.center,
                  child: pw.Text('Rx', style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic)),
                ),
                pw.SizedBox(width: 10),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(_clinicName, style: pw.TextStyle(color: pGreen, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Medical Center & Specialized Care', style: pw.TextStyle(color: pGray, fontSize: 8)),
                ]),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('Dr. $_doctorName', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: pDark)),
                pw.Text(_doctorSpec,        style: pw.TextStyle(fontSize: 10, color: pGray)),
              ]),
            ]),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 3, color: pGreen),
            pw.SizedBox(height: 8),
            // ── Patient bar ──
            pw.Container(
              decoration: pw.BoxDecoration(
                color: pLightGreen,
                border: pw.Border.all(color: pBorderGn),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(children: [
                _pdfCell(pGray, pDark, 'Patient',      _patientName),
                _pdfVbar(pBorderGn),
                _pdfCell(pGray, pDark, 'Age / Gender', '$_age / ${_gender.isNotEmpty ? _gender : '—'}'),
                _pdfVbar(pBorderGn),
                _pdfCell(pGray, pDark, 'Visit Date',   _createdAt),
                _pdfVbar(pBorderGn),
                _pdfCell(pGray, pDark, 'Record ID',    _recordId),
              ]),
            ),
            pw.SizedBox(height: 12),
            // ── Vitals ──
            if (_hasVitals) ...[
              _pdfSectionLabel('Vital Signs', pGreen),
              pw.SizedBox(height: 6),
              pw.Wrap(spacing: 6, runSpacing: 6, children: _vitalsMap.entries.map((e) =>
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: pBorderGn), borderRadius: pw.BorderRadius.circular(4)),
                  child: pw.Column(children: [
                    pw.Text(e.key, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: pGray, letterSpacing: 0.5)),
                    pw.Text(e.value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: pGreen)),
                  ]),
                ),
              ).toList()),
              pw.SizedBox(height: 10),
            ],
            // ── Diagnosis ──
            _pdfSectionLabel('Clinical Diagnosis', pGreen),
            pw.SizedBox(height: 4),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: pLightGreen,
                border: pw.Border(left: pw.BorderSide(color: pGreen, width: 3)),
              ),
              child: pw.Text(_diagnosis, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: pDark)),
            ),
            if (_symptoms.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              _pdfSectionLabel('Patient Complaints', pGreen),
              pw.SizedBox(height: 4),
              pw.Text(_symptoms, style: pw.TextStyle(fontSize: 11, color: pGray, fontStyle: pw.FontStyle.italic)),
            ],
            pw.SizedBox(height: 12),
            pw.Divider(thickness: 1, color: pLightGreen),
            pw.Row(children: [
              pw.Text('Rx', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: pGreen, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(width: 6),
              pw.Text('MEDICATION PLAN', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: pDark, letterSpacing: 1)),
            ]),
            pw.SizedBox(height: 8),
            // ── Meds table ──
            pw.Table(
              border: pw.TableBorder(
                bottom: pw.BorderSide(color: pBorderGn, width: 0.5),
                horizontalInside: pw.BorderSide(color: pLightGreen, width: 0.5),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(0.5),
                1: pw.FlexColumnWidth(2.5),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(1.5),
                4: pw.FlexColumnWidth(1.5),
                5: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: pLightGreen),
                  children: ['#', 'MEDICATION', 'DOSAGE', 'FREQUENCY', 'DURATION', 'INSTRUCTIONS'].map((h) =>
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: pw.Text(h, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: pGreen, letterSpacing: 0.4)),
                    ),
                  ).toList(),
                ),
                if (_meds.isEmpty)
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('—', style: pw.TextStyle(color: pGray))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('No medications prescribed.', style: pw.TextStyle(color: pGray, fontStyle: pw.FontStyle.italic))),
                    ...List.generate(4, (_) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(''))),
                  ])
                else
                  for (var i = 0; i < _meds.length; i++)
                    pw.TableRow(
                      decoration: i.isOdd ? pw.BoxDecoration(color: pAlt) : null,
                      children: [
                        _pdfTd('${i + 1}', bold: true, color: pGreen),
                        _pdfTd((_meds[i] as Map)['name'] ?? '', bold: true, color: pDark),
                        _pdfTd((_meds[i] as Map)['dosage'] ?? '—'),
                        _pdfTd((_meds[i] as Map)['frequency'] ?? '—'),
                        _pdfTd((_meds[i] as Map)['duration'] ?? '—'),
                        _pdfTd((_meds[i] as Map)['instructions'] ?? '—', color: pGray),
                      ],
                    ),
              ],
            ),
            pw.Spacer(),
            // ── Footer ──
            pw.Divider(color: pBorderGn),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.SizedBox(height: 28),
                pw.Container(width: 160, height: 1, color: PdfColor.fromHex('CBD5E1')),
                pw.SizedBox(height: 4),
                pw.Text("CLINIC STAMP & DOCTOR'S SIGNATURE", style: pw.TextStyle(fontSize: 7, color: pGray, letterSpacing: 0.5)),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('Get Well Soon', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: pGreen)),
                pw.SizedBox(height: 4),
                pw.Text('$_createdAt  |  $_clinicName', style: pw.TextStyle(fontSize: 8, color: pGray)),
              ]),
            ]),
          ],
        ),
      ),
    );
    return doc.save();
  }

  pw.Widget _pdfCell(PdfColor labelColor, PdfColor valColor, String label, String value) =>
    pw.Expanded(
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label.toUpperCase(), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: labelColor, letterSpacing: 0.4)),
          pw.SizedBox(height: 3),
          pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: valColor)),
        ]),
      ),
    );

  pw.Widget _pdfVbar(PdfColor color) => pw.Container(width: 1, height: 44, color: color);

  pw.Widget _pdfSectionLabel(String text, PdfColor color) =>
    pw.Text(text.toUpperCase(), style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: color, letterSpacing: 1.2));

  pw.Widget _pdfTd(String text, {bool bold = false, PdfColor? color}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
    );

  // ─── Actions ──────────────────────────────────────────────────────────────────
  Future<void> _printPrescription() async {
    await Printing.layoutPdf(
      onLayout: (format) => _buildPdf(format),
      name: 'Prescription_${widget.consultationId}',
    );
  }

  Future<void> _sharePdf() async {
    final bytes = await _buildPdf(PdfPageFormat.a4);
    await Printing.sharePdf(bytes: bytes, filename: 'Prescription_${widget.consultationId}.pdf');
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _green))
                : _error != null
                    ? _buildError()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: [
                            _buildPrescriptionCard(),
                            const SizedBox(height: 16),
                            _buildActionButtons(),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
    decoration: const BoxDecoration(
      color: _green,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text('الوصفة الطبية', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        if (_data != null)
          GestureDetector(
            onTap: _sharePdf,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.share_outlined, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text('مشاركة', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 13)),
              ]),
            ),
          ),
      ],
    ),
  );

  // ─── Error state ──────────────────────────────────────────────────────────────
  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, size: 56, color: Color(0xFF94A3B8)),
      const SizedBox(height: 16),
      Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF64748B)), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: _load,
        style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white)),
      ),
    ]),
  );

  // ─── Main prescription card (mirrors web print.blade.php) ────────────────────
  Widget _buildPrescriptionCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Rx Header ──────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2A7F62), Color(0xFF3DBF8F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: const Color(0xFF2A7F62).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                alignment: Alignment.center,
                child: const Text('Rx', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_clinicName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _green, letterSpacing: -0.3)),
                const Text('Medical Center & Specialized Care', style: TextStyle(fontSize: 9, color: _grayTxt, letterSpacing: 0.5)),
              ]),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Dr. $_doctorName', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _darkTxt)),
              Text(_doctorSpec, style: const TextStyle(fontSize: 11, color: _grayTxt)),
            ]),
          ],
        ),
        const SizedBox(height: 14),
        Container(height: 4, color: _green),
        const SizedBox(height: 16),

        // ── Patient bar ────────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: _lightGn,
            border: Border.all(color: _borderGn),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            _patientCell('Patient', _patientName),
            Container(width: 1, color: _borderGn, height: 56),
            _patientCell('Age / Gender', '$_age / ${_gender.isNotEmpty ? _gender : '—'}'),
            Container(width: 1, color: _borderGn, height: 56),
            _patientCell('Visit Date', _createdAt),
            Container(width: 1, color: _borderGn, height: 56),
            _patientCell('Record ID', _recordId),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Vitals ─────────────────────────────────────────────────────────────
        if (_hasVitals) ...[
          _sectionLabel('⚕  VITAL SIGNS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _vitalsMap.entries.map((e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(children: [
                Text(e.key, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _grayTxt, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _green)),
              ]),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // ── Diagnosis ──────────────────────────────────────────────────────────
        _sectionLabel('🔬  CLINICAL DIAGNOSIS'),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: _lightGn,
            border: Border(left: BorderSide(color: _green, width: 4)),
          ),
          child: Text(_diagnosis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _darkTxt)),
        ),

        // ── Symptoms ───────────────────────────────────────────────────────────
        if (_symptoms.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionLabel('📋  PATIENT COMPLAINTS'),
          const SizedBox(height: 6),
          Text(_symptoms, style: const TextStyle(fontSize: 13, color: _grayTxt, fontStyle: FontStyle.italic, height: 1.6)),
        ],
        const SizedBox(height: 16),

        // ── Rx symbol row ──────────────────────────────────────────────────────
        const Divider(color: _lightGn, thickness: 2),
        const SizedBox(height: 8),
        const Row(children: [
          Text('℞', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _green, fontStyle: FontStyle.italic)),
          SizedBox(width: 8),
          Text('MEDICATION PLAN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _darkTxt, letterSpacing: 1)),
        ]),
        const SizedBox(height: 12),

        // ── Medications table ──────────────────────────────────────────────────
        _medsTable(),
        const SizedBox(height: 36),

        // ── Footer ─────────────────────────────────────────────────────────────
        const Divider(color: _borderGn),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 28),
              Container(width: 180, height: 1, color: const Color(0xFFCBD5E1)),
              const SizedBox(height: 6),
              const Text("CLINIC STAMP & DOCTOR'S SIGNATURE", style: TextStyle(fontSize: 9, color: _grayTxt, letterSpacing: 0.5)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('🌿 Get Well Soon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _green)),
              const SizedBox(height: 4),
              Text('$_createdAt  |  $_clinicName', style: const TextStyle(fontSize: 10, color: _grayTxt)),
            ]),
          ],
        ),
      ],
    ),
  );

  // ─── Action buttons ───────────────────────────────────────────────────────────
  Widget _buildActionButtons() => Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: _printPrescription,
          icon: const Icon(Icons.print_outlined, color: Colors.white, size: 20),
          label: const Text('طباعة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _sharePdf,
          icon: const Icon(Icons.picture_as_pdf_outlined, color: _green, size: 20),
          label: const Text('PDF مشاركة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: _green, fontSize: 15)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: _green),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ],
  );

  // ─── Widget helpers ───────────────────────────────────────────────────────────
  Widget _patientCell(String label, String value) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6B9E8A), letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _darkTxt), overflow: TextOverflow.ellipsis),
      ]),
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _green, letterSpacing: 1.5),
  );

  Widget _medsTable() {
    if (_meds.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: _borderGn),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('No medications prescribed.', style: TextStyle(color: _grayTxt, fontStyle: FontStyle.italic)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(28),
          1: FlexColumnWidth(2.5),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.5),
          5: FlexColumnWidth(2),
        },
        border: TableBorder(
          bottom: const BorderSide(color: _borderGn, width: 0.5),
          horizontalInside: const BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        children: [
          // Header row
          TableRow(
            decoration: const BoxDecoration(color: _lightGn),
            children: ['#', 'Medication', 'Dosage', 'Frequency', 'Duration', 'Instructions'].map((h) =>
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(h, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _green, letterSpacing: 0.4)),
              ),
            ).toList(),
          ),
          // Data rows
          for (var i = 0; i < _meds.length; i++)
            TableRow(
              decoration: BoxDecoration(color: i.isOdd ? _tblAlt : Colors.white),
              children: [
                _td('${i + 1}', bold: true, color: _green),
                _td((_meds[i] as Map)['name']?.toString() ?? '', bold: true),
                _td((_meds[i] as Map)['dosage']?.toString() ?? '—'),
                _td((_meds[i] as Map)['frequency']?.toString() ?? '—'),
                _td((_meds[i] as Map)['duration']?.toString() ?? '—'),
                _td((_meds[i] as Map)['instructions']?.toString() ?? '—', color: _grayTxt),
              ],
            ),
        ],
      ),
    );
  }

  Widget _td(String text, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color ?? _darkTxt),
    ),
  );
}
