import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import 'package:depir/features/product/domain/entities/product.dart';
import 'package:depir/features/product/domain/usecases/product_usecases.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/services/sms_service.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  BillingBloc({required this.getProductByBarcodeUseCase})
      : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<UpdateWeightEvent>(_onUpdateWeight);
    on<ClearCartEvent>(_onClearCart);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<SendSmsReceiptEvent>(_onSendSmsReceipt);
    on<ClearPendingProductEvent>(_onClearPendingProduct);
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
}