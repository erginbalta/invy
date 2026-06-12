// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Invy';

  @override
  String get continueAction => 'Devam et';

  @override
  String get saving => 'Kaydediliyor...';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get reset => 'Sıfırla';

  @override
  String get change => 'Değiştir';

  @override
  String get personal => 'Kişisel';

  @override
  String get business => 'İşletme';

  @override
  String get notSet => 'Ayarlanmadı';

  @override
  String get onboardingTagline => 'Telefonunda kalan basit stok takibi.';

  @override
  String get onboardingQuestion => 'Invy\'yi nasıl kullanacaksın?';

  @override
  String get personalSubtitle => 'Ev, koleksiyonlar veya kişisel eşyalar için';

  @override
  String get businessSubtitle =>
      'Küçük dükkanlar, tezgahlar veya stok odaları için';

  @override
  String get businessName => 'İşletme adı';

  @override
  String get businessNameHint => 'Örnek: Ada Market';

  @override
  String get businessNameRequired => 'Devam etmek için işletme adını gir.';

  @override
  String get addProduct => 'Ürün ekle';

  @override
  String get editProduct => 'Ürünü düzenle';

  @override
  String get product => 'Ürün';

  @override
  String get products => 'Ürünler';

  @override
  String get settings => 'Ayarlar';

  @override
  String get scan => 'Tara';

  @override
  String get searchProductsOrCodes => 'Ürün veya kod ara';

  @override
  String get lowStockOnly => 'Sadece düşük stok';

  @override
  String get lowStock => 'Düşük stok';

  @override
  String get noProductsYet => 'Henüz ürün yok';

  @override
  String get nothingFound => 'Sonuç bulunamadı';

  @override
  String get emptyProductsMessage =>
      'Başlamak için ilk ürününü ekle veya barkod tara.';

  @override
  String get emptySearchMessage =>
      'Farklı bir arama dene veya düşük stok filtresini temizle.';

  @override
  String minimumAbbreviation(int value) {
    return 'Min $value';
  }

  @override
  String get low => 'Düşük';

  @override
  String get inStock => 'Stokta';

  @override
  String get productName => 'Ürün adı';

  @override
  String get enterProductName => 'Ürün adını gir.';

  @override
  String get barcodeOrCode => 'Barkod veya kod';

  @override
  String get barcodeOrCodeOptional => 'Barkod veya kod (isteğe bağlı)';

  @override
  String get barcodeCodeHelper => 'Boş bırakırsan Invy QR kodu oluşturulur.';

  @override
  String get savedProductNeedsCode => 'Kaydedilmiş ürün için kod gerekir.';

  @override
  String get area => 'Alan';

  @override
  String get areas => 'Alanlar';

  @override
  String get allAreas => 'Tümü';

  @override
  String areaCount(int count) {
    return '$count alan';
  }

  @override
  String get areaBreakdown => 'Alan dağılımı';

  @override
  String get generalArea => 'Genel Alan';

  @override
  String get startingStock => 'Başlangıç stoğu';

  @override
  String get currentStock => 'Mevcut stok';

  @override
  String get minimumStock => 'Minimum stok';

  @override
  String get useStockActions =>
      'Bunu değiştirmek için stok işlemlerini kullan.';

  @override
  String get addOptionalImage => 'İsteğe bağlı görsel ekle';

  @override
  String get chooseImageSource => 'Görsel kaynağı seç';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get saveProduct => 'Ürünü kaydet';

  @override
  String get duplicateCodeMessage => 'Bu barkod veya kod zaten kullanılıyor.';

  @override
  String get useZeroOrMore => '0 veya daha büyük bir değer gir.';

  @override
  String get productNotFound => 'Ürün bulunamadı';

  @override
  String get productNotFoundMessage => 'Bu ürün silinmiş olabilir.';

  @override
  String get editProductTooltip => 'Ürünü düzenle';

  @override
  String get deleteProductTooltip => 'Ürünü sil';

  @override
  String get deleteProductTitle => 'Ürün silinsin mi?';

  @override
  String deleteProductMessage(Object name) {
    return '$name ürün listesinden gizlenecek.';
  }

  @override
  String get current => 'Mevcut';

  @override
  String get minimum => 'Minimum';

  @override
  String get stockIn => 'Stok girişi';

  @override
  String get stockOut => 'Stok çıkışı';

  @override
  String get setStockCount => 'Stok sayısını ayarla';

  @override
  String get qrCode => 'QR kod';

  @override
  String get customizeQr => 'QR özelleştir';

  @override
  String get downloadQr => 'QR indir';

  @override
  String get qrColor => 'QR rengi';

  @override
  String get qrBackground => 'Arka plan';

  @override
  String get qrShape => 'QR stili';

  @override
  String get qrSquare => 'Kare';

  @override
  String get qrRounded => 'Yuvarlak';

  @override
  String qrSaved(Object path) {
    return 'QR kaydedildi: $path';
  }

  @override
  String get movementHistory => 'Hareket geçmişi';

  @override
  String get noStockMovementsYet => 'Henüz stok hareketi yok.';

  @override
  String get adjustment => 'Düzeltme';

  @override
  String movementRange(int previous, int next, Object date) {
    return '$previous - $next - $date';
  }

  @override
  String get stockOperation => 'Stok işlemi';

  @override
  String currentStockValue(int value) {
    return 'Mevcut stok: $value';
  }

  @override
  String get operationIn => 'Giriş';

  @override
  String get operationOut => 'Çıkış';

  @override
  String get operationSet => 'Ayarla';

  @override
  String get quantity => 'Miktar';

  @override
  String get newStock => 'Yeni stok';

  @override
  String get noteOptional => 'Not (isteğe bağlı)';

  @override
  String get enterValidQuantity => 'Geçerli bir miktar gir.';

  @override
  String get stockCannotGoBelowZero => 'Stok sıfırın altına düşemez.';

  @override
  String get saveOperation => 'İşlemi kaydet';

  @override
  String get scanCode => 'Kodu tara';

  @override
  String get manualCode => 'Manuel kod';

  @override
  String get enterBarcodeOrCode => 'Barkod veya kod gir.';

  @override
  String get enterBarcodeOrInvyCode => 'Barkod veya INVY kodu gir';

  @override
  String get useManualCode => 'Manuel kodu kullan';

  @override
  String get cameraUnavailable =>
      'Kamera kullanılamıyor. Aşağıdan manuel kod girebilirsin.';

  @override
  String get usageType => 'Kullanım tipi';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get businessNameSetting => 'İşletme adı';

  @override
  String get areasSubtitle => 'Ürünleri basit yerel alanlara ayır.';

  @override
  String get localData => 'Yerel veri';

  @override
  String get localDataMessage => 'Invy her şeyi bu cihazda saklar.';

  @override
  String get resetLocalData => 'Yerel veriyi sıfırla';

  @override
  String get resetLocalDataTitle => 'Yerel veri sıfırlansın mı?';

  @override
  String get resetLocalDataMessage =>
      'Bu işlem bu cihazdaki kurulumu, ürünleri ve hareket geçmişini siler.';

  @override
  String get newArea => 'Yeni alan';

  @override
  String get renameArea => 'Alanı yeniden adlandır';

  @override
  String get areaName => 'Alan adı';

  @override
  String get deleteArea => 'Alanı sil';

  @override
  String get deleteAreaTooltip => 'Alanı sil';

  @override
  String get renameAreaTooltip => 'Alanı yeniden adlandır';

  @override
  String get addAreaTooltip => 'Alan ekle';

  @override
  String get deleteAreaTitle => 'Alan silinsin mi?';

  @override
  String deleteAreaMessage(Object name) {
    return '$name yalnızca ona bağlı aktif ürün yoksa silinebilir.';
  }

  @override
  String get areaInUseMessage => 'Önce bu alandaki ürünleri taşı veya sil.';

  @override
  String get noAreasYet => 'Henüz alan yok';

  @override
  String get noAreasMessage => 'Ürün eklemeden önce basit bir alan oluştur.';

  @override
  String get addArea => 'Alan ekle';

  @override
  String get home => 'Ana';

  @override
  String get receiptInvoice => 'Fiş/Fatura';

  @override
  String get orders => 'Sipariş';

  @override
  String get dashboardSubtitle => 'Hızlı yerel stok işlemleri.';

  @override
  String get quickActions => 'Hızlı işlemler';

  @override
  String get addReceiptInvoice => 'Fiş/Fatura ekle';

  @override
  String get scanReceipt => 'Fiş oku';

  @override
  String get scanInvoice => 'Fatura oku';

  @override
  String get chooseReceiptSource => 'Fiş kaynağını seç';

  @override
  String get chooseInvoiceSource => 'Fatura kaynağını seç';

  @override
  String get receiptReview => 'Önizleme';

  @override
  String get noReceiptLines =>
      'Ürün satırı bulunamadı. Manuel satır ekleyebilirsin.';

  @override
  String get productMatch => 'Ürün eşlemesi';

  @override
  String get newProduct => 'Yeni ürün';

  @override
  String get distributeToAreas => 'Alanlara dağıt';

  @override
  String get splitEvenly => 'Eşit böl';

  @override
  String get allocatedMismatch => 'Alan miktarları ürün miktarıyla eşleşmeli.';

  @override
  String get confirmAddStock => 'Onayla ve stoğa ekle';

  @override
  String get addLine => 'Satır ekle';

  @override
  String get removeLine => 'Satırı kaldır';

  @override
  String get selectArea => 'Alan seç';

  @override
  String get selectProduct => 'Ürün seç';

  @override
  String get receiptSaved => 'Fişten stok eklendi.';

  @override
  String get receiptReadFailed =>
      'Ürün satırları okunamadı. Manuel ekleyebilirsin.';

  @override
  String get orderTitle => 'Sipariş başlığı';

  @override
  String get orderItems => 'Sipariş ürünleri';

  @override
  String get noOrdersYet => 'Henüz sipariş yok';

  @override
  String get noOrdersMessage => 'Basit bir liste oluştur, sonra fişle kapat.';

  @override
  String get newOrder => 'Yeni sipariş';

  @override
  String get createOrder => 'Sipariş oluştur';

  @override
  String get addOrderItem => 'Ürün ekle';

  @override
  String get saveOrder => 'Siparişi kaydet';

  @override
  String get waitingReceipt => 'Fiş bekliyor';

  @override
  String get received => 'Teslim alındı';

  @override
  String get draft => 'Taslak';

  @override
  String get addReceiptToOrder => 'Siparişe fiş ekle';

  @override
  String get orderSaved => 'Sipariş listesi kaydedildi.';

  @override
  String get orderCompleted => 'Sipariş teslim alındı ve stok eklendi.';

  @override
  String get manualItem => 'Manuel ürün';

  @override
  String get itemName => 'Ürün adı';

  @override
  String get status => 'Durum';

  @override
  String get noOrderItems => 'Bu siparişte ürün yok.';

  @override
  String get enterOrderTitle => 'Sipariş başlığı gir.';

  @override
  String get enterItemName => 'Ürün adı gir.';

  @override
  String get areaRequired => 'Önce alan ekle veya seç.';

  @override
  String get addAreaFirst => 'Önce alan ekle';

  @override
  String get chooseAreaForCode => 'Alan seç';

  @override
  String get createInArea => 'Bu alana ekle';

  @override
  String get codeAlreadyUsedInArea =>
      'Bu barkod veya kod bu alanda zaten kullanılıyor.';

  @override
  String get addBarcode => 'Barkod ekle';

  @override
  String get scanBarcode => 'Barkod tara';

  @override
  String get enterBarcode => 'Barkod gir';

  @override
  String get barcodeAdded => 'Barkod eklendi.';

  @override
  String get barcodeRequired => 'Barkod gir veya tara.';

  @override
  String get transferStock => 'Stok taşı';

  @override
  String get fromArea => 'Kaynak alan';

  @override
  String get toArea => 'Hedef alan';

  @override
  String get moveAll => 'Tümünü seç';

  @override
  String availableStock(int value) {
    return 'Mevcut: $value';
  }

  @override
  String get move => 'Taşı';

  @override
  String get sameAreaTransferMessage => 'Farklı bir alan seç.';

  @override
  String get notEnoughStockMessage => 'Miktar mevcut stoktan fazla olamaz.';

  @override
  String get transferSaved => 'Stok taşındı.';
}
