import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:organic_grow/core/models/category_model.dart';
import 'package:organic_grow/core/models/product_model.dart';
import 'package:organic_grow/core/models/vendor_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.15:5000/api';
  static const String imageBaseUrl = 'http://192.168.1.15:5000/';

  static final Dio _dio = _initDio();

  // Helper method to setup Dio with logging and token interceptors
  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _setupInterceptors(dio);
    return dio;
  }

  // Global static token holder to persist in memory during app session
  static String? userToken;
  static const String _tokenKey = 'user_token';

  // Loads the saved token from local storage
  static Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userToken = prefs.getString(_tokenKey);
      if (userToken != null && userToken!.isNotEmpty) {
        initInterceptors();
      }
    } catch (e) {
      debugPrint("Failed to load saved token: $e");
    }
  }

  // Persists the token into local storage
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      userToken = token;
      initInterceptors();
    } catch (e) {
      debugPrint("Failed to save token: $e");
    }
  }

  // Clears the token from local storage (on Logout)
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      userToken = null;
      initInterceptors();
    } catch (e) {
      debugPrint("Failed to clear token: $e");
    }
  }

  // Initialize/re-initialize logging and header interceptors
  static void initInterceptors() {
    _setupInterceptors(_dio);
  }

  // Configures requests to output clean cURL and response structures to debug log
  static void _setupInterceptors(Dio dioInstance) {
    dioInstance.interceptors.clear();
    dioInstance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (userToken != null && userToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $userToken';
          }

          // Print cURL representation of request to debug console
          debugPrint("\n🚀 [Dio Request cURL]");
          debugPrint(_requestToCurl(options));
          debugPrint("--------------------------------------------------------------------------------\n");

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Print successful response details
          debugPrint("\n✅ [Dio Response SUCCESS]");
          debugPrint("STATUS: ${response.statusCode} ${response.statusMessage}");
          debugPrint("URL: ${response.requestOptions.uri}");
          debugPrint("DATA: ${jsonEncode(response.data)}");
          debugPrint("================================================================================\n");

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Print error response details
          debugPrint("\n❌ [Dio Response ERROR]");
          debugPrint("STATUS: ${e.response?.statusCode} ${e.response?.statusMessage}");
          debugPrint("URL: ${e.requestOptions.uri}");
          debugPrint("ERROR: ${e.message}");
          debugPrint("RESPONSE DATA: ${e.response?.data != null ? jsonEncode(e.response?.data) : 'No response body'}");
          debugPrint("================================================================================\n");

          return handler.next(e);
        },
      ),
    );
  }

  // Translates options into shell-executable cURL equivalent
  static String _requestToCurl(RequestOptions options) {
    List<String> curlParts = ['curl -i'];
    curlParts.add('-X ${options.method.toUpperCase()}');

    options.headers.forEach((key, value) {
      if (key != 'cookie') {
        curlParts.add('-H "$key: $value"');
      }
    });

    if (options.data != null) {
      final requestBody = options.data is Map || options.data is List
          ? jsonEncode(options.data)
          : options.data.toString();
      curlParts.add('-d \'$requestBody\'');
    }

    final String finalUrl = options.path.startsWith('http')
        ? options.path
        : '${options.baseUrl}${options.path}';
    curlParts.add('"$finalUrl"');

    return curlParts.join(' \\\n  ');
  }

  // Helper to build full image URL from backend path
  static String buildImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$imageBaseUrl${path.replaceAll('\\', '/')}';
  }

  // ==========================================
  // AUTHENTICATION APIs
  // ==========================================

  /// Sends a 4-digit OTP to the user's phone number
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await _dio.post('/auth/send-otp', data: {
        'phone': phone,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send OTP. Connection error.');
    }
  }

  /// Verifies the OTP and returns the user payload and JWT token
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phone': phone,
        'otp': otp,
      });
      
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['token'] != null) {
        await saveToken(data['token']); // Save and persist token
      }
      return data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Invalid OTP verification failed.');
    }
  }

  /// Fetches the authenticated user profile using authorization token
  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      initInterceptors(); // Ensure interceptors are active
      final response = await _dio.get('/auth/profile');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch user profile.');
    }
  }

  /// Updates user location coordinates and address details on backend
  static Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    String? fullAddress,
    String? city,
    String? state,
    String? pincode,
  }) async {
    try {
      initInterceptors(); // Ensure authorization token header is appended
      final response = await _dio.put('/auth/location', data: {
        'latitude': latitude,
        'longitude': longitude,
        if (fullAddress != null) 'fullAddress': fullAddress,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (pincode != null) 'pincode': pincode,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update user location.');
    }
  }

  /// Registers or updates a user profile on the backend
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String fullAddress,
    required String city,
    required String state,
    required String pincode,
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    try {
      initInterceptors(); // Ensure authorization token header is appended
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'fullAddress': fullAddress,
        'city': city,
        'state': state,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed.');
    }
  }

  // ==========================================
  // CATEGORY APIs
  // ==========================================

  // Fetch categories dynamically from backend database
  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['categories'] ?? [];
        return list.map((json) => Category(
          id: json['_id'] ?? '',
          name: json['name'] ?? '',
          icon: json['icon'] ?? 'local_florist',
        )).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Failed to fetch categories: $e");
      return [];
    }
  }

  // ==========================================
  // PRODUCT APIs
  // ==========================================

  // Fetch all products (for featured section)
  static Future<List<Product>> fetchFeaturedProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['products'] ?? [];
        return list.map((json) {
          final product = Product.fromJson(json);
          // Build full image URL
          return Product(
            id: product.id,
            name: product.name,
            price: product.price,
            mrpPrice: product.mrpPrice,
            image: buildImageUrl(product.image),
            images: product.images.map((e) => buildImageUrl(e)).toList(),
            rating: product.rating == 0 ? 4.5 : product.rating,
            categoryId: product.categoryId,
            categoryName: product.categoryName,
            description: product.description,
            unit: product.unit,
            weight: product.weight,
            stock: product.stock,
            vendorId: product.vendorId,
            vendorName: product.vendorName,
            isAvailable: product.isAvailable,
            isFeatured: product.isFeatured,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Failed to fetch products: $e");
      return [];
    }
  }

  // ==========================================
  // VENDOR APIs 🏪
  // ==========================================

  /// Fetch all approved vendors
  static Future<List<Vendor>> fetchVendors() async {
    try {
      final response = await _dio.get('/vendors');
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['vendors'] ?? [];
        return list.map((json) => Vendor.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Failed to fetch vendors: $e");
      return [];
    }
  }

  /// Fetch nearby vendors based on user location
  static Future<List<Vendor>> fetchNearbyVendors(double lat, double lng, {double radius = 10}) async {
    try {
      final response = await _dio.get('/vendors/nearby', queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
      });
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['vendors'] ?? [];
        return list.map((json) => Vendor.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Failed to fetch nearby vendors: $e");
      return [];
    }
  }

  /// Fetch single vendor detail
  static Future<Vendor?> fetchVendorById(String vendorId) async {
    try {
      final response = await _dio.get('/vendors/$vendorId');
      if (response.data['success'] == true) {
        return Vendor.fromJson(response.data['vendor']);
      }
      return null;
    } catch (e) {
      debugPrint("Failed to fetch vendor: $e");
      return null;
    }
  }

  /// Fetch all products of a specific vendor
  static Future<List<Product>> fetchVendorProducts(String vendorId) async {
    try {
      final response = await _dio.get('/vendors/$vendorId/products');
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['products'] ?? [];
        return list.map((json) {
          final product = Product.fromJson(json);
          return Product(
            id: product.id,
            name: product.name,
            price: product.price,
            mrpPrice: product.mrpPrice,
            image: buildImageUrl(product.image),
            images: product.images.map((e) => buildImageUrl(e)).toList(),
            rating: product.rating,
            categoryId: product.categoryId,
            categoryName: product.categoryName,
            description: product.description,
            unit: product.unit,
            weight: product.weight,
            stock: product.stock,
            vendorId: product.vendorId,
            vendorName: product.vendorName,
            isAvailable: product.isAvailable,
            isFeatured: product.isFeatured,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Failed to fetch vendor products: $e");
      return [];
    }
  }

  // ==========================================
  // VENDOR PANEL APIs (Protected)
  // ==========================================

  /// Fetch Vendor Dashboard Stats
  static Future<Map<String, dynamic>?> fetchVendorDashboard() async {
    try {
      initInterceptors();
      final response = await _dio.get('/vendors/panel/dashboard');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Failed to fetch vendor dashboard: $e");
      return null;
    }
  }

  /// Toggle Shop Open/Close Status
  static Future<Map<String, dynamic>?> toggleShopStatus() async {
    try {
      initInterceptors();
      final response = await _dio.put('/vendors/panel/toggle-shop');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Failed to toggle shop status: $e");
      return null;
    }
  }

  // ==========================================
  // CART APIs 🛒 (Server-Side)
  // ==========================================

  /// Fetch user's current cart from server
  static Future<Map<String, dynamic>?> fetchCart() async {
    try {
      initInterceptors();
      final response = await _dio.get('/cart');
      if (response.data['success'] == true) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint("Failed to fetch cart: $e");
      return null;
    }
  }

  /// Add item to cart (handles vendor conflict with 409 response)
  /// Returns: { success: true, cart: {...} } or { success: false, conflict: true, ... }
  static Future<Map<String, dynamic>> addToCart(String productId, {int quantity = 1}) async {
    try {
      initInterceptors();
      final response = await _dio.post('/cart/add', data: {
        'productId': productId,
        'quantity': quantity,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // Vendor conflict — return the conflict data for UI to handle
        return e.response?.data as Map<String, dynamic>;
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to add to cart.');
    }
  }

  /// Replace cart (user confirmed vendor switch)
  static Future<Map<String, dynamic>> replaceCart(String productId, {int quantity = 1}) async {
    try {
      initInterceptors();
      final response = await _dio.post('/cart/replace', data: {
        'productId': productId,
        'quantity': quantity,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to replace cart.');
    }
  }

  /// Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItem(String productId, int quantity) async {
    try {
      initInterceptors();
      final response = await _dio.put('/cart/update', data: {
        'productId': productId,
        'quantity': quantity,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update cart.');
    }
  }

  /// Remove single item from cart
  static Future<Map<String, dynamic>> removeCartItem(String productId) async {
    try {
      initInterceptors();
      final response = await _dio.delete('/cart/remove/$productId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to remove item.');
    }
  }

  /// Clear entire cart
  static Future<Map<String, dynamic>> clearCart() async {
    try {
      initInterceptors();
      final response = await _dio.delete('/cart/clear');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to clear cart.');
    }
  }

  // ==========================================
  // BANNER (mock for now)
  // ==========================================

  // Fetch banners (mock compatibility layer for existing screens)
  static Future<List<String>> fetchBanners() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      "assets/banner_images/banner1.jpg",
      "assets/banner_images/banner2.png",
      "assets/banner_images/banner3.png",
    ];
  }
}