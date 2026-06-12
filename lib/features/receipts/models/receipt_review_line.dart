class ReceiptAllocation {
  const ReceiptAllocation({
    required this.areaId,
    required this.quantity,
  });

  final int areaId;
  final int quantity;

  ReceiptAllocation copyWith({
    int? areaId,
    int? quantity,
  }) {
    return ReceiptAllocation(
      areaId: areaId ?? this.areaId,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ReceiptReviewLine {
  const ReceiptReviewLine({
    required this.name,
    required this.quantity,
    this.selectedProductId,
    this.allocations = const [],
  });

  final String name;
  final int quantity;
  final int? selectedProductId;
  final List<ReceiptAllocation> allocations;

  int get allocatedQuantity {
    return allocations.fold<int>(0, (sum, allocation) => sum + allocation.quantity);
  }

  bool get isValid {
    return name.trim().isNotEmpty &&
        quantity > 0 &&
        allocations.isNotEmpty &&
        allocatedQuantity == quantity &&
        allocations.every((allocation) => allocation.quantity > 0);
  }

  ReceiptReviewLine copyWith({
    String? name,
    int? quantity,
    int? selectedProductId,
    bool clearSelectedProduct = false,
    List<ReceiptAllocation>? allocations,
  }) {
    return ReceiptReviewLine(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      selectedProductId: clearSelectedProduct
          ? null
          : selectedProductId ?? this.selectedProductId,
      allocations: allocations ?? this.allocations,
    );
  }
}
