import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PhotoPage(photoId: '照片 A')));

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.photoId});
  final String photoId;

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  bool _busy = false;
  String _message = '尚未加载';
  String? _error;

  Future<String> _fetchMessage() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return '照片信息已准备好';
  }

  Future<void> _load() async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await _fetchMessage();
      if (!mounted) return;
      setState(() {
        _message = result;
      });
    } catch (error) {
      debugPrint('加载失败：$error');
      if (!mounted) return;
      setState(() {
        _error = '加载失败，请重试';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_message),
            Text(_error ?? ''),
            FilledButton(
              onPressed: _busy ? null : _load,
              child: Text(_busy ? '加载中…' : '加载 / 重试'),
            ),
          ],
        ),
      ),
    );
  }
}
