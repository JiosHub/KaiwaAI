import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
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
    Set<String> _ids = {'100messages', '500messages'};
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
            print("Purchase Token (purchaseID): ${purchaseDetails.purchaseID}");
            
            try {
              final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
              //functions.useFunctionsEmulator('localhost', 5001);
              final result = await functions.httpsCallable('updateUserValues').call({
                'platform': 'android',
                'productId': purchaseDetails.productID,
                'purchaseID': purchaseDetails.purchaseID,
                'serverVerificationData': purchaseDetails.verificationData.serverVerificationData,
              });
              _purchaseCompleter.complete("");
              if (purchaseDetails.pendingCompletePurchase) {
                await _iap.completePurchase(purchaseDetails);
              }
            } catch (error) {
              print("Error during Firebase function call: $error");
              _purchaseCompleter.complete("Firebase function error: $error");
            }
          }
        }
      });
    }, onError: (error) {
      print("Stream error received");
      _purchaseCompleter.complete("Stream error: $error");
    });
  }

  Future<String> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: purchaseParam);
    return _purchaseCompleter.future;
  }
  
  void resetPurchaseCompleter() {
    _purchaseCompleter = Completer<String>();
  }

  void dispose() {
    _purchaseSubscription?.cancel();
  }
}