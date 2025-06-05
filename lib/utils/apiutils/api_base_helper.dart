import 'dart:async';

import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/constant/api_constant.dart';
import 'package:pingmexx/utils/constant/string_const.dart';
import 'package:dio/dio.dart';

class ApiBaseHelper {
  late Dio _dio;

  ApiBaseHelper() {
    BaseOptions options = BaseOptions(
        receiveTimeout: const Duration(seconds: ApiConstant.timeOut),
        connectTimeout: const Duration(seconds: ApiConstant.timeOut));
    if (ApiConstant.isDebug) {
      options.baseUrl = ApiConstant.qaBaseUrl;
    } else {
      options.baseUrl = ApiConstant.baseUrl;
    }
    _dio = Dio(options);
    _dio.options.headers["Accept"] = "application/json";
    _dio.options.headers["Authorization"] =
        "Bearer ${ApiConstant.ACCESS_TOKEN}";
    // _dio.interceptors.add(AppInterceptors(_dio));
    _dio.interceptors.add(LogInterceptor(
        responseBody: true,
        request: true,
        requestBody: true,
        requestHeader: true));
  }

  Future<Response<dynamic>> get(
      {String url = '', Map<String, dynamic>? params}) async {
    if (!await checkInternetConnection()) {
      return Response(
          requestOptions: RequestOptions(path: url),
          statusCode: ApiResponseCode.internetUnavailable,
          statusMessage: StringConst.noInternetConnection);
    }
    params = removeNullKeyValue(params);
    return await _dio.get(url,
        queryParameters: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType));
  }

  Future<Response<dynamic>> getAnyResponse(
      {String url = '', Map<String, dynamic>? params}) async {
    if (!await checkInternetConnection()) {
      return Response(
          requestOptions: RequestOptions(path: url),
          statusCode: ApiResponseCode.internetUnavailable,
          statusMessage: StringConst.noInternetConnection);
    }
    params = removeNullKeyValue(params);
    return await _dio.get(url,
        queryParameters: params,
        options: Options(responseType: ResponseType.json));
  }

  Future<Response<dynamic>> getWithParam(
      {String endpoint = '', Map<String, dynamic>? params}) async {
    try {
      if (!await checkInternetConnection()) {
        return Response(
            requestOptions: RequestOptions(path: endpoint),
            statusCode: ApiResponseCode.internetUnavailable,
            statusMessage: StringConst.noInternetConnection);
      }
      params = removeNullKeyValue(params);
      return await _dio.get(endpoint,
          queryParameters: params,
          options: Options(
              responseType: ResponseType.json,
              contentType: Headers.jsonContentType));
    } catch (e) {
      return Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 999,
          statusMessage: e.toString());
    }
  }

  Map<String, dynamic>? removeNullKeyValue(Map<String, dynamic>? map) {
    map?.removeWhere((key, value) {
      if (value is Map) {
        removeNullKeyValue(value.cast<String, dynamic>());
      }
      if (value is List) {
        return value.isEmpty;
      }
      return value == null || (value is String && value.isEmpty);
    });
    return map;
  }

  Future<Response> post({String url = '', dynamic params}) async {
    if (!await checkInternetConnection()) {
      return Response(
          requestOptions: RequestOptions(path: url),
          statusCode: ApiResponseCode.internetUnavailable,
          statusMessage: StringConst.noInternetConnection);
    }
    params = removeNullKeyValue(params);
    return await _dio.post(url,
        data: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType));
  }

  Future<Response> put({String url = '', dynamic params}) async {
    if (!await checkInternetConnection()) {
      return Response(
          requestOptions: RequestOptions(path: url),
          statusCode: ApiResponseCode.internetUnavailable,
          statusMessage: StringConst.noInternetConnection);
    }
    params = removeNullKeyValue(params);
    return await _dio.put(url,
        data: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType));
  }

  Future<Response> delete({String url = '', dynamic params}) async {
    if (!await checkInternetConnection()) {
      return Response(
          requestOptions: RequestOptions(path: url),
          statusCode: ApiResponseCode.internetUnavailable,
          statusMessage: StringConst.noInternetConnection);
    }
    params = removeNullKeyValue(params);
    return await _dio.delete(url,
        data: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType));
  }
}

class ApiResponseCode {
  static const int success200 = 200;
  static const int success201 = 201;
  static const int error400 = 400;
  static const int error499 = 499;
  static const int error401 = 401;
  static const int error404 = 404;
  static const int error500 = 500;
  static const int internetUnavailable = 999;
  static const int unknown = 533;
}

///Single final Object of ApiBaseHelper
final apiHelper = ApiBaseHelper();
