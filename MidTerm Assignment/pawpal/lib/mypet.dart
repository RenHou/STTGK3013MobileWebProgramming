class MyPet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  String? imagePaths;
  String? lat;
  String? lng;
  String? createdAt;
  
  String? name;
  String? email;
  String? phone;
  String? regDate;

  MyPet(
      {this.petId,
      this.userId,
      this.petName,
      this.petType,
      this.category,
      this.description,
      this.imagePaths,
      this.lat,
      this.lng,
      this.createdAt,
      this.name,
      this.email,
      this.phone,
      this.regDate});

  MyPet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    imagePaths = json['image_paths'];
    lat = json['lat'];
    lng = json['lng'];
    createdAt = json['created_at'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    regDate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pet_id'] = this.petId;
    data['user_id'] = this.userId;
    data['pet_name'] = this.petName;
    data['pet_type'] = this.petType;
    data['category'] = this.category;
    data['description'] = this.description;
    data['image_paths'] = this.imagePaths;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['created_at'] = this.createdAt;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['reg_date'] = this.regDate;
    return data;
  }
}