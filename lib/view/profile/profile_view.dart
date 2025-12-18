import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/storage_service.dart';
import 'package:food_delivery/common/supabase_service.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:image_picker/image_picker.dart';
import '../more/my_order_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  Uint8List? imageBytesWeb; // for web preview/upload
  String? networkImageUrl;
  bool isLoading = true;
  bool isSaving = false;

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();

  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final user = SupabaseService.currentUser;
    txtEmail.text = user?.email ?? '';
    _loadFuture = loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await SupabaseService.getProfile();
      if (profile != null) {
        txtName.text = profile['name'] ?? txtName.text;
        txtMobile.text = profile['mobile'] ?? '';
        txtAddress.text = profile['address'] ?? '';
        networkImageUrl = profile['image_url'];
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes(); // Uint8List
        setState(() {
          image = picked;
          imageBytesWeb = bytes;
        });
      } else {
        setState(() {
          image = picked;
          imageBytesWeb = null;
        });
      }
    }
  }

  Future<void> saveProfile() async {
    if (isSaving) return;
    setState(() => isSaving = true);
    Globs.showHUD();
    String? imageUrl = networkImageUrl;

    try {
      final userId = SupabaseService.currentUser?.id ?? '';

      if (image != null) {
        if (kIsWeb) {
          if (imageBytesWeb != null) {
            imageUrl = await StorageService.uploadProfileImageBytes(
              imageBytesWeb!,
              userId,
            );
          }
        } else {
          imageUrl = await StorageService.uploadProfileImage(
            File(image!.path),
            userId,
          );
        }
      }

      await SupabaseService.updateProfile(
        name: txtName.text,
        mobile: txtMobile.text,
        address: txtAddress.text,
        imageUrl: imageUrl,
      );

      if (!mounted) return;
      setState(() {
        networkImageUrl = imageUrl;
        image = null;
        imageBytesWeb = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved!")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed: $e")),
        );
      }
    } finally {
      Globs.hideHUD();
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "welcome", (_) => false);
    }
  }

  Widget _avatar() {
    Widget child;
    if (imageBytesWeb != null && kIsWeb) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Image.memory(imageBytesWeb!,
            width: 110, height: 110, fit: BoxFit.cover),
      );
    } else if (image != null && !kIsWeb) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Image.file(
          File(image!.path),
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
      );
    } else if (networkImageUrl != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Image.network(
          networkImageUrl!,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.person, size: 65, color: TColor.secondaryText),
        ),
      );
    } else {
      child = Icon(Icons.person, size: 65, color: TColor.secondaryText);
    }

    return GestureDetector(
      onTap: pickImage,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: TColor.placeholder,
          borderRadius: BorderRadius.circular(55),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 46),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Profile",
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MyOrderView()));
                          },
                          icon: Image.asset(
                            "assets/img/shopping_cart.png",
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _avatar(),
                  TextButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.edit, color: TColor.primary, size: 12),
                    label: Text("Edit Profile",
                        style: TextStyle(color: TColor.primary, fontSize: 12)),
                  ),
                  Text(
                      "Hi there ${txtName.text.isNotEmpty ? txtName.text : 'User'}!",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: signOut,
                    child: Text("Sign Out",
                        style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: RoundTitleTextfield(
                        title: "Name",
                        hintText: "Enter Name",
                        controller: txtName),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: RoundTitleTextfield(
                        title: "Email",
                        hintText: "Enter Email",
                        keyboardType: TextInputType.emailAddress,
                        controller: txtEmail),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: RoundTitleTextfield(
                        title: "Mobile No",
                        hintText: "Enter Mobile No",
                        controller: txtMobile,
                        keyboardType: TextInputType.phone),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: RoundTitleTextfield(
                        title: "Address",
                        hintText: "Enter Address",
                        controller: txtAddress),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RoundButton(
                      title: isSaving ? "Saving..." : "Save",
                      onPressed: isSaving ? () {} : saveProfile,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}