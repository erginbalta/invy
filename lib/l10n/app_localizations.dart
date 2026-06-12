import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Invy'**
  String get appTitle;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Simple stock tracking that stays on your phone.'**
  String get onboardingTagline;

  /// No description provided for @onboardingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How will you use Invy?'**
  String get onboardingQuestion;

  /// No description provided for @personalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For home, collections, or personal items'**
  String get personalSubtitle;

  /// No description provided for @businessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For small shops, kiosks, or stock rooms'**
  String get businessSubtitle;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @businessNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Ada Market'**
  String get businessNameHint;

  /// No description provided for @businessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the business name to continue.'**
  String get businessNameRequired;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @searchProductsOrCodes.
  ///
  /// In en, this message translates to:
  /// **'Search products or codes'**
  String get searchProductsOrCodes;

  /// No description provided for @lowStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Low stock only'**
  String get lowStockOnly;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @emptyProductsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first product or scan a barcode to begin.'**
  String get emptyProductsMessage;

  /// No description provided for @emptySearchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear the low-stock filter.'**
  String get emptySearchMessage;

  /// No description provided for @minimumAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Min {value}'**
  String minimumAbbreviation(int value);

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter a product name.'**
  String get enterProductName;

  /// No description provided for @barcodeOrCode.
  ///
  /// In en, this message translates to:
  /// **'Barcode or code'**
  String get barcodeOrCode;

  /// No description provided for @barcodeOrCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Barcode or code (optional)'**
  String get barcodeOrCodeOptional;

  /// No description provided for @barcodeCodeHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to generate an Invy QR code.'**
  String get barcodeCodeHelper;

  /// No description provided for @savedProductNeedsCode.
  ///
  /// In en, this message translates to:
  /// **'A saved product needs a code.'**
  String get savedProductNeedsCode;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @areas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get areas;

  /// No description provided for @allAreas.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAreas;

  /// No description provided for @areaCount.
  ///
  /// In en, this message translates to:
  /// **'{count} areas'**
  String areaCount(int count);

  /// No description provided for @areaBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Area breakdown'**
  String get areaBreakdown;

  /// No description provided for @generalArea.
  ///
  /// In en, this message translates to:
  /// **'General Area'**
  String get generalArea;

  /// No description provided for @startingStock.
  ///
  /// In en, this message translates to:
  /// **'Starting stock'**
  String get startingStock;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current stock'**
  String get currentStock;

  /// No description provided for @minimumStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock'**
  String get minimumStock;

  /// No description provided for @useStockActions.
  ///
  /// In en, this message translates to:
  /// **'Use stock actions to change this.'**
  String get useStockActions;

  /// No description provided for @addOptionalImage.
  ///
  /// In en, this message translates to:
  /// **'Add optional image'**
  String get addOptionalImage;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get chooseImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save product'**
  String get saveProduct;

  /// No description provided for @duplicateCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'That barcode or code is already used.'**
  String get duplicateCodeMessage;

  /// No description provided for @useZeroOrMore.
  ///
  /// In en, this message translates to:
  /// **'Use 0 or more.'**
  String get useZeroOrMore;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @productNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This product may have been deleted.'**
  String get productNotFoundMessage;

  /// No description provided for @editProductTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProductTooltip;

  /// No description provided for @deleteProductTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProductTooltip;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product?'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will be hidden from your product list.'**
  String deleteProductMessage(Object name);

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @stockIn.
  ///
  /// In en, this message translates to:
  /// **'Stock in'**
  String get stockIn;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Stock out'**
  String get stockOut;

  /// No description provided for @setStockCount.
  ///
  /// In en, this message translates to:
  /// **'Set stock count'**
  String get setStockCount;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCode;

  /// No description provided for @customizeQr.
  ///
  /// In en, this message translates to:
  /// **'Customize QR'**
  String get customizeQr;

  /// No description provided for @downloadQr.
  ///
  /// In en, this message translates to:
  /// **'Download QR'**
  String get downloadQr;

  /// No description provided for @qrColor.
  ///
  /// In en, this message translates to:
  /// **'QR color'**
  String get qrColor;

  /// No description provided for @qrBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get qrBackground;

  /// No description provided for @qrShape.
  ///
  /// In en, this message translates to:
  /// **'QR style'**
  String get qrShape;

  /// No description provided for @qrSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get qrSquare;

  /// No description provided for @qrRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get qrRounded;

  /// No description provided for @qrSaved.
  ///
  /// In en, this message translates to:
  /// **'QR saved to {path}'**
  String qrSaved(Object path);

  /// No description provided for @movementHistory.
  ///
  /// In en, this message translates to:
  /// **'Movement history'**
  String get movementHistory;

  /// No description provided for @noStockMovementsYet.
  ///
  /// In en, this message translates to:
  /// **'No stock movements yet.'**
  String get noStockMovementsYet;

  /// No description provided for @adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get adjustment;

  /// No description provided for @movementRange.
  ///
  /// In en, this message translates to:
  /// **'{previous} to {next} - {date}'**
  String movementRange(int previous, int next, Object date);

  /// No description provided for @stockOperation.
  ///
  /// In en, this message translates to:
  /// **'Stock operation'**
  String get stockOperation;

  /// No description provided for @currentStockValue.
  ///
  /// In en, this message translates to:
  /// **'Current stock: {value}'**
  String currentStockValue(int value);

  /// No description provided for @operationIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get operationIn;

  /// No description provided for @operationOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get operationOut;

  /// No description provided for @operationSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get operationSet;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @newStock.
  ///
  /// In en, this message translates to:
  /// **'New stock'**
  String get newStock;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity.'**
  String get enterValidQuantity;

  /// No description provided for @stockCannotGoBelowZero.
  ///
  /// In en, this message translates to:
  /// **'Stock cannot go below zero.'**
  String get stockCannotGoBelowZero;

  /// No description provided for @saveOperation.
  ///
  /// In en, this message translates to:
  /// **'Save operation'**
  String get saveOperation;

  /// No description provided for @scanCode.
  ///
  /// In en, this message translates to:
  /// **'Scan code'**
  String get scanCode;

  /// No description provided for @manualCode.
  ///
  /// In en, this message translates to:
  /// **'Manual code'**
  String get manualCode;

  /// No description provided for @enterBarcodeOrCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a barcode or code.'**
  String get enterBarcodeOrCode;

  /// No description provided for @enterBarcodeOrInvyCode.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode or INVY code'**
  String get enterBarcodeOrInvyCode;

  /// No description provided for @useManualCode.
  ///
  /// In en, this message translates to:
  /// **'Use manual code'**
  String get useManualCode;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera is unavailable. Use manual code entry below.'**
  String get cameraUnavailable;

  /// No description provided for @usageType.
  ///
  /// In en, this message translates to:
  /// **'Usage type'**
  String get usageType;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @businessNameSetting.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessNameSetting;

  /// No description provided for @areasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group products by simple local areas.'**
  String get areasSubtitle;

  /// No description provided for @localData.
  ///
  /// In en, this message translates to:
  /// **'Local data'**
  String get localData;

  /// No description provided for @localDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Invy stores everything on this device.'**
  String get localDataMessage;

  /// No description provided for @resetLocalData.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get resetLocalData;

  /// No description provided for @resetLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset local data?'**
  String get resetLocalDataTitle;

  /// No description provided for @resetLocalDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes onboarding, products, and movement history from this device.'**
  String get resetLocalDataMessage;

  /// No description provided for @newArea.
  ///
  /// In en, this message translates to:
  /// **'New area'**
  String get newArea;

  /// No description provided for @renameArea.
  ///
  /// In en, this message translates to:
  /// **'Rename area'**
  String get renameArea;

  /// No description provided for @areaName.
  ///
  /// In en, this message translates to:
  /// **'Area name'**
  String get areaName;

  /// No description provided for @deleteArea.
  ///
  /// In en, this message translates to:
  /// **'Delete area'**
  String get deleteArea;

  /// No description provided for @deleteAreaTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete area'**
  String get deleteAreaTooltip;

  /// No description provided for @renameAreaTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rename area'**
  String get renameAreaTooltip;

  /// No description provided for @addAreaTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add area'**
  String get addAreaTooltip;

  /// No description provided for @deleteAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete area?'**
  String get deleteAreaTitle;

  /// No description provided for @deleteAreaMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} can be deleted only when no active product uses it.'**
  String deleteAreaMessage(Object name);

  /// No description provided for @areaInUseMessage.
  ///
  /// In en, this message translates to:
  /// **'Move or delete products in this area first.'**
  String get areaInUseMessage;

  /// No description provided for @noAreasYet.
  ///
  /// In en, this message translates to:
  /// **'No areas yet'**
  String get noAreasYet;

  /// No description provided for @noAreasMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a simple area before adding products.'**
  String get noAreasMessage;

  /// No description provided for @addArea.
  ///
  /// In en, this message translates to:
  /// **'Add area'**
  String get addArea;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @receiptInvoice.
  ///
  /// In en, this message translates to:
  /// **'Receipt/Invoice'**
  String get receiptInvoice;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick local stock actions.'**
  String get dashboardSubtitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @addReceiptInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add receipt/invoice'**
  String get addReceiptInvoice;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceipt;

  /// No description provided for @scanInvoice.
  ///
  /// In en, this message translates to:
  /// **'Scan invoice'**
  String get scanInvoice;

  /// No description provided for @chooseReceiptSource.
  ///
  /// In en, this message translates to:
  /// **'Choose receipt source'**
  String get chooseReceiptSource;

  /// No description provided for @chooseInvoiceSource.
  ///
  /// In en, this message translates to:
  /// **'Choose invoice source'**
  String get chooseInvoiceSource;

  /// No description provided for @receiptReview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get receiptReview;

  /// No description provided for @noReceiptLines.
  ///
  /// In en, this message translates to:
  /// **'No product lines found. Add a line manually.'**
  String get noReceiptLines;

  /// No description provided for @productMatch.
  ///
  /// In en, this message translates to:
  /// **'Product match'**
  String get productMatch;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProduct;

  /// No description provided for @distributeToAreas.
  ///
  /// In en, this message translates to:
  /// **'Distribute to areas'**
  String get distributeToAreas;

  /// No description provided for @splitEvenly.
  ///
  /// In en, this message translates to:
  /// **'Split evenly'**
  String get splitEvenly;

  /// No description provided for @allocatedMismatch.
  ///
  /// In en, this message translates to:
  /// **'Area quantities must match the product quantity.'**
  String get allocatedMismatch;

  /// No description provided for @confirmAddStock.
  ///
  /// In en, this message translates to:
  /// **'Confirm and add to stock'**
  String get confirmAddStock;

  /// No description provided for @addLine.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get addLine;

  /// No description provided for @removeLine.
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get removeLine;

  /// No description provided for @selectArea.
  ///
  /// In en, this message translates to:
  /// **'Select area'**
  String get selectArea;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select product'**
  String get selectProduct;

  /// No description provided for @receiptSaved.
  ///
  /// In en, this message translates to:
  /// **'Stock was added from the receipt.'**
  String get receiptSaved;

  /// No description provided for @receiptReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read product lines. You can add them manually.'**
  String get receiptReadFailed;

  /// No description provided for @orderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order title'**
  String get orderTitle;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order items'**
  String get orderItems;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a simple list, then close it with a receipt.'**
  String get noOrdersMessage;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrder;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create order'**
  String get createOrder;

  /// No description provided for @addOrderItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addOrderItem;

  /// No description provided for @saveOrder.
  ///
  /// In en, this message translates to:
  /// **'Save order'**
  String get saveOrder;

  /// No description provided for @waitingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Waiting receipt'**
  String get waitingReceipt;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @addReceiptToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add receipt to order'**
  String get addReceiptToOrder;

  /// No description provided for @orderSaved.
  ///
  /// In en, this message translates to:
  /// **'Order list saved.'**
  String get orderSaved;

  /// No description provided for @orderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order received and stock was added.'**
  String get orderCompleted;

  /// No description provided for @manualItem.
  ///
  /// In en, this message translates to:
  /// **'Manual item'**
  String get manualItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @noOrderItems.
  ///
  /// In en, this message translates to:
  /// **'No items in this order.'**
  String get noOrderItems;

  /// No description provided for @enterOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter an order title.'**
  String get enterOrderTitle;

  /// No description provided for @enterItemName.
  ///
  /// In en, this message translates to:
  /// **'Enter an item name.'**
  String get enterItemName;

  /// No description provided for @areaRequired.
  ///
  /// In en, this message translates to:
  /// **'Add or select an area first.'**
  String get areaRequired;

  /// No description provided for @addAreaFirst.
  ///
  /// In en, this message translates to:
  /// **'Add an area first'**
  String get addAreaFirst;

  /// No description provided for @chooseAreaForCode.
  ///
  /// In en, this message translates to:
  /// **'Choose area'**
  String get chooseAreaForCode;

  /// No description provided for @createInArea.
  ///
  /// In en, this message translates to:
  /// **'Create in this area'**
  String get createInArea;

  /// No description provided for @codeAlreadyUsedInArea.
  ///
  /// In en, this message translates to:
  /// **'That barcode or code is already used in this area.'**
  String get codeAlreadyUsedInArea;

  /// No description provided for @addBarcode.
  ///
  /// In en, this message translates to:
  /// **'Add barcode'**
  String get addBarcode;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @enterBarcode.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode'**
  String get enterBarcode;

  /// No description provided for @barcodeAdded.
  ///
  /// In en, this message translates to:
  /// **'Barcode added.'**
  String get barcodeAdded;

  /// No description provided for @barcodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter or scan a barcode.'**
  String get barcodeRequired;

  /// No description provided for @transferStock.
  ///
  /// In en, this message translates to:
  /// **'Move stock'**
  String get transferStock;

  /// No description provided for @fromArea.
  ///
  /// In en, this message translates to:
  /// **'From area'**
  String get fromArea;

  /// No description provided for @toArea.
  ///
  /// In en, this message translates to:
  /// **'To area'**
  String get toArea;

  /// No description provided for @moveAll.
  ///
  /// In en, this message translates to:
  /// **'Move all'**
  String get moveAll;

  /// No description provided for @availableStock.
  ///
  /// In en, this message translates to:
  /// **'Available: {value}'**
  String availableStock(int value);

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @sameAreaTransferMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a different area.'**
  String get sameAreaTransferMessage;

  /// No description provided for @notEnoughStockMessage.
  ///
  /// In en, this message translates to:
  /// **'Quantity cannot be higher than available stock.'**
  String get notEnoughStockMessage;

  /// No description provided for @transferSaved.
  ///
  /// In en, this message translates to:
  /// **'Stock moved.'**
  String get transferSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
