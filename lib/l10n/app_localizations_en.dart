// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Invy';

  @override
  String get continueAction => 'Continue';

  @override
  String get saving => 'Saving...';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get reset => 'Reset';

  @override
  String get change => 'Change';

  @override
  String get personal => 'Personal';

  @override
  String get business => 'Business';

  @override
  String get notSet => 'Not set';

  @override
  String get onboardingTagline =>
      'Simple stock tracking that stays on your phone.';

  @override
  String get onboardingQuestion => 'How will you use Invy?';

  @override
  String get personalSubtitle => 'For home, collections, or personal items';

  @override
  String get businessSubtitle => 'For small shops, kiosks, or stock rooms';

  @override
  String get businessName => 'Business name';

  @override
  String get businessNameHint => 'Example: Ada Market';

  @override
  String get businessNameRequired => 'Enter the business name to continue.';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get product => 'Product';

  @override
  String get products => 'Products';

  @override
  String get settings => 'Settings';

  @override
  String get scan => 'Scan';

  @override
  String get searchProductsOrCodes => 'Search products or codes';

  @override
  String get lowStockOnly => 'Low stock only';

  @override
  String get lowStock => 'Low stock';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get emptyProductsMessage =>
      'Add your first product or scan a barcode to begin.';

  @override
  String get emptySearchMessage =>
      'Try a different search or clear the low-stock filter.';

  @override
  String minimumAbbreviation(int value) {
    return 'Min $value';
  }

  @override
  String get low => 'Low';

  @override
  String get inStock => 'In stock';

  @override
  String get productName => 'Product name';

  @override
  String get enterProductName => 'Enter a product name.';

  @override
  String get barcodeOrCode => 'Barcode or code';

  @override
  String get barcodeOrCodeOptional => 'Barcode or code (optional)';

  @override
  String get barcodeCodeHelper => 'Leave empty to generate an Invy QR code.';

  @override
  String get savedProductNeedsCode => 'A saved product needs a code.';

  @override
  String get area => 'Area';

  @override
  String get areas => 'Areas';

  @override
  String get allAreas => 'All';

  @override
  String areaCount(int count) {
    return '$count areas';
  }

  @override
  String get areaBreakdown => 'Area breakdown';

  @override
  String get generalArea => 'General Area';

  @override
  String get startingStock => 'Starting stock';

  @override
  String get currentStock => 'Current stock';

  @override
  String get minimumStock => 'Minimum stock';

  @override
  String get useStockActions => 'Use stock actions to change this.';

  @override
  String get addOptionalImage => 'Add optional image';

  @override
  String get chooseImageSource => 'Choose image source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get saveProduct => 'Save product';

  @override
  String get duplicateCodeMessage => 'That barcode or code is already used.';

  @override
  String get useZeroOrMore => 'Use 0 or more.';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get productNotFoundMessage => 'This product may have been deleted.';

  @override
  String get editProductTooltip => 'Edit product';

  @override
  String get deleteProductTooltip => 'Delete product';

  @override
  String get deleteProductTitle => 'Delete product?';

  @override
  String deleteProductMessage(Object name) {
    return '$name will be hidden from your product list.';
  }

  @override
  String get current => 'Current';

  @override
  String get minimum => 'Minimum';

  @override
  String get stockIn => 'Stock in';

  @override
  String get stockOut => 'Stock out';

  @override
  String get setStockCount => 'Set stock count';

  @override
  String get qrCode => 'QR code';

  @override
  String get customizeQr => 'Customize QR';

  @override
  String get downloadQr => 'Download QR';

  @override
  String get qrColor => 'QR color';

  @override
  String get qrBackground => 'Background';

  @override
  String get qrShape => 'QR style';

  @override
  String get qrSquare => 'Square';

  @override
  String get qrRounded => 'Rounded';

  @override
  String qrSaved(Object path) {
    return 'QR saved to $path';
  }

  @override
  String get movementHistory => 'Movement history';

  @override
  String get noStockMovementsYet => 'No stock movements yet.';

  @override
  String get adjustment => 'Adjustment';

  @override
  String movementRange(int previous, int next, Object date) {
    return '$previous to $next - $date';
  }

  @override
  String get stockOperation => 'Stock operation';

  @override
  String currentStockValue(int value) {
    return 'Current stock: $value';
  }

  @override
  String get operationIn => 'In';

  @override
  String get operationOut => 'Out';

  @override
  String get operationSet => 'Set';

  @override
  String get quantity => 'Quantity';

  @override
  String get newStock => 'New stock';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get enterValidQuantity => 'Enter a valid quantity.';

  @override
  String get stockCannotGoBelowZero => 'Stock cannot go below zero.';

  @override
  String get saveOperation => 'Save operation';

  @override
  String get scanCode => 'Scan code';

  @override
  String get manualCode => 'Manual code';

  @override
  String get enterBarcodeOrCode => 'Enter a barcode or code.';

  @override
  String get enterBarcodeOrInvyCode => 'Enter barcode or INVY code';

  @override
  String get useManualCode => 'Use manual code';

  @override
  String get cameraUnavailable =>
      'Camera is unavailable. Use manual code entry below.';

  @override
  String get usageType => 'Usage type';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get businessNameSetting => 'Business name';

  @override
  String get areasSubtitle => 'Group products by simple local areas.';

  @override
  String get localData => 'Local data';

  @override
  String get localDataMessage => 'Invy stores everything on this device.';

  @override
  String get resetLocalData => 'Reset local data';

  @override
  String get resetLocalDataTitle => 'Reset local data?';

  @override
  String get resetLocalDataMessage =>
      'This removes onboarding, products, and movement history from this device.';

  @override
  String get newArea => 'New area';

  @override
  String get renameArea => 'Rename area';

  @override
  String get areaName => 'Area name';

  @override
  String get deleteArea => 'Delete area';

  @override
  String get deleteAreaTooltip => 'Delete area';

  @override
  String get renameAreaTooltip => 'Rename area';

  @override
  String get addAreaTooltip => 'Add area';

  @override
  String get deleteAreaTitle => 'Delete area?';

  @override
  String deleteAreaMessage(Object name) {
    return '$name can be deleted only when no active product uses it.';
  }

  @override
  String get areaInUseMessage => 'Move or delete products in this area first.';

  @override
  String get noAreasYet => 'No areas yet';

  @override
  String get noAreasMessage => 'Create a simple area before adding products.';

  @override
  String get addArea => 'Add area';

  @override
  String get home => 'Home';

  @override
  String get receiptInvoice => 'Receipt/Invoice';

  @override
  String get orders => 'Orders';

  @override
  String get dashboardSubtitle => 'Quick local stock actions.';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get addReceiptInvoice => 'Add receipt/invoice';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get scanInvoice => 'Scan invoice';

  @override
  String get chooseReceiptSource => 'Choose receipt source';

  @override
  String get chooseInvoiceSource => 'Choose invoice source';

  @override
  String get receiptReview => 'Preview';

  @override
  String get noReceiptLines => 'No product lines found. Add a line manually.';

  @override
  String get productMatch => 'Product match';

  @override
  String get newProduct => 'New product';

  @override
  String get distributeToAreas => 'Distribute to areas';

  @override
  String get splitEvenly => 'Split evenly';

  @override
  String get allocatedMismatch =>
      'Area quantities must match the product quantity.';

  @override
  String get confirmAddStock => 'Confirm and add to stock';

  @override
  String get addLine => 'Add line';

  @override
  String get removeLine => 'Remove line';

  @override
  String get selectArea => 'Select area';

  @override
  String get selectProduct => 'Select product';

  @override
  String get receiptSaved => 'Stock was added from the receipt.';

  @override
  String get receiptReadFailed =>
      'Could not read product lines. You can add them manually.';

  @override
  String get orderTitle => 'Order title';

  @override
  String get orderItems => 'Order items';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get noOrdersMessage =>
      'Create a simple list, then close it with a receipt.';

  @override
  String get newOrder => 'New order';

  @override
  String get createOrder => 'Create order';

  @override
  String get addOrderItem => 'Add item';

  @override
  String get saveOrder => 'Save order';

  @override
  String get waitingReceipt => 'Waiting receipt';

  @override
  String get received => 'Received';

  @override
  String get draft => 'Draft';

  @override
  String get addReceiptToOrder => 'Add receipt to order';

  @override
  String get orderSaved => 'Order list saved.';

  @override
  String get orderCompleted => 'Order received and stock was added.';

  @override
  String get manualItem => 'Manual item';

  @override
  String get itemName => 'Item name';

  @override
  String get status => 'Status';

  @override
  String get noOrderItems => 'No items in this order.';

  @override
  String get enterOrderTitle => 'Enter an order title.';

  @override
  String get enterItemName => 'Enter an item name.';

  @override
  String get areaRequired => 'Add or select an area first.';

  @override
  String get addAreaFirst => 'Add an area first';

  @override
  String get chooseAreaForCode => 'Choose area';

  @override
  String get createInArea => 'Create in this area';

  @override
  String get codeAlreadyUsedInArea =>
      'That barcode or code is already used in this area.';

  @override
  String get addBarcode => 'Add barcode';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get enterBarcode => 'Enter barcode';

  @override
  String get barcodeAdded => 'Barcode added.';

  @override
  String get barcodeRequired => 'Enter or scan a barcode.';

  @override
  String get transferStock => 'Move stock';

  @override
  String get fromArea => 'From area';

  @override
  String get toArea => 'To area';

  @override
  String get moveAll => 'Move all';

  @override
  String availableStock(int value) {
    return 'Available: $value';
  }

  @override
  String get move => 'Move';

  @override
  String get sameAreaTransferMessage => 'Choose a different area.';

  @override
  String get notEnoughStockMessage =>
      'Quantity cannot be higher than available stock.';

  @override
  String get transferSaved => 'Stock moved.';
}
