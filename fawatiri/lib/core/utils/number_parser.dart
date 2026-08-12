/// تحويل الأرقام العربية والفارسية إلى إنجليزية
String normalizeNumbers(String input) {
  return input
    .replaceAll('٠', '0').replaceAll('۰', '0')
    .replaceAll('١', '1').replaceAll('۱', '1')
    .replaceAll('٢', '2').replaceAll('۲', '2')
    .replaceAll('٣', '3').replaceAll('۳', '3')
    .replaceAll('٤', '4').replaceAll('۴', '4')
    .replaceAll('٥', '5').replaceAll('۵', '5')
    .replaceAll('٦', '6').replaceAll('۶', '6')
    .replaceAll('٧', '7').replaceAll('۷', '7')
    .replaceAll('٨', '8').replaceAll('۸', '8')
    .replaceAll('٩', '9').replaceAll('۹', '9')
    .replaceAll('٫', '.');
}