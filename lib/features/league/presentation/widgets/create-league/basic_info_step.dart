import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

class BasicInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final GlobalKey<FormState> formKey;

  const BasicInfoStep({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informazioni di Base',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeSizes.xl),
          _buildNameField(context),
          const SizedBox(height: ThemeSizes.md),
          _buildDescriptionField(context),
        ],
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
            floatingLabelStyle: TextStyle(color: Colors.white),
          ),
        ),
        child: TextFormField(
          controller: nameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Nome Lega',
            hintText: 'es. Fanta Marbella',
            prefixIcon: Icon(Icons.title, color: context.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: context.secondaryBgColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
            floatingLabelStyle: TextStyle(color: Colors.white),
          ),
        ),
        child: TextFormField(
          controller: descriptionController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Motto',
            hintText: 'Hai un motto? Scrivilo qui!',
            prefixIcon: Icon(Icons.description, color: context.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: context.secondaryBgColor,
          ),
          maxLines: 3,
        ),
      ),
    );
  }
}
