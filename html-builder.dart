String _escapeAttribute(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
}

String _escapeContent(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
}

typedef TagBuilder = String Function([dynamic content]);
typedef TagBuilderWithAttrs = TagBuilder Function([Map<String, String> attributes]);

TagBuilderWithAttrs _createTag(String tagName, {bool selfClosing = false}) {
    return ([Map<String, String> attributes = const {}]) {
        return ([dynamic content]) {
            // Build attributes string
            final attrs = attributes.entries
                .map((e) => ' ${_escapeAttribute(e.key)}="${_escapeAttribute(e.value)}"')
                .join();

            // Handle self-closing tags
            if (selfClosing) return '<$tagName$attrs />';

            // Handle regular tags with content
            final body = content != null ? content.toString() : '';
            return '<$tagName$attrs>$body</$tagName>';
        };
    };
}

// Top-level functions that don't escape content (to allow HTML tags)
String html(dynamic content) => '<!DOCTYPE html><html>$content</html>';
String head(dynamic content) => '<head>$content</head>';
String body(dynamic content) => '<body>$content</body>';

// Content-bearing tags that need escaping
String title(dynamic content) => '<title>${_escapeContent(content.toString())}</title>';
String script(dynamic content) => '<script>${content is String ? _escapeContent(content) : content}</script>';
String style(dynamic content) => '<style>${content is String ? _escapeContent(content) : content}</style>';

// Regular tags
final h1 = _createTag('h1');
final h2 = _createTag('h2');
final h3 = _createTag('h3');
final div = _createTag('div');
final p = _createTag('p');
final span = _createTag('span');
final a = _createTag('a');
final button = _createTag('button');

// Self-closing tags
final img = _createTag('img', selfClosing: true);
final input = _createTag('input', selfClosing: true);
final br = _createTag('br', selfClosing: true);
final hr = _createTag('hr', selfClosing: true);
final link = _createTag('link', selfClosing: true);
final meta = _createTag('meta', selfClosing: true);