import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

// this block for gender selection part (radio buttons)

enum Gender { Men, Women }

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({super.key});
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _discountFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;

  // if this screen is redirected from the "ADD" IconButton
  var _editedProduct = Product(
      id: '',
      title: '',
      price: 0,
      description: '',
      imageUrl: '',
      isFavorite: false,
      isMan: true,
      discount: 0,
      category: '');

  Map<String, dynamic> _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
    'isMan': true,
    'discount': '',
    'category': ''
  };
  Gender? _selectedGender = Gender.Men;

  @override
  void initState() {
    _selectedGender = _initValues['isMan'] == true ? Gender.Men : Gender.Women;
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          !_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) {
        return;
      }
      setState(() {});
    }
  }

// if this screen is redirected from the "Edit" IconButton of a UsersProductItem
  @override
  void didChangeDependencies() {
    // first set the isInit var to true (When the widget is first built), then fetch the
    // selected productItem from the "Products" provider. Then set the _isInit to false
    // since the productItem has already been fetched the first time this widget got built
    if (_isInit) {
      final productid = ModalRoute.of(context)!.settings.arguments;
      if (productid != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productid as String);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
          'isMan': _editedProduct.isMan,
          'discount': _editedProduct.discount.toString(),
          'category': _editedProduct.category
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }

    _selectedGender = _initValues['isMan'] == true ? Gender.Men : Gender.Women;

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  Future<void> _saveForm() async {
    // dummy image url link
    // https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id == '') {
      // adds product item
      try {
        // _editedProduct.isMan = genderObject.sele
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("An error occured !"),
                  content: const Text("Something went wrong!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("Okay"))
                  ],
                ));
      }
    } else {
      // edits product item
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    }
    setState(() {
      _isLoading:
      false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Edit Product",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: value!,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite,
                              isMan: _editedProduct.isMan,
                              discount: _editedProduct.discount,
                              category: _editedProduct.category);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the value';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: double.parse(value!),
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite,
                              isMan: _editedProduct.isMan,
                              discount: _editedProduct.discount,
                              category: _editedProduct.category);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a price";
                          }
                          if (double.tryParse(value) == '') {
                            return "Please enter a valid number";
                          }
                          if (double.parse(value) <= 0) {
                            return "Price must be greater than zero";
                          }
                          return null;
                        },
                        focusNode: _priceFocusNode,
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: value!,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite,
                              isMan: _editedProduct.isMan,
                              discount: _editedProduct.discount,
                              category: _editedProduct.category);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a description";
                          }
                          if (value.length < 10) {
                            return "The description is too short (<10)";
                          }
                          // returning null means no error in validation and the opposite when string is returned
                          return null;
                        },
                        focusNode: _descriptionFocusNode,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_discountFocusNode);
                        },
                      ),
                      //discount
                      TextFormField(
                        initialValue: _initValues['discount'],
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite,
                              isMan: _editedProduct.isMan,
                              discount: double.parse(value!),
                              category: _editedProduct.category);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the discount, if there is none, enter 0";
                          }
                          // returning null means no error in validation and the opposite when string is returned
                          return null;
                        },
                        focusNode: _discountFocusNode,
                        decoration:
                            const InputDecoration(labelText: 'Discount %'),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_categoryFocusNode);
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      //category
                      TextFormField(
                        initialValue: _initValues['category'],
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite,
                              isMan: _editedProduct.isMan,
                              discount: _editedProduct.discount,
                              category: value!);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the category of the product";
                          }
                          // returning null means no error in validation and the opposite when string is returned
                          return null;
                        },
                        focusNode: _categoryFocusNode,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        textInputAction: TextInputAction.next,
                      ),
                      // Gender Selection
                      Row(
                        children: <Widget>[
                          Container(
                            constraints: const BoxConstraints(
                                minWidth: 60, maxWidth: 160),
                            child: ListTile(
                              title: const Text('Men'),
                              leading: Radio<Gender>(
                                value: Gender.Men,
                                groupValue: _selectedGender,
                                onChanged: (Gender? value) {
                                  _editedProduct = Product(
                                      title: _editedProduct.title,
                                      id: _editedProduct.id,
                                      price: _editedProduct.price,
                                      description: _editedProduct.description,
                                      imageUrl: _editedProduct.imageUrl,
                                      isFavorite: _editedProduct.isFavorite,
                                      isMan: true,
                                      discount: _editedProduct.discount,
                                      category: _editedProduct.category);
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(
                                minWidth: 60, maxWidth: 160),
                            child: ListTile(
                              title: const Text('Women'),
                              leading: Radio<Gender>(
                                value: Gender.Women,
                                groupValue: _selectedGender,
                                onChanged: (Gender? value) {
                                  _editedProduct = Product(
                                      title: _editedProduct.title,
                                      id: _editedProduct.id,
                                      price: _editedProduct.price,
                                      description: _editedProduct.description,
                                      imageUrl: _editedProduct.imageUrl,
                                      isFavorite: _editedProduct.isFavorite,
                                      isMan: false,
                                      discount: _editedProduct.discount,
                                      category: _editedProduct.category);
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? const Text("Enter an Image URL")
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                              child: TextFormField(
                            onSaved: (value) {
                              _editedProduct = Product(
                                  title: _editedProduct.title,
                                  id: _editedProduct.id,
                                  price: _editedProduct.price,
                                  description: _editedProduct.description,
                                  imageUrl: value!,
                                  isFavorite: _editedProduct.isFavorite,
                                  isMan: _editedProduct.isMan,
                                  discount: _editedProduct.discount,
                                  category: _editedProduct.category);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a URL";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid URL";
                              }

                              return null;
                            },
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _saveForm,
                            // onEditingComplete: () {
                            //   setState(() {});
                            // },
                          )),
                        ],
                      ),
                    ],
                  ))),
    );
  }
}
