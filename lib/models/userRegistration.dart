
class UserRegistration {
  String? firstname;
  String? lastname;
  String? email;
  String? password;
  String phone = "";
  String phonePrefix = "+33";
  bool?   acceptNewsletter;
  UserRegistration({this.firstname, this.lastname, this.email, password});


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['phonePrefix'] = this.phonePrefix;
    data['acceptNewsletter'] = this.acceptNewsletter;
    return data;
  }

  setUserRegistrationVlue(type, value) {
    if(type == 'firstname') {
      this.firstname = value;
    } else if(type == 'lastname') {
      this.lastname = value;
    } else if(type == 'email') {
      this.email = value.trim();
    } else if(type == 'password') {
      this.password = value.trim();
    }
  }
}