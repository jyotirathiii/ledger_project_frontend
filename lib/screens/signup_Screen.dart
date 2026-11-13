import 'package:flutter/material.dart';
import 'package:ledger_project/constants/colors.dart';
import 'package:ledger_project/services/api_service.dart';
import 'package:ledger_project/widgets/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  bool isPassword1Visible = false;
  bool isPassword2Visible = false;
  bool isLoading = false;

  Future<void> onSignUp() async {
    final email = emailController.text.trim();
    final password1 = password1Controller.text;
    final password2 = password2Controller.text;

    void showMessage(text) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }

    if (email.isEmpty || !email.contains('@')) {
      showMessage('Please write the valid Email');
      return;
    }
    if (password1.length < 6) {
      showMessage('Password must be atleast 6 character');
      return;
    }

    if (password1 != password2) {
      showMessage('Password is not matched');
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.signUp(email, password1);
      if (!mounted) return;
      if (result['status'] == 'created') {
        showMessage('Account created,Please Login');
        Navigator.pop(context);
      } else {
        showMessage(result['detail'] ?? 'SignUp Failed');
      }
    } catch (e) {
      if (!mounted) return;
      showMessage('Error:$e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    password1Controller.dispose();
    password2Controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60),
                    Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'You get RS 1000 practice balance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Email',
                      style: TextStyle(fontSize: 13, color: Color(0XFF4E5A54)),
                    ),
                    SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.green),
                        ),
                        hintText: 'abc@gmail.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Password',
                      style: TextStyle(fontSize: 13, color: Color(0XFF4E5A54)),
                    ),
                    SizedBox(height: 6),
                    TextField(
                      controller: password1Controller,

                      obscureText: !isPassword1Visible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.green),
                        ),
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPassword1Visible = !isPassword1Visible;
                            });
                          },
                          icon: Icon(
                            isPassword1Visible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Confirm Password',
                      style: TextStyle(fontSize: 13, color: Color(0XFF4E5A54)),
                    ),
                    SizedBox(height: 6),
                    TextField(
                      controller: password2Controller,

                      obscureText: !isPassword2Visible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.green),
                        ),
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPassword2Visible = !isPassword2Visible;
                            });
                          },
                          icon: Icon(
                            isPassword2Visible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    CustomButton(
                      text: 'SignUp',
                      onPressed: onSignUp,
                      backgroundColor: Color(0XFF0F7B5F),
                      textColor: Colors.white,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: screenHeight / 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'LogIn',
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
