import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

class MarkOptions {
  MarkOptions({
    this.styleBuilder,
    this.onTap,
    this.spanBuilder,
    this.recognizerFactory,
  });

  /// Custom recognizer to handle custom gestures
  final GestureRecognizer? Function(String text, String payload)? recognizerFactory;

  /// Builder for displaying the mark span
  final InlineSpan Function(
    BuildContext context,
    TextSpan markTextSpan,
    String text,
    String payload,
  )? spanBuilder;

  /// Customize the style of the text
  final TextStyle? Function(
    BuildContext context,
    String text,
    String payload,
    TextStyle? defaultStyle,
  )? styleBuilder;

  final Function(String text, String payload)? onTap;

  MarkOptions copyFrom(MarkOptions? other) {
    if (other == null) return this;
    return MarkOptions(
      styleBuilder: other.styleBuilder ?? styleBuilder,
      onTap: other.onTap ?? onTap,
      spanBuilder: other.spanBuilder ?? spanBuilder,
    );
  }
}
