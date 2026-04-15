import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '43765152948-2qoau6ji9a1runlo7mgppd3hh0fmpntd.apps.googleusercontent.com',
  );
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final Map<String, String?> _fieldErrors = {};
  Map<String, String?> get fieldErrors => _fieldErrors;

  String? _error;
  String? get error => _error;
  String? getFieldError(String field) => _fieldErrors[field];

  User? get user => _authService.currentUser;
  String _email = '';
  String _password = '';
  String _name = '';

  void setEmail(String email) {
    _email = email;
    _fieldErrors.remove('email');
    _error = null;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    _fieldErrors.remove('password');
    _error = null;
    notifyListeners();
  }
  void setName(String name) => _name = name;

  void clearErrors() {
    _fieldErrors.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login() async {

    _fieldErrors.clear();
    _error = null;

    if (_email.isEmpty || !_email.contains('@')) {
      _fieldErrors['email'] = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    if (_password.isEmpty) {
      _fieldErrors['password'] = 'Please enter your password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(_email, _password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No account exists with this email.';
          break;
        case 'wrong-password':
          _error = 'Incorrect password. Please try again.';
          break;
        case 'invalid-credential':
          _error = 'Invalid email or password. Please check and try again.';
          break;
        case 'user-disabled':
          _error = 'This account has been disabled by the administrator.';
          break;
        case 'network-request-failed':
          _error = 'No internet connection. Please check your network.';
          break;
        default:
          _error = 'Login failed. Please try again later.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      if (e.toString().contains('PigeonUserDetails')) {
        debugPrint("Ignoring Pigeon Plugin error as login is successful");
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = "An unexpected error occurred. Please try again.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<bool> signup() async {
    _fieldErrors.clear();
    _error = null;
    bool hasError = false;

    if (_name.isEmpty) {
      _fieldErrors['name'] = 'Please enter your name';
      hasError = true;
    }

    if (_email.isEmpty || !_email.contains('@')) {
      _fieldErrors['email'] = 'Invalid email address';
      hasError = true;
    }

    if (_password.length < 8) {
      _fieldErrors['password'] = 'Password must be at least 8 characters long';
      hasError = true;
    }

    if (hasError) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      UserCredential? credential = await _authService.signUp(_email, _password, _name);
      await credential?.user?.updateDisplayName(_name);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // Firebase ke errors ko Global _error mein dalen
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'This email is already registered.';
          break;
        case 'invalid-email':
          _error = 'The email address is not valid.';
          break;
        case 'weak-password':
          _error = 'The password is too weak.';
          break;
        default:
          _error = 'An unexpected error occurred. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "Something went wrong. Please try again.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _fieldErrors.clear();
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setLoading(false);
        return false;
      }

      setLoading(true);

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential? userCredential = await _authService.signInWithGoogle(credential);

      setLoading(false);
      return (userCredential != null);

    } on FirebaseAuthException catch (e) {
      debugPrint("Google Auth Firebase Error: ${e.code}");
      switch (e.code) {
        case 'account-exists-with-different-credential':
          _error = 'This email is already linked with another login method.';
          break;
        case 'invalid-credential':
          _error = 'Error occurred while accessing Google credentials.';
          break;
        case 'network-request-failed':
          _error = 'Network error. Please check your internet connection.';
          break;
        case 'user-disabled':
          _error = 'This user account has been disabled.';
          break;
        default:
          _error = 'Google login failed. Please try again.';
      }
      setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Google Auth General Error: $e");
      _error = "An unexpected error occurred during Google login.";
      setLoading(false);
      notifyListeners();
      return false;
    }
  }
  Future<void> logout() async {
    try {
      await _authService.signOut();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint("Logout process info: $e");
    } finally {
      _email = '';
      _password = '';
      _name = '';
      _error = null;
      notifyListeners();
    }
  }

  bool _isResetLoading = false;
  bool get isResetLoading => _isResetLoading;
  Future<bool> resetPassword(String email) async {
    _fieldErrors.clear();
    _error = null;

    if (email.isEmpty || !email.contains('@')) {
      _fieldErrors['email'] = 'Please enter a valid email address.';
      notifyListeners();
      return false;
    }

    _isResetLoading = true;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isResetLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'No account found with this email address.';
          break;
        case 'invalid-email':
          _error = 'The email address is not valid.';
          break;
        case 'network-request-failed':
          _error = 'Network error. Please check your internet connection.';
          break;
        default:
          _error = 'Could not send reset email. Please try again.';
      }
      _isResetLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "An unexpected error occurred. Please try again.";
      _isResetLoading = false;
      notifyListeners();
      return false;
    }
  }
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
}