// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralPaymentRequest _$ReferralPaymentRequestFromJson(
        Map<String, dynamic> json) =>
    ReferralPaymentRequest()
      ..client_triggered_event = json['client_triggered_event'] as bool?
      ..request_status = json['request_status'] as int?
      ..error_code = json['error_code'] as int?
      ..error_msg = json['error_msg'] as String?
      ..request_type = json['request_type'] as int?
      ..payment_amount = FirebaseDocument.DoubleFromJson(json['payment_amount'])
      ..requester_id = json['requester_id'] as String?
      ..requester_name = json['requester_name'] as String?
      ..requester_phone = json['requester_phone'] as String?
      ..send_to_id = json['send_to_id'] as String?
      ..send_to_name = json['send_to_name'] as String?
      ..send_to_phone = json['send_to_phone'] as String?
      ..ref_transaction_id = json['ref_transaction_id'] as String?
      ..requested_time =
          FirebaseDocument.DateTimeFromJson(json['requested_time']);

Map<String, dynamic> _$ReferralPaymentRequestToJson(
        ReferralPaymentRequest instance) =>
    <String, dynamic>{
      'client_triggered_event': instance.client_triggered_event,
      'request_status': instance.request_status,
      'error_code': instance.error_code,
      'error_msg': instance.error_msg,
      'request_type': instance.request_type,
      'payment_amount': instance.payment_amount,
      'requester_id': instance.requester_id,
      'requester_name': instance.requester_name,
      'requester_phone': instance.requester_phone,
      'send_to_id': instance.send_to_id,
      'send_to_name': instance.send_to_name,
      'send_to_phone': instance.send_to_phone,
      'ref_transaction_id': instance.ref_transaction_id,
      'requested_time':
          FirebaseDocument.DateTimeToJson(instance.requested_time),
    };
