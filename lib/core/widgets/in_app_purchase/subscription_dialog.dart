// import 'dart:developer';
// import 'package:fantavacanze_official/core/constants/constants.dart';
// import 'package:fantavacanze_official/core/pages/app_terms.dart';
// import 'package:fantavacanze_official/core/theme/colors.dart';
// import 'package:fantavacanze_official/core/theme/theme.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';

// // List of premium features
// const List<String> premiumFeatures = [
//   "Nessuna pubblicità",
//   "3 obiettivi giornalieri",
//   "Accesso diretto ai giochi",
//   "Whitelist per future posizioni lavorative",
//   "Supporto prioritario",
// ];

// void showSubscriptionDialog(
//   BuildContext context, {
//   required Function(ProductDetails?) onProductSelected,
//   String title = "Abbonamento Premium",
// }) {
//   showModalBottomSheet<bool?>(
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(20),
//         topRight: Radius.circular(20),
//       ),
//     ),
//     backgroundColor: context.secondaryBgColor,
//     showDragHandle: true,
//     context: context,
//     isScrollControlled: true,
//     builder: (BuildContext context) {
//       return Theme(
//         data: AppTheme.applyPremiumBottomSheetTheme(context),
//         child: BlocProvider.value(
//           value: BlocProvider.of<SubscriptionCubit>(context),
//           child: SubscriptionBottomSheet(
//             title: title,
//             onProductSelected: onProductSelected,
//           ),
//         ),
//       );
//     },
//   ).then((value) async {
//     if (value != true || !context.mounted) return;

//     final selectedProduct =
//         context.read<SubscriptionCubit>().state.selectedProduct;
    
//     if (selectedProduct == null && context.mounted) {
//       log("Seleziona un piano Premium");
//       return;
//     }

//     onProductSelected(selectedProduct);
//   });
// }

// class SubscriptionBottomSheet extends StatelessWidget {
//   final String title;
//   final Function(ProductDetails?) onProductSelected;

//   const SubscriptionBottomSheet({
//     super.key,
//     required this.title,
//     required this.onProductSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<SubscriptionCubit, SubscriptionState>(
//       listener: (context, state) {
//         if (state.status == SubscriptionStatus.error &&
//             state.errorMessage != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.errorMessage!)),
//           );
//         } else if (state.status == SubscriptionStatus.restored) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Acquisti ripristinati con successo")),
//           );
//         }
//       },
//       builder: (context, state) {                        
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHeader(context),
//                 const SizedBox(height: 5),
//                 _buildFeatures(context),
//                 const SizedBox(height: 15),
//                 _buildSubscriptionOptions(context, state),
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(AppTermsPage.route);
//                   },
//                   child: Text(
//                     "Termini e Condizioni",
//                     style: TextStyle(color: ColorPalette.info),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 _buildSubscribeButton(context, state),
//                 const SizedBox(height: 15),
//                 _buildRestorePurchaseButton(context),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 10),
//         Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: context.textPrimaryColor,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatures(BuildContext context) {
//     return Column(
//       children: [
//         for (var feature in premiumFeatures)
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.check_circle,
//                   color: ColorPalette.success,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     feature,
//                     style: TextStyle(
//                       color: context.textSecondaryColor,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildSubscriptionOptions(
//       BuildContext context, SubscriptionState state) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 5, bottom: 10),
//           child: Text(
//             "Scegli il tuo piano",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: context.textPrimaryColor,
//             ),
//           ),
//         ),
//         if (state.availableProducts.isEmpty)
//           _buildEmptyProductsView(context, state),
//         ...List.generate(state.availableProducts.length, (index) {
//           final plan = state.availableProducts[index];
//           final isSelected = state.selectedProduct?.id == plan.id;
//           final isMonthly = plan.id.contains('monthly');

//           return GradientSubscriptionCard(
//             plan: plan,
//             isSelected: isSelected,
//             isMonthly: isMonthly,
//             onTap: () {
//               context.read<SubscriptionCubit>().selectProduct(plan);
//             },
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildEmptyProductsView(BuildContext context, SubscriptionState state) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: state.status == SubscriptionStatus.loading ||
//                 state.status == SubscriptionStatus.purchasing
//             ? CircularProgressIndicator(color: ColorPalette.premiumUser)
//             : Text(
//                 "Nessun piano disponibile",
//                 style: TextStyle(color: context.textSecondaryColor),
//               ),
//       ),
//     );
//   }

//   Widget _buildSubscribeButton(BuildContext context, SubscriptionState state) {
//     bool isLoading = state.status == SubscriptionStatus.loading ||
//         state.status == SubscriptionStatus.purchasing;

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: ColorPalette.premiumUser,
//         ),
//         onPressed: state.selectedProduct == null || isLoading
//             ? null
//             : () {
//                 Navigator.of(context).pop(true);
//               },
//         child: isLoading
//             ? SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             : const Text("Abbonati ora"),
//       ),
//     );
//   }

//   Widget _buildRestorePurchaseButton(BuildContext context) {
//     return OutlinedButton(
//       style: OutlinedButton.styleFrom(
//         fixedSize: Size.fromWidth(Constants.getWidth(context)),
//         foregroundColor: ColorPalette.premiumUser,
//         side: BorderSide(color: ColorPalette.premiumUser, width: 1.5),
//       ),
//       onPressed: () {
//         context.read<SubscriptionCubit>().restorePurchases();
//       },
//       child: const Text("Ripristina acquisti"),
//     );
//   }
// }

// class GradientSubscriptionCard extends StatelessWidget {
//   final ProductDetails plan;
//   final bool isSelected;
//   final bool isMonthly;
//   final VoidCallback onTap;

//   const GradientSubscriptionCard({
//     super.key,
//     required this.plan,
//     required this.isSelected,
//     required this.isMonthly,
//     required this.onTap,
//   });

//   String _getLocalizedTitle(ProductDetails product) {
//     if (product.id.contains('monthly')) {
//       return 'Piano Mensile';
//     } else if (product.id.contains('annual')) {
//       return 'Piano Annuale';
//     }
//     return product.title.split('(').first;
//   }

//   String _getDurationTitle(String idCode) {
//     if (idCode.contains('monthly')) {
//       return "al mese";
//     }
//     return "all'anno";
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Define gradient colors based on plan type and selection status
//     final List<Color> gradientColors = isMonthly
//         ? [
//             const Color(0xFF8A2387),
//             const Color(0xFFE94057),
//             const Color(0xFFF27121),
//           ]
//         : [
//             const Color(0xFF1A2980),
//             const Color(0xFF26D0CE),
//           ];
    
//     // Calculate discount percentage for annual plan (if applicable)
//     final bool hasDiscount = !isMonthly;
//     final String discountText = hasDiscount ? "Risparmia 25%" : "";
    
//     // Plan-specific icon
//     final IconData planIcon = isMonthly
//         ? Icons.calendar_month_rounded
//         : Icons.calendar_today_rounded;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         child: Stack(
//           children: [
//             // Main card with gradient
//             Container(
//               padding: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: isSelected
//                       ? ColorPalette.premiumUser
//                       : Colors.transparent,
//                   width: 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: isSelected
//                         ? gradientColors.first.withValues(alpha: 0.3)
//                         : gradientColors.first.withValues(alpha: 0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 20, horizontal: 16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: isSelected
//                         ? gradientColors
//                         : gradientColors.map(
//                             (color) => color.withValues(alpha: 0.1),
//                           ).toList()
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     // Left side - Plan icon and info
//                     Expanded(
//                       flex: 3,
//                       child: Row(
//                         children: [
//                           // Radio button or plan icon
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? Colors.white.withValues(alpha: 0.2)
//                                   : gradientColors.first.withValues(alpha: 0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               planIcon,
//                               size: 24,
//                               color: isSelected
//                                   ? Colors.white
//                                   : gradientColors.first,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           // Plan name and description
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _getLocalizedTitle(plan),
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                     color: isSelected
//                                         ? Colors.white
//                                         : context.textPrimaryColor,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   plan.description,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: isSelected
//                                         ? Colors.white.withValues(alpha: 0.8)
//                                         : context.textSecondaryColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     // Right side - Price info
//                     Expanded(
//                       flex: 2,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             plan.price,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: isSelected
//                                   ? Colors.white
//                                   : context.textPrimaryColor,
//                             ),
//                           ),
//                           Text(
//                             _getDurationTitle(plan.id),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isSelected
//                                   ? Colors.white.withValues(alpha: 0.8)
//                                   : context.textSecondaryColor,
//                             ),
//                           ),
//                           if (hasDiscount) ...[
//                             const SizedBox(height: 4),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Colors.white.withValues(alpha: 0.2)
//                                     : ColorPalette.success.withValues(alpha: 0.2),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Text(
//                                 discountText,
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                   color: isSelected
//                                       ? Colors.white
//                                       : ColorPalette.success,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Selection indicator (checkmark)
//             if (isSelected)
//               Positioned(
//                 top: 2,
//                 right: 2,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.check_circle,
//                     size: 14,
//                     color: ColorPalette.premiumUser,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
