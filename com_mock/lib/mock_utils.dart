import 'dart:math';

final _rnd = Random();

const _names = [
  'Anh Trung',
  'Lan',
  'Minh',
  'Hoa',
  'Huy',
  'Nga',
  'Khanh',
  'Dung',
  'Phong',
  'Tuan',
];

String randomName() => _names[_rnd.nextInt(_names.length)];

String randomImage({int w = 200, int h = 200}) =>
    'https://picsum.photos/seed/${_rnd.nextInt(10000)}/$w/$h';

const _messages = [
  'Hello!',
  'Bạn có rảnh không?',
  'Đã xong chưa?',
  'Gửi mình file nhé',
  'OK, được rồi',
  'Cần hỗ trợ gấp',
  'Tối nay đi ăn nhé',
  'Cảm ơn bạn',
  'Đợi 1 chút',
  'Tuyệt vời!'
];

String randomMessage() => _messages[_rnd.nextInt(_messages.length)];
