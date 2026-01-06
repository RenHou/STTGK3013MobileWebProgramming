class User {
  String? userId;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? regDate;
  int? walletBalanceCents;

  User({
    this.userId,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.regDate,
    this.walletBalanceCents,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    regDate = json['reg_date'];
    // Convert RM to cents: multiply by 100
    walletBalanceCents = (double.parse(json['wallet_balance'].toString()) * 100)
        .toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['phone'] = phone;
    data['reg_date'] = regDate;
    // Convert cents back to RM: divide by 100
    data['wallet_balance'] = (walletBalanceCents ?? 0) / 100;
    return data;
  }
}
