// import 'package:flutter/material.dart';

// class TaskLableWidget extends StatelessWidget {
//   const TaskLableWidget({super.key, required this.labels});
//   final List<String> labels;

//   Icon getIcon() {
//     switch (labels[0]) {
//       case 'study':
//         return Icon(Icons.school, color: Colors.blue[200], size: 16);
//       case 'work':
//         return Icon(Icons.work, color: Colors.blue[200], size: 16);
//       case 'health':
//         return Icon(
//           Icons.health_and_safety,
//           color: Colors.green[200],
//           size: 16,
//         );
//       case 'finance':
//         return Icon(Icons.monetization_on, color: Colors.yellow[200], size: 16);
//       case 'social':
//         return Icon(Icons.people, color: Colors.yellow[200], size: 16);
//       case 'leisure':
//         return Icon(Icons.label, color: Colors.blue[200], size: 16);
//       case 'home':
//         return Icon(Icons.home, color: Colors.green[200], size: 16);
//       case 'family':
//         return Icon(Icons.family_restroom, color: Colors.purple[200], size: 16);
//       case 'self':
//         return Icon(Icons.label, color: Colors.pink[200], size: 16);
//       default:
//         return Icon(Icons.label, color: Colors.white.withAlpha(100), size: 16);
//     }
//   }

//   Color getColor() {
//     switch (labels[0]) {
//       case 'study':
//         return Colors.blue[200]!;
//       case 'work':
//         return Colors.blue[200]!;
//       case 'health':
//         return Colors.green[200]!;
//       case 'finance':
//         return Colors.yellow[200]!;
//       case 'social':
//         return Colors.yellow[200]!;
//       case 'leisure':
//         return Colors.blue[200]!;
//       case 'home':
//         return Colors.green[200]!;
//       case 'family':
//         return Colors.purple[200]!;
//       case 'self':
//         return Colors.pink[200]!;
//       default:
//         return Colors.white.withAlpha(100);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: getColor().withAlpha(50), width: 1),
//         color: getColor().withAlpha(50),
//       ),
//       child: Row(
//         children: [
//           getIcon(),
//           SizedBox(width: 4),
//           Text(
//             labels[0],
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
