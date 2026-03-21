class NumberToWords {
  static String convert(int number) {
    final units = ['', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять'];
    final teens = ['десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать'];
    final tens = ['', 'десять', 'двадцать', 'тридцать', 'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят', 'восемьдесят', 'девяносто'];
    final hundreds = ['', 'сто', 'двести', 'триста', 'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот'];

    if (number == 0) return 'ноль';

    String result = '';

    if (number >= 100) {
      result += hundreds[number ~/ 100] + ' ';
      number %= 100;
    }

    if (number >= 20) {
      result += tens[number ~/ 10] + ' ';
      number %= 10;
    } else if (number >= 10) {
      result += teens[number - 10] + ' ';
      number = 0;
    }

    if (number > 0) {
      result += units[number] + ' ';
    }

    return result.trim();
  }

  static String getNounForm(int number) {
    final n = number % 100;
    if (n >= 11 && n <= 14) return 'наименований';
    switch (number % 10) {
      case 1:
        return 'наименование';
      case 2:
      case 3:
      case 4:
        return 'наименования';
      default:
        return 'наименований';
    }
  }
}
