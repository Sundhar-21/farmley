import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/shared/design_constants.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedUnit = 'kg';
  int? _selectedCategoryId;
  bool _isLoading = false;
  
  Uint8List? _imageBytes;
  final _picker = ImagePicker();

  final List<String> _units = ['kg', 'g', 'L', 'pc', 'dozen'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final user = supabase.auth.currentUser;

      if (user == null) throw Exception("User not logged in");

      // Verify user is a farmer (double check)
      // In a real app, RLS protects this, but good for UI feedback

      final productData = {
        'farmer_id': user.id,
        'category_id': _selectedCategoryId,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stock_quantity': int.parse(_stockController.text),
        'unit': _selectedUnit,
        'is_available': true,
        'image_url': null, // Will update if image exists
      };
      
      // Upload Image if selected
      if (_imageBytes != null) {
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('product-images').uploadBinary(
          fileName,
          _imageBytes!,
        );
        final imageUrl = supabase.storage.from('product-images').getPublicUrl(fileName);
        productData['image_url'] = imageUrl;
      }

      await supabase.from('products').insert(productData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context); // Go back to dashboard
        // ref.refresh(productsProvider); // If we display products on dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker UI
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                    image: _imageBytes != null 
                        ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageBytes == null 
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                            const SizedBox(height: 8),
                            Text("Tap to add product image", style: GoogleFonts.outfit(color: const Color(0xFF444444), fontWeight: FontWeight.bold)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  prefixIcon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF111111)),
                  labelStyle: GoogleFonts.outfit(color: const Color(0xFF111111), fontWeight: FontWeight.w600),
                  floatingLabelStyle: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.m),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.m),
                    borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFF111111)),
                  labelStyle: GoogleFonts.outfit(color: const Color(0xFF111111), fontWeight: FontWeight.w600),
                  floatingLabelStyle: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.m),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.m),
                    borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: "Price",
                        prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF111111)),
                        labelStyle: GoogleFonts.outfit(color: const Color(0xFF111111), fontWeight: FontWeight.w600),
                        floatingLabelStyle: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.m),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.m),
                          borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value == null || value.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: "Unit",
                        labelStyle: GoogleFonts.outfit(color: const Color(0xFF111111), fontWeight: FontWeight.w600),
                        floatingLabelStyle: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.m),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.m),
                          borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) => setState(() => _selectedUnit = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: "Stock Quantity",
                  prefixIcon: const Icon(Icons.inventory, color: Color(0xFF111111)),
                  labelStyle: GoogleFonts.outfit(color: const Color(0xFF111111), fontWeight: FontWeight.w600),
                  floatingLabelStyle: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.m),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.m),
                    borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF111111)),
                    labelStyle: GoogleFonts.outfit(color: const Color(0xFF111111), fontWeight: FontWeight.w600),
                    floatingLabelStyle: GoogleFonts.outfit(color: DesignColors.primary, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.m)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.m),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.m),
                      borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: categories.map((cat) => DropdownMenuItem<int>(
                    value: cat['id'] as int,
                    child: Text(cat['name'] as String),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text("Error loading categories: $e"),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProduct,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Add Product"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
