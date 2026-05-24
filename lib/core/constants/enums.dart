enum VehicleType {
  motor('Motor'),
  mobil('Mobil'),
  lainnya('Lainnya');

  final String label;
  const VehicleType(this.label);
}

enum FuelType {
  pertalite('Pertalite'),
  pertamax('Pertamax'),
  pertamaxTurbo('Pertamax Turbo'),
  solar('Solar'),
  listrik('Listrik');

  final String label;
  const FuelType(this.label);
}

enum ServiceCategory {
  gantiOliMesin('Ganti Oli Mesin'),
  gantiOliGardan('Ganti Oli Gardan'),
  gantiBan('Ganti Ban'),
  tuneUp('Tune Up / Servis Rutin'),
  gantiAki('Ganti Aki'),
  gantiKampasRem('Ganti Kampas Rem'),
  gantiVBelt('Ganti V-Belt'),
  servisAC('Servis AC'),
  perpanjangSTNK('Perpanjang STNK / Pajak'),
  lainnya('Lain-lain');

  final String label;
  const ServiceCategory(this.label);
}

enum TimePeriod {
  mingguIni('Minggu ini'),
  bulanIni('Bulan ini'),
  tigaBulan('3 Bulan'),
  enamBulan('6 Bulan'),
  tahunIni('Tahun ini'),
  custom('Custom');

  final String label;
  const TimePeriod(this.label);
}
