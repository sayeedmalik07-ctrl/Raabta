class QatarExampleBarcode {
  final String code;
  final String label;
  final String emoji;

  const QatarExampleBarcode({
    required this.code,
    required this.label,
    required this.emoji,
  });
}

const qatarExampleBarcodes = [
  QatarExampleBarcode(code: '5449000000996', label: 'Coca-Cola', emoji: '🥤'),
  QatarExampleBarcode(code: '8000500310427', label: 'Nutella', emoji: '🍫'),
  QatarExampleBarcode(code: '5000159484695', label: 'Maggi Noodles', emoji: '🍜'),
  QatarExampleBarcode(code: '3017620422003', label: 'Nutella (EU)', emoji: '🍫'),
];
