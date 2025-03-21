class BaseResponse {
  final bool success;
  final dynamic data;
  final String? message;

  BaseResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['message'] != null,
      data: json['data'] ?? json,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
    };
  }

  T? getDataAs<T>() {
    return data as T?;
  }
}
