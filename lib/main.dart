import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EduKidsApp());
}

class EduKidsApp extends StatelessWidget {
  const EduKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduKidsTask',
      theme: ThemeData(
        primaryColor: Colors.orange.shade500,
        scaffoldBackgroundColor: Colors.amber.shade100,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange.shade500,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade500,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const PasswordCheckScreen(),
    );
  }
}

class PasswordCheckScreen extends StatefulWidget {
  const PasswordCheckScreen({super.key});

  @override
  State<PasswordCheckScreen> createState() => _PasswordCheckScreenState();
}

class _PasswordCheckScreenState extends State<PasswordCheckScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPassword();
  }

  Future<void> _checkPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPassword = prefs.getString('password') != null;

    if (hasPassword) {
      // Password exists, navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // No password set, show password creation screen
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const CreatePasswordScreen();
  }
}

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  String _errorMessage = '';

  // PIN input state
  List<String> _password = ['', '', '', ''];
  List<String> _confirmPassword = ['', '', '', ''];

  // Focus nodes for PIN input fields
  List<FocusNode> _passwordFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  List<FocusNode> _confirmFocusNodes = List.generate(4, (index) => FocusNode());

  // Controllers for PIN input fields
  List<TextEditingController> _passwordControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  List<TextEditingController> _confirmControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    // Dispose all focus nodes and controllers
    for (var node in _passwordFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmFocusNodes) {
      node.dispose();
    }
    for (var controller in _passwordControllers) {
      controller.dispose();
    }
    for (var controller in _confirmControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Build a single PIN input box
  Widget _buildPinBox(
    TextEditingController controller,
    FocusNode focusNode,
    List<String> pinList,
    int index,
    List<FocusNode> focusNodes,
  ) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            pinList[index] = value;
            // Move to next field if available
            if (index < 3) {
              focusNodes[index + 1].requestFocus();
            }
          } else {
            pinList[index] = '';
            // Move to previous field on backspace if not the first field
            if (index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  // Build a row of PIN boxes
  Widget _buildPinRow(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
    List<String> pinList,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => _buildPinBox(
          controllers[index],
          focusNodes[index],
          pinList,
          index,
          focusNodes,
        ),
      ),
    );
  }

  Future<void> _savePassword() async {
    final password = _password.join();
    final confirmPassword = _confirmPassword.join();

    if (password.length != 4) {
      setState(() {
        _errorMessage = 'Password must be 4 digits';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    // Save password
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          double fontSize = screenWidth * 0.05;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.25,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: CurvedTopPainter(),
                    child: Center(
                      child: Text(
                        "Add short password",
                        style: TextStyle(
                          fontSize: fontSize * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter short password",
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildPinRow(
                        _passwordControllers,
                        _passwordFocusNodes,
                        _password,
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Confirm password",
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildPinRow(
                        _confirmControllers,
                        _confirmFocusNodes,
                        _confirmPassword,
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: fontSize * 0.8,
                            ),
                          ),
                        ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _savePassword,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EduKidsTask",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 30),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const PasswordDialog(),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to EduKidsTask!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  String _errorMessage = '';

  // PIN input state
  List<String> _password = ['', '', '', ''];

  // Focus nodes for PIN input fields
  List<FocusNode> _passwordFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  // Controllers for PIN input fields
  List<TextEditingController> _passwordControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    // Dispose all focus nodes and controllers
    for (var node in _passwordFocusNodes) {
      node.dispose();
    }
    for (var controller in _passwordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Build a single PIN input box
  Widget _buildPinBox(
    TextEditingController controller,
    FocusNode focusNode,
    List<String> pinList,
    int index,
    List<FocusNode> focusNodes,
  ) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            pinList[index] = value;
            // Move to next field if available
            if (index < 3) {
              focusNodes[index + 1].requestFocus();
            }
          } else {
            pinList[index] = '';
            // Move to previous field on backspace if not the first field
            if (index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  // Build a row of PIN boxes
  Widget _buildPinRow(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
    List<String> pinList,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => _buildPinBox(
          controllers[index],
          focusNodes[index],
          pinList,
          index,
          focusNodes,
        ),
      ),
    );
  }

  Future<void> _verifyPassword() async {
    final password = _password.join();

    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password');

    if (password == savedPassword) {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MenuPage()));
      }
    } else {
      setState(() {
        _errorMessage = 'Wrong password, try again';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Password"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _buildPinRow(_passwordControllers, _passwordFocusNodes, _password),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _verifyPassword, child: const Text("Verify")),
      ],
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              // Navigate to about
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help"),
            onTap: () {
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String _errorMessage = '';
  bool _isSuccess = false;

  // PIN input state
  List<String> _currentPassword = ['', '', '', ''];
  List<String> _newPassword = ['', '', '', ''];
  List<String> _confirmPassword = ['', '', '', ''];

  // Focus nodes for PIN input fields
  List<FocusNode> _currentPasswordFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  List<FocusNode> _newPasswordFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  List<FocusNode> _confirmFocusNodes = List.generate(4, (index) => FocusNode());

  // Controllers for PIN input fields
  List<TextEditingController> _currentPasswordControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  List<TextEditingController> _newPasswordControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  List<TextEditingController> _confirmControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    // Dispose all focus nodes and controllers
    for (var node in [
      ..._currentPasswordFocusNodes,
      ..._newPasswordFocusNodes,
      ..._confirmFocusNodes,
    ]) {
      node.dispose();
    }
    for (var controller in [
      ..._currentPasswordControllers,
      ..._newPasswordControllers,
      ..._confirmControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // Build a single PIN input box
  Widget _buildPinBox(
    TextEditingController controller,
    FocusNode focusNode,
    List<String> pinList,
    int index,
    List<FocusNode> focusNodes,
  ) {
    return Container(
      width: 45,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            pinList[index] = value;
            // Move to next field if available
            if (index < 3) {
              focusNodes[index + 1].requestFocus();
            }
          } else {
            pinList[index] = '';
            // Move to previous field on backspace if not the first field
            if (index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  // Build a row of PIN boxes
  Widget _buildPinRow(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
    List<String> pinList,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => _buildPinBox(
          controllers[index],
          focusNodes[index],
          pinList,
          index,
          focusNodes,
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = '';
      _isSuccess = false;
    });

    final currentPassword = _currentPassword.join();
    final newPassword = _newPassword.join();
    final confirmPassword = _confirmPassword.join();

    // Validate current password
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password');

    if (currentPassword != savedPassword) {
      setState(() {
        _errorMessage = 'Current password is incorrect';
      });
      return;
    }

    // Validate new password
    if (newPassword.length != 4) {
      setState(() {
        _errorMessage = 'New password must be 4 digits';
      });
      return;
    }

    // Validate confirmation
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'New passwords do not match';
      });
      return;
    }

    // Save new password
    await prefs.setString('password', newPassword);

    setState(() {
      _isSuccess = true;
      // Clear all input fields
      for (var controller in [
        ..._currentPasswordControllers,
        ..._newPasswordControllers,
        ..._confirmControllers,
      ]) {
        controller.clear();
      }
      _currentPassword = ['', '', '', ''];
      _newPassword = ['', '', '', ''];
      _confirmPassword = ['', '', '', ''];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double fontSize = screenWidth * 0.04;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Password",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildPinRow(
                    _currentPasswordControllers,
                    _currentPasswordFocusNodes,
                    _currentPassword,
                  ),
                  SizedBox(height: 25),
                  Text(
                    "New Password",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildPinRow(
                    _newPasswordControllers,
                    _newPasswordFocusNodes,
                    _newPassword,
                  ),
                  SizedBox(height: 25),
                  Text(
                    "Confirm New Password",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildPinRow(
                    _confirmControllers,
                    _confirmFocusNodes,
                    _confirmPassword,
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: fontSize),
                      ),
                    ),
                  if (_isSuccess)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "Password changed successfully!",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CurvedTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.orange.shade500;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
