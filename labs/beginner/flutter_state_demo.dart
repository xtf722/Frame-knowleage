import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PhotoPage(photoId: '照片 A')));

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.photoId});
  final String photoId;

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  int _likes = 0;

  void _like() {
    setState(() {
      _likes = _likes + 1;
    });
    debugPrint('字段现在是 $_likes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State 练习')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.photoId}：$_likes 个赞'),
            FilledButton(onPressed: _like, child: const Text('点赞')),
          ],
        ),
      ),
    );
  }
}
