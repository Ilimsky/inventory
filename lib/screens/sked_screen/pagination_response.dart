class PaginationResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final int numberOfElements;

  PaginationResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.numberOfElements,
  });

  factory PaginationResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final content = json['content'] as List? ?? [];
    final pageInfo = json['pageable'] as Map<String, dynamic>? ?? {};

    return PaginationResponse<T>(
      content: content.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int? ?? 1,
      totalElements: json['totalElements'] as int? ?? content.length,
      size: pageInfo['pageSize'] as int? ?? 20,
      number: pageInfo['pageNumber'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? false,
      numberOfElements: json['numberOfElements'] as int? ?? content.length,
    );
  }
}