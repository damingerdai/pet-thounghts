class CommonReponse {
  String message;

  CommonReponse({ required this.message});
  
  factory CommonReponse.fromJson(Map<String, dynamic> json) {
    return CommonReponse(
      message: json['message'],
    );
  }
}