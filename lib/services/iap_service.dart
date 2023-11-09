import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails>? products;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Completer<bool> _purchaseCompleter = Completer<bool>();

  IAPService() {
    _initialize();
  }

  void _initialize() async {
    // Fetch products when the service is initialized
    print("_______SETUP________");
    await _fetchProducts();
    print("iap service init");
    // Listen for purchase updates
    _listenToPurchaseUpdated();
  }

  Future<void> _fetchProducts() async {
    Set<String> _ids = {'100messages', '500messages'};
    final ProductDetailsResponse response = await _iap.queryProductDetails(_ids);
    products = response.productDetails;
  }

  Future<bool> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: purchaseParam);
    return _purchaseCompleter.future;
  }

  void _listenToPurchaseUpdated() {
    _purchaseSubscription = _iap.purchaseStream.listen((purchaseDetailsList) {
      purchaseDetailsList.forEach((purchaseDetails) async {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          // Handle pending transactions
        } else {
          if (purchaseDetails.status == PurchaseStatus.error) {
            print("Error during purchase: ${purchaseDetails.error}");
            _purchaseCompleter.complete(true);
          } else if (purchaseDetails.status == PurchaseStatus.purchased) {
            print("Purchase Token (purchaseID): ${purchaseDetails.purchaseID}");
            
            try {
              final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
              final result = await functions.httpsCallable('updateUserValues').call({
                'platform': 'android',
                'productId': purchaseDetails.productID,
                'purchaseToken': purchaseDetails.verificationData.localVerificationData,
                'serverVerificationData': purchaseDetails.verificationData.serverVerificationData,
              });
              _purchaseCompleter.complete(false);
              if (purchaseDetails.pendingCompletePurchase) {
                await _iap.completePurchase(purchaseDetails);
              }
            } catch (error) {
              print("Error during Firebase function call: $error");
              _purchaseCompleter.complete(true);
            }
          }
        }
      });
    }, onError: (error) {
      print("Stream error received");
      _purchaseCompleter.complete(true);
    });
  }

  void resetPurchaseCompleter() {
    _purchaseCompleter = Completer<bool>();
  }

  void dispose() {
    print("_______DISPOSE________");
    _purchaseSubscription?.cancel();
  }
}