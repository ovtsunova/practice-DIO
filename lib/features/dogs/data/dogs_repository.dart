import 'package:dio/dio.dart';

import 'dog_breed.dart';

class DogsRepository {
  final Dio _dio;

  DogsRepository(this._dio);

  Future<List<DogBreed>> searchDogs(
    DogSearchParams params, {
    required int offset,
  }) async {
    final response = await _dio.get(
      '/dogs',
      queryParameters: params.toQuery(offset: offset),
    );

    final data = response.data;

    if (data is! List) {
      throw Exception('Некорректный формат ответа API');
    }

    return data
        .map((item) => DogBreed.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}