
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/db_service.dart';
import '../services/web_storage_service.dart';
import '../utils/toast.dart';
import 'MainNavigationScreen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen(this.isStart, this.isFromBluetooth,{super.key});
  final bool isStart;
  final bool isFromBluetooth;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String _gender = "Male";
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _chairHeightController = TextEditingController();
  String _chairType = "Ergonomic Office Chairs";
  bool _isLoading = true;
  UserProfile? _existingUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (kIsWeb) {
      _existingUser = await WebStorageService.loadUser();
    } else {
      final users = await DBService().getAllUsers();
      if (users.isNotEmpty) _existingUser = users.first;
    }

    if (_existingUser != null) {
      _nameController.text = _existingUser!.name;
      _gender = _existingUser!.gender;
      _ageController.text = _existingUser!.age.toString();
      _heightController.text = _existingUser!.heightCm.toString();
      _chairType = _existingUser!.chairType;
      _chairHeightController.text = _existingUser!.chairHeight.toString();
    }

    setState(() => _isLoading = false);

    if (!widget.isStart && widget.isFromBluetooth) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }


  Future<void> _saveUser() async {
    if (_formKey.currentState?.validate() != true) return;

    final int? age = int.tryParse(_ageController.text);
    final double? height = double.tryParse(_heightController.text);
    final double? chairHeight = double.tryParse(_chairHeightController.text);

    if (age == null || age < 0 || age > 120) {
      openToast("Age must be between 0 and 120.");
      return;
    }
    if (height == null || height <= 0 || height > 220) {
      openToast("Height must be between 0cm and 220cm.");
      return;
    }
    if (chairHeight == null || chairHeight <= 0 || chairHeight > 150) {
      openToast("Chair height must be between 0cm and 150cm.");
      return;
    }

    final user = UserProfile(
      id: _existingUser?.id ?? 0,
      name: _nameController.text,
      gender: _gender,
      age: age,
      heightCm: height,
      chairType: _chairType,
      chairHeight: chairHeight,
    );

    if (kIsWeb) {
      await WebStorageService.saveUser(user);
    } else {
      if (_existingUser == null) {
        await DBService().insertUser(user);
      } else {
        await DBService().deleteAllUsers();
        await DBService().insertUser(user);
      }
    }

    openToast("Profile saved successfully");
    if (widget.isStart && widget.isFromBluetooth) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Info"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Name", _nameController),
              const SizedBox(height: 10),
              _buildGenderDropdown(),
              const SizedBox(height: 10),
              _buildTextField("Age", _ageController, isNumber: true),
              const SizedBox(height: 10),
              _buildTextField("Height (cm)", _heightController, isDecimal: true),
              const SizedBox(height: 10),
              //_buildTextField("Chair Type", _chairTypeController),
              _buildChairTypeDropdown(),
              const SizedBox(height: 10),
              _buildTextField("Chair Height (cm)", _chairHeightController, isDecimal: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Save Info"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool isDecimal = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: const InputDecoration(
        labelText: "Gender",
        border: OutlineInputBorder(),
      ),
      items: ["Male", "Female", "Other"].map((g) {
        return DropdownMenuItem(value: g, child: Text(g));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _gender = value ?? "Male";
        });
      },
    );
  }

  Widget _buildChairTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _chairType,
      decoration: const InputDecoration(
        labelText: "ChairType",
        border: OutlineInputBorder(),
      ),
      items: ["Ergonomic Office Chairs", "Kneeling Chairs", "Active Sitting Chairs", "Reclining Chairs \nwith Adjustable Support"].map((g) {
        return DropdownMenuItem(value: g, child: Text(g));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _chairType = value ?? "Ergonomic Office Chairs";
        });
      },
    );
  }
}
