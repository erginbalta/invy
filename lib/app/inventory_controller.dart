import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../features/areas/models/area.dart';
import '../features/areas/repositories/area_repository.dart';
import '../features/onboarding/data/settings_repository.dart';
import '../features/orders/models/order_item.dart';
import '../features/orders/models/order_list.dart';
import '../features/orders/repositories/order_repository.dart';
import '../features/products/models/product.dart';
import '../features/products/repositories/product_repository.dart';
import '../features/receipts/models/receipt_review_line.dart';
import '../features/stock_operations/models/stock_movement.dart';
import '../features/stock_operations/repositories/stock_movement_repository.dart';

class InventoryController extends ChangeNotifier {
  InventoryController()
      : _database = AppDatabase.instance,
        _settingsRepository = SettingsRepository(AppDatabase.instance),
        _areaRepository = AreaRepository(AppDatabase.instance),
        _productRepository = ProductRepository(AppDatabase.instance),
        _orderRepository = OrderRepository(AppDatabase.instance),
        _movementRepository = StockMovementRepository(AppDatabase.instance);

  final AppDatabase _database;
  final SettingsRepository _settingsRepository;
  final AreaRepository _areaRepository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;
  final StockMovementRepository _movementRepository;

  LocalSetup setup = const LocalSetup(isComplete: false);
  bool isLoading = true;
  String languagePreference = 'system';
  String searchQuery = '';
  bool lowStockOnly = false;
  int? selectedAreaId;
  List<Area> areas = [];
  List<OrderList> orders = [];
  List<Product> _products = [];
  List<Product> get activeProducts => List.unmodifiable(_products);

  List<Product> get products {
    final query = searchQuery.trim().toLowerCase();
    final filtered = _products.where((product) {
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.code.toLowerCase().contains(query) ||
          product.areaName.toLowerCase().contains(query);
      final matchesLowStock = !lowStockOnly || product.isLowStock;
      final matchesArea = selectedAreaId == null || product.areaId == selectedAreaId;
      return matchesQuery && matchesLowStock && matchesArea;
    }).toList();

    if (selectedAreaId != null) return filtered;
    return _aggregateByName(filtered);
  }

  int get totalProductCount => _products.length;
  int get lowStockCount => _products.where((product) => product.isLowStock).length;
  Locale? get locale {
    return switch (languagePreference) {
      'tr' => const Locale('tr'),
      'en' => const Locale('en'),
      _ => null,
    };
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    setup = await _settingsRepository.getSetup();
    languagePreference = await _settingsRepository.getLanguagePreference();
    await loadAreas();
    await loadProducts();
    await loadOrders();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _products = await _productRepository.getActiveProducts();
    notifyListeners();
  }

  Future<void> loadAreas() async {
    areas = await _areaRepository.getActiveAreas();
    notifyListeners();
  }

  Future<void> loadOrders() async {
    orders = await _orderRepository.getActiveOrders();
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setLowStockOnly(bool value) {
    lowStockOnly = value;
    notifyListeners();
  }

  void setAreaFilter(int? areaId) {
    selectedAreaId = areaId;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String usageType,
    String? businessName,
  }) async {
    await _settingsRepository.saveSetup(
      usageType: usageType,
      businessName: businessName,
    );
    setup = await _settingsRepository.getSetup();
    await loadAreas();
    notifyListeners();
  }

  Future<void> setLanguagePreference(String preference) async {
    languagePreference = preference;
    notifyListeners();
    await _settingsRepository.saveLanguagePreference(preference);
  }

  Future<void> updateUsageType({
    required String usageType,
    String? businessName,
  }) async {
    await _settingsRepository.updateUsageType(
      usageType: usageType,
      businessName: businessName,
    );
    setup = await _settingsRepository.getSetup();
    notifyListeners();
  }

  Product? productById(int id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<Product> variantsFor(Product product) {
    if (!product.isAggregate) return [product];
    final ids = product.aggregateProductIds.toSet();
    return _products.where((item) => ids.contains(item.id)).toList()
      ..sort((a, b) => a.areaName.compareTo(b.areaName));
  }

  List<Product> _aggregateByName(List<Product> source) {
    final grouped = <String, List<Product>>{};
    for (final product in source) {
      final key = product.name.trim().toLowerCase();
      grouped.putIfAbsent(key, () => []).add(product);
    }

    return grouped.values.map((items) {
      if (items.length == 1) return items.first;

      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final first = items.first;
      final stock = items.fold<int>(0, (sum, item) => sum + item.currentStock);
      final minimum = items.fold<int>(0, (sum, item) => sum + item.minimumStock);
      final oldest = items
          .map((item) => item.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final newest = items
          .map((item) => item.updatedAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      return first.copyWith(
        currentStock: stock,
        minimumStock: minimum,
        createdAt: oldest,
        updatedAt: newest,
        aggregateProductIds: [
          for (final item in items)
            if (item.id != null) item.id!,
        ],
      );
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<Product?> findByCode(String code) => _productRepository.findByCode(code);

  Future<List<Product>> findAllByCode(String code) => _productRepository.findAllByCode(code);

  Future<Product?> findByCodeAndArea({
    required String code,
    required int areaId,
  }) {
    return _productRepository.findByCodeAndArea(code: code, areaId: areaId);
  }

  Future<Product?> productByRawId(int id) => _productRepository.getById(id);

  Future<Product?> findProductByNameAndArea({
    required String name,
    required int areaId,
  }) {
    return _productRepository.findByNameAndArea(name: name, areaId: areaId);
  }

  Future<Product> createProduct({
    required String name,
    required String? code,
    required int? areaId,
    required int currentStock,
    required int minimumStock,
    String? imagePath,
  }) async {
    final product = await _productRepository.create(
      name: name,
      code: code,
      areaId: areaId,
      currentStock: currentStock,
      minimumStock: minimumStock,
      imagePath: imagePath,
    );
    await loadAreas();
    await loadProducts();
    return product;
  }

  Future<void> updateProduct(Product product) async {
    await _productRepository.update(product);
    await loadAreas();
    await loadProducts();
  }

  Future<void> updateProductCode({
    required int productId,
    required String code,
  }) async {
    await _productRepository.updateCode(productId: productId, code: code);
    await loadProducts();
  }

  Future<Product> copyProductToArea({
    required Product source,
    required int areaId,
  }) async {
    final existing = await _productRepository.findByCodeAndArea(
      code: source.code,
      areaId: areaId,
    );
    if (existing != null) return existing;

    final product = await _productRepository.create(
      name: source.name,
      code: source.code,
      areaId: areaId,
      currentStock: 0,
      minimumStock: source.minimumStock,
      imagePath: source.imagePath,
    );
    await loadProducts();
    return product;
  }

  Future<Area> createArea(String name) async {
    final area = await _areaRepository.create(name);
    await loadAreas();
    return area;
  }

  Future<void> renameArea({
    required int id,
    required String name,
  }) async {
    await _areaRepository.rename(id: id, name: name);
    await loadAreas();
    await loadProducts();
  }

  Future<void> softDeleteArea(int id) async {
    await _areaRepository.softDelete(id);
    await loadAreas();
    await loadProducts();
  }

  Future<void> softDeleteProduct(int id) async {
    await _productRepository.softDelete(id);
    await loadProducts();
  }

  Future<List<StockMovement>> movementsFor(int productId) {
    return _movementRepository.forProduct(productId);
  }

  Future<void> stockIn({
    required int productId,
    required int quantity,
    String? note,
  }) async {
    await _movementRepository.stockIn(
      productId: productId,
      quantity: quantity,
      note: note,
    );
    await loadProducts();
  }

  Future<void> stockOut({
    required int productId,
    required int quantity,
    String? note,
  }) async {
    await _movementRepository.stockOut(
      productId: productId,
      quantity: quantity,
      note: note,
    );
    await loadProducts();
  }

  Future<void> transferStock({
    required Product source,
    required int targetAreaId,
    required int quantity,
  }) async {
    final existingTarget = await _productRepository.findByCodeAndArea(
      code: source.code,
      areaId: targetAreaId,
    );
    final target = existingTarget ??
        await _productRepository.create(
          name: source.name,
          code: source.code,
          areaId: targetAreaId,
          currentStock: 0,
          minimumStock: source.minimumStock,
          imagePath: source.imagePath,
        );

    await _movementRepository.transfer(
      sourceProductId: source.id!,
      targetProductId: target.id!,
      quantity: quantity,
    );
    await loadAreas();
    await loadProducts();
  }

  Future<void> adjustTo({
    required int productId,
    required int newStock,
    String? note,
  }) async {
    await _movementRepository.adjustTo(
      productId: productId,
      newStock: newStock,
      note: note,
    );
    await loadProducts();
  }

  Future<OrderList> createOrder({
    required String title,
    required List<DraftOrderItem> items,
  }) async {
    final order = await _orderRepository.create(title: title, items: items);
    await loadOrders();
    return order;
  }

  Future<List<OrderItem>> orderItemsFor(int orderId) {
    return _orderRepository.itemsFor(orderId);
  }

  Future<void> applyReceiptLines({
    required List<ReceiptReviewLine> lines,
    int? orderId,
  }) async {
    for (final line in lines) {
      final selected = line.selectedProductId == null
          ? null
          : await _productRepository.getById(line.selectedProductId!);
      final productName = (selected?.name ?? line.name).trim();

      for (final allocation in line.allocations) {
        if (allocation.quantity <= 0) continue;

        Product? target;
        if (selected != null && selected.areaId == allocation.areaId) {
          target = selected;
        }

        target ??= await _productRepository.findByNameAndArea(
          name: productName,
          areaId: allocation.areaId,
        );

        target ??= await _productRepository.create(
          name: productName,
          code: null,
          areaId: allocation.areaId,
          currentStock: 0,
          minimumStock: selected?.minimumStock ?? 0,
          imagePath: selected?.imagePath,
        );

        await _movementRepository.stockIn(
          productId: target.id!,
          quantity: allocation.quantity,
          note: 'RECEIPT_IMPORT',
        );
      }
    }

    if (orderId != null) {
      await _orderRepository.markReceived(orderId);
      await loadOrders();
    }

    await loadAreas();
    await loadProducts();
  }

  Future<void> resetLocalData() async {
    await _database.resetAllData();
    searchQuery = '';
    lowStockOnly = false;
    selectedAreaId = null;
    areas = [];
    orders = [];
    _products = [];
    setup = const LocalSetup(isComplete: false);
    notifyListeners();
  }
}
