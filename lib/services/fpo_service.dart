import 'dart:async';

class FPOService {
  static final FPOService _instance = FPOService._internal();
  factory FPOService() => _instance;
  FPOService._internal();

  // 1. MARKET OFFERS
  final List<Map<String, dynamic>> _marketOffers = [
    {
      "id": "1",
      "fpo_name": "AgriGlobal Exporters",
      "crop": "Mustard",
      "min_qtl": 20,
      "max_qtl": 100,
      "price_per_qtl": 6100,
      "location": "Ahmedabad, Gujarat",
      "valid_till": "2 Days",
      "buyer_id": "buyer_01",
      "status": "open"
    },
    {
      "id": "2",
      "fpo_name": "Fresh Foods Ltd",
      "crop": "Wheat",
      "min_qtl": 50,
      "max_qtl": 500,
      "price_per_qtl": 2400,
      "location": "Rajkot, Gujarat",
      "valid_till": "5 Days",
      "buyer_id": "buyer_02",
      "status": "open"
    }
  ];

  // 2. FARMER REQUESTS
  final List<Map<String, dynamic>> _farmerRequests = [];

  // 3. NOTIFICATIONS (New Feature)
  final List<Map<String, dynamic>> _notifications = [];

  // --- METHODS FOR FARMER SIDE ---

  Future<List<Map<String, dynamic>>> loadOffers() async {
    return _marketOffers.where((o) => o['status'] == 'open').toList();
  }

  // UPDATED: Now generates a Notification when Farmer sends interest
  Future<void> sendInterest(String offerId, String farmerName, double quantity) async {
    final offerIndex = _marketOffers.indexWhere((o) => o['id'] == offerId);
    if (offerIndex != -1) {
      final offer = _marketOffers[offerIndex];
      
      // 1. Create Request
      _farmerRequests.add({
        "request_id": DateTime.now().millisecondsSinceEpoch.toString(),
        "offer_id": offerId,
        "buyer_id": offer['buyer_id'],
        "farmer": farmerName,
        "crop": offer['crop'],
        "qty": "$quantity Quintals",
        "price": "₹${offer['price_per_qtl']}/qtl",
        "status": "pending" 
      });

      // 2. Generate Notification for Buyer
      _notifications.insert(0, {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": "New Interest Received! 📢",
        "body": "$farmerName wants to sell $quantity Quintals of ${offer['crop']}.",
        "time": "Just Now",
        "isRead": false
      });
    }
  }

  // --- METHODS FOR BUYER SIDE ---

  Future<void> postBuyerRequirement(String buyerName, String crop, double price, double qty, String msg) async {
    _marketOffers.insert(0, {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "fpo_name": buyerName,
      "crop": crop,
      "min_qtl": qty,
      "max_qtl": qty,
      "price_per_qtl": price,
      "location": "Gujarat",
      "valid_till": "7 Days",
      "buyer_id": "current_buyer",
      "status": "open",
      "message": msg
    });
  }

  List<Map<String, dynamic>> getRequestsForBuyer() {
    return _farmerRequests.where((r) => r['status'] == 'pending').toList();
  }

  void acceptRequest(String requestId) {
    final index = _farmerRequests.indexWhere((r) => r['request_id'] == requestId);
    if (index != -1) {
      _farmerRequests[index]['status'] = 'accepted';
      
      // Optional: Notify Farmer back (Simulated)
      // print("Notification sent to Farmer: Deal Accepted");
    }
  }

  List<Map<String, dynamic>> getAcceptedDeals() {
    return _farmerRequests.where((r) => r['status'] == 'accepted').toList();
  }

  // Get Notifications
  List<Map<String, dynamic>> getNotifications() {
    return _notifications;
  }
  
  // Clear Notifications
  void clearNotifications() {
    _notifications.clear();
  }
}