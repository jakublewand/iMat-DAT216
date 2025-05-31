import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/widgets/product_lightbox.dart';
import 'package:imat/pages/main_view.dart';
import 'package:imat/routes.dart';

class ProductDetailView extends StatefulWidget {
  final int productId;
  
  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  bool _lightboxShown = false;

  @override
  void initState() {
    super.initState();
    _showProductLightbox();
  }

  @override
  void didUpdateWidget(ProductDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      setState(() {
        _lightboxShown = false;
      });
      _showProductLightbox();
    }
  }

  void _showProductLightbox() {
    if (_lightboxShown) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final iMat = Provider.of<ImatDataHandler>(context, listen: false);
      final product = iMat.getProduct(widget.productId);
      
      if (product != null) {
        setState(() {
          _lightboxShown = true;
        });
        
        showModalBottomSheet(
          anchorPoint: const Offset(0, 0),
          context: context,
          constraints: const BoxConstraints(maxWidth: 1000),
          isScrollControlled: true,
          isDismissible: true,
          enableDrag: true,
          builder: (BuildContext modalContext) {
            return ProductLightbox(product: product);
          },
        ).then((_) {
          // När lightboxen stängs, gå tillbaka till hem
          if (mounted) {
            context.go(AppRoutes.home);
          }
        });
      } else {
        // Om produkten inte finns, gå till hem
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(AppRoutes.home);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Visa MainView i bakgrunden medan lightboxen laddas
    return const MainView();
  }
} 