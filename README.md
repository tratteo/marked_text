# Handle text spans like a pro

## Features

`marked_text` allows to _mark_ certain sections of text in order to render them differently and attach behaviors with the `GestureRecognizer`

## Building
Since the package allows to dynamically obtain icons based on their id with the `Mark.icon()`, when building the Flutter application the flag `--no-tree-shake-icons` must be provided.

## Getting started

### Set default options

```dart
MarkedText.setDefaults({
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
      )
});
```

### Render your text

Define custom marks if needed or use the already implemented one.

```dart
MarkedText(
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
        styleBuilder: (context, text, payload, defaultStyle) =>
            defaultStyle?.copyWith(decoration: TextDecoration.underline, color: Colors.amberAccent),
        ),
    ),
    Mark(
        id: "longpress",
        options: MarkOptions(
        recognizerFactory: (text, payload) => LongPressGestureRecognizer(duration: const Duration(milliseconds: 200))
            ..onLongPress = () => debugPrint("long pressed text $text with payload $payload"),
        styleBuilder: (context, text, payload, defaultStyle) =>
            defaultStyle?.copyWith(decoration: TextDecoration.underline, color: Colors.red),
        ),
    )
    ],
),
```

### Text source
The following text shows an example on how marks are defined inside a text.
```txt
Lorem ${[ipsum]longpress()}, lorem ${[ipsum]i()}, lorem ${[ipsum]b()} 
```

## Usage

The marks `id` define how the mark is identified in the source string.
The RegExp __must__ contain three named groups and __must__ be limited, that is it has to have symbols that allows to identify the end of the corresponding mark.

* `text` generally the text to be displayed
* `id` the type (id) used to identify which mark to use
* `payload` the payload of the mark

Groups are named, therefore they can be placed in any order in the source string.

-----
The default regexp matches the marks in this form:

`${[text]type(payload)}`

It is highly recommended to deeply test the regexp in order to be sure the correct functioning
  
The algorithm does the following:

* matches the first mark and extracts its information
* copies the remaining string after the match
* repeat

Therefore be sure that the regexp matches only the strict necessary and is able to deterministically stop and the correct spot.
