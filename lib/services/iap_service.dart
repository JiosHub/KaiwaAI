import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails>? products;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

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
            // Handle errors
          } else if (purchaseDetails.status == PurchaseStatus.purchased) {
            // Verify purchase on your server, then deliver the content.
            if (purchaseDetails.pendingCompletePurchase) {
              await _iap.completePurchase(purchaseDetails);
            }
          }
        }
      });
    });
  }

  Future<void> buyProduct(ProductDetails product) async {
    print(product.id);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void dispose() {
    _purchaseSubscription?.cancel();
  }
}