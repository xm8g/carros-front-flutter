import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'package:carros/pages/api_response.dart';
import 'package:carros/pages/login/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

String firebaseUserId;

class FirebaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ApiResponse> loginGoogle() async {
    try {
      // Login com o Google
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print("Google User: ${googleUser.email}");

      // Credenciais para o Firebase
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login no Firebase
      AuthResult result = await _auth.signInWithCredential(credential);
      final FirebaseUser fuser = result.user;
      print("Firebase Nome: ${fuser.displayName}");
      print("Firebase Email: ${fuser.email}");
      print("Firebase Foto: ${fuser.photoUrl}");

      saveUser();

      // Cria um usuario do app
      final user = Usuario(
        nome: fuser.displayName,
        login: fuser.email,
        email: fuser.email,
        urlFoto: fuser.photoUrl,
      );
      user.save();

      // Resposta genérica
      return ApiResponse.ok();
    } catch (error) {
      print("Firebase error $error");
      return ApiResponse.error(msg: "Não foi possível fazer o login");
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    try {

      // Login no Firebase (methodo email/senha)
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final FirebaseUser fuser = result.user;
      print("Firebase Nome: ${fuser.displayName}");
      print("Firebase Email: ${fuser.email}");
      print("Firebase Foto: ${fuser.photoUrl}");

      saveUser();

      // Cria um usuario do app
      final user = Usuario(
        nome: fuser.displayName,
        login: fuser.email,
        email: fuser.email,
        urlFoto: fuser.photoUrl,
      );
      user.save();

      // Resposta genérica
      return ApiResponse.ok();
    } catch (error) {
      print("Firebase error $error");
      return ApiResponse.error(msg: "Não foi possível fazer o login");
    }
  }

  Future<ApiResponse> cadastrar(String nome, String email, String senha) async {
    try {
      // Usuario do Firebase
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      final FirebaseUser fUser = result.user;
      print("Firebase Nome: ${fUser.displayName}");
      print("Firebase Email: ${fUser.email}");
      print("Firebase Foto: ${fUser.photoUrl}");

      // Dados para atualizar o usuário
      final userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.displayName = nome;
      userUpdateInfo.photoUrl = "https://s3-sa-east-1.amazonaws.com/livetouch-temp/livrows/foto.png";

      fUser.updateProfile(userUpdateInfo);

      // Resposta genérica
      return ApiResponse.ok(msg:"Usuário criado com sucesso");
    } catch(error) {
      print(error);

      if(error is PlatformException) {
        print("Error Code ${error.code}");

        return ApiResponse.error(msg: "Erro ao criar um usuário.\n\n${error.message}");
      }

      return ApiResponse.error(msg: "Não foi possível criar um usuário.");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  //salva o usuario na collection (firebase) de usuários logados
  void saveUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      firebaseUserId = user.uid;
      DocumentReference refUser = Firestore.instance.collection("users").document(firebaseUserId);
      refUser.setData({'nome':user.displayName, 'email':user.email});
    }

  }

  static Future<String> uploadFirebaseStorage(File image) async {
    print("Upload Storage ${image}");
    String fileName = path.basename(image.path);
    final storageRef = FirebaseStorage.instance.ref().child(fileName);

    final StorageTaskSnapshot task = await storageRef.putFile(image).onComplete;
    String urlFoto = await task.ref.getDownloadURL();
    print("Storage > ${urlFoto}");

    return urlFoto;
  }
}