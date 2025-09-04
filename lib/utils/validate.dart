extension Validator on String {
  bool validateEmail() {
    const String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(this);
  }

  bool validatePassword() {
    const String pattern = r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,10}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(this);
  }
}
