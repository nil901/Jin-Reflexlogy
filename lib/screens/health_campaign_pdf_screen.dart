import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';


const Map<int, int> _knownTotalPagesByYear = {
  2015: 117,
  2016: 122,
  2017: 168,
  2018: 230,
  2019: 132,
  2020: 133,
  2021: 133,
  2022: 231,
  2023: 102,
  2024: 105,
  2025: 84,
  2026: 160,
};

String _twoDigitYear(int year) => (year % 100).toString().padLeft(2, '0');

Future<String?> _fetchImageBase64Flexible({
  required int year,
  required int pageZeroBased,
}) async {
  final aCandidates = <String>[
    _twoDigitYear(year),
    year.toString(),
    '1',
  ];

  final nameCandidates = <String>[
    (pageZeroBased + 1).toString(),
    pageZeroBased.toString(),
  ];

  for (final a in aCandidates) {
    for (final name in nameCandidates) {
      final response = await http
          .post(
            Uri.parse('https://jinreflexology.in/api1/glimpse$year.php'),
            body: {
              "a": a,
              "name": name,
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) continue;

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) continue;

      final success = decoded['success'];
      final data = decoded['data'];
      if (success == 1 && data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map && first['image'] is String) {
          return first['image'] as String;
        }
      }
    }
  }

  return null;
}

class HealthCampaignScreen extends StatefulWidget {
  const HealthCampaignScreen({super.key, this.initialYear});
  final initialYear;

  @override
  State<HealthCampaignScreen> createState() => _HealthCampaignScreenState();
}

class _HealthCampaignScreenState extends State<HealthCampaignScreen> {
  int currentPage = 0;
  bool isLoading = false;
  bool hasError = false;
  String imageBase64 = '';
  bool isNextPageLoading = false;
  int totalPages = 0;
  final int year = 2015;
  final TextEditingController _pageNumberController = TextEditingController();

  int get _effectiveYear => int.tryParse('${widget.initialYear}') ?? year;
  int get _knownTotalPages => _knownTotalPagesByYear[_effectiveYear] ?? 0;
  int get _displayedPage => currentPage + 1;

  @override
  void initState() {
    super.initState();
    totalPages = _knownTotalPages;
    _pageNumberController.text = '1';
    loadPage(currentPage);
  }

  Future<void> loadPage(int page, {bool isNextPage = false}) async {
    if (isNextPage) {
      setState(() {
        isNextPageLoading = true;
      });
    } else {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }

    try {
      final image = await _fetchImageBase64Flexible(
        year: _effectiveYear,
        pageZeroBased: page,
      );

      if (image != null && image.isNotEmpty) {
        setState(() {
          imageBase64 = image;
          currentPage = page;
          _pageNumberController.text = (page + 1).toString();
          isLoading = false;
          isNextPageLoading = false;
          hasError = false;
        });
      } else {
        if (page > 0) {
          setState(() {
            totalPages = totalPages > 0 ? totalPages : page + 1;
            isNextPageLoading = false;
            isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You've reached the last page"),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
            isNextPageLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
        isNextPageLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void gotoPage() {
    if (isLoading) return;
    final raw = _pageNumberController.text.trim();
    final pageOneBased = int.tryParse(raw);
    if (pageOneBased == null || pageOneBased < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid page number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (totalPages > 0 && pageOneBased > totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a page between 1 and $totalPages'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newPage = pageOneBased - 1;
    if (newPage == currentPage) return;
    loadPage(newPage);
  }

  void nextPage() {
    if (!isNextPageLoading && !hasError && (totalPages == 0 || currentPage + 1 < totalPages)) {
      loadPage(currentPage + 1, isNextPage: true);
    }
  }

  void previousPage() {
    if (currentPage > 0 && !isLoading) {
      loadPage(currentPage - 1);
    }
  }

  void retryLoading() {
    loadPage(currentPage);
  }

  Future<void> _showGoToPageDialog() async {
    final controller = TextEditingController(text: '${currentPage + 1}');

    final int? pageOneBased = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Go to page'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter page number',
              helperText: totalPages > 0
                  ? '1 - $totalPages'
                  : 'Enter a page number (starting from 1)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = controller.text.trim();
                final parsed = int.tryParse(raw);
                if (parsed == null || parsed < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid page number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (totalPages > 0 && parsed > totalPages) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Max page is $totalPages'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, parsed);
              },
              child: const Text('Go'),
            ),
          ],
        );
  final _CampaignPdfItem item;

  @override
  State<_CampaignPdfTab> createState() => _CampaignPdfTabState();
}

class _CampaignPdfTabState extends State<_CampaignPdfTab>
    with AutomaticKeepAliveClientMixin<_CampaignPdfTab> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  bool get wantKeepAlive => true;

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfViewerController.previousPage();
    }
  }

  void _goToNextPage() {
    if (_totalPages > 0 && _currentPage < _totalPages) {
      _pdfViewerController.nextPage();
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SfPdfViewer.network(
      widget.item.url,
      controller: _pdfViewerController,
      pageLayoutMode: PdfPageLayoutMode.single,
      scrollDirection: PdfScrollDirection.horizontal,
      canShowPaginationDialog: true,
      canShowScrollHead: true,
      enableDoubleTapZooming: true,

      onDocumentLoaded: (details) {
        if (!mounted) return;
        setState(() {
          _totalPages = details.document.pages.count;
        });
      },

      onPageChanged: (details) {
        if (!mounted) return;
        setState(() {
          _currentPage = details.newPageNumber;
        });
      },

      onDocumentLoadFailed: (details) {
        print("PDF Error: ${details.description}");
      },
    );

    if (!mounted || pageOneBased == null) return;

    final targetPageZeroBased = pageOneBased - 1;
    if (targetPageZeroBased == currentPage) return;
    await loadPage(targetPageZeroBased);
  }

  Future<void> saveAndOpenImage() async {
    if (imageBase64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image to save")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Uint8List imageBytes = base64Decode(imageBase64);
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/campaign_image_$timestamp.png';
      File file = File(filePath);
      await file.writeAsBytes(imageBytes);
      await OpenFile.open(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image saved and opened successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving file: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showFullScreenPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePreview(
          imageBase64: imageBase64,
          currentPage: currentPage,
          totalPages: totalPages,
          initialYear: _effectiveYear,
          onNext: () => navigateInFullScreen(1),
          onPrevious: () => navigateInFullScreen(-1),
          hasNext: totalPages == 0 || currentPage + 1 < totalPages,
          hasPrevious: currentPage > 0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageNumberController.dispose();
    super.dispose();
  }

  void navigateInFullScreen(int direction) async {
    int newPage = currentPage + direction;
    
    if (direction == 1 && totalPages > 0 && newPage >= totalPages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You've reached the last page"),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    if (direction == -1 && newPage < 0) {
      return;
    }
    
    setState(() {
      isNextPageLoading = true;
    });

    try {
      final image = await _fetchImageBase64Flexible(
        year: _effectiveYear,
        pageZeroBased: newPage,
      );

      if (image != null && image.isNotEmpty) {
        setState(() {
          imageBase64 = image;
          currentPage = newPage;
          isNextPageLoading = false;
          hasError = false;
        });
      } else {
        if (newPage > 0) {
          setState(() {
            totalPages = totalPages > 0 ? totalPages : newPage + 1;
            isNextPageLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You've reached the last page"),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            hasError = true;
            isNextPageLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isNextPageLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: Text('Health Campaign $_effectiveYear'),
      //   backgroundColor: Colors.black,
      //   foregroundColor: Colors.white,
        
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       tooltip: 'Go to page',
      //       onPressed: isLoading ? null : _showGoToPageDialog,
      //       icon: const Icon(Icons.search),
      //     ),
      //     IconButton(
      //       tooltip: 'Open image',
      //       onPressed: isLoading ? null : saveAndOpenImage,
      //       icon: const Icon(Icons.open_in_new),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: showFullScreenPreview,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: isLoading
                      ? const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Loading page...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : hasError
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Failed to load page",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Please check your internet connection",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: retryLoading,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Try Again"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InteractiveViewer(
                                    minScale: 0.8,
                                    maxScale: 4.0,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    child: Image.memory(
                                      base64Decode(imageBase64),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                size: 64,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Failed to load image",
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Tap for Full Screen",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ),
          
          // Loading indicator for next page
          if (isNextPageLoading)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Page search / goto controls
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pageNumberController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => gotoPage(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Page number',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: gotoPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Go'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: currentPage > 0 && !isLoading 
                          ? previousPage 
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      label: const Text("Previous"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      totalPages > 0 && _displayedPage >= totalPages
                          ? "$_displayedPage/$totalPages (Last)"
                          : "$_displayedPage/$totalPages",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: !isNextPageLoading && !hasError && (totalPages == 0 || currentPage + 1 < totalPages)
                          ? nextPage 
                          : null,
                      icon: const Icon(Icons.chevron_right, size: 20),
                      label: const Text("Next"),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Full Screen Image Preview with Navigation (Stays in Full Screen)
class FullScreenImagePreview extends StatefulWidget {
  final String imageBase64;
  final int currentPage;
  final int totalPages;
  final int initialYear;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  const FullScreenImagePreview({
    super.key,
    required this.imageBase64,
    required this.currentPage,
    required this.totalPages,
    required this.initialYear,
    required this.onNext,
    required this.onPrevious,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  State<FullScreenImagePreview> createState() => _FullScreenImagePreviewState();
}

class _FullScreenImagePreviewState extends State<FullScreenImagePreview> {
  late String currentImageBase64;
  late int currentPage;
  late int totalPages;
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    currentImageBase64 = widget.imageBase64;
    currentPage = widget.currentPage;
    totalPages = widget.totalPages > 0
        ? widget.totalPages
        : (_knownTotalPagesByYear[widget.initialYear] ?? 0);
  }

  Future<void> loadPage(int page, {bool isNext = false}) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final image = await _fetchImageBase64Flexible(
        year: widget.initialYear,
        pageZeroBased: page,
      );

      if (image != null && image.isNotEmpty) {
        setState(() {
          currentImageBase64 = image;
          currentPage = page;
          isLoading = false;
          hasError = false;
        });
      } else {
        if (page > 0) {
          setState(() {
            totalPages = totalPages > 0 ? totalPages : page + 1;
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You've reached the last page"),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void nextPage() {
    if (!isLoading && !hasError && (totalPages == 0 || currentPage + 1 < totalPages)) {
      loadPage(currentPage + 1);
    }
  }

  void previousPage() {
    if (currentPage > 0 && !isLoading) {
      loadPage(currentPage - 1);
    }
  }

  Future<void> _showGoToPageDialog() async {
    final controller = TextEditingController(text: '${currentPage + 1}');

    final int? pageOneBased = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Go to page'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter page number',
              helperText: totalPages > 0
                  ? '1 - $totalPages'
                  : 'Enter a page number (starting from 1)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = controller.text.trim();
                final parsed = int.tryParse(raw);
                if (parsed == null || parsed < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid page number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (totalPages > 0 && parsed > totalPages) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Max page is $totalPages'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, parsed);
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );

    if (!mounted || pageOneBased == null) return;

    final targetPageZeroBased = pageOneBased - 1;
    if (targetPageZeroBased == currentPage) return;
    await loadPage(targetPageZeroBased);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Image with Interactive Viewer
          Center(
            child: isLoading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Loading page...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Failed to load page",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please check your internet connection",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => loadPage(currentPage),
                            icon: const Icon(Icons.refresh),
                            label: const Text("Try Again"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      )
                    : InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 5.0,
                        boundaryMargin: const EdgeInsets.all(20),
                        child: Image.memory(
                          base64Decode(currentImageBase64),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Failed to load image",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
          
          // Top Bar with Close Button and Page Info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      totalPages > 0 && currentPage + 1 >= totalPages
                          ? "${currentPage + 1}/$totalPages (Last)"
                          : "${currentPage + 1}/$totalPages",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Go to page',
                    onPressed: isLoading ? null : _showGoToPageDialog,
                    icon: const Icon(Icons.search, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: currentPage > 0 && !isLoading
                          ? previousPage
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 24),
                      label: const Text("Previous", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Next Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: !isLoading && !hasError && (totalPages == 0 || currentPage + 1 < totalPages)
                          ? nextPage
                          : null,
                      icon: const Icon(Icons.chevron_right, size: 24),
                      label: const Text("Next", style: TextStyle(fontSize: 16)),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Instruction Text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Pinch to zoom • Swipe to pan",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple card screen for 2015 only
class HealthCampaign2015CardScreen extends StatelessWidget {
  const HealthCampaign2015CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Health Awareness Campaigns",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HealthCampaignScreen(initialYear: 2015),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue,
                          Colors.blueAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.campaign,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Health Awareness 2015",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap to view glimpses of 2015 campaign",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "View",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
