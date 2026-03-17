import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../services/analytics_service.dart';

/// Schermata per visualizzare PDF all'interno dell'app.
/// Scarica il PDF dall'URL, lo salva in cache locale e lo renderizza
/// con il viewer Syncfusion (motore basato su PDFium/Adobe).
class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewerScreen({super.key, required this.title, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _controller = PdfViewerController();
  final PdfTextSearchResult _searchResult = PdfTextSearchResult();

  bool _loading = true;
  String? _error;
  File? _localFile;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _nightMode = false;
  bool _showSearchBar = false;
  final _searchCtrl = TextEditingController();

  // Chiave per salvare ultima pagina letta per URL
  String get _lastPageKey => 'pdf_page_${widget.url.hashCode.abs()}';

  @override
  void initState() {
    super.initState();
    _downloadPdf();
    AnalyticsService().trackEvent('pdf_open', {'title': widget.title});
  }

  @override
  void dispose() {
    _saveLastPage();
    _searchCtrl.dispose();
    _searchResult.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveLastPage() async {
    if (_currentPage > 0) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastPageKey, _currentPage);
      } catch (_) {}
    }
  }

  Future<int> _loadLastPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_lastPageKey) ?? 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> _downloadPdf() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final fileName = 'vdc_pdf_${widget.url.hashCode.abs()}.pdf';

      if (!kIsWeb) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');

        if (await file.exists() && await file.length() > 0) {
          if (mounted) {
            setState(() {
              _localFile = file;
              _loading = false;
            });
          }
          return;
        }

        final response = await http.get(Uri.parse(widget.url))
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          if (mounted) {
            setState(() {
              _localFile = file;
              _loading = false;
            });
          }
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('PdfViewerScreen download error: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Impossibile caricare il PDF.\n$e';
        });
      }
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      _searchResult.clear();
      _controller.searchText(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _nightMode ? Colors.black : const Color(0xFF2D2D2D),
      appBar: AppBar(
        title: _showSearchBar
            ? _buildSearchField()
            : Text(widget.title, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        actions: [
          // Ricerca testo
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            tooltip: 'Cerca nel PDF',
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchCtrl.clear();
                  _searchResult.clear();
                }
              });
            },
          ),
          // Indicatore pagina
          if (!_showSearchBar && _totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$_currentPage/$_totalPages',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ),
          // Night mode
          IconButton(
            icon: Icon(_nightMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: _nightMode ? 'Modalità chiara' : 'Modalità notturna',
            onPressed: () => setState(() => _nightMode = !_nightMode),
          ),
          // Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              switch (v) {
                case 'bookmarks':
                  _pdfViewerKey.currentState?.openBookmarkView();
                  break;
                case 'zoom_in':
                  _controller.zoomLevel = (_controller.zoomLevel + 0.5).clamp(0.5, 5.0);
                  break;
                case 'zoom_out':
                  _controller.zoomLevel = (_controller.zoomLevel - 0.5).clamp(0.5, 5.0);
                  break;
                case 'fit_width':
                  _controller.zoomLevel = 1.0;
                  break;
                case 'first_page':
                  _controller.jumpToPage(1);
                  break;
                case 'last_page':
                  _controller.jumpToPage(_totalPages);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'bookmarks', child: ListTile(leading: Icon(Icons.bookmark_outline), title: Text('Segnalibri'), dense: true, contentPadding: EdgeInsets.zero)),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'zoom_in', child: Text('Zoom +')),
              const PopupMenuItem(value: 'zoom_out', child: Text('Zoom -')),
              const PopupMenuItem(value: 'fit_width', child: Text('Adatta larghezza')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'first_page', child: Text('Prima pagina')),
              const PopupMenuItem(value: 'last_page', child: Text('Ultima pagina')),
            ],
          ),
        ],
      ),
      // Barra navigazione risultati ricerca
      bottomNavigationBar: _searchResult.hasResult
          ? Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_searchResult.currentInstanceIndex} di ${_searchResult.totalInstanceCount}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.navigate_before, color: Colors.white),
                    onPressed: () => _searchResult.previousInstance(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next, color: Colors.white),
                    onPressed: () => _searchResult.nextInstance(),
                  ),
                ],
              ),
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchCtrl,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Cerca nel PDF...',
        hintStyle: TextStyle(color: Colors.white38),
        border: InputBorder.none,
      ),
      onSubmitted: _onSearch,
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Caricamento PDF...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    Widget viewer;

    if (!kIsWeb && _localFile != null) {
      viewer = SfPdfViewer.file(
        _localFile!,
        key: _pdfViewerKey,
        controller: _controller,
        canShowScrollHead: true,
        canShowPaginationDialog: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        pageSpacing: 4,
        onDocumentLoaded: (details) async {
          if (!mounted) return;
          final lastPage = await _loadLastPage();
          setState(() {
            _totalPages = details.document.pages.count;
            _currentPage = lastPage.clamp(1, _totalPages);
          });
          if (lastPage > 1 && lastPage <= _totalPages) {
            _controller.jumpToPage(lastPage);
          }
        },
        onPageChanged: (details) {
          if (mounted) {
            setState(() => _currentPage = details.newPageNumber);
          }
        },
        onDocumentLoadFailed: (details) {
          if (mounted) {
            setState(() => _error = 'Errore apertura PDF: ${details.description}');
          }
        },
      );
    } else {
      viewer = SfPdfViewer.network(
        widget.url,
        key: _pdfViewerKey,
        controller: _controller,
        canShowScrollHead: true,
        enableDoubleTapZooming: true,
        pageSpacing: 4,
        onDocumentLoaded: (details) {
          if (mounted) {
            setState(() {
              _totalPages = details.document.pages.count;
              _currentPage = 1;
            });
          }
        },
        onPageChanged: (details) {
          if (mounted) {
            setState(() => _currentPage = details.newPageNumber);
          }
        },
        onDocumentLoadFailed: (details) {
          if (mounted) {
            setState(() => _error = 'Errore apertura PDF: ${details.description}');
          }
        },
      );
    }

    // Night mode: inverte i colori per lettura notturna
    if (_nightMode) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]),
        child: viewer,
      );
    }

    return viewer;
  }
}
