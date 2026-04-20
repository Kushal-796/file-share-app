import 'dart:math';

class CodeGenerator {
  static String generate() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoid confusing characters like 0, O, 1, I
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }
}
