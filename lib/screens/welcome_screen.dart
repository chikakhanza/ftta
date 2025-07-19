import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF8EAF1),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Color(0xFF9B4064),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(120),
                bottomRight: Radius.circular(120),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                SizedBox(height: 30),
                Row(
                  children: [
                    Image.asset('assets/images/house.png', width: 60, height: 60),
                    SizedBox(height: 10),
                    Text(
                      'WELCOME\nHOMESTAY ECOPARK SYARIAH',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
           SizedBox(height: 60),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize:  Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>  RegisterScreen()));
                  },
                  child: Text('Sign Up'),
                ),
                 SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>  LoginScreen()));
                  },
                  child: Text('Log In'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 