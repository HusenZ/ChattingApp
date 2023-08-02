import 'dart:io';
import 'package:chit_chat/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen>{
  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  var _enteredemail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;
  var _enteredUsername = '';

  void _submit() async{
    final isValid = _formKey.currentState!.validate();

    if(!isValid || !_isLogin && _selectedImage == null){
      return;
    }

    _formKey.currentState!.save();
    try{
      setState(() {
        _isAuthenticating = true;
      });
      if(_isLogin){
      final userCredentials = await _firebase
          .signInWithEmailAndPassword(
          email: _enteredemail, password: _enteredPassword);
      }else{
        final userCredentials = await _firebase
            .createUserWithEmailAndPassword(
            email: _enteredemail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance.ref().child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        //since set() yields a future so await the below process
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username' : _enteredUsername,
          'email': _enteredemail,
          'image_url' : imageUrl,
        });
      }
    }on FirebaseAuthException catch(error){
        if(error.code == 'email-already-in-use'){
          //...
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed.')),
        );
        setState(() {
          _isAuthenticating = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome!',
                style: TextStyle(fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            const SizedBox(height: 12,),
            if(!_isLogin)
              UserImagePicker(onPickedImage: (pickedImage) {
                _selectedImage = pickedImage;
              },),
            const SizedBox(height: 12,),
            if(!_isLogin)
              TextFormField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter Username',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 15),
                  contentPadding:  EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(13)),borderSide: BorderSide(color: Colors.white)),
                ),
                enableSuggestions: false,
                validator: (value){
                  if(value == null || value.isEmpty || value.trim().length < 4){
                    return 'Please enter a valid username';
                  }
                  return null;
                },
                onSaved: (value){
                  _enteredUsername = value!;
                },
              ),
            const SizedBox(height: 12,),
            TextFormField(
              style: const TextStyle(
                color: Colors.white,
              ),
              key: _emailKey,
              decoration:  const InputDecoration(
                hintText: 'Enter e-mail',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 15),
                contentPadding:  EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(13)),borderSide: BorderSide(color: Colors.white)),
              ),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              validator: (value){
                if(value == null || value.trim().isEmpty || !value.contains('@')){
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onSaved: (value){
                _enteredemail = value!;
              },
            ),
            const SizedBox(height: 15,),
            TextFormField(
              key: _passwordKey,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration:  const InputDecoration(
                hintText: 'Enter Password',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 15),
                contentPadding:  EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(13)),borderSide: BorderSide(color: Colors.white)),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              validator: (value){
                if(value == null || value.trim().length < 6){
                  return 'Password be at least 6 letters long';
                }
                return null;
              },
              onSaved: (value){
                _enteredPassword = value!;
              },
            ),
            const SizedBox(height: 16,),
            if(_isAuthenticating)
              const CircularProgressIndicator(),
            if(!_isAuthenticating)
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Login':'SignUp'),
              ),
              const SizedBox(height: 16,),
            if(!_isAuthenticating)
              TextButton(
                onPressed: (){
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? 'Create an account': 'I already have an account'),
              ),
          ],
        ),
      ),
    );
  }
}