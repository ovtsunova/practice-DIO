import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final String Function() tokenProvider;

  AuthInterceptor(this.tokenProvider);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = tokenProvider().trim();

    if (token.isNotEmpty) {
      options.headers['X-Api-Key'] = token;
    }

    handler.next(options);
  }
}