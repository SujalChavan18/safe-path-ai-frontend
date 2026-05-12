import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/logger.dart';
import 'firebase_service.dart';

/// Service layer encapsulating all Firebase Authentication operations.
///
/// This class handles raw Firebase Auth calls and should NOT extend
/// [ChangeNotifier]. UI-reactive state is managed by [AuthProvider]
/// which consumes this service.
///
/// **Design rationale**: Separating the service from the provider keeps
/// auth logic testable (mock this class) and prevents tight coupling
/// between Firebase SDK types and the UI layer.
class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ═══════════════════════════════════════════════════════════
  //  STATE ACCESSORS
  // ═══════════════════════════════════════════════════════════

  /// The currently signed-in user, or `null`.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => currentUser != null;

  /// Whether the current user's email is verified.
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Stream of authentication state changes.
  ///
  /// Emits the current [User] on sign-in and `null` on sign-out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes (includes profile updates, token refresh).
  Stream<User?> get userChanges => _auth.userChanges();

  // ═══════════════════════════════════════════════════════════
  //  EMAIL / PASSWORD AUTHENTICATION
  // ═══════════════════════════════════════════════════════════

  /// Sign in with email and password.
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    AppLogger.info('Attempting email sign-in for: $email', tag: 'Auth');

    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    AppLogger.info('Email sign-in successful: ${credential.user?.uid}', tag: 'Auth');
    return credential;
  }

  /// Create a new account with email, password, and display name.
  ///
  /// After creation, updates the user profile with [displayName]
  /// and creates a Firestore user document.
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    AppLogger.info('Creating account for: $email', tag: 'Auth');

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update display name
    await credential.user?.updateDisplayName(displayName.trim());
    await credential.user?.reload();

    // Create Firestore user document
    final updatedUser = _auth.currentUser;
    if (updatedUser != null) {
      await FirebaseService.createUserDocument(updatedUser);
    }

    AppLogger.info(
      'Account created successfully: ${credential.user?.uid}',
      tag: 'Auth',
    );
    return credential;
  }

  // ═══════════════════════════════════════════════════════════
  //  GOOGLE SIGN-IN
  // ═══════════════════════════════════════════════════════════

  /// Authenticate with Google Sign-In.
  ///
  /// Opens the Google Sign-In flow, exchanges the result for a
  /// Firebase credential, and signs in.
  ///
  /// Returns the [UserCredential] on success, or `null` if the
  /// user cancelled the sign-in dialog.
  /// Throws [FirebaseAuthException] on Firebase-level failures.
  Future<UserCredential?> signInWithGoogle() async {
    AppLogger.info('Starting Google Sign-In flow', tag: 'Auth');

    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      AppLogger.info('Google Sign-In cancelled by user', tag: 'Auth');
      return null; // User cancelled
    }

    // Obtain auth details
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final userCredential = await _auth.signInWithCredential(credential);

    // Create/update Firestore user document
    final user = userCredential.user;
    if (user != null) {
      await FirebaseService.createUserDocument(user);
    }

    AppLogger.info(
      'Google Sign-In successful: ${userCredential.user?.uid}',
      tag: 'Auth',
    );
    return userCredential;
  }

  // ═══════════════════════════════════════════════════════════
  //  SIGN OUT
  // ═══════════════════════════════════════════════════════════

  /// Sign out from Firebase and any linked providers (Google).
  ///
  /// Also removes the FCM token from Firestore to stop
  /// push notifications for this device.
  Future<void> signOut() async {
    AppLogger.info('Signing out user: ${currentUser?.uid}', tag: 'Auth');

    // Remove FCM token before signing out
    try {
      await FirebaseService.removeFcmTokenFromFirestore();
    } catch (e) {
      AppLogger.warning('Failed to remove FCM token on sign-out: $e', tag: 'Auth');
    }

    // Sign out from Google if signed in via Google
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      AppLogger.warning('Google sign-out error: $e', tag: 'Auth');
    }

    // Sign out from Firebase
    await _auth.signOut();

    AppLogger.info('Sign-out complete', tag: 'Auth');
  }

  // ═══════════════════════════════════════════════════════════
  //  PASSWORD MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Send a password reset email.
  ///
  /// Throws [FirebaseAuthException] if the email is invalid or not found.
  Future<void> sendPasswordResetEmail(String email) async {
    AppLogger.info('Sending password reset to: $email', tag: 'Auth');
    await _auth.sendPasswordResetEmail(email: email.trim());
    AppLogger.info('Password reset email sent', tag: 'Auth');
  }

  /// Update the current user's password.
  ///
  /// Requires recent authentication. Call [reauthenticate] first if needed.
  /// Throws [FirebaseAuthException] on failure.
  Future<void> updatePassword(String newPassword) async {
    final user = currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');
    await user.updatePassword(newPassword);
    AppLogger.info('Password updated successfully', tag: 'Auth');
  }

  // ═══════════════════════════════════════════════════════════
  //  EMAIL VERIFICATION
  // ═══════════════════════════════════════════════════════════

  /// Send an email verification link to the current user.
  ///
  /// No-op if email is already verified.
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) return;
    if (user.emailVerified) return;

    await user.sendEmailVerification();
    AppLogger.info('Verification email sent to: ${user.email}', tag: 'Auth');
  }

  /// Reload the current user to refresh email verification status.
  ///
  /// Returns the updated [User], or `null` if not signed in.
  Future<User?> refreshUser() async {
    final user = currentUser;
    if (user == null) return null;

    await user.reload();
    return _auth.currentUser;
  }

  // ═══════════════════════════════════════════════════════════
  //  PROFILE MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Update the current user's display name and/or photo URL.
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');

    if (displayName != null) {
      await user.updateDisplayName(displayName.trim());
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    await user.reload();

    // Sync to Firestore
    final updatedUser = _auth.currentUser;
    if (updatedUser != null) {
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName.trim();
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      
      if (updateData.isNotEmpty) {
        await FirebaseService.usersCollection.doc(updatedUser.uid).update(updateData);
      }
    }

    AppLogger.info('Profile updated', tag: 'Auth');
  }

  // ═══════════════════════════════════════════════════════════
  //  RE-AUTHENTICATION
  // ═══════════════════════════════════════════════════════════

  /// Re-authenticate the current user with email and password.
  ///
  /// Required before sensitive operations like [deleteAccount]
  /// or [updatePassword] when the session is stale.
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    final user = currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');

    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    AppLogger.info('Re-authentication successful', tag: 'Auth');
  }

  // ═══════════════════════════════════════════════════════════
  //  ACCOUNT DELETION
  // ═══════════════════════════════════════════════════════════

  /// Delete the current user's account.
  ///
  /// This permanently deletes the Firebase Auth account.
  /// The Firestore user document should be cleaned up via
  /// Cloud Functions or a separate service.
  ///
  /// May require recent authentication — call [reauthenticate] first.
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');

    AppLogger.warning('Deleting account: ${user.uid}', tag: 'Auth');

    // Remove FCM tokens
    try {
      await FirebaseService.removeFcmTokenFromFirestore();
    } catch (_) {}

    // Sign out from Google if applicable
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
    } catch (_) {}

    // Delete the Firebase Auth account
    await user.delete();

    AppLogger.info('Account deleted', tag: 'Auth');
  }

  // ═══════════════════════════════════════════════════════════
  //  PROVIDER INFORMATION
  // ═══════════════════════════════════════════════════════════

  /// Get the list of sign-in providers linked to the current account.
  ///
  /// Returns provider IDs like `password`, `google.com`, `phone`.
  List<String> get linkedProviders {
    return currentUser?.providerData
            .map((info) => info.providerId)
            .toList() ??
        [];
  }

  /// Whether the current user signed in with Google.
  bool get isGoogleLinked => linkedProviders.contains('google.com');

  /// Whether the current user signed in with email/password.
  bool get isPasswordLinked => linkedProviders.contains('password');
}
