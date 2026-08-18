import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> employees = [
      {
        'image':
            'https://static.vecteezy.com/system/resources/thumbnails/048/887/349/small/portrait-of-a-serious-young-man-photo.jpg',
        'name': 'Bilal Shah',
        'role': 'ESP32 Tech Support',
        'email': 'bilal.s@company.com',
        'phone': '+92 333 9876543',
      },
      {
        'image':
            'https://static.vecteezy.com/system/resources/thumbnails/048/887/349/small/portrait-of-a-serious-young-man-photo.jpg',
        'name': 'Bilal Shah',
        'role': 'ESP32 Tech Support',
        'email': 'bilal.s@company.com',
        'phone': '+92 333 9876543',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Registered Employees',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
        itemCount: employees.length,

        separatorBuilder: (context, index) {
          return const SizedBox(height: 3);
        },

        itemBuilder: (context, index) {
          final emp = employees[index];

          return Dismissible(
            key: ValueKey(index),

            direction: DismissDirection.horizontal,

            // Swipe RIGHT → Edit UI
            background: Container(
              padding: const EdgeInsets.only(left: 25),
              width: 50,
              alignment: Alignment.centerLeft,
              color: const Color(0xFF00D9A5),
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.black, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'EDIT',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Swipe LEFT → Delete UI
            secondaryBackground: Container(
              padding: const EdgeInsets.only(right: 25),
              alignment: Alignment.centerRight,
              color: Colors.redAccent,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'DELETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ],
              ),
            ),

            child: EmployeeLandscapeCard(
              name: emp['name']!,
              role: emp['role']!,
              email: emp['email']!,
              phone: emp['phone']!,
              image: emp['image']!,
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('addemployee');
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_alt_outlined),
      ),
    );
  }
}

// ============================================================
// EMPLOYEE CARD CLASS
// ============================================================

class EmployeeLandscapeCard extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String image;

  const EmployeeLandscapeCard({
    super.key,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF151D25),

        border: Border.all(
          color: const Color(0xFF00D9A5).withOpacity(0.08),
          width: 1,
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ==================================================
          // PROFILE IMAGE
          // ==================================================
          Container(
            height: 90,
            width: 90,

            decoration: BoxDecoration(
              color: const Color(0xFF0B0F14),

              borderRadius: BorderRadius.circular(8),

              border: Border.all(
                color: const Color(0xFF00D9A5).withOpacity(0.25),
                width: 2,
              ),

              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ==================================================
          // EMPLOYEE INFORMATION
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // NAME
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // ROLE
                Text(
                  role,
                  style: const TextStyle(
                    color: Color(0xFF00D9A5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // EMAIL
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                      size: 14,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // PHONE
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: Colors.grey,
                      size: 14,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        phone,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
