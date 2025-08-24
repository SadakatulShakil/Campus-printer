class DocumentResponse {
  final String? error;
  final String message;
  final List<Document> data;

  DocumentResponse({
    this.error,
    required this.message,
    required this.data,
  });

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      error: json['error'],
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((e) => Document.fromJson(e))
          .toList(),
    );
  }
}

class Document {
  final int id;
  final DateTime createdAt;
  final String file;
  final String status;

  Document({
    required this.id,
    required this.createdAt,
    required this.file,
    required this.status,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      file: json['file'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
