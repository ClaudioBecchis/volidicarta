import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Widget che mostra un banner di stato connessione.
/// Controlla periodicamente la raggiungibilità di rete.
class ConnectivityIndicator extends StatefulWidget {
  final Widget child;
  final Duration checkInterval;

  const ConnectivityIndicator({
    super.key,
    required this.child,
    this.checkInterval = const Duration(seconds: 30),
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  bool _isOnline = true;
  bool _checking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _timer = Timer.periodic(widget.checkInterval, (_) => _checkConnectivity());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    if (_checking) return;
    _checking = true;
    try {
      final response = await http.head(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _isOnline = response.statusCode == 200);
      }
    } catch (_) {
      if (mounted) setState(() => _isOnline = false);
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isOnline ? 0 : 28,
          child: _isOnline
              ? const SizedBox.shrink()
              : Material(
                  color: Colors.red.shade700,
                  child: InkWell(
                    onTap: _checkConnectivity,
                    child: const SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Nessuna connessione internet',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.refresh, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Banner compatto per indicare sincronizzazione in sospeso.
class SyncPendingBanner extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onSyncNow;

  const SyncPendingBanner({
    super.key,
    required this.pendingCount,
    this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount <= 0) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.sync_problem, color: Colors.orange.shade800, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$pendingCount ${pendingCount == 1 ? 'modifica' : 'modifiche'} in attesa di sincronizzazione',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 12,
              ),
            ),
          ),
          if (onSyncNow != null)
            TextButton(
              onPressed: onSyncNow,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
              ),
              child: Text(
                'Sincronizza',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
