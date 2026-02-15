class PiiScrubber {
  // Regex patterns for PII
  static final RegExp _emailRegex = RegExp(
    r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b',
    caseSensitive: false,
  );

  static final RegExp _phoneRegex = RegExp(
    r'\b(\+\d{1,2}\s?)?(\(\d{3}\)|\d{3})[\s.-]?\d{3}[\s.-]?\d{4}\b',
  );

  static final RegExp _ssnRegex = RegExp(
    r'\b\d{3}-\d{2}-\d{4}\b',
  );

  /// Scans the input text and replaces PII with [REDACTED].
  /// Returns the scrubbed text.
  String scrub(String text) {
    String scrubbedText = text;

    // Redact Emails
    scrubbedText = scrubbedText.replaceAll(_emailRegex, '[REDACTED EMAIL]');

    // Redact Phone Numbers
    scrubbedText = scrubbedText.replaceAll(_phoneRegex, '[REDACTED PHONE]');

    // Redact SSNs
    scrubbedText = scrubbedText.replaceAll(_ssnRegex, '[REDACTED SSN]');

    return scrubbedText;
  }

  /// Checks if the text contains any PII.
  bool containsPii(String text) {
    return _emailRegex.hasMatch(text) ||
        _phoneRegex.hasMatch(text) ||
        _ssnRegex.hasMatch(text);
  }
}
