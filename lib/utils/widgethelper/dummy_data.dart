import 'dart:ui';

final List<String> availableFonts = [
  'Roboto',
  'Lato',
  'Open Sans',
  'Montserrat',
  'Poppins',
  'Raleway',
  'Playfair Display'
];

enum LogoStyle {
  circle,
  star,
  rectangle,
  roundedRectangle,
  diamond,
  hexagon,
  octagon,
}

enum WavePattern {
  wave,
  curve,
  triangle
}

enum Position {
  leftTop,
  leftCenter,
  leftBottom,
  centerTop,
  center,
  centerBottom,
  rightTop,
  rightCenter,
  rightBottom,
}

enum Arrangement {
  logoThenText,
  textThenLogo,
  logoAboveText,
  textAboveLogo,
}


// Predefined colors with names
class NamedColor {
  final String name;
  final String hexCode;

  NamedColor(this.name, this.hexCode);

  Color get color {
    return Color(int.parse('0xFF${hexCode.replaceAll('#', '')}'));
  }
}


final List<NamedColor> predefinedColors = [
  NamedColor('White', '#FFFFFF'),
  NamedColor('Black', '#000000'),
  NamedColor('Red', '#FF0000'),
  NamedColor('Green', '#00FF00'),
  NamedColor('Blue', '#0000FF'),
  NamedColor('Yellow', '#FFFF00'),
  NamedColor('Purple', '#800080'),
  NamedColor('Orange', '#FFA500'),
  NamedColor('Pink', '#FFC0CB'),
  NamedColor('Teal', '#008080'),
  NamedColor('Cyan', '#00FFFF'),
  NamedColor('Amber', '#FFBF00'),
  NamedColor('Indigo', '#4B0082'),
  NamedColor('Brown', '#A52A2A'),
  NamedColor('Grey', '#808080'),
];

Color hexCodeColor(String hexCode) {
  return Color(int.parse('0xFF${hexCode.replaceAll('#', '')}'));
}

List<double> generateLogoSizes(int size) {
  return [for (var i = 1; i <= size; i++) i.toDouble()];
}
String backgroundImageUrl = 'https://cdn.pixabay.com/photo/2024/05/26/10/15/bird-8788491_1280.jpg';
String logoImageUrl = 'https://avatars.githubusercontent.com/u/38448422?v=4';
String titleText = 'Deepak Sharma';
String subTitleText = 'EM';
String lastTitleText = '90****1407';


final List<String> categories = [
  "All",
  "Day’s Special",
  "Birthday",
  "Good Morning",
  "Festival",
  "Wedding",
  "Anniversary",
  "Graduation",
  "Thank You",
  "Friendship"
];

final Map<String, List<String>> categoryImages = {
  "All":[
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Toast
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg", // Celebration
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Smiling
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg", // Confetti
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Smiling
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg", // Confetti
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Friends
    "https://images.pexels.com/photos/3182773/pexels-photo-3182773.jpeg", // Ceremony
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8",
    "https://images.pexels.com/photos/1232594/pexels-photo-1232594.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/3024929/pexels-photo-3024929.jpeg",
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg",
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8",
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24",
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg",
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24",
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24",
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg",
  ],
  "Day’s Special": [
    "https://images.unsplash.com/photo-1498837167922-ddd27525d352", // Coffee
    "https://images.pexels.com/photos/461428/pexels-photo-461428.jpeg", // Breakfast
    "https://images.unsplash.com/photo-1505576399279-565b52d4ac71", // Sunset
    "https://images.pexels.com/photos/326055/pexels-photo-326055.jpeg", // Planner
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00", // Beach
    "https://images.pexels.com/photos/207529/pexels-photo-207529.jpeg", // Cityscape
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Fireworks
    "https://images.pexels.com/photos/1024963/pexels-photo-1024963.jpeg", // Cake
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Champagne
    "https://images.pexels.com/photos/2690323/pexels-photo-2690323.jpeg", // Dancing
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed", // Hug
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg", // Kiss
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00", // Sunset
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg", // Letter
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Sparklers
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg", // Ring
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Toast
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg", // Celebration
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Cap throw
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg", // Diploma
  ],
  "Birthday": [
    "https://images.unsplash.com/photo-1554412933-514a83d2f3c8", // Balloons
    "https://images.pexels.com/photos/2531546/pexels-photo-2531546.jpeg", // Cake
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Sparklers
    "https://images.pexels.com/photos/1024963/pexels-photo-1024963.jpeg", // Gift
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Champagne
    "https://images.pexels.com/photos/2690323/pexels-photo-2690323.jpeg", // Dancing
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed", // Hug
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg", // Kiss
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00", // Sunset
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg", // Letter
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Sparklers
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg", // Ring
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Toast
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg", // Celebration
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Cap throw
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg", // Diploma
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24", // Group
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg", // Portrait
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Smiling
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg", // Confetti
  ],
  "Good Morning": [
    "https://images.unsplash.com/photo-1498837167922-ddd27525d352", // Coffee
    "https://images.pexels.com/photos/461428/pexels-photo-461428.jpeg", // Breakfast
    "https://images.unsplash.com/photo-1505576399279-565b52d4ac71", // Sunrise
    "https://images.pexels.com/photos/326055/pexels-photo-326055.jpeg", // Planner
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00", // Beach
    "https://images.pexels.com/photos/207529/pexels-photo-207529.jpeg", // Cityscape
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Fireworks
    "https://images.pexels.com/photos/1024963/pexels-photo-1024963.jpeg", // Cake
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Champagne
    "https://images.pexels.com/photos/2690323/pexels-photo-2690323.jpeg", // Dancing
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed", // Hug
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg", // Kiss
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00", // Sunset
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg", // Letter
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Sparklers
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg", // Ring
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Toast
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg", // Celebration
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Cap throw
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg", // Diploma
  ],
  "Festival": [
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Fireworks
    "https://images.pexels.com/photos/1024963/pexels-photo-1024963.jpeg", // Cake
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Champagne
    "https://images.pexels.com/photos/2690323/pexels-photo-2690323.jpeg", // Dancing
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed", // Hug
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg", // Kiss
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00", // Sunset
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg", // Letter
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8", // Sparklers
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg", // Ring
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Toast
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg", // Celebration
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Cap throw
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg", // Diploma
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24", // Group
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg", // Portrait
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1", // Smiling
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg", // Confetti
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc", // Friends
    "https://images.pexels.com/photos/3182773/pexels-photo-3182773.jpeg", // Ceremony
  ],
  "Wedding": [
    "https://images.unsplash.com/photo-1583939003579-730e3918a45a",
    "https://images.pexels.com/photos/169198/pexels-photo-169198.jpeg",
    "https://images.unsplash.com/photo-1523438885200-e635ba2c371e",
    "https://images.pexels.com/photos/2659475/pexels-photo-2659475.jpeg",
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed",
    "https://images.pexels.com/photos/3777931/pexels-photo-3777931.jpeg",
    "https://images.unsplash.com/photo-1542037104857-ffbb0b9155fb",
    "https://images.pexels.com/photos/4050291/pexels-photo-4050291.jpeg",
    "https://images.unsplash.com/photo-1519671482749-fd09be7ccebf",
    "https://images.pexels.com/photos/3014856/pexels-photo-3014856.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg",
    "https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6",
    "https://images.pexels.com/photos/2362979/pexels-photo-2362979.jpeg",
    "https://images.unsplash.com/photo-1497215728101-856f4ea42174",
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8",
    "https://images.pexels.com/photos/1232594/pexels-photo-1232594.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/3024929/pexels-photo-3024929.jpeg",
  ],
  "Anniversary": [
    "https://images.unsplash.com/photo-1505935428862-770b6f24f629",
    "https://images.pexels.com/photos/2253870/pexels-photo-2253870.jpeg",
    "https://images.unsplash.com/photo-1518895949257-7621c3c786d7",
    "https://images.pexels.com/photos/2908175/pexels-photo-2908175.jpeg",
    "https://images.unsplash.com/photo-1507035895480-2b3156c31fc8",
    "https://images.pexels.com/photos/1387174/pexels-photo-1387174.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/4050320/pexels-photo-4050320.jpeg",
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8",
    "https://images.pexels.com/photos/1024963/pexels-photo-1024963.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/2690323/pexels-photo-2690323.jpeg",
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed",
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg",
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8",
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
  ],
  "Graduation": [
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24",
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg",
    "https://images.unsplash.com/photo-1542037104857-ffbb0b9155fb",
    "https://images.pexels.com/photos/3182773/pexels-photo-3182773.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg",
    "https://images.unsplash.com/photo-1523438885200-e635ba2c371e",
    "https://images.pexels.com/photos/3182773/pexels-photo-3182773.jpeg",
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed",
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24",
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg",
  ],
  "Thank You": [
    "https://images.unsplash.com/photo-1530103862676-de8c9debad1d",
    "https://images.pexels.com/photos/3184183/pexels-photo-3184183.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/2690323/pexels-photo-2690323.jpeg",
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed",
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg",
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8",
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24",
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg",
  ],
  "Friendship": [
    "https://images.unsplash.com/photo-1498837167922-ddd27525d352",
    "https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/2422293/pexels-photo-2422293.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/2690323/pexels-photo-2690323.jpeg",
    "https://images.unsplash.com/photo-1519225421980-715cb0215aed",
    "https://images.pexels.com/photos/1450082/pexels-photo-1450082.jpeg",
    "https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00",
    "https://images.pexels.com/photos/3771114/pexels-photo-3771114.jpeg",
    "https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8",
    "https://images.pexels.com/photos/4050319/pexels-photo-4050319.jpeg",
    "https://images.unsplash.com/photo-1511285560929-80b456fea0bc",
    "https://images.pexels.com/photos/3184306/pexels-photo-3184306.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg",
    "https://images.unsplash.com/photo-1541178735493-479c1a27ed24",
    "https://images.pexels.com/photos/710908/pexels-photo-710908.jpeg",
    "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
    "https://images.pexels.com/photos/1595391/pexels-photo-1595391.jpeg",
  ],
};






final List<String> portraitImageUrls = [
  // People (Portraits)
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d', // Man (Close-up)
  'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg', // Woman (Smiling)
  'https://images.unsplash.com/photo-1554151228-14d9def656e4', // Woman (Natural light)
  'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg', // Woman (Black & white)
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb', // Woman (Model)

  // Nature (Portrait-oriented)
  'https://images.unsplash.com/photo-1505142468610-359e7d316be0', // Waterfall (Tall)
  'https://images.pexels.com/photos/15286/pexels-photo.jpg', // Forest (Vertical)
  'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f', // Sunset (Portrait)
  'https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg', // Snowy mountain
  'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05', // Misty trees

  // Animals (Portrait shots)
  'https://images.unsplash.com/photo-1555169062-013468b47731', // Owl (Close-up)
  'https://images.pexels.com/photos/145939/pexels-photo-145939.jpeg', // Lion (Portrait)
  'https://images.unsplash.com/photo-1564349683136-77e08dba1ef7', // Wolf (Vertical)
  'https://images.pexels.com/photos/162140/duckling-birds-yellow-fluffy-162140.jpeg', // Duckling
  'https://images.unsplash.com/photo-1543946207-39bd91e70ca7', // Horse (Portrait)

  // Architecture (Tall buildings)
  'https://images.unsplash.com/photo-1487958449943-2429e8be8625', // Skyscraper
  'https://images.pexels.com/photos/323780/pexels-photo-323780.jpeg', // Modern house
  'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2', // Beach house
  'https://images.pexels.com/photos/186077/pexels-photo-186077.jpeg', // Staircase
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750', // House interior
];



final List<String> imageUrls = [
  // Nature & Landscapes
  'https://images.unsplash.com/photo-1506744038136-46273834b3fb', // Sunset
  'https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg', // Mountain
  'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d', // Forest
  'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg', // Beach
  'https://images.unsplash.com/photo-1426604966848-d7adac402bff', // Field

  // Animals
  'https://images.unsplash.com/photo-1474511320723-9a56873867b5', // Fox
  'https://images.pexels.com/photos/45853/grey-crowned-crane-bird-crane-animal-45853.jpeg', // Crane
  'https://images.unsplash.com/photo-1555169062-013468b47731', // Owl
  'https://images.pexels.com/photos/47547/squirrel-animal-cute-rodents-47547.jpeg', // Squirrel
  'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46', // Dolphin

  // Cities & Architecture
  'https://images.unsplash.com/photo-1518391846015-55a9cc003b25', // New York
  'https://images.pexels.com/photos/374870/pexels-photo-374870.jpeg', // Paris
  'https://images.unsplash.com/photo-1538970272646-f61fabb3a8a2', // Tokyo
  'https://images.pexels.com/photos/290386/pexels-photo-290386.jpeg', // Bridge
  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b', // City Skyline

  // Food
  'https://images.unsplash.com/photo-1512621776951-a57141f2eefd', // Salad
  'https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg', // Tacos
  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38', // Pizza
  'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg', // Burger
  'https://images.unsplash.com/photo-1563805042-7684c019e1cb', // Donuts
];