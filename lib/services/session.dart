class Session {
  static String? token;
  static String? email;

  static void clear() {
    token = null;
    email = null;
  }
}
