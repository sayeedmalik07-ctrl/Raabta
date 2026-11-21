enum ScanFilter {
  original,
  colorEnhance,
  blackWhite,
  grayscale,
  magicColor,
  highContrast,
  documentMode,
  receiptMode,
  lowLight,
}

extension ScanFilterExt on ScanFilter {
  String get labelKey {
    switch (this) {
      case ScanFilter.original:
        return 'filter_original';
      case ScanFilter.colorEnhance:
        return 'filter_color_enhance';
      case ScanFilter.blackWhite:
        return 'filter_black_white';
      case ScanFilter.grayscale:
        return 'filter_grayscale';
      case ScanFilter.magicColor:
        return 'filter_magic_color';
      case ScanFilter.highContrast:
        return 'filter_high_contrast';
      case ScanFilter.documentMode:
        return 'filter_document';
      case ScanFilter.receiptMode:
        return 'filter_receipt';
      case ScanFilter.lowLight:
        return 'filter_low_light';
    }
  }
}
