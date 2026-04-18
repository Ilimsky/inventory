class PaginationResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final int numberOfElements;
  final List<T>? availableNumbers; // Новое поле для доступных номеров

  PaginationResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.numberOfElements,
    this.availableNumbers, // Новый параметр
  });

  factory PaginationResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final content = json['content'] as List? ?? [];
    final pageInfo = json['pageable'] as Map<String, dynamic>? ?? {};

    // Обработка доступных номеров, если они есть в ответе
    List<T>? availableNumbers;
    if (json['availableNumbers'] != null) {
      availableNumbers = (json['availableNumbers'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PaginationResponse<T>(
      content: content.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: json['totalPages'] as int? ?? 1,
      totalElements: json['totalElements'] as int? ?? content.length,
      size: pageInfo['pageSize'] as int? ?? 20,
      number: pageInfo['pageNumber'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? false,
      numberOfElements: json['numberOfElements'] as int? ?? content.length,
      availableNumbers: availableNumbers,
    );
  }

  // Новый метод для создания ответа со списком доступных номеров
  factory PaginationResponse.withAvailableNumbers({
    required List<T> content,
    required List<T> availableNumbers,
    int totalPages = 1,
    int totalElements = 0,
    int size = 20,
    int number = 0,
    bool first = true,
    bool last = false,
    int numberOfElements = 0,
  }) {
    return PaginationResponse<T>(
      content: content,
      totalPages: totalPages,
      totalElements: totalElements,
      size: size,
      number: number,
      first: first,
      last: last,
      numberOfElements: numberOfElements,
      availableNumbers: availableNumbers,
    );
  }
}