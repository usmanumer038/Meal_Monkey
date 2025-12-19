import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // ---------- Auth ----------
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String mobile,
    required String address,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'mobile': mobile,
        'address': address,
      },
    );
    if (res.user != null) {
      await supabase.from('profiles').upsert({
        'id': res.user!.id,
        'name': name,
        'mobile': mobile,
        'address': address,
      });
    }
    return res;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      supabase.auth.signInWithPassword(email: email, password: password);

  static Future<void> signOut() => supabase.auth.signOut();

  static Future<void> requestPasswordReset(String email) =>
      supabase.auth.resetPasswordForEmail(email);

  static User? get currentUser => supabase.auth.currentUser;

  // ---------- Profile ----------
  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final res = await supabase.from('profiles').select().eq('id', uid).single();
    return res;
  }

  static Future<void> updateProfile({
    String? name,
    String? mobile,
    String? address,
    String? imageUrl,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (mobile != null) updates['mobile'] = mobile;
    if (address != null) updates['address'] = address;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    await supabase.from('profiles').update(updates).eq('id', uid);
  }

  // ---------- Orders ----------
  static Future<Map<String, dynamic>> createOrder({
    required String deliveryAddress,
    required List<Map<String, dynamic>> items, // each: {id, name, qty, price}
    required double total,
    String? restaurantId, // optional
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final order = await supabase
        .from('orders')
        .insert({
      'user_id': userId,
      'delivery_address': deliveryAddress,
      'total': total,
      'status': 'pending',
      if (restaurantId != null) 'restaurant_id': restaurantId,
    })
        .select()
        .single();

    final orderId = order['id'];
    final orderItems = items
        .map((e) => {
      'order_id': orderId,
      'meal_id': e['id'],
      'meal_name': e['name'],
      'qty': e['qty'],
      'price': e['price'],
    })
        .toList();

    await supabase.from('order_items').insert(orderItems);
    return order;
  }

  static Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    return await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
  }

  // ---------- Favorites ----------
  static Future<void> toggleFavorite(String mealId, bool isFav) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    if (isFav) {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', uid)
          .eq('meal_id', mealId);
    } else {
      await supabase.from('favorites').upsert({
        'user_id': uid,
        'meal_id': mealId,
      });
    }
  }

  static Future<List<String>> fetchFavoriteIds() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    final rows =
    await supabase.from('favorites').select('meal_id').eq('user_id', uid);
    return rows.map<String>((r) => r['meal_id'] as String).toList();
  }

  // ---------- Addresses ----------
  static Future<List<Map<String, dynamic>>> fetchAddresses() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    return await supabase.from('addresses').select().eq('user_id', uid);
  }

  static Future<void> addAddress(Map<String, dynamic> address) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await supabase.from('addresses').insert({
      ...address,
      'user_id': uid,
    });
  }
}