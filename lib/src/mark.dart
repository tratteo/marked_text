import "package:flutter/material.dart";
import "package:marked_text/marked_text.dart";
import "package:marked_text/src/gen/material_icons_g.dart";
import "package:url_launcher/url_launcher.dart";

class Mark {
  Mark({
    required this.id,
    MarkOptions? options,
  }) : options = options ?? MarkOptions();

  /// Create a default bold token with the id `mail`
  ///
  /// When tapped, open the mail application with the provided [mailSubject]
  factory Mark.mail(
    String mailSubject, {
    MarkOptions? options,
  }) {
    MarkOptions def = MarkOptions(
      styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(fontWeight: FontWeight.w600),
      onTap: (text, payload) async {
        Uri mail = Uri.parse("mailto:$payload?subject=$mailSubject");
        await launchUrl(mail, mode: LaunchMode.platformDefault);
      },
    );
    def = def.copyFrom(MarkedText.getDefaultOptionsFor("mail"));
    return Mark(id: "mail", options: def.copyFrom(options));
  }

  /// Create a default bold token with the id `lk`
  ///
  /// When tapped, attempt to open the link specified in the payload
  factory Mark.link({
    MarkOptions? options,
  }) {
    MarkOptions def = MarkOptions(
      styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(decoration: TextDecoration.underline),
      onTap: (text, payload) async {
        try {
          final url = Uri.parse(payload);
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } catch (_) {}
      },
    );
    def = def.copyFrom(MarkedText.getDefaultOptionsFor("lk"));
    return Mark(id: "lk", options: def.copyFrom(options));
  }

  /// Create a default bold token with the id `b`
  factory Mark.bold({
    FontWeight? fontWeight,
    MarkOptions? options,
  }) {
    MarkOptions def = MarkOptions(
      styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(fontWeight: fontWeight ?? FontWeight.bold),
    );
    def = def.copyFrom(MarkedText.getDefaultOptionsFor("b"));
    return Mark(id: "b", options: def.copyFrom(options));
  }

  /// Create a default bold token with the id `i`
  factory Mark.italic({MarkOptions? options}) {
    MarkOptions def = MarkOptions(
      styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(fontStyle: FontStyle.italic),
    );
    def = def.copyFrom(MarkedText.getDefaultOptionsFor("i"));
    return Mark(id: "i", options: def.copyFrom(options));
  }

  /// Create a default icon token with the id `icon`
  ///
  /// The payload must contain the int in _hex_ form of the icon, the text will be rendered as it is
  ///
  /// Icons: https://api.flutter.dev/flutter/material/Icons-class.html#constants
  factory Mark.icon({
    MarkOptions? options,
    IconThemeData? Function(BuildContext context, String text, String payload)? iconThemeBuilder,
    bool iconBefore = true,
    WrapCrossAlignment crossAlignment = WrapCrossAlignment.center,
    WrapAlignment alignment = WrapAlignment.center,
    PlaceholderAlignment placeholderAlignment = PlaceholderAlignment.bottom,
    double spacing = 4,
  }) {
    MarkOptions def = MarkOptions(
      spanBuilder: (context, tokenSpan, text, payload, defaultStyle) {
        var theme = iconThemeBuilder?.call(context, text, payload);
        int? iconHex = int.tryParse(payload);
        var elems = <Widget>[
          if (iconHex != null)
            Icon(
              materialIconsHexMap[iconHex],
              color: theme?.color,
              fill: theme?.fill,
              grade: theme?.grade,
              opticalSize: theme?.opticalSize,
              weight: theme?.weight,
              shadows: theme?.shadows,
              size: theme?.size ?? 16,
            )
          else if (materialIconsNameMap.containsKey(payload))
            Icon(
              materialIconsNameMap[payload],
              color: theme?.color,
              fill: theme?.fill,
              grade: theme?.grade,
              opticalSize: theme?.opticalSize,
              weight: theme?.weight,
              shadows: theme?.shadows,
              size: theme?.size ?? 16,
            ),
          RichText(text: tokenSpan),
        ];
        return WidgetSpan(
          child: Wrap(
            crossAxisAlignment: crossAlignment,
            runAlignment: alignment,
            spacing: spacing,
            children: iconBefore ? elems : elems.reversed.toList(),
          ),
          baseline: TextBaseline.alphabetic,
          alignment: placeholderAlignment,
        );
      },
    );
    def = def.copyFrom(MarkedText.getDefaultOptionsFor("icon"));
    return Mark(id: "icon", options: def.copyFrom(options));
  }

  final MarkOptions options;
  final String id;
}
