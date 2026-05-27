part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final bool isSendingSms;
  final bool smsSuccess;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.isSendingSms = false,
    this.smsSuccess = false,
  });

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + item.total);

  double get vatAmount => subtotal * 0.09;

  double get totalAmount => subtotal + vatAmount;

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    bool? isSendingSms,
    bool? smsSuccess,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      isSendingSms: isSendingSms ?? this.isSendingSms,
      smsSuccess: smsSuccess ?? this.smsSuccess,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        error,
        isPrinting,
        printSuccess,
        isSendingSms,
        smsSuccess,
      ];
}