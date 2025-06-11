import 'package:get/get.dart';

class ValidationHelper {

  static String? empty(String value, String msg) {
    if (value.isEmpty) {
      return msg;
    }
    return null;
  }
  
  static String? validateName(String? value) {
    String pattern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = RegExp(pattern);
    if (value?.trim().isBlank == true) {
      return "Name is Required";
    } else if (value!.trim().length < 2) {
      return "Name must be at least 2 characters";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return null;
  }

  static String? validateMobile(String? value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value?.trim().isBlank == true) {
      return "Mobile is Required";
    } else if (value!.length < 9 || value.length != 10) {
      return "Mobile number must 10 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Mobile Number must be digits";
    }
    return null;
  }
  
  static String? validateZipCode(String? value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value?.trim().isBlank == true) {
      return "ZipCode is Required";
    } else if (value!.length != 6) {
      return "ZipCode must 6 digits";
    } else if (!regExp.hasMatch(value)) {
      return "ZipCode must be digits";
    }
    return null;
  }

  static String? validateAadhar(String? value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value?.trim().isBlank == true) {
      return "Aadhar Number is Required";
    } else if (value!.length != 12) {
      return "Aadhar number must 12 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Aadhar number must be digits";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value?.trim().isBlank == true) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value!)) {
      return "Invalid Email";
    }
    return null;
  }
  
  static String? validateSimplePassword(String? value) {
    if (value?.trim().isBlank == true) {
      return "Password is required";
    } else if (value!.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }
  
  static String? validateNormalPass(String? value) {
    if (value?.trim().isBlank == true) {
      return "Password is Required";
    } else if (value!.length < 7) {
      return "Password must grater then 7 digits";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    RegExp upperCasePatten = RegExp("[A-Z]");
    RegExp lowerCasePatten = RegExp("[a-z]");
    RegExp digitCasePatten = RegExp("[0-9]");
    RegExp specialCasePatten = RegExp("[!@#\$&*~]");
    if (value?.trim().isBlank == true) {
      return "Password is Required";
    } else if (!upperCasePatten.hasMatch(value!)) {
      return 'Password must have atleast one uppercase character';
    } else if (!lowerCasePatten.hasMatch(value)) {
      return 'Password must have atleast one lowercase character';
    } else if (!digitCasePatten.hasMatch(value)) {
      return 'Password must have atleast one digit character';
    } else if (!specialCasePatten.hasMatch(value)) {
      return 'Password must have atleast one special character';
    } else if (value.length < 8) {
      return "Password must grater then 8 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Password";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value?.trim().isBlank == true) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateOtpAadhar(String? value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value?.trim().isBlank == true) {
      return "OTP is Required";
    } else if (value!.length != 6) {
      return "OTP must 6 digits";
    } else if (!regExp.hasMatch(value)) {
      return "OTP must be digits";
    }
    return null;
  }
  
  static String? validateOtp(String? value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value?.trim().isBlank == true) {
      return "OTP is Required";
    } else if (value!.length != 5) {
      return "OTP must 5 digits";
    } else if (!regExp.hasMatch(value)) {
      return "OTP must be digits";
    }
    return null;
  }
  
  static String? validateDob(String? value) {
    if (value?.trim().isBlank == true) {
      return "DOB is Required";
    }
    return null;
  }

  static String? validateGender(String? value) {
    if (value?.trim().isBlank == true) {
      return "Gender is required";
    }
    return null;
  }
}
