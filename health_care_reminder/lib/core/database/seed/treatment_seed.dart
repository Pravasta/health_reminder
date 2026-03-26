import 'package:sqflite/sqflite.dart';

class TreatmentSeeder {
  static Future<void> seed(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM treatments'),
    );

    if (count != null && count > 0) {
      // sudah ada data, jangan seed ulang
      return;
    }

    final batch = db.batch();

    batch.insert('treatments', {
      'name': 'Obat for testing',
      'default_duration': 5,
      'description': 'Pengingat minum obat untuk testing',
    });

    batch.insert('treatments', {
      'name': 'Minum Obat',
      'default_duration': 480,
      'description': 'Pengingat minum obat rutin',
    });

    batch.insert('treatments', {
      'name': 'Suntik Insulin',
      'default_duration': 720,
      'description': 'Pengingat suntik insulin',
    });

    batch.insert('treatments', {
      'name': 'Transfusi Darah',
      'default_duration': 1440,
      'description': 'Pengingat transfusi darah',
    });

    batch.insert('treatments', {
      'name': 'Cuci Darah',
      'default_duration': 2880,
      'description': 'Pengingat cuci darah',
    });

    batch.insert('treatments', {
      'name': 'Kontrol Dokter',
      'default_duration': 10080,
      'description': 'Pengingat kontrol ke dokter',
    });

    await batch.commit(noResult: true);
  }
}
