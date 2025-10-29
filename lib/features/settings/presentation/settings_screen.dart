import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // để format ngày tháng

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sales = true;
  bool newArrivals = false;
  bool deliveryStatus = false;

  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(
    text: "15/01/2004",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "****************",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PERSONAL INFORMATION",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 12),

            // Fullname
            _buildTextField("Fullname", _fullnameController),

            const SizedBox(height: 12),

            // Date of Birth (chọn bằng DatePicker)
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _buildTextField("Date of Birth", _dobController),
              ),
            ),

            const SizedBox(height: 25),

            // Password Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Password",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _changePasswordDialog,
                  child: const Text(
                    "Change",
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTextField(
              "Password",
              _passwordController,
              obscureText: true,
              enabled: false,
            ),

            const SizedBox(height: 30),
            const Text(
              "Notifications",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile("Sales", sales, (value) {
              setState(() => sales = value);
            }),
            _buildSwitchTile("New arrivals", newArrivals, (value) {
              setState(() => newArrivals = value);
            }),
            _buildSwitchTile("Delivery status changes", deliveryStatus, (
              value,
            ) {
              setState(() => deliveryStatus = value);
            }),
          ],
        ),
      ),
    );
  }

  // chọn ngày sinh
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateFormat("dd/MM/yyyy").parse(_dobController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
    }
  }

  // dialog đổi mật khẩu
  Future<void> _changePasswordDialog() async {
    final TextEditingController newPassController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: newPassController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _passwordController.text = "****************";
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password changed successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // textfield tái sử dụng
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  // switch
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.teal,
      contentPadding: EdgeInsets.zero,
    );
  }
}
