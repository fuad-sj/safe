// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_ride_broadcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedRideDetails _$SharedRideDetailsFromJson(Map<String, dynamic> json) =>
    SharedRideDetails()
      ..order_state = json['os'] as int?
      ..client_triggered_event = json['cte'] as bool?
      ..place_name = json['pn'] as String?
      ..place_id = json['pi'] as String?
      ..place_loc = FirebaseDocument.LatLngFromJson(json['plc'])
      ..initial_loc = FirebaseDocument.LatLngFromJson(json['il'])
      ..created_timestamp = json['cts'] as int?
      ..trip_started_timestamp = json['tsts'] as int?
      ..driver_name = json['dn'] as String?
      ..driver_phone = json['dp'] as String?
      ..car_plate = json['cp'] as String?
      ..car_details = json['cd'] as String?
      ..is_six_seater = json['iss'] as bool?
      ..est_price = FirebaseDocument.DoubleFromJson(json['ep'])
      ..distance_km = FirebaseDocument.DoubleFromJson(json['dk'])
      ..duration_minutes = FirebaseDocument.DoubleFromJson(json['dm'])
      ..is_forcefully_filled = json['iff'] as bool?
      ..num_forceful_filled = json['nff'] as int?
      ..seats_remaining = json['sr'] as int?
      ..reached_out_customers =
          SharedRideReachOutCustomer.List_FromJson(json['roc'])
      ..vetted_reachout_customers =
          SharedRideVettedReachoutCustomer.List_FromJson(json['vrc'])
      ..accepted_customers =
          SharedRideAcceptedCustomer.List_FromJson(json['ac'])
      ..separate_dropoffs = SharedRideSeparateDropoff.List_FromJson(json['sd']);

Map<String, dynamic> _$SharedRideDetailsToJson(SharedRideDetails instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('os', instance.order_state);
  writeNotNull('cte', instance.client_triggered_event);
  writeNotNull('pn', instance.place_name);
  writeNotNull('pi', instance.place_id);
  writeNotNull('plc', FirebaseDocument.LatLngToJson(instance.place_loc));
  writeNotNull('il', FirebaseDocument.LatLngToJson(instance.initial_loc));
  writeNotNull('cts', instance.created_timestamp);
  writeNotNull('tsts', instance.trip_started_timestamp);
  writeNotNull('dn', instance.driver_name);
  writeNotNull('dp', instance.driver_phone);
  writeNotNull('cp', instance.car_plate);
  writeNotNull('cd', instance.car_details);
  writeNotNull('iss', instance.is_six_seater);
  writeNotNull('ep', instance.est_price);
  writeNotNull('dk', instance.distance_km);
  writeNotNull('dm', instance.duration_minutes);
  writeNotNull('iff', instance.is_forcefully_filled);
  writeNotNull('nff', instance.num_forceful_filled);
  writeNotNull('sr', instance.seats_remaining);
  writeNotNull('roc',
      SharedRideReachOutCustomer.List_ToJson(instance.reached_out_customers));
  writeNotNull(
      'vrc',
      SharedRideVettedReachoutCustomer.List_ToJson(
          instance.vetted_reachout_customers));
  writeNotNull('ac',
      SharedRideAcceptedCustomer.List_ToJson(instance.accepted_customers));
  writeNotNull(
      'sd', SharedRideSeparateDropoff.List_ToJson(instance.separate_dropoffs));
  return val;
}

SharedRideReachOutCustomer _$SharedRideReachOutCustomerFromJson(
        Map<String, dynamic> json) =>
    SharedRideReachOutCustomer()
      ..customer_phone = json['cp'] as String
      ..customer_id = json['ci'] as String
      ..reachout_timestamp = json['rt'] as int?;

Map<String, dynamic> _$SharedRideReachOutCustomerToJson(
        SharedRideReachOutCustomer instance) =>
    <String, dynamic>{
      'cp': instance.customer_phone,
      'ci': instance.customer_id,
      'rt': _ServerTimeStampFiller(instance.reachout_timestamp),
    };

SharedRideVettedReachoutCustomer _$SharedRideVettedReachoutCustomerFromJson(
        Map<String, dynamic> json) =>
    SharedRideVettedReachoutCustomer()
      ..customer_phone = json['cp'] as String
      ..customer_id = json['ci'] as String
      ..reachout_timestamp = json['rt'] as int?;

Map<String, dynamic> _$SharedRideVettedReachoutCustomerToJson(
        SharedRideVettedReachoutCustomer instance) =>
    <String, dynamic>{
      'cp': instance.customer_phone,
      'ci': instance.customer_id,
      'rt': _ServerTimeStampFiller(instance.reachout_timestamp),
    };

SharedRideAcceptedCustomer _$SharedRideAcceptedCustomerFromJson(
        Map<String, dynamic> json) =>
    SharedRideAcceptedCustomer()
      ..customer_phone = json['cp'] as String
      ..customer_id = json['ci'] as String
      ..accepted_timestamp = json['at'] as int?
      ..num_customers = json['nc'] as int;

Map<String, dynamic> _$SharedRideAcceptedCustomerToJson(
        SharedRideAcceptedCustomer instance) =>
    <String, dynamic>{
      'cp': instance.customer_phone,
      'ci': instance.customer_id,
      'at': _ServerTimeStampFiller(instance.accepted_timestamp),
      'nc': instance.num_customers,
    };

SharedRideSeparateDropoff _$SharedRideSeparateDropoffFromJson(
        Map<String, dynamic> json) =>
    SharedRideSeparateDropoff()
      ..customer_phone = json['cp'] as String
      ..customer_id = json['ci'] as String
      ..num_customers = json['nc'] as int
      ..dropoff_loc = (json['dl'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();

Map<String, dynamic> _$SharedRideSeparateDropoffToJson(
        SharedRideSeparateDropoff instance) =>
    <String, dynamic>{
      'cp': instance.customer_phone,
      'ci': instance.customer_id,
      'nc': instance.num_customers,
      'dl': instance.dropoff_loc,
    };

SharedRideDropoffPrice _$SharedRideDropoffPriceFromJson(
        Map<String, dynamic> json) =>
    SharedRideDropoffPrice()
      ..customer_phone = json['cp'] as String
      ..customer_id = json['ci'] as String
      ..num_customers = json['nc'] as int
      ..travelled_km = (json['tk'] as num).toDouble()
      ..travelled_time = (json['tt'] as num).toDouble()
      ..each_price = (json['ep'] as num).toDouble()
      ..total_price = (json['tp'] as num).toDouble()
      ..dropoff_timestamp = json['dt'] as int?;

Map<String, dynamic> _$SharedRideDropoffPriceToJson(
        SharedRideDropoffPrice instance) =>
    <String, dynamic>{
      'cp': instance.customer_phone,
      'ci': instance.customer_id,
      'nc': instance.num_customers,
      'tk': instance.travelled_km,
      'tt': instance.travelled_time,
      'ep': instance.each_price,
      'tp': instance.total_price,
      'dt': _ServerTimeStampFiller(instance.dropoff_timestamp),
    };
