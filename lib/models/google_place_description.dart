class GooglePlaceDescription {
  late String place_id;
  late String main_name;
  late String detailed_name;

  GooglePlaceDescription({
    required this.place_id,
    required this.main_name,
    required this.detailed_name,
  });

  GooglePlaceDescription.fromJson(Map<String, dynamic> json) {
    place_id = json['place_id'];
    main_name = json['main_name'];
    detailed_name = json['detailed_name'];
  }
}
