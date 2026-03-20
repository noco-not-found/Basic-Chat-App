import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey =
      GlobalKey<
        FormState
      >(); // for assigning an unique key to froms inorder to refer them when needed.

  var _isLogin = true;
  var _showPassword = false;

  var _enteredEmail = '';
  var _enteredPassword = '';

  File? _selectedImage;

  var _isUploading = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (!_isLogin && _selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();
    // print(_enteredEmail);
    // print(_enteredPassword);
    if (_isLogin) {
      // we can log users in
      try {
        setState(() {
          _isUploading = true;
        });
        final usercred = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${usercred.user!.uid}.jpeg');

        await storageRef.putFile(_selectedImage!);
        final imageURL = storageRef.getDownloadURL();
        print(imageURL);

        print(usercred);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Auth failed  womp womp')),
        );
      }
    } else {
      try {
        setState(() {
          _isUploading = true;
        });
        final usercred = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${usercred.user!.uid}.jpeg');

        await storageRef.putFile(_selectedImage!);
        final imageURL = storageRef.getDownloadURL();
        print(imageURL);

        // print(usercred);
      } on FirebaseAuthException catch (e) {
        if (e.code == "email-already-in-use") {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Auth failed  womp womp')),
        );
      }
    }
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          // For ensuring that the list is scrollable
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/image1.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  // For ensuring that the list is scrollable
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          TextFormField(
                            // input for email
                            decoration: InputDecoration(
                              label: Text("Email Address"),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid message bruh';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),

                          TextFormField(
                            // input for password
                            decoration: InputDecoration(
                              label: Text("Password"),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                icon: Icon(
                                  !_showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: !_showPassword,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return "Password must be atleast 6 characters long bruh";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),

                          const SizedBox(height: 12),

                          if (_isUploading) const CircularProgressIndicator(),

                          if (!_isUploading)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                              child: Text(
                                _isLogin ? "Sign in" : "Create account",
                              ),
                            ),
                          if (!_isUploading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: _isLogin
                                  ? Text("Create an Account")
                                  : Text("Sign in"),
                            ), // for sewicthing between singin and Sign in
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
