import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sampan/data/service/utils.dart';

/// Result of referral code validation.
class ValidateReferralResult {
  final bool valid;
  final int? referrerId;

  const ValidateReferralResult({required this.valid, this.referrerId});

  static ValidateReferralResult fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ValidateReferralResult(valid: false);
    final valid = json['valid'] == true;
    final referrerId = json['referrerId'];
    return ValidateReferralResult(
      valid: valid,
      referrerId: referrerId is int ? referrerId : (referrerId is num ? referrerId.toInt() : null),
    );
  }
}

/// Result of CleanCloud addCustomer.
class AddCustomerResult {
  final bool success;
  final String? customerId;
  final String? errorMessage;

  const AddCustomerResult({
    required this.success,
    this.customerId,
    this.errorMessage,
  });

  static AddCustomerResult fromResponse(Map<String, dynamic>? body) {
    if (body == null) return const AddCustomerResult(success: false, errorMessage: 'No response');
    final success = body['Success'] == 'True' || body['Success'] == true;
    final customerId = (body['CustomerID'] ?? body['cid'])?.toString().trim();
    final errorMessage = body['Error']?.toString() ?? body['error']?.toString();
    return AddCustomerResult(
      success: success,
      customerId: customerId?.isNotEmpty == true ? customerId : null,
      errorMessage: errorMessage,
    );
  }
}

/// API logic for auth: referral validation, CleanCloud addCustomer, referral apply.
class AuthService {
  AuthService() : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  final Dio _dio;

  /// POST /validate-referral-code. Returns valid + referrerId.
  Future<ValidateReferralResult> validateReferralCode(String referralCode) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        AuthEndpoints.validateReferralCode,
        data: {'referralCode': referralCode.trim()},
      );
      final body = res.data;
      debugPrint('[AuthService] validateReferralCode response: $body');
      return ValidateReferralResult.fromJson(body);
    } on DioException catch (e) {
      debugPrint('[AuthService] validateReferralCode error: ${e.message}');
      if (e.response?.data is Map) {
        return ValidateReferralResult.fromJson(Map<String, dynamic>.from(e.response!.data as Map));
      }
      return const ValidateReferralResult(valid: false);
    } catch (e) {
      debugPrint('[AuthService] validateReferralCode exception: $e');
      return const ValidateReferralResult(valid: false);
    }
  }

  /// POST CleanCloud addCustomer. Optional [promoCode]; omit from body when null.
  Future<AddCustomerResult> addCustomer({
    required String customerName,
    required String customerTel,
    required String customerEmail,
    required String customerPassword,
    required String customerAddress,
    String? promoCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'api_token': ApiConfig.apiToken,
        'customerName': customerName,
        'customerTel': customerTel,
        'customerEmail': customerEmail,
        'customerPassword': customerPassword,
        'customerAddress': customerAddress,
        'customerNotes': 'New customer registration from Sampan app',
      };
      if (promoCode != null && promoCode.trim().isNotEmpty) {
        body['promoCode'] = promoCode.trim();
      }
      final res = await _dio.post<Map<String, dynamic>>(
        Urls.accountCreate,
        data: body,
      );
      final data = res.data;
      final ok = res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;
      debugPrint('[AuthService] addCustomer status=${res.statusCode} body=$data');
      return AddCustomerResult.fromResponse(ok ? data : null);
    } on DioException catch (e) {
      final body = e.response?.data;
      Map<String, dynamic>? map;
      if (body is Map) {
        map = Map<String, dynamic>.from(body);
      } else if (body != null) {
        try {
          map = jsonDecode(body is String ? body : body.toString()) as Map<String, dynamic>?;
        } catch (_) {}
      }
      final result = map != null ? AddCustomerResult.fromResponse(map) : null;
      debugPrint('[AuthService] addCustomer error: ${e.message}');
      return result ?? AddCustomerResult(success: false, errorMessage: e.message ?? 'Request failed');
    } catch (e) {
      debugPrint('[AuthService] addCustomer exception: $e');
      return AddCustomerResult(success: false, errorMessage: e.toString());
    }
  }

  /// POST /referral/apply — record referral and give referrer reward.
  Future<bool> applyReferral({required String newCustomerId, required String referralCode}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        AuthEndpoints.applyReferral,
        data: {
          'newCustomerId': newCustomerId,
          'referralCode': referralCode.trim(),
        },
      );
      final ok = res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;
      debugPrint('[AuthService] applyReferral status=${res.statusCode}');
      return ok;
    } on DioException catch (e) {
      debugPrint('[AuthService] applyReferral error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[AuthService] applyReferral exception: $e');
      return false;
    }
  }
}
