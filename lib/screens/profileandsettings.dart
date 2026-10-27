import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/patient_profile.dart';
import '../widgets/bottom_navigation.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final PatientProfile profile = PatientProfile.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  DateTime? _dateOfBirth;
  String? _photoUrl;
  Uint8List? _photoBytes;

  static const Color _background = Color(0xFF101010);
  static const Color _surface = Color(0xFF1D1A1C);
  static const Color _mauve = Color(0xFFB78A9B);
  static const Color _mutedText = Color(0xFFBDB5B9);
  static const Color _border = Color(0xFF393236);

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: profile.name);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _addressController = TextEditingController(text: profile.address);
    _notesController = TextEditingController(text: profile.medicalNotes);

    _dateOfBirth = profile.dateOfBirth;
    _photoUrl = profile.photoUrl;
    _photoBytes = profile.photoBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _mauve,
              surface: _surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _changePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _photoBytes = bytes;
        _photoUrl = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not select the photo. Please try again.'),
        ),
      );
    }
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    profile.updateProfile(
      name: _nameController.text.trim(),
      dateOfBirth: _dateOfBirth,
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      medicalNotes: _notesController.text.trim(),
      photoUrl: _photoUrl,
      photoBytes: _photoBytes,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
      ),
    );
  }

  
  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: _mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFFF454D)),
            ),
          ),
        ],
      ),
    );

    if (!mounted || shouldLogout != true) return;

    profile.clearProfile();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  Widget _buildAvatar() {
    Widget image;

    if (_photoBytes != null) {
      image = Image.memory(
        _photoBytes!,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultAvatar(),
      );
    } else if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      image = Image.network(
        _photoUrl!,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultAvatar(),
      );
    } else {
      image = _defaultAvatar();
    }

    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _mauve, width: 2),
      ),
      child: ClipOval(child: image),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 104,
      height: 104,
      color: _mauve.withAlpha(35),
      child: const Icon(
        Icons.person_outline_rounded,
        color: _mauve,
        size: 54,
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _mauve, size: 21),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint ?? 'Enter $label',
              hintStyle: const TextStyle(
                color: Color(0xFF777077),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFF151315),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: _mauve, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField() {
    final dateText = _dateOfBirth == null
        ? 'Select your date of birth'
        : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/'
            '${_dateOfBirth!.month.toString().padLeft(2, '0')}/'
            '${_dateOfBirth!.year}';

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of Birth',
            style: TextStyle(
              color: _mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: const Color(0xFF151315),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: _mauve,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          color: _dateOfBirth == null
                              ? const Color(0xFF777077)
                              : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _mutedText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Row(
                children: [
                  Material(
                    color: _surface,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(13),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile & Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage your personal information',
                          style: TextStyle(
                            color: _mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable profile content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile photo card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          _buildAvatar(),
                          const SizedBox(height: 14),
                          Text(
                            _nameController.text.isEmpty
                                ? 'Your Profile'
                                : _nameController.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _dateOfBirth == null
                                ? 'Personal health profile'
                                : 'Age: ${profile.age}',
                            style: const TextStyle(
                              color: _mutedText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: _changePhoto,
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 17,
                            ),
                            label: const Text('Change Photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _mauve,
                              side: const BorderSide(color: _mauve),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Personal information
                    _sectionTitle(
                      'Personal Information',
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 4),

                    _field('Full Name', _nameController),
                    _dateField(),
                    _field(
                      'Phone Number',
                      _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'Address',
                      _addressController,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 28),

                    // Medical information
                    _sectionTitle(
                      'Medical Information',
                      Icons.medical_information_outlined,
                    ),
                    _field(
                      'Medical Notes',
                      _notesController,
                      hint: 'Enter relevant medical notes',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 28),

                    // Save button
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save_outlined, size: 20),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mauve,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Log out button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6666),
                          side: const BorderSide(
                            color: Color(0xFFFF454D),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const HealthLineBottomNavigation(selectedIndex: 3),
          ],
        ),
      ),
    );
  }
}