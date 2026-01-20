import 'package:flutter/material.dart';

class PersonalDataSectionBook extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController complaintController;
  final bool isLoadingLocation;
  final VoidCallback onGetLocation;

  const PersonalDataSectionBook({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.complaintController,
    required this.isLoadingLocation,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Diri Anda',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap Anda',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Nomor HP / WhatsApp',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor HP tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: 'Alamat Saat Ini',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: IconButton(
              onPressed: isLoadingLocation ? null : onGetLocation,
              icon: isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: complaintController,
          decoration: const InputDecoration(
            labelText: 'Keluhan / Isu Utama',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.healing),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Keluhan tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}


