import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// ══════════════════════════════════════════════════════════════
//  HOW TO ADD TO pubspec.yaml:
//
//  dependencies:
//    syncfusion_flutter_pdfviewer: ^25.1.38
//    path_provider: ^2.1.2
//
//  Also add to AndroidManifest.xml (android/app/src/main/):
//    <uses-permission android:name="android.permission.INTERNET"/>
//    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
//
//  Also add to Info.plist (ios/Runner/):
//    <key>NSPhotoLibraryUsageDescription</key>
//    <string>Required to read PDF files</string>
// ══════════════════════════════════════════════════════════════

/// Safe PDF Viewer — supports Asset, File path, URL, and Bytes.
/// Handles all crash scenarios with proper error UI.
class SafePdfViewer extends StatefulWidget {
  /// Title shown in the AppBar
  final String title;

  /// Use ONE of these four sources:
  final String? assetPath;   // e.g. 'assets/sample.pdf'
  final String? filePath;    // e.g. '/storage/.../file.pdf'
  final String? networkUrl;  // e.g. 'https://example.com/doc.pdf'
  final Uint8List? bytes;    // raw PDF bytes

  const SafePdfViewer({
    Key? key,
    this.title = 'PDF Viewer',
    this.assetPath,
    this.filePath,
    this.networkUrl,
    this.bytes,
  })  : assert(
          assetPath != null ||
              filePath != null ||
              networkUrl != null ||
              bytes != null,
          'Provide at least one PDF source',
        ),
        super(key: key);

  @override
  State<SafePdfViewer> createState() => _SafePdfViewerState();
}

class _SafePdfViewerState extends State<SafePdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // For asset/file → we load bytes first to avoid platform crashes
  Uint8List? _resolvedBytes;

  @override
  void initState() {
    super.initState();
    _loadPdfSource();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  // ── Source resolution ──────────────────────────────────────

  Future<void> _loadPdfSource() async {
    try {
      if (widget.bytes != null) {
        // Already have bytes — nothing to load
        setState(() => _isLoading = false);
        return;
      }

      if (widget.assetPath != null) {
        final data = await rootBundle.load(widget.assetPath!);
        _resolvedBytes = data.buffer.asUint8List();
        setState(() => _isLoading = false);
        return;
      }

      if (widget.filePath != null) {
        final file = File(widget.filePath!);
        if (!await file.exists()) {
          throw Exception('File not found: ${widget.filePath}');
        }
        _resolvedBytes = await file.readAsBytes();
        setState(() => _isLoading = false);
        return;
      }

      // Network URL — let SfPdfViewer.network handle it directly
      setState(() => _isLoading = false);
    } catch (e) {
      _setError('Failed to load PDF: $e');
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  // ── Build the right viewer widget ─────────────────────────

  Widget _buildPdfViewer() {
    try {
      // Bytes (from asset / file / direct bytes)
      final bytes = _resolvedBytes ?? widget.bytes;
      if (bytes != null) {
        return SfPdfViewer.memory(
          bytes,
          key: _pdfViewerKey,
          controller: _pdfController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            _setError('Document load failed: ${details.error}');
          },
          onDocumentLoaded: (_) {
            // Clear loading state if still set
            if (_isLoading && mounted) setState(() => _isLoading = false);
          },
          pageLayoutMode: PdfPageLayoutMode.continuous,
          scrollDirection: PdfScrollDirection.vertical,
          enableDoubleTapZooming: true,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          canShowPaginationDialog: true,
        );
      }

      // Network
      if (widget.networkUrl != null) {
        return SfPdfViewer.network(
          widget.networkUrl!,
          key: _pdfViewerKey,
          controller: _pdfController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            _setError('Network PDF failed: ${details.error}');
          },
          onDocumentLoaded: (_) {
            if (_isLoading && mounted) setState(() => _isLoading = false);
          },
          pageLayoutMode: PdfPageLayoutMode.continuous,
          scrollDirection: PdfScrollDirection.vertical,
          enableDoubleTapZooming: true,
          canShowScrollHead: true,
        );
      }

      return _buildErrorWidget('No valid PDF source provided.');
    } catch (e) {
      return _buildErrorWidget('Viewer error: $e');
    }
  }

  // ── Error & Loading UI ────────────────────────────────────

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'PDF उघडता आले नाही',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = '';
                  _resolvedBytes = null;
                });
                _loadPdfSource();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('पुन्हा प्रयत्न करा'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.teal),
          SizedBox(height: 16),
          Text('PDF लोड होत आहे...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // ── Toolbar actions ───────────────────────────────────────

  void _jumpToFirstPage() {
    try {
      _pdfController.jumpToPage(1);
    } catch (_) {}
  }

  void _jumpToLastPage() {
    try {
      _pdfController.jumpToPage(_pdfController.pageCount);
    } catch (_) {}
  }

  void _zoomIn() {
    try {
      _pdfController.zoomLevel =
          (_pdfController.zoomLevel + 0.25).clamp(1.0, 3.0);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      _pdfController.zoomLevel =
          (_pdfController.zoomLevel - 0.25).clamp(1.0, 3.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: _hasError || _isLoading
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  tooltip: 'पहिले पान',
                  onPressed: _jumpToFirstPage,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  tooltip: 'Zoom In',
                  onPressed: _zoomIn,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  tooltip: 'Zoom Out',
                  onPressed: _zoomOut,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  tooltip: 'शेवटचे पान',
                  onPressed: _jumpToLastPage,
                ),
              ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _hasError
              ? _buildErrorWidget(_errorMessage)
              : _buildPdfViewer(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  EXAMPLE USAGE SCREEN
//  Replace this with your actual usage in the Health Meter app
// ══════════════════════════════════════════════════════════════

class HealthMeterPdfScreen extends StatelessWidget {
  const HealthMeterPdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SafePdfViewer(
      title: 'Health Report',
      // ── OPTION 1: Asset PDF (add to pubspec.yaml assets section)
      assetPath: 'assets/health_report.pdf',

      // ── OPTION 2: File from device storage
      // filePath: '/storage/emulated/0/Download/report.pdf',

      // ── OPTION 3: Network PDF
      // networkUrl: 'https://example.com/health_report.pdf',

      // ── OPTION 4: Bytes (e.g. from API response)
      // bytes: myPdfBytes,
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  HOW TO NAVIGATE TO PDF VIEWER FROM YOUR EXISTING SCREEN
//  Add this button/gesture in health_meter_example_screen.dart
// ══════════════════════════════════════════════════════════════

/*
  ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SafePdfViewer(
            title: 'Health Report',
            assetPath: 'assets/health_report.pdf',
            // OR networkUrl: 'https://...',
          ),
        ),
      );
    },
    child: const Text('PDF पहा'),
  ),
*/