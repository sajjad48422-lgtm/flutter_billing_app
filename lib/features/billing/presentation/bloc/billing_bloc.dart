import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cart_item.dart';
import 'package:depir/features/product/domain/entities/product.dart';
import 'package:depir/features/product/domain/usecases/product_usecases.dart';
import 'package:depir/features/sales/domain/entities/sale_record.dart';
import 'package:depir/features/sales/domain/usecases/sale_usecases.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/services/sms_service.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final SaveSaleUseCase saveSaleUseCase;
  final UpdateProductUseCase updateProductUseCase;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.saveSaleUseCase,
    required this.updateProductUseCase,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<UpdateWeightEvent>(_onUpdateWeight);
    on<ClearCartEvent>(_onClearCart);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<SendSmsReceiptEvent>(_onSendSmsReceipt);
    on<ClearPendingProductEvent>(_onClearPendingProduct);
    on<CompleteSaleEvent>(_onCompleteSale);
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) => emit(state.copyWith(
          error: 'محصول یافت نشد: ${event.barcode}')),
      (product) {
        final isWeightBased = product.unit == ProductUnit.kg ||
            product.unit == ProductUnit.gram ||
            product.unit == ProductUnit.liter ||
            product.unit == ProductUnit.meter;

        if (isWeightBased) {
          emit(state.copyWith(pendingWeightProduct: product));
        } else {
          add(AddProductToCartEvent(product));
        }
      },
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    final cleanState = state.copyWith(error: null);

    final isWeightBased = event.product.unit == ProductUnit.kg ||
    event.product.unit == ProductUnit.gram ||
    event.product.unit == ProductUnit.liter ||
    event.product.unit == ProductUnit.meter;

final newItem = CartItem(
  product: event.product,
  weightAmount: isWeightBased ? (event.weightAmount ?? 1.0) : 1.0,
);

    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);

    if (existingIndex >= 0 && !newItem.isWeightBased) {
      final existingItem = cleanState.cartItems[existingIndex];
      final updatedItems = List<CartItem>.from(cleanState.cartItems);
      updatedItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(cleanState.copyWith(cartItems: updatedItems, error: null));
    } else {
      emit(cleanState.copyWith(
          cartItems: [...cleanState.cartItems, newItem], error: null));
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }
    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onUpdateWeight(
      UpdateWeightEvent event, Emitter<BillingState> emit) {
    if (event.weightAmount <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }
    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(weightAmount: event.weightAmount);
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(error: 'اتصال به پرینتر ناموفق بود!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(error: 'پرینتر متصل نیست!', clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(isPrinting: true, printSuccess: false, clearError: true));

    try {
      final items = state.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.isWeightBased ? item.weightAmount : item.quantity,
                'price': item.product.price,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
          shopName: event.shopName,
          address1: event.address1,
          address2: event.address2,
          phone: event.phone,
          items: items,
          total: state.totalAmount,
          footer: event.footer);

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(isPrinting: false, error: 'خطا در چاپ: $e', clearError: false));
      emit(state.copyWith(clearError: true));
    }
  }

  Future<void> _onSendSmsReceipt(
      SendSmsReceiptEvent event, Emitter<BillingState> emit) async {
    emit(state.copyWith(isSendingSms: true, smsSuccess: false));

    final items = state.cartItems
        .map((item) => InvoiceItem(
              name: '${item.product.name} (${item.displayAmount})',
              quantity: item.isWeightBased ? 1 : item.quantity,
              total: item.total,
            ))
        .toList();

    final result = await SmsService.sendInvoiceViaSim(
      customerPhone: event.customerPhone,
      shopName: event.shopName,
      items: items,
      subtotal: state.subtotal,
      vatAmount: state.vatAmount,
      total: state.totalAmount,
      invoiceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    switch (result) {
      case SmsResult.success:
        emit(state.copyWith(isSendingSms: false, smsSuccess: true));
        break;
      case SmsResult.permissionDenied:
        emit(state.copyWith(isSendingSms: false, error: 'دسترسی به پیامک داده نشد!', clearError: false));
        emit(state.copyWith(clearError: true));
        break;
      case SmsResult.failed:
        emit(state.copyWith(isSendingSms: false, error: 'ارسال پیامک ناموفق بود!', clearError: false));
        emit(state.copyWith(clearError: true));
        break;
    }
  }

  void _onClearPendingProduct(
      ClearPendingProductEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(clearPendingProduct: true));
  }

  Future<void> _onCompleteSale(
      CompleteSaleEvent event, Emitter<BillingState> emit) async {
    if (state.cartItems.isEmpty || state.saleSaved || state.isSavingSale) {
      return;
    }

    emit(state.copyWith(isSavingSale: true, clearError: true));

    final saleItems = state.cartItems.map((item) {
      final qty =
          item.isWeightBased ? item.weightAmount : item.quantity.toDouble();
      return SaleItem(
        productId: item.product.id,
        productName: item.product.name,
        price: item.product.price,
        purchasePrice: item.product.purchasePrice,
        quantity: qty,
        total: item.total,
      );
    }).toList();

    final totalPurchaseAmount = state.cartItems.fold<double>(
      0,
      (sum, item) =>
          sum +
          (item.product.purchasePrice *
              (item.isWeightBased ? item.weightAmount : item.quantity)),
    );

    final saleRecord = SaleRecord(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      items: saleItems,
      totalAmount: state.subtotal,
      totalPurchaseAmount: totalPurchaseAmount,
      taxAmount: state.vatAmount,
      finalAmount: state.totalAmount,
    );

    final saveResult = await saveSaleUseCase(saleRecord);

    final failure = saveResult.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(
          isSavingSale: false,
          error: 'خطا در ثبت فروش: ${failure.message}',
          clearError: false));
      return;
    }

    // کسر موجودی هر کالا از انبار
    for (final item in state.cartItems) {
      final deductAmount =
          item.isWeightBased ? item.weightAmount.round() : item.quantity;
      final remainingStock = item.product.stock - deductAmount;
      final updatedProduct = item.product.copyWith(
        stock: remainingStock < 0 ? 0 : remainingStock,
      );
      await updateProductUseCase(updatedProduct);
    }

    emit(state.copyWith(isSavingSale: false, saleSaved: true));
  }
}