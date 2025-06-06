import 'dart:convert';

import 'package:pingmexx/utils/apiutils/api_base_helper.dart';
import 'package:pingmexx/utils/constant/string_const.dart';
import 'package:dio/dio.dart';

class ApiResponse<T> {
  ApiStatus? status;
  T? data;
  String? message;
  int? statusCode;
  T? errorData;

  // ApiResponse.withoutData({this.status,this.message,this.statusCode, this.errorData});
  ApiResponse({this.status, this.data,this.message,this.statusCode, this.errorData});

  /// loading
  static ApiResponse<T> loading<T>() {
    return ApiResponse<T>(status: ApiStatus.loading);
  }

  /// success
  static ApiResponse success<T>(int? statusCode, String? message,T data) {
    return ApiResponse<T>(status: ApiStatus.success,message: message,statusCode: statusCode, data: data);
  }

  /// error
  static ApiResponse error<T>({int? statusCode, String? message, T? errBdy, T? data}) {
    return ApiResponse<T>(
        status: ApiStatus.error,statusCode: statusCode,message: message,data: data, errorData: errBdy);
  }


  /// method wraps response in ApiResponse class
  static ApiResponse<T> handleResponse<T>({
    required Response response,
    required T Function(Map<String, dynamic> json) fromJson,
    String? customErrorMessage,
  }) {
    if (response.statusCode == ApiResponseCode.internetUnavailable) {
      return (ApiResponse.error<T>(
        statusCode: response.statusCode,
        message: StringConst.noInternetConnection,
        errBdy: fromJson({"message": StringConst.noInternetConnection}),
        data: fromJson({"message": StringConst.noInternetConnection}),
      )) as ApiResponse<T>;
    } else if (response.statusCode == ApiResponseCode.success201 ||
        response.statusCode == ApiResponseCode.success200 ||
        response.statusCode! <= ApiResponseCode.error404) {
      return (ApiResponse.success<T>(
        response.statusCode??-1,
        response.statusMessage ??"",
        response.data == null
            ? fromJson({"message": "No data received"})
            : fromJson(jsonDecode(response.toString())),
      )) as ApiResponse<T>;
    } else if (response.statusCode! >= ApiResponseCode.error400 &&
        response.statusCode! <= ApiResponseCode.error499) {
      return (ApiResponse.error<T>(
        statusCode: response.statusCode,
        message: response.statusMessage ??
            customErrorMessage ??
            StringConst.somethingWentWrong,
        errBdy: response.data??fromJson({
          "message": response.statusMessage ??
              customErrorMessage ??
              StringConst.somethingWentWrong
        }),
        data: response.data??fromJson({
          "message": response.statusMessage ??
              customErrorMessage ??
              StringConst.somethingWentWrong
        }),
      )) as ApiResponse<T>;
    } else {
      return (ApiResponse.error<T>(
        statusCode: ApiResponseCode.error500,
        message: StringConst.somethingWentWrong,
        errBdy: response.statusMessage??response.data??fromJson({"message": StringConst.somethingWentWrong, "statusCode": response.data}),
        data: response.data,
      )) as ApiResponse<T>;
    }
  }

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }

}

/// Error class to store Api Error Response
class ApiError<T> {
  int? statusCode;
  String? errorMessage;
  T? errorBody;

  ApiError({statusCode, this.errorMessage, this.errorBody});
}

/// Enum to check Api Status
enum ApiStatus { loading, success, error, noInternet }


