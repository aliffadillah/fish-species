import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  // Method to fetch user data from the API
  Future<void> _fetchUserDataFromApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://ikanapi-465762037323.asia-southeast2.run.app/api/users/profile'), // Replace with the actual API URL
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        // Store user data in shared preferences
        await prefs.setString('user_email', responseData['email']);
        await prefs.setString('user_firstName', responseData['firstName']);
        await prefs.setString('user_lastName', responseData['lastName']);
        await prefs.setString('user_birthDate', responseData['birthDate']);
        notifyListeners(); // Notify listeners about the update
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // Method to save user data
  Future<void> saveUser(String email, String password, String firstName, String lastName, String birthDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setString('user_firstName', firstName);
    await prefs.setString('user_lastName', lastName);
    await prefs.setString('user_birthDate', birthDate);
  }

  // Validate user credentials from saved preferences
  Future<bool> validateUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedPassword = prefs.getString('user_password');
    return email == savedEmail && password == savedPassword;
  }

  // Get the stored email
  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? '';
  }

  // Get user data from SharedPreferences or fetch it if necessary
  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null && email.isNotEmpty) {
      // Assuming token is stored in SharedPreferences
      final token = prefs.getString('user_token');
      if (token != null) {
        // Fetch the data if it doesn't exist or is outdated
        await _fetchUserDataFromApi(token);
      }
    }
    return {
      'firstName': prefs.getString('user_firstName') ?? '',
      'lastName': prefs.getString('user_lastName') ?? '',
      'bio': prefs.getString('user_bio') ?? '',
      'birthDate': prefs.getString('user_birthDate') ?? '',
    };
  }

  // Update the first and last name of the user
  Future<void> updateNames(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_firstName', firstName);
    await prefs.setString('user_lastName', lastName);
    notifyListeners();
  }

  // Update the bio of the user
  Future<void> updateBio(String bio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_bio', bio);
    notifyListeners();
  }

  // Update the email of the user
  Future<void> updateEmail(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', newEmail);
    notifyListeners();
  }

  // Update both email and password
  Future<void> updateEmailAndPassword(String newEmail, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', newEmail);
    await prefs.setString('user_password', newPassword);
  }

  // Update the birthdate of the user
  Future<void> updateBirthDate(String birthDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_birthDate', birthDate);
    notifyListeners();
  }
}
