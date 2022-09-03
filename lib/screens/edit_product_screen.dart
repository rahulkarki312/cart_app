import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  // if this screen is redirected from the "ADD" IconButton
  var _editedProduct = Product(
      id: '',
      title: '',
      price: 0,
      description: '',
      imageUrl: '',
      isFavorite: false);

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

// if this screen is redirected from the "Edit" IconButton of a UsersProductItem
  @override
  void didChangeDependencies() {
    // first set the isInit var to true (When the widget is first built), then fetch the
    // selected productItem from the "Products" provider. Then set the _isInit to false
    // since the productItem has already been fetched the first time this widget got built
    if (_isInit) {
      final productid = ModalRoute.of(context)!.settings.arguments as String;
      if (productid != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productid);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl.toString();
      }
    }
    _isInit = false;
    super.didChangeDependencies();
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

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    if (_editedProduct.id == null) {
      Provider.of<Products>(context).addProduct(_editedProduct);
    } else {
      Provider.of<Products>(context)
          .updateProduct(_editedProduct.id, _editedProduct);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
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
                          isFavorite: _editedProduct.isFavorite);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the value';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Title'),
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
                          isFavorite: _editedProduct.isFavorite);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a price";
                      }
                      if (double.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      if (double.parse(value) <= 0) {
                        return "Price must be greater than zero";
                      }
                    },
                    focusNode: _priceFocusNode,
                    decoration: InputDecoration(labelText: 'Price'),
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
                          isFavorite: _editedProduct.isFavorite);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a description";
                      }
                      if (value.length < 10) {
                        return "The description is too short (<10)";
                      }
                      return null;
                    },
                    focusNode: _descriptionFocusNode,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        margin: EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: _imageUrlController.text.isEmpty
                            ? Text("Enter an Image URL")
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
                              title: value!,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: value,
                              isFavorite: _editedProduct.isFavorite);
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
                        focusNode: _imageUrlFocusNode,
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        onFieldSubmitted: (_) => _saveForm,
                        // onEditingComplete: () {
                        //   setState(() {});
                        // },
                      )),
                    ],
                  )
                ],
              ))),
    );
  }
}
