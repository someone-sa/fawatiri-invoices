import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fawatiri/models/product.dart';
import 'package:fawatiri/core/utils/number_parser.dart';
import 'package:fawatiri/core/utils/theme.dart';

class ProductRow {
  final String id = const Uuid().v4();
  final nameCtrl  = TextEditingController();
  final priceCtrl = TextEditingController();
  int qty = 1;

  double get unitPrice => double.tryParse(priceCtrl.text) ?? 0;
  double get subtotal => unitPrice * qty;

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

class ProductRowWidget extends StatefulWidget {
  final ProductRow row;
  final List<Product> products;
  final int index;
  final bool showDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const ProductRowWidget({
    super.key,
    required this.row,
    required this.products,
    required this.index,
    required this.showDelete,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<ProductRowWidget> createState() => _ProductRowWidgetState();
}

class _ProductRowWidgetState extends State<ProductRowWidget> {
  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(widget.row.priceCtrl.text) ?? 0;
    final subtotal = price * widget.row.qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showDelete)
                _IconButton(
                  icon: Icons.delete_outline,
                  color: AppTheme.error,
                  onTap: widget.onDelete,
                )
              else
                const SizedBox(width: 40),
              Text(
                'منتج ${widget.index + 1}',
                style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Autocomplete<Product>(
  optionsBuilder: (v) => v.text.isEmpty
      ? const Iterable<Product>.empty()
      : widget.products.where((p) =>
          p.name.toLowerCase().contains(v.text.toLowerCase())),
  displayStringForOption: (p) => p.name,
  onSelected: (p) {
    widget.row.nameCtrl.text = p.name;
    widget.row.priceCtrl.text = '${p.defaultPrice}';
    setState(() {});
    widget.onChanged();
  },
  // ← جديد: تخصيص شكل القائمة المنسدلة
  optionsViewBuilder: (context, onSelected, options) {
    return Align(
      alignment: Alignment.topRight,
      child: Material(
        color: const Color(0xFF2A2A2A), // خلفية داكنة
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width - 64, // عرض مناسب
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final product = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(product),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: index < options.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.defaultPrice.toStringAsFixed(2)} ر.ي',
                        style: AppTheme.labelMedium(color: AppTheme.primary),
                      ),
                      Text(
                        product.name,
                        style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  },
  fieldViewBuilder: (_, ctrl, focus, __) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (ctrl.text != widget.row.nameCtrl.text) {
                  ctrl.text = widget.row.nameCtrl.text;
                }
              });
              return TextField(
                controller: ctrl,
                focusNode: focus,
                textAlign: TextAlign.right,
                style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'اسم المنتج',
                  labelStyle: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.label_outlined, color: AppTheme.onSurfaceVariant, size: 20),
                  filled: true,
                  fillColor: AppTheme.surfaceContainerLow,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => widget.row.nameCtrl.text = v,
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.row.priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'سعر الوحدة',
                    labelStyle: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.attach_money_outlined, color: AppTheme.onSurfaceVariant, size: 20),
                    filled: true,
                    fillColor: AppTheme.surfaceContainerLow,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    final normalized = normalizeNumbers(value);
                    if (normalized != value) {
                      widget.row.priceCtrl.value = TextEditingValue(
                        text: normalized,
                        selection: TextSelection.collapsed(
                          offset: normalized.length,
                        ),
                      );
                    }
                    setState(() {});
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    _IconButton(
                      icon: Icons.remove,
                      color: AppTheme.primary,
                      onTap: () {
                        if (widget.row.qty <= 1) return;
                        setState(() => widget.row.qty--);
                        widget.onChanged();
                      },
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${widget.row.qty}',
                        textAlign: TextAlign.center,
                        style: AppTheme.headlineSmall(color: AppTheme.onSurface),
                      ),
                    ),
                    _IconButton(
                      icon: Icons.add,
                      color: AppTheme.primary,
                      onTap: () {
                        setState(() => widget.row.qty++);
                        widget.onChanged();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                subtotal.toStringAsFixed(2),
                style: AppTheme.headlineSmall(color: AppTheme.primary),
              ),
              const SizedBox(width: 4),
              Text(
                'ر.ي',
                style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }
}