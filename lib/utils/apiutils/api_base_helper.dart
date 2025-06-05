import 'dart:async';

import 'package:medibot/utils/constant/api_constant.dart';
import 'package:medibot/utils/constant/string_const.dart';
import 'package:dio/dio.dart';

class ApiBaseHelper {
  late Dio _dio;

  ApiBaseHelper() {
    BaseOptions options = BaseOptions(
        receiveTimeout: const Duration(seconds: ApiConstant.timeOut),
        connectTimeout: const Duration(seconds: ApiConstant.timeOut));
    if(ApiConstant.isDebug) {
      options.baseUrl = ApiConstant.qaBaseUrl;
    } else {
      options.baseUrl = ApiConstant.baseUrl;
    }
    _dio = Dio(options);
    _dio.options.headers["Accept"] = "application/json";
    _dio.options.headers["Authorization"] =
        "Bearer ${ApiConstant.ACCESS_TOKEN}";
    // _dio.interceptors.add(AppInterceptors(_dio));
    _dio.interceptors.add(LogInterceptor(responseBody: true,request: true, requestBody: true,requestHeader: true));
  }

  Future<Response<dynamic>> get(
      {String url = '', Map<String, dynamic>? params}) async {
    params = removeNullKeyValue(params);
    Response response = await _dio.get(url,
        queryParameters: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType,
            validateStatus: (status) {
              return status! < 500;
            }));
    return response;
  }

  Future<Response<dynamic>> getAnyResponse(
      {String url = '', Map<String, dynamic>? params}) async {
    params = removeNullKeyValue(params);
    Response response = await _dio.get(url,
        queryParameters: params,
        options: Options(
            responseType: ResponseType.json,
            validateStatus: (status) {
              return status! < 500;
            }));
    return response;
  }

  Future<Response<dynamic>> getWithParam(
      {String endpoint = '', Map<String, dynamic>? params}) async {
    Response response;
    params = removeNullKeyValue(params);
    try {
      response = await _dio.get(endpoint,
          queryParameters: params,
          options: Options(
              responseType: ResponseType.json,
              contentType: Headers.jsonContentType,
              validateStatus: (status) {
                return status! < 500;
              }));
    } on Exception catch (_) {
      response = Response(requestOptions: RequestOptions(path: 'path'));
      response.statusCode = ApiResponseCode.internetUnavailable;
      response.statusMessage = StringConst.noInternetConnection;
    } catch (e) {
      response = Response(requestOptions: RequestOptions(path: 'path'));
      response.statusCode = ApiResponseCode.unknown;
      response.statusMessage = "$e ${StringConst.somethingWentWrong}";
    }
    return response;
  }
  Map<String, dynamic>? removeNullKeyValue(Map<String, dynamic>? map) {
    map?.removeWhere((key, value) {
      if (value is Map) {
        removeNullKeyValue(value.cast<String, dynamic>()); // Ensure the nested map is also of type Map<String, dynamic>
      }
      if (value is List) {
        return value.isEmpty;
      }
      return value == null || (value is String && value.isEmpty);
    });

    return map;
  }

  Future<Response> post({String url = '', params}) async {
    params = removeNullKeyValue(params);
    var response = await _dio.post(url,
        data: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType,
            validateStatus: (status) {
              return status! < 500;
            }));

    return response;
  }

  Future<Response> put({String url = '', params}) async {
    params = removeNullKeyValue(params);
    var response = await _dio.put(url,
        data: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType,
            validateStatus: (status) {
              return status! < 500;
            }));
    return response;
  }

  Future<Response> delete({String url = '', params}) async {
    params = removeNullKeyValue(params);
    var response = await _dio.delete(url,
        data: params,
        options: Options(
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType,
            validateStatus: (status) {
              return status! < 500;
            }));
    return response;
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
