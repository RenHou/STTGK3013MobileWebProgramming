class User {
  String? userId;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? regDate;

  User(
      {this.userId,
      this.name,
      this.email,
      this.password,
      this.phone,
      this.regDate});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    regDate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['phone'] = phone;
    data['reg_date'] = regDate;
    return data;
  }
}