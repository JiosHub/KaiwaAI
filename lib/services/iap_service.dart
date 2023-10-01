import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails>? products;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Completer<String> _purchaseCompleter = Completer<String>();

  IAPService() {
    _initialize();
  }

  void _initialize() async {
    // Fetch products when the service is initialized
    await _fetchProducts();
    print("iap service init");
    // Listen for purchase updates
    _listenToPurchaseUpdated();
  }

  Future<void> _fetchProducts() async {
    Set<String> _ids = {'100_messages', '500_messages'};
    final ProductDetailsResponse response = await _iap.queryProductDetails(_ids);

    if (response.notFoundIDs.isNotEmpty) {
      // Handle any errors or missing IDs
    }

    products = response.productDetails;
  }

  void _listenToPurchaseUpdated() {
    _purchaseSubscription = _iap.purchaseStream.listen((purchaseDetailsList) {
      purchaseDetailsList.forEach((purchaseDetails) async {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          // Handle pending transactions
        } else {
          if (purchaseDetails.status == PurchaseStatus.error) {
            print("yoooo ${purchaseDetails.error}");
            _purchaseCompleter.complete("Error during purchase: ${purchaseDetails.error}");
          } else if (purchaseDetails.status == PurchaseStatus.purchased) {
            if (purchaseDetails.pendingCompletePurchase) {
              await _iap.completePurchase(purchaseDetails);
            }
            _purchaseCompleter.complete("Success");
          }
        }
      });
    }, onError: (error) {
      _purchaseCompleter.complete(error.toString());
    });
  }

  void resetPurchaseCompleter() {
    _purchaseCompleter = Completer<String>();
  }

  Future<String> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    return _purchaseCompleter.future;
  }

  void dispose() {
    _purchaseSubscription?.cancel();
  }
}