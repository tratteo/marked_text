import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:marked_text/marked_text.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "Marked text example"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: use_raw_strings
  String rawStringSource = """
Welcome to the \${[example]i()} of the package \${[mapplet_text]b()}.
To check out more information, be sure to visit the package on \${[pub.dev]lk(https://pub.dev/packages/marked_text)}.
This package allows to mark arbitrary text spans in order to customize the appearance and to include custom callbacks when interacting with the marks.
It is also possible to include custom icons in the text using the int code of the \${[Flutter Material Icons]lk(https://api.flutter.dev/flutter/material/Icons-class.html#constants)}.
\${[Icon with text]icon(0xf53f)}
\${[Another icon]icon(0xe062)}

\${[Custom mark]custom(first payload)}
\${[Custom mark]custom(second payload)}

\${[Long press text]longpress(long press payload)}
""";

  @override
  void initState() {
    super.initState();
    // Set some default options
    MarkedText.setDefaults(
      textStyle: const TextStyle(color: Colors.white, fontSize: 20),
      marksOptions: {
        // Make all icons text by default orange
        "icon": MarkOptions(
          styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(color: Colors.orange),
        ),
        // Make italic text opaque, remember to set it to italic
        "i": MarkOptions(
          styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(color: Colors.black54, fontStyle: FontStyle.italic),
        ),
        // Make bold text bigger, remember to set it to bold
        "b": MarkOptions(
          styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: MarkedText(
          source: rawStringSource,
          textAlign: TextAlign.start,
          marks: [
            Mark.bold(),
            Mark.italic(),
            Mark.link(),
            Mark.icon(),
            Mark(
              id: "custom",
              options: MarkOptions(
                onTap: (text, payload) => debugPrint("tapped text $text with payload $payload"),
                styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(decoration: TextDecoration.underline, color: Colors.amberAccent),
              ),
            ),
            Mark(
              id: "longpress",
              options: MarkOptions(
                recognizerFactory: (text, payload) =>
                    LongPressGestureRecognizer(duration: const Duration(milliseconds: 200))..onLongPress = () => debugPrint("long pressed text $text with payload $payload"),
                styleBuilder: (context, text, payload, defaultStyle) => defaultStyle?.copyWith(decoration: TextDecoration.underline, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
