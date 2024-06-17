import 'package:flutter/foundation.dart';

class ApiConstant {
  static const String qaBaseUrl = 'https://ezeerides.piousindia.com/';
  static const String baseUrl = 'https://backend.ezeerides.com/';
  static const String noInternetConnection = "No Internet Connection";
  static String demoImg =
      'https://avatars0.githubusercontent.com/u/38448422?s=460&u=21b610183d275611a9bc0f730653d931b39f2d0b&v=4';
  static const int timeOut = 5000;
  static const bool isDebug = kDebugMode;

  static String known = 'Known';
  static String whatsappUrl =
      'https://api.whatsapp.com/send?phone=+91';
  static String playstoreUrl =
      'https://play.google.com/store/apps/details?id=com.microprixs.ezeerides';
  static String appstoreJUrl =
      'https://apps.apple.com/sg/app/ezee-rides/id1611175779';

//  const API_KEY = 'bc5e897b0a20a7b102f692c7fecaf961';
//  final String apiKey = "8a1227b5735a7322c4a43a461953d4ff";

  // static var IMAGE_ORIG_POSTER = 'https://image.tmdb.org/t/p/original';
  // static var IMAGE_POSTER = 'https://image.tmdb.org/t/p/w185';

  // static var IMAGE_POSTER_300 = 'https://image.tmdb.org/t/p/w300';

  static var language = 'en-US';
  static var GRANT_TYPE = "password";
  static var USER_NAME = "";
  static var PASSWORD = "";
  static var DOMAIN = "";
  static var CLIENT_ID = "1_3bcbxd9e24g0gk4swg0kwgcwg4o8k8g4g888kwc44gcc0gwwk4";
  static var CLIENT_SECRET =
      "4ok2x70rlfokc8g0wws8c8kwcokw80k44sg48goc0ok4w0so0k";

  static var ACCESS_TOKEN = "";
  static var USER_INFO;
  static var customerLogin = "api/customer-login";

  static var PICK_N_DROP_REQUEST = 'api/pickup-drop-request';
  static var ACCESSORIES_AMT_CALCULATE = 'api/return_vehicle_accessories_total_amount';

  static var VEHICLE_RIDES = 'api/vehicle-rides';
  static var VEHICLE_MODEL_CENTER = 'api/vehicle-model-center';

  static var CHECK_CUSTOMER_AADHAR = 'api/check-customer-aadhar';
  static var AADHAR_VERIFIED_CONFIRMATION = 'api/verify-aadhar';
  static var AADHAR_DIGIO_KYC_REGISTER = 'api/digio_kyc_register';
  static var AADHAR_DIGIO_DOC_VERIFY = 'api/digio_doc_verify';

  static var NOTIFICATION_LIST = 'api/notification-list';
  static var BOOKING_LIST = 'api/booking-list';
  static var BOOKING_DETAIL = 'api/booking-detail';
  static var ADD_MONEY = 'api/add-money';
  static var CONFIRM_WALLET_PAYMENT = 'api/confirm-wallet-payment';
  static var WALLET_AMOUNT = 'api/wallet-amount';
  static var WALLET_HISTORY = 'api/wallet-history';
  static var NEED_HELP = 'api/need-help';
  static var CREATE_TICKET = 'api/create-ticket';
  static var TICKET_HISTORY = 'api/ticket-history';

  static var TOKEN = "/oauth/v2/token";

  static var DETAILS = 'api/details';
  static var GET_LOCATION = 'api/location';
  static var CURRENT_STATUS = 'api/currentstatus';
  static var SHIFT_AVAILABLE = 'api/available';
  static var TODAY_SHIFTS = 'api/shifts';
  static var GET_PHOTOS = 'api/photo';

  static var HOME_NOTIFICATION_LIST = 'api/home-notification-list';

  static var CANCEL_BOOKING = 'api/cancel-booking';

  static var EXPAND_DROP = 'api/expand-drop';
  static var MAKE_EXPAND_PAYMENT = 'api/make-expand-payment';
  static var CONFIRM_EXPAND_PAYMENT = 'api/confirm-expand-payment';

  static var MAKE_PENALTY_PAYMENT = 'api/make-penalty-payment';
  static var CONFIRM_PENALTY_PAYMENT = 'api/confirm-penalty-payment';

  static var MAKE_SMS_BOOKING_PAYMENT = 'api/make-smsbooking-payment';
  static var CONFIRM_SMS_BOOKING_PAYMENT = 'api/confirm-smsbooking-payment';

  static var MAKE_ACCESSORIES_PAYMENT = 'api/make-accessory-payment';
  static var CONFIRM_ACCESSORIES_BOOKING_PAYMENT = 'api/confirm-accessory-payment';

  static var UPGRADE_VEHICLE_FILTER = 'api/upgrade-vehicle-filter';
  static var UPGRADE_BIKE = 'api/upgrade-bike';
  static var MAKE_PAYMENT_UPGRADE_BIKE = 'api/make-payment-upgrade-bike';
  static var CONFIRM_UPGRADE_BIKE_PAYMENT = 'api/confirm-upgrade-bike-payment';
}
