import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:imat/model/imat/credit_card.dart';
import 'package:imat/model/imat/customer.dart';
import 'package:imat/model/imat/order.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/product_detail.dart';
import 'package:imat/model/imat/settings.dart';
import 'package:imat/model/imat/shopping_cart.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat/user.dart';
import 'package:imat/model/internet_handler.dart';
import 'package:imat/model/product_filter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ImatDataHandler extends ChangeNotifier {
  // Initializes the IMatDataHandler
  ImatDataHandler() {
    _setUp();
  }

  // Login state management
  bool _isLoggedIn = false;
  static const String _loginKey = 'loggedIn';

  // Never changing, only loaded on startup
  List<Product> get products => _products;

  List<ProductDetail> get details => _details;

  // Access a list of all previous orders
  List<Order> get orders => _orders;

  //
  // Handle product filtering
  //

  // Current active filters
  final List<ProductFilter> _filters = [];

  // Reactive getter that returns filtered products based on current filters
  List<Product> get selectProducts => _getFilteredProducts();

  // Get current active filters
  List<ProductFilter> get activeFilters => List.unmodifiable(_filters);

  // Get the current category filter if one exists
  CategoryFilter? get currentCategoryFilter => 
      _filters.whereType<CategoryFilter>().firstOrNull;

  // Get all active category filters (including multiple category filters)
  List<CategoryFilter> get activeCategoryFilters => 
      _filters.whereType<CategoryFilter>().toList();

  // Get the current multiple category filter if one exists
  MultipleCategoryFilter? get currentMultipleCategoryFilter => 
      _filters.whereType<MultipleCategoryFilter>().firstOrNull;

  // Get all active category types
  List<ProductCategory> get activeCategories {
    final singleCategories = activeCategoryFilters.map((filter) => filter.category).toList();
    final multipleCategories = currentMultipleCategoryFilter?.categories ?? [];
    return [...singleCategories, ...multipleCategories];
  }

  // Check if any of the given categories are currently active
  bool areCategoriesActive(List<ProductCategory> categories) {
    final activeSet = activeCategories.toSet();
    return categories.any((category) => activeSet.contains(category));
  }

  // Get the current search filter if one exists
  SearchFilter? get currentSearchFilter => 
      _filters.whereType<SearchFilter>().firstOrNull;

  // Check if search is currently active
  bool get isSearchActive => currentSearchFilter != null;

  // Apply filters to get the current product selection
  List<Product> _getFilteredProducts() {
    List<Product> result = List.from(_products);
    
    for (final filter in _filters) {
      result = filter.apply(result);
    }
    
    return result;
  }

  // Add a filter to the current filters
  void addFilter(ProductFilter filter) {
    // Remove any existing filter of the same type for search and category
    if (filter is SearchFilter) {
      _filters.removeWhere((f) => f is SearchFilter);
    } else if (filter is CategoryFilter || filter is MultipleCategoryFilter) {
      _filters.removeWhere((f) => f is CategoryFilter || f is MultipleCategoryFilter);
    } else if (filter is FavoritesFilter) {
      _filters.removeWhere((f) => f is FavoritesFilter);
    }
    
    _filters.add(filter);
    notifyListeners();
  }

  // Remove a specific filter
  void removeFilter(ProductFilter filter) {
    _filters.remove(filter);
    notifyListeners();
  }

  // Remove all filters of a specific type
  void removeFiltersOfType<T extends ProductFilter>() {
    if (T == CategoryFilter) {
      // Remove both CategoryFilter and MultipleCategoryFilter when removing category filters
      _filters.removeWhere((filter) => filter is CategoryFilter || filter is MultipleCategoryFilter);
    } else {
      _filters.removeWhere((filter) => filter is T);
    }
    notifyListeners();
  }

  // Clear all filters
  void clearAllFilters() {
    _filters.clear();
    notifyListeners();
  }

  // Convenience methods for common filtering operations
  
  // Show all products (clear all filters)
  void selectAllProducts() {
    clearAllFilters();
    // Clear the search field UI
    _onSearchClear?.call();
  }

  // Show only favorite products
  void selectFavorites() {
    final favoriteIds = _favorites.keys.toSet();
    clearAllFilters();
    addFilter(FavoritesFilter(favoriteIds));
  }

  // Callback for when search field should be cleared
  VoidCallback? _onSearchClear;
  
  // Set callback for clearing search field
  void setSearchClearCallback(VoidCallback? callback) {
    _onSearchClear = callback;
  }

  // Filter by category
  void selectCategory(ProductCategory category) {
    // Clear search filters when selecting a category
    removeFiltersOfType<SearchFilter>();
    removeFiltersOfType<FavoritesFilter>();
    // Clear the search field UI
    _onSearchClear?.call();
    // Clear any existing category filters (both single and multiple)
    _filters.removeWhere((filter) => filter is CategoryFilter || filter is MultipleCategoryFilter);
    addFilter(CategoryFilter(category));
  }

  // Filter by multiple categories (for category buckets)
  void selectCategories(List<ProductCategory> categories) {
    // Clear search filters when selecting categories
    removeFiltersOfType<SearchFilter>();
    removeFiltersOfType<FavoritesFilter>();
    // Clear the search field UI
    _onSearchClear?.call();
    
    // Use MultipleCategoryFilter for OR logic
    addFilter(MultipleCategoryFilter(categories));
  }

  // Filter by search term
  void searchProducts(String searchTerm) {
    if (searchTerm.isEmpty) {
      removeFiltersOfType<SearchFilter>();
      removeFiltersOfType<FavoritesFilter>();
    } else {
      // Clear category filters when searching (both single and multiple)
      _filters.removeWhere((filter) => filter is CategoryFilter || filter is MultipleCategoryFilter);
      removeFiltersOfType<FavoritesFilter>();
      addFilter(SearchFilter(searchTerm));
    }
  }

  // Legacy methods for backward compatibility (now using filters internally)
  
  // Returnerar alla produkter som hör till category.
  List<Product> findProductsByCategory(ProductCategory category) {
    return CategoryFilter(category).apply(_products);
  }

  // Returnerar en lista med alla produkter vars namn matchar search.
  List<Product> findProducts(String search) {
    return SearchFilter(search).apply(_products);
  }

  // Returnerar produkten med productId idNbr eller null
  // om produkten inte finns med i sortimentet.
  Product? getProduct(int idNbr) {
    for (final product in _products) {
      if (product.productId == idNbr) {
        return product;
      }
    }
    return null;
  }

  //
  // Manage favorites
  //

  // Returnerar en lista med alla favoritmarkerade produkter.
  List<Product> get favorites => _favorites.values.toList();

  // Returnerar om product är markerad som favorit.
  bool isFavorite(Product product) {
    return _favorites[product.productId] != null;
  }

  // 'Togglar' om product är favorit eller inte.
  // Dvs om produkten är favorit tas den bort annars läggs
  // läggs den till.
  // Meddelar GUI:t att data har ändrats och uppdaterar på servern
  void toggleFavorite(Product product) {
    var pid = product.productId;

    if (_favorites.containsKey(pid)) {
      _favorites.remove(pid);
      _removeFavorite(product);
    } else {
      _favorites[pid] = product;
      _addFavorite(product);
    }
    
    // Update favorite filters if active
    _updateFavoriteFilters();
  }

  // Update favorite filters with current favorite list
  void _updateFavoriteFilters() {
    final favoriteFilterIndex = _filters.indexWhere((filter) => filter is FavoritesFilter);
    if (favoriteFilterIndex != -1) {
      // Replace existing favorite filter with updated one
      _filters[favoriteFilterIndex] = FavoritesFilter(_favorites.keys.toSet());
      notifyListeners();
    }
  }

  CreditCard getCreditCard() => _creditCard;

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  void setCreditCard(CreditCard card) async {
    _creditCard.cardType = card.cardType;
    _creditCard.holdersName = card.holdersName;
    _creditCard.validMonth = card.validMonth;
    _creditCard.validYear = card.validYear;
    _creditCard.cardNumber = card.cardNumber;
    _creditCard.verificationCode = card.verificationCode;

    String _ = await InternetHandler.setCreditCard(_creditCard);
    notifyListeners();
  }

  Customer getCustomer() => _customer;

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  void setCustomer(Customer customer) async {
    _customer.firstName = customer.firstName;
    _customer.lastName = customer.lastName;
    _customer.phoneNumber = customer.phoneNumber;
    _customer.mobilePhoneNumber = customer.mobilePhoneNumber;
    _customer.email = customer.email;
    _customer.address = customer.address;
    _customer.postCode = customer.postCode;
    _customer.postAddress = customer.postAddress;

    String _ = await InternetHandler.setCustomer(_customer);
    notifyListeners();
  }

  // Sparar information till servern och
  // meddelar gränssnittet att data ändrats
  User getUser() => _user;

  void setUser(User user) async {
    _user.userName = user.userName;
    _user.password = user.password;

    String _ = await InternetHandler.setUser(_user);
    notifyListeners();
  }

  // Kontrollerar om användaren är inloggad
  bool get isLoggedIn => _isLoggedIn;

  // Spara login-status till SharedPreferences
  Future<void> _saveLoginState(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, loggedIn);
    _isLoggedIn = loggedIn;
    notifyListeners();
  }

  // Ladda login-status från SharedPreferences
  Future<void> _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_loginKey) ?? false;
  }

  // Loggar ut användaren
  Future<void> logout() async {
    _user = User('', '');
    await _saveLoginState(false);
  }

  // Loggar in användaren genom att kontrollera credentials mot API:et
  Future<String?> login(String username, String password) async {
    try {
      // Hämta användardata från servern för att verifiera credentials
      String userJson = await InternetHandler.getUser();
      
      if (userJson.isNotEmpty) {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        User storedUser = User.fromJson(userMap);
        
        // Kontrollera om username och password matchar
        if (storedUser.userName == username && storedUser.password == password) {
          _user = User(username, password);
          await _saveLoginState(true);
          
          // Load user data immediately after successful login
          await _loadUserData();
          
          return null; // Success, no error
        }
      }
      
      return 'Felaktig e-post eller lösenord';
    } catch (e) {
      print('Login error: $e');
      return 'Ett fel uppstod vid inloggning';
    }
  }

  // Ladda användardata (customer, creditcard, orders, etc.) efter inloggning
  Future<void> _loadUserData() async {
    try {
      // Fetching CreditCard, Customer & User
      var response = await InternetHandler.getCreditCard();
      var singleJson = jsonDecode(response);
      _creditCard = CreditCard.fromJson(singleJson);

      response = await InternetHandler.getCustomer();
      singleJson = jsonDecode(response);
      _customer = Customer.fromJson(singleJson);

      response = await InternetHandler.getUser();
      singleJson = jsonDecode(response);
      _user = User.fromJson(singleJson);

      response = await InternetHandler.getOrders();
      singleJson = jsonDecode(response);
      var jsonData = jsonDecode(response);
      _orders.clear();
      _orders.addAll(jsonData.map((item) => Order.fromJson(item)).toList());

      response = await InternetHandler.getShoppingCart();
      singleJson = jsonDecode(response);
      _shoppingCart = ShoppingCart.fromJson(singleJson);

      response = await InternetHandler.getExtras();
      _extras = jsonDecode(response);
      
      notifyListeners(); // Notify UI that user data has been loaded
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Registrera ny användare och logga in automatiskt
  Future<String?> registerUser(String username, String password, Customer customer) async {
    try {
      // Create new user
      final user = User(username, password);
      
      // Set user data on server (these are async)
      setUser(user);
      setCustomer(customer);
      setCreditCard(CreditCard.empty);
      
      // Clear cart and filters (these are sync)
      shoppingCartClear();
      clearAllFilters();
      
      // Set current user and log in
      _user = user;
      await _saveLoginState(true);
      
      return null; // Success, no error
    } catch (e) {
      print('Registration error: $e');
      return 'Ett fel uppstod vid registrering';
    }
  }

  // Returnerar ProductDetail för produkten p
  // eller null om information saknas
  ProductDetail? getDetail(Product p) {
    return getDetailWithId(p.productId);
  }

  // Returnerar ProductDetail för produkten p
  // med idNbr eller null om information saknas
  ProductDetail? getDetailWithId(int idNbr) {
    for (ProductDetail d in _details) {
      if (d.productId == idNbr) {
        return d;
      }
    }
    return null;
  }

  // Returnerar en Map med strängar som nycklar och
  // något som kan uttryckas med json som värde.
  Map<String, dynamic> getExtras() {
    return _extras;
  }

  // Lägg till ett nytt värde för nyckeln key.
  // Om key redan finns så ersätts dess värde med jsonData.
  // jsonData ska vara en bastyp, en lista eller en map.
  // Sparar data till servern och meddelar GUI:t att data ändrats
  void addExtra(String key, dynamic jsonData) {
    _extras[key] = jsonData;
    setExtras(_extras);
  }

  // Tar bort key från extras.
  // Sparar data till servern och meddelar GUI:t att data ändrats.
  void removeExtra(String key) {
    _extras.remove(key);
    setExtras(_extras);
  }

  // Sparar extras till servern och meddelar GUI:t att data ändrats.
  // Om man ändrar mapen som returneras från getExtras direkt så
  // måste denna metod anropas för att data ska sparas och GUI:t uppdateras
  // annars behöver man inte använda den.
  void setExtras(Map<String, dynamic> extras) async {
    await InternetHandler.setExtras(extras);
    notifyListeners();
  }

  // Cache for Image widgets to avoid recreating them
  final Map<int, Widget> _imageWidgetCache = {};
  
  // Maximum number of cached image widgets to prevent memory issues
  static const int _maxImageWidgetCache = 50;

  // Preload images for the first N products to improve initial loading
  void preloadInitialImages({int count = 20}) {
    final productsToPreload = _products.take(count);
    for (final product in productsToPreload) {
      final url = InternetHandler.getImageUrl(product.productId);
      _triggerLoadIfNeeded(url);
    }
  }

  // Clear old cache entries when it gets too large
  void _manageCacheSize() {
    if (_imageWidgetCache.length > _maxImageWidgetCache) {
      // Remove oldest entries (simple FIFO approach)
      final keysToRemove = _imageWidgetCache.keys.take(_imageWidgetCache.length - _maxImageWidgetCache);
      for (final key in keysToRemove) {
        _imageWidgetCache.remove(key);
      }
    }
  }

  // Returnerar bilden som hör till produkten p.
  // Om bilden inte finns cachad returneras en tillfällig bild.
  // När bilden har hämtats meddelas gränssnittet och bilden visas
  // automatiskt om getImage använts i ett sammanhang som använder watch.
  // getImage använder getImageData med Boxfit.cover.
  Widget getImage(Product p) {
    // Check if we have a cached widget for this product
    if (_imageWidgetCache.containsKey(p.productId)) {
      return _imageWidgetCache[p.productId]!;
    }

    String url = InternetHandler.getImageUrl(p.productId);
    
    // Check if we have cached image data
    Uint8List? imageData = _imageData[url];
    
    Widget imageWidget;
    if (imageData != null) {
      // Use cached image data
      imageWidget = Image.memory(
        imageData,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(Icons.image, size: 48, color: Colors.grey[400]),
          );
        },
      );
    } else {
      // Trigger loading if not already in progress
      _triggerLoadIfNeeded(url);
      
      // Return loading placeholder
      imageWidget = Container(
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey[400],
          ),
        ),
      );
    }
    
    // Manage cache size before adding new entry
    _manageCacheSize();
    
    // Cache the widget
    _imageWidgetCache[p.productId] = imageWidget;
    return imageWidget;
  }

  // Can be used to create desired images using
  // Image.memory
  // final bytes = getImageData(product);
  // if (bytes != null)
  // Image img = Image.memory(bytes + other parameters)

  // Returnerar bild-data tillhörande produktbilden för p.
  // Om bilden inte är cachad returneras null.
  // När bilden har hämtats uppdateras resultatet precis som
  // för getImage. Man behöver själv hantera null. T ex något i stil med
  // var data = getImageData(p);
  // Widget image = data ?? Image.memory(data) : CircularSpinner();
  // När man använder Image.memory kan man ange ett flertal parametrar
  // t ex storlek. Kolla dokumentationen för Image.
  Uint8List? getImageData(Product p) {
    String url = InternetHandler.getImageUrl(p.productId);

    return _getImageData(url);
  }

  // Returnerar kundvagnen. Så längt det är möjligt är det att
  // fördedra att ändra kundvagnen med metoderna nedan.
  // Om man gör något annat behöver man anropa setShoppingCart för
  // att ändringarna ska sparas.
  ShoppingCart getShoppingCart() => _shoppingCart;

  // Lägger till item i kundvagnen. Om den produkt som ingår i item redan finns
  // i kundvagnen så ökas mängden på det som fanns redan.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartAdd(ShoppingItem item) {
    //print('Adding ${item.product.name}');
    _shoppingCart.addItem(item);

    // Update and notify listeners
    setShoppingCart();
  }

  // Uppdaterar mängden som finns av item med delta.
  // Ett positiv värde ökar mängden och ett negativ minskar.
  // Om värdet blir <= 0 så tas item bort ur kundvagnen.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartUpdate(ShoppingItem item, {double delta = 0.0, absolute = false}) {
    //print('Adding ${item.product.name}');
    _shoppingCart.updateItem(item, delta: delta, absolute: absolute);

    // Update and notify listeners
    setShoppingCart();
  }

  // Tar bort item från kundvagnen.
  // Uppdaterar till servern och meddelar GUI:t att kundvagnen ändrats.
  void shoppingCartRemove(ShoppingItem item) {
    //print('Removing ${item.product.name}');
    _shoppingCart.removeItem(item);

    // Update and notify listeners
    setShoppingCart();
  }

  // Tömmer kundvagnen.
  // Uppdaterar på servern och meddelar GUI:t.
  void shoppingCartClear() {
    _shoppingCart.clear();

    // Update and notify listeners
    setShoppingCart();
  }

  double shoppingCartTotal() {
    double total = 0;

    for (final item in _shoppingCart.items) {
      total = total + item.amount * item.product.price;
    }
    return total;
  }

  // Uppdaterar kundvagnen på servern och
  // meddelar GUI:t att kundvagnen ändrats.
  void setShoppingCart() async {
    await InternetHandler.setShoppingCart(_shoppingCart);
    notifyListeners();
  }

  void placeOrder() async {
    await InternetHandler.placeOrder();
    _shoppingCart.clear();
    notifyListeners();

    // Reload orders
    var response = await InternetHandler.getOrders();

    //print('Orders $response');
    var jsonData = jsonDecode(response) as List;

    _orders.clear();
    _orders.addAll(jsonData.map((item) => Order.fromJson(item)).toList());
    notifyListeners();
  }

  ///
  // Code below this line is private and can be disregarded
  ///
  void _addFavorite(Product p) async {
    String _ = await InternetHandler.addFavorite(p.productId);

    notifyListeners();
  }

  void _removeFavorite(Product p) async {
    String _ = await InternetHandler.removeFavorite(p.productId);

    notifyListeners();
  }

  final List<Product> _products = [];

  final List<ProductDetail> _details = [];

  final Map<int, Product> _favorites = {};

  User _user = User('', '');

  Customer _customer = Customer('', '', '', '', '', '', '', '');

  CreditCard _creditCard = CreditCard('', '', 12, 25, '', 0);

  ShoppingCart _shoppingCart = ShoppingCart([]);

  final List<Order> _orders = [];

  Map<String, dynamic> _extras = {};

  //final Map<int, Image> _imageCache = HashMap();

  /*
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
*/

  //class ImageCacheProvider extends ChangeNotifier {
  /* import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
*/

  //class ImageCacheProvider extends ChangeNotifier {
  final Map<String, Uint8List> _imageData = {};
  final Set<String> _loadingUrls = {};
  final Queue<String> _queue = Queue();

  final int maxConcurrentRequests = 5;
  int _currentRequests = 0;

  //ImageCacheProvider({this.maxConcurrentRequests = 5});

  /// Students can use this to get raw image bytes
  Uint8List? _getImageData(String url) {
    _triggerLoadIfNeeded(url);
    return _imageData[url];
  }

  void _triggerLoadIfNeeded(String url) {
    if (_imageData.containsKey(url) ||
        _loadingUrls.contains(url) ||
        _queue.contains(url)) {
      return;
    }

    _queue.add(url);
    _tryNext();
  }

  void _tryNext() {
    if (_currentRequests >= maxConcurrentRequests || _queue.isEmpty) return;

    final url = _queue.removeFirst();
    _loadingUrls.add(url);
    _currentRequests++;

    _fetch(url).whenComplete(() {
      _loadingUrls.remove(url);
      _currentRequests--;
      _tryNext();
    });
  }

  Future<void> _fetch(String url) async {
    //print(url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: InternetHandler.apiKeyHeader,
      );
      if (response.statusCode == 200) {
        _imageData[url] = response.bodyBytes;
        
        // Clear cached widgets for this URL so they get recreated with new data
        final productId = _extractProductIdFromUrl(url);
        if (productId != null) {
          _imageWidgetCache.remove(productId);
        }
        
        notifyListeners(); // So UI rebuilds if needed
      } else {
        debugPrint('Failed to load image $url: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching $url: $e');
    }
  }

  // Helper method to extract product ID from image URL
  int? _extractProductIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return int.tryParse(segments.last);
      }
    } catch (e) {
      debugPrint('Error extracting product ID from URL: $e');
    }
    return null;
  }

  /*
  // Not working, there's no corresponding endpoint
  void setFavorites() async {
    String _ = await InternetHandler.setFavorites(favorites);
    notifyListeners();
  }
  */

  void _setUp() async {
    InternetHandler.kGroupId = Settings.groupId;

    // Load login state first
    await _loadLoginState();

    // Fetching all products
    var response = await InternetHandler.getProducts();

    //print(response);
    List<dynamic> jsonData = jsonDecode(response);

    _products.clear();
    _products.addAll(jsonData.map((item) => Product.fromJson(item)).toList());

    // Fetching product details
    response = await InternetHandler.getDetails();
    jsonData = jsonDecode(response);

    _details.clear();
    _details.addAll(
      jsonData.map((item) => ProductDetail.fromJson(item)).toList(),
    );

    // Fetching favorites
    response = await InternetHandler.getFavorites();
    jsonData = jsonDecode(response);

    var favList = jsonData.map((item) => Product.fromJson(item)).toList();
    for (final product in favList) {
      _favorites[product.productId] = product;
    }

    notifyListeners();

    // Preload images for the first few products to improve initial loading experience
    preloadInitialImages();

    // Only fetch user data if logged in
    if (_isLoggedIn) {
      // Fetching CreditCard, Customer & User
      response = await InternetHandler.getCreditCard();
      var singleJson = jsonDecode(response);
      _creditCard = CreditCard.fromJson(singleJson);

      response = await InternetHandler.getCustomer();
      singleJson = jsonDecode(response);
      _customer = Customer.fromJson(singleJson);

      response = await InternetHandler.getUser();
      singleJson = jsonDecode(response);
      _user = User.fromJson(singleJson);

      //print('User ${singleJson}');

      response = await InternetHandler.getOrders();
      singleJson = jsonDecode(response);

      jsonData = jsonDecode(response);

      _orders.clear();
      _orders.addAll(jsonData.map((item) => Order.fromJson(item)).toList());

      response = await InternetHandler.getShoppingCart();

      //print('Cart $response');
      singleJson = jsonDecode(response);
      _shoppingCart = ShoppingCart.fromJson(singleJson);

      response = await InternetHandler.getExtras();
      _extras = jsonDecode(response);
    } else {
      // Initialize with empty data when not logged in
      _creditCard = CreditCard.empty;
      _customer = Customer('', '', '', '', '', '', '', '');
      _user = User('', '');
      _orders.clear();
      _shoppingCart = ShoppingCart([]);
      _extras = {};
    }

    /* Testcode

    print('New extras $_extras');
    _extras['Brand'] = 'Findus';

    var _ = await InternetHandler.setExtras(_extras);

    response = await InternetHandler.getExtras();
    _extras = jsonDecode(response);
    // Testcode

    print('Got ${_extras}');

     Testcode 
     */

    notifyListeners();
  }
}
