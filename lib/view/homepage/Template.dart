import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/video/shortv_player.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class Template extends StatefulWidget {
  final String? html;
  final String? title;
  final String? imagePath;
  Template({Key? key, this.html, this.title, this.imagePath}) : super(key: key);
  @override
  State<StatefulWidget> createState() => TemplateState();
}


class TemplateState extends State<Template> {
  final List<Widget> flutterList = [];

  @override
  void initState() {
    super.initState();
    _parseAndBuild(widget.html ?? '');
  }

  void _parseAndBuild(String html) {
    final doc = html_parser.parse(html);
    final body = doc.body;
    if (body == null) return;

    final built = <Widget>[];
    for (final node in body.nodes) {
      final w = _buildFromNode(node);
      if (w != null) built.add(w);
    }

    setState(() {
      flutterList
        ..clear()
        ..addAll(built);
    });
  }

  Widget? _buildFromNode(dom.Node node) {
    if (node is dom.Text) {
      final text = node.text.trim();
      if (text.isEmpty) return null;
      return _p(TextSpan(text: text));
    }

    if (node is dom.Element) {
      switch (node.localName) {
        case 'p':
          final spans = _inlineSpans(node);
          if (spans.isEmpty) return const SizedBox.shrink();
          return _p(TextSpan(children: spans));

        case 'img':
          final src = node.attributes['src'];
          if (src == null || src.isEmpty) return null;
          return _image(src);

        case 'video':
          return _videoFromVideoElement(node);

        default:
          final spans = _inlineSpans(node);
          if (spans.isNotEmpty) return _p(TextSpan(children: spans));
          final children = <Widget>[];
          for (final c in node.nodes) {
            final w = _buildFromNode(c);
            if (w != null) children.add(w);
          }
          if (children.isEmpty) return null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
      }
    }
    return null;
  }

  Widget? _videoFromVideoElement(dom.Element e) {
    String? url = e.attributes['src'];

    if (url == null || url.isEmpty) {
      final source = e.querySelector('source');
      url = source?.attributes['src'];
    }
    if (url == null || url.isEmpty) return null;

    return _video(url);
  }

  List<InlineSpan> _inlineSpans(dom.Element e) {
    final spans = <InlineSpan>[];
    for (final n in e.nodes) {
      if (n is dom.Text) {
        final t = n.text;
        if (t.isNotEmpty) {
          spans.add(TextSpan(
            text: t,
            style: TextStyle(fontSize: 15.sp, height: 1.5, color: StyleTheme.cTitleColor),
          ));
        }
      } else if (n is dom.Element) {
        if (n.localName == 'a') {
          final hrefText = n.text.trim();
          if (hrefText.isNotEmpty) {
            spans.add(TextSpan(
              text: hrefText,
              style: TextStyle(
                color: StyleTheme.cDangerColor,
                fontSize: 15.sp,
                height: 1.5,
                decorationColor: StyleTheme.cDangerColor,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final encoded = Uri.encodeComponent(hrefText);
                  AppGlobal.appRouter?.push(
                    CommonUtils.getRealHash('browser/$encoded/${widget.title ?? '-'}'),
                  );
                },
            ));
          }
        } else if (n.localName == 'img') {
          final src = n.attributes['src'];
          if (src != null && src.isNotEmpty) {
            spans.add(WidgetSpan(child: _image(src)));
          }
        } else if (n.localName == 'video') {
          final w = _videoFromVideoElement(n);
          if (w != null) spans.add(WidgetSpan(child: w));
        } else {
          spans.addAll(_inlineSpans(n));
        }
      }
    }
    return spans;
  }

  Widget _p(TextSpan span) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: RichText(text: span),
    );
  }

  Widget _image(String url) {
    String urls = url.startsWith('http') ? url : (widget.imagePath! + url);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14.5.w),
      constraints: BoxConstraints(maxHeight: 320.w),
      child: Center(
        child: NetImageTool(url: urls, fit: BoxFit.cover),
      ),
    );
  }

  Widget _video(String url) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14.5.w),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ShortVPlayer(url: url, cover_url: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: flutterList,
    );
  }
}
