class Donation {
  String? donationId;
  String? userId;
  String? userName;
  String? petId;
  String? petName;
  String? donationType;
  int? donationAmountCents;
  String? donationDescription;
  String? donationDate;

  Donation({
    this.donationId,
    this.userId,
    this.userName,
    this.petId,
    this.petName,
    this.donationType,
    this.donationAmountCents,
    this.donationDescription,
    this.donationDate,
  });

  Donation.fromJson(Map<String, dynamic> json) {
    donationId = json['donation_id'];
    userId = json['user_id'];
    userName = json['name'];
    petId = json['pet_id'];
    petName = json['pet_name'];
    donationType = json['donation_type'];
    // Convert RM to cents: multiply by 100
    donationAmountCents = (double.parse(json['amount'].toString()) * 100)
        .toInt();
    donationDescription = json['donation_description'];
    donationDate = json['donation_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = userName;
    data['pet_id'] = petId;
    data['pet_name'] = petName;
    data['donation_type'] = donationType;
    data['amount'] = (donationAmountCents ?? 0) / 100;
    data['donation_description'] = donationDescription;
    data['donation_date'] = donationDate;
    // Convert cents back to RM: divide by 100
    return data;
  }
}
