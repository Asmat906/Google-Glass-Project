class Client {
  String name = "";
  String email = "";
  String address = "";
  String phone = "";

  Client(this.name, this.email, this.address, this.phone);

  static Client createFromJson(dynamic clientJson) {
    return Client(
      clientJson['name'],
      clientJson['email'],
      clientJson['address'],
      clientJson['phone'],
    );
  }
}
