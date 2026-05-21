/// Default filename when the backend omits [Content-Disposition].
String portfolioPdfExportFallbackFilename({DateTime? reference}) {
  final utc = (reference ?? DateTime.now()).toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return 'cryprice-portfolio-report-$year-$month-$day.pdf';
}
