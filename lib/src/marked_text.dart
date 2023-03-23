import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

import "package:marked_text/marked_text.dart";

class MarkedText extends StatefulWidget {
  const MarkedText({
    super.key,
    required this.source,
    required this.marks,
    this.marksRegexp,
    this.textAlign = TextAlign.start,
    this.defaultStyle,
  });

  static Map<String, MarkOptions> _defaultMarksOptions = Map.identity();
  static TextStyle? _defaultTextStyle;

  /// Set default options for different marks
  ///
  /// Options can be overridden in the definition of any single [Mark]
  static void setDefaults({TextStyle? textStyle, Map<String, MarkOptions>? marksOptions}) {
    if (marksOptions != null) {
      _defaultMarksOptions = marksOptions;
    }
    _defaultTextStyle = textStyle;
  }

  static MarkOptions? getDefaultOptionsFor(String id) => _defaultMarksOptions[id];

  /// Override the default regexp for the marked text
  ///
  /// The [RegExp] __must__ contain three named groups and __must__ be limited, that is it has to have symbols that allows to identify the end of the corresponding mark.
  ///
  /// * `text` generally the text to be displayed
  /// * `id` the type (id) used to identify which mark to use
  /// * `payload` the payload of the mark
  ///
  /// Groups are named, therefore they can be placed in any order in the source string.
  ///
  /// -----
  /// The default regexp matches the marks in this form:
  ///
  /// `${[text]type(payload)}`
  ///
  /// It is highly recommended to deeply test the regexp in order to be sure the correct functioning
  ///
  /// The algorithm does the following:
  ///
  /// * matches the first mark and extracts its information
  /// * copies the remaining string after the match
  /// * repeat
  ///
  /// Therefore be sure that the regexp matches only the strict necessary and is able to deterministically stop and the correct spot
  final RegExp? marksRegexp;

  /// A list of marks that are available to this [MarkedText]
  final List<Mark> marks;
  final TextAlign textAlign;

  /// The default style of the text and the marks
  final TextStyle? defaultStyle;

  final String source;

  @override
  State<MarkedText> createState() => _MarkedTextState();
}

class _MarkedTextState extends State<MarkedText> {
  RegExp defaultMarksRegexp = RegExp(
    r"\$\{\[(?<text>.+?(?=]))\](?<id>[a-zA-z0-9]+)\((?<payload>.*?(?=\)))\)\}",
  );

  String content = "";
  TextStyle? defaultStyle;
  RegExp get regexp => widget.marksRegexp ?? defaultMarksRegexp;

  final List<Object> _tokensMatch = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    content = widget.source;
    _tokensMatch.clear();
    _tokensMatch.addAll(_tokenizeRawString());
    defaultStyle = widget.defaultStyle ?? (MarkedText._defaultTextStyle ?? const TextStyle());
  }

  List<Object> _tokenizeRawString() {
    var res = List<Object>.empty(growable: true);
    var input = content;
    var match = regexp.firstMatch(input);
    if (match == null) {
      return List.filled(1, content);
    }
    var suffix = "";
    while (match != null) {
      var prefix = input.substring(0, match.start);
      suffix = input.substring(match.end, input.length);
      res.add(prefix);
      res.add(match);
      input = suffix;
      match = regexp.firstMatch(input);
    }
    if (suffix.isNotEmpty) {
      res.add(suffix);
    }
    return res;
  }

  Mark? _getMarkById(String id) {
    var index = widget.marks.indexWhere((element) => element.id == id);
    return index >= 0 ? widget.marks[index] : null;
  }

  List<InlineSpan> _buildMarksWidgets() {
    return List.generate(_tokensMatch.length, (index) {
      var current = _tokensMatch.elementAt(index);
      if (current is String) {
        return TextSpan(text: current, style: defaultStyle);
      } else if (current is RegExpMatch) {
        var text = current.namedGroup("text")!;
        var id = current.namedGroup("id")!;
        var payload = current.namedGroup("payload")!;
        var mark = _getMarkById(id);
        if (mark == null) {
          return TextSpan(
            text: text,
            style: defaultStyle,
          );
        }
        var markOptions = MarkedText.getDefaultOptionsFor(id);
        if (markOptions != null) {
          markOptions = markOptions.copyFrom(mark.options);
        } else {
          markOptions = mark.options;
        }
        var span = TextSpan(
          recognizer: markOptions.recognizerFactory?.call(text, payload) ??
              (mark.options.onTap != null ? (TapGestureRecognizer()..onTap = () async => markOptions!.onTap?.call(text, payload)) : null),
          text: text,
          style: markOptions.styleBuilder?.call(context, text, payload, defaultStyle) ?? defaultStyle,
        );
        return markOptions.spanBuilder != null ? markOptions.spanBuilder!.call(context, span, text, payload) : span;
      }
      return const TextSpan(text: "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: _buildMarksWidgets()),
      textAlign: widget.textAlign,
    );
  }
}
