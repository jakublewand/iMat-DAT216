import 'package:imat/model/imat/product.dart';

/// Base class for product filters
abstract class ProductFilter {
  /// Apply this filter to a list of products
  List<Product> apply(List<Product> products);
  
  /// Get a description of this filter for debugging
  String get description;
  
  @override
  bool operator ==(Object other) {
    return runtimeType == other.runtimeType && _isEqual(other);
  }
  
  @override
  int get hashCode => _getHashCode();
  
  /// Subclasses should implement this for equality comparison
  bool _isEqual(Object other);
  
  /// Subclasses should implement this for hash code generation
  int _getHashCode();
}

/// Filter products by search string
class SearchFilter extends ProductFilter {
  final String searchTerm;
  
  SearchFilter(this.searchTerm);
  
  @override
  List<Product> apply(List<Product> products) {
    if (searchTerm.isEmpty) return products;
    
    final lowerSearch = searchTerm.toLowerCase();
    return products.where((product) {
      final name = product.name.toLowerCase();
      return name.contains(lowerSearch);
    }).toList();
  }
  
  @override
  String get description => 'Search: "$searchTerm"';
  
  @override
  bool _isEqual(Object other) {
    return other is SearchFilter && other.searchTerm == searchTerm;
  }
  
  @override
  int _getHashCode() => searchTerm.hashCode;
}

/// Filter products by category
class CategoryFilter extends ProductFilter {
  final ProductCategory category;
  
  CategoryFilter(this.category);
  
  @override
  List<Product> apply(List<Product> products) {
    return products.where((product) => product.category == category).toList();
  }
  
  @override
  String get description => 'Category: ${category.name}';
  
  @override
  bool _isEqual(Object other) {
    return other is CategoryFilter && other.category == category;
  }
  
  @override
  int _getHashCode() => category.hashCode;
}

/// Filter products by multiple categories (OR logic)
class MultipleCategoryFilter extends ProductFilter {
  final List<ProductCategory> categories;
  
  MultipleCategoryFilter(this.categories);
  
  @override
  List<Product> apply(List<Product> products) {
    if (categories.isEmpty) return products;
    
    return products.where((product) => 
        categories.contains(product.category)
    ).toList();
  }
  
  @override
  String get description => 'Categories: ${categories.map((c) => c.name).join(", ")}';
  
  @override
  bool _isEqual(Object other) {
    return other is MultipleCategoryFilter && 
           other.categories.length == categories.length &&
           other.categories.toSet().containsAll(categories.toSet());
  }
  
  @override
  int _getHashCode() => categories.fold(0, (prev, cat) => prev ^ cat.hashCode);
}

/// Filter to show only favorite products
class FavoritesFilter extends ProductFilter {
  final Set<int> favoriteProductIds;
  
  FavoritesFilter(this.favoriteProductIds);
  
  @override
  List<Product> apply(List<Product> products) {
    return products.where((product) => favoriteProductIds.contains(product.productId)).toList();
  }
  
  @override
  String get description => 'Favorites only';
  
  @override
  bool _isEqual(Object other) {
    return other is FavoritesFilter && 
           other.favoriteProductIds.length == favoriteProductIds.length &&
           other.favoriteProductIds.containsAll(favoriteProductIds);
  }
  
  @override
  int _getHashCode() => favoriteProductIds.fold(0, (prev, id) => prev ^ id.hashCode);
} 