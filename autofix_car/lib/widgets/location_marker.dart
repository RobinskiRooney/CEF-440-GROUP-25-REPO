// import 'package:flutter/material.dart';
// import '../models/map_location.dart';

// class LocationMarker extends StatelessWidget {
//   final MapLocation location;
//   final VoidCallback onTap;

//   const LocationMarker({
//     super.key,
//     required this.location,
//     required this.onTap,
//   });

//   IconData _getLocationIcon(LocationType type) {
//     switch (type) {
//       case LocationType.academy:
//         return Icons.school;
//       case LocationType.hotel:
//         return Icons.hotel;
//       case LocationType.stadium:
//         return Icons.sports_soccer;
//       case LocationType.university:
//         return Icons.account_balance;
//       case LocationType.mechanicShop:
//         return Icons.build;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: location.position.dx,
//       top: location.position.dy,
//       child: GestureDetector(
//         onTap: onTap,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: location.type == LocationType.academy
//                     ? Colors.purple.shade400
//                     : Colors.pink.shade400,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 location.name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: location.type == LocationType.academy
//                     ? Colors.purple.shade400
//                     : Colors.pink.shade400,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//               child: Icon(
//                 _getLocationIcon(location.type),
//                 color: Colors.white,
//                 size: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }