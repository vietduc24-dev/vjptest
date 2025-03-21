class ObjectMapper {
  ObjectMapper._();

  static final ObjectMapper instance = ObjectMapper._();

  List<Map<String, dynamic>> mapArray(data) {
    final List<Map> listDecode = List<Map<String, dynamic>>.from(data);
    return listDecode as List<Map<String, dynamic>>;
  }

  Map<String, dynamic> mapObject(data) {
    final Map decode = Map<String, dynamic>.from(data);
    return decode as Map<String, dynamic>;
  }
}