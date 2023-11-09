import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';

class IAPService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final HttpsCallable _updateUserValuesCallable = FirebaseFunctions.instance.httpsCallable('updateUserValues');

  void completePurchase(PurchaseDetails purchaseDetails) {
    _inAppPurchase.completePurchase(purchaseDetails);
  }

  Future<void> startPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final result = await _updateUserValuesCallable.call(<String, dynamic>{
        'platform': 'android',
        'productId': purchaseDetails.productID,
        'purchaseToken': purchaseDetails.verificationData.localVerificationData,
        'serverVerificationData': purchaseDetails.verificationData.serverVerificationData,
      });
      // Handle the result of the purchase here
    } on FirebaseFunctionsException catch (e) {
      // Handle if the cloud function throws an error
      throw e;
    } catch (e) {
      // Handle any other error that might occur
      throw e;
    }
  }

  Future<List<ProductDetails>> fetchProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // The store cannot be reached or accessed. Handle this case.
      return [];
    }

    Set<String> ids = {'100messages', '500messages'};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error if any of the ids are not found.
    }

    return response.productDetails;
  }

  // Call this when the user wants to initiate a purchase
  void buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }
}