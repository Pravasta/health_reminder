class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email tidak boleh kosong";
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return "Masukkan email yang valid";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value) ||
        !RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf besar dan kecil';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka';
    }

    return null; // Valid
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password) {
      return 'Password tidak sama';
    }
    return null;
  }

  // Validasi nama: minimal 2 karakter, hanya huruf dan spasi
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s]+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Nama hanya boleh mengandung huruf dan spasi';
    }
    return null;
  }

  // Validasi nomor telepon: hanya angka, panjang minimal 8-15 digit
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final phoneRegex = RegExp(r'^\d{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Masukkan nomor telepon yang valid (8-15 digit angka)';
    }
    return null;
  }

  // Validasi kode pos: hanya angka, 5 digit
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kode pos tidak boleh kosong';
    }
    final postalCodeRegex = RegExp(r'^\d{5}$');
    if (!postalCodeRegex.hasMatch(value)) {
      return 'Kode pos harus 5 digit angka';
    }
    return null;
  }

  // Validasi teks biasa: minimal panjang tertentu
  static String? validateText(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini tidak boleh kosong';
    }
    if (value.trim().length < minLength) {
      return 'Minimal $minLength karakter';
    }
    return null;
  }

  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Field ini tidak boleh kosong';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Masukkan angka yang valid';
    }
    if (min != null && number < min) {
      return 'Nilai minimal adalah $min';
    }
    if (max != null && number > max) {
      return 'Nilai maksimal adalah $max';
    }
    return null;
  }
}
