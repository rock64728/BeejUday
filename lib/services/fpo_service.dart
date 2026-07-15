import 'package:supabase_flutter/supabase_flutter.dart';

class FPOService {
  static final FPOService _instance = FPOService._internal();
  factory FPOService() => _instance;
  FPOService._internal();

  // Access Supabase
  final supabase = Supabase.instance.client;

  // We are keeping this local list ONLY for notifications for now so your UI doesn't crash. 
  // We will replace this with real Push Notifications in Phase 3.
  final List<Map<String, dynamic>> _notifications = [];

  // --- METHODS FOR FARMER SIDE ---

  Future<List<Map<String, dynamic>>> loadOffers() async {
    try {
      // 1. Fetch live open offers from Cloud
      final response = await supabase
          .from('market_offers')
          .select()
          .eq('status', 'open')
          .order('created_at', ascending: false);

      // 2. Map the Cloud Data to the exact keys your UI cards expect
      return response.map((offer) => {
            "id": offer['id'],
            "fpo_name": offer['buyer_name'], 
            "crop": offer['crop'],
            "min_qtl": offer['qty_required'], 
            "max_qtl": offer['qty_required'],
            "price_per_qtl": offer['price_per_qtl'],
            "location": offer['location'],
            "valid_till": "7 Days", // Hardcoded UI placeholder for now
            "buyer_id": offer['buyer_id'],
            "status": offer['status']
          }).toList();
    } catch (e) {
      print("Error loading cloud offers: $e");
      return [];
    }
  }

  Future<void> sendInterest(String offerId, String fakeUiFarmerName, double quantity) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 1. Look up the REAL Farmer Name securely from the cloud
      final profile = await supabase.from('farmer_profiles').select('full_name').eq('id', user.id).single();
      final realFarmerName = profile['full_name'] ?? "Unknown Farmer";

      // 2. Fetch the specific offer
      final offer = await supabase.from('market_offers').select().eq('id', offerId).single();

      // 3. Create the Request in the Cloud using the REAL name
      await supabase.from('farmer_requests').insert({
        'offer_id': offerId,
        'farmer_id': user.id,
        'buyer_id': offer['buyer_id'],
        'farmer_name': realFarmerName, // Overrides the fake 'rahulo' name
        'crop': offer['crop'],
        'qty_offered': quantity,
        'price_agreed': offer['price_per_qtl'],
        'status': 'pending'
      });

      _notifications.insert(0, {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": "Request Sent to Cloud! ☁️",
        "body": "Waiting for buyer to accept.",
        "time": "Just Now",
        "isRead": false
      });
    } catch (e) {
      print("Error sending interest to cloud: $e");
    }
  }

  // --- METHODS FOR BUYER SIDE ---

  Future<void> postBuyerRequirement(String fakeUiBuyerName, String crop, double price, double qty, String msg) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 1. Look up the REAL Company Name securely from the cloud
      final profile = await supabase.from('buyer_profiles').select('company_name').eq('id', user.id).single();
      final realBuyerName = profile['company_name'] ?? "Unknown Company";

      // 2. Create Offer in the Cloud using the REAL name
      await supabase.from('market_offers').insert({
        'buyer_id': user.id,
        'buyer_name': realBuyerName, // Overrides 'My buyer company'
        'crop': crop,
        'price_per_qtl': price,
        'qty_required': qty,
        'location': 'Gujarat', 
        'status': 'open'
      });
    } catch (e) {
      print("Error posting offer to cloud: $e");
    }
  }

  // 🔴 NOTE: This now returns a Future because it fetches from the cloud
  Future<List<Map<String, dynamic>>> getRequestsForBuyer() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final response = await supabase
          .from('farmer_requests')
          .select()
          .eq('buyer_id', user.id)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response.map((req) => {
            "request_id": req['id'],
            "farmer": req['farmer_name'],
            "crop": req['crop'],
            "qty": "${req['qty_offered']} Quintals",
            "price": "₹${req['price_agreed']}/qtl",
            "status": req['status']
          }).toList();
    } catch (e) {
      print("Error loading buyer requests: $e");
      return [];
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      // 1. Fetch the request details so we know WHO the farmer is
      final request = await supabase
          .from('farmer_requests')
          .select('farmer_id, buyer_id, crop, farmer_name')
          .eq('id', requestId)
          .single();

      final farmerId = request['farmer_id'];

      // 2. Update the status in the database
      await supabase
          .from('farmer_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);


      // 3. 🔴 TRIGGER THE BUZZ: Call your new Edge Function
      // We use 'supabase.functions.invoke' to talk to the code you just deployed
      await supabase.functions.invoke(
        'send_notification',
        body: {
          'farmer_id': farmerId,
          'title': 'Deal Accepted! 🚜',
          'body': 'A buyer has accepted your request for ${request['crop']}. Check your app!',
        },
      );
      
      print("✅ Database updated and Notification triggered for farmer: $farmerId");

    } catch (e) {
      print("Error accepting cloud request or sending notification: $e");
    }
  }

  // Notifications
  List<Map<String, dynamic>> getNotifications() => _notifications;
  void clearNotifications() => _notifications.clear();

  Future<List<Map<String, dynamic>>> getAcceptedDeals() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final response = await supabase
          .from('farmer_requests')
          .select()
          .eq('buyer_id', user.id)
          .eq('status', 'accepted') // Filter by accepted status
          .order('created_at', ascending: false);

      return response.map((req) => {
            "request_id": req['id'],
            "farmer": req['farmer_name'],
            "crop": req['crop'],
            "qty": "${req['qty_offered']} Quintals",
            "price": "₹${req['price_agreed']}/qtl",
            "status": req['status']
          }).toList();
    } catch (e) {
      print("Error loading accepted deals: $e");
      return [];
    }
  }
}

