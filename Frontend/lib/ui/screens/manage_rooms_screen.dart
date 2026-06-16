import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/admin_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class ManageRoomsScreen extends StatefulWidget {
  const ManageRoomsScreen({super.key});

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      Provider.of<AdminProvider>(context, listen: false).fetchRooms();
    });
  }

  // دالة مساعدة لطلب صلاحيات الموقع وجلب الإحداثيات
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
    );
  }

  // نافذة الإضافة والتعديل
  void _showAddOrEditRoomDialog({Map<String, dynamic>? roomToEdit}) {
    final isEditing = roomToEdit != null;

    double initialLat = 0.0;
    double initialLng = 0.0;

    if (isEditing && roomToEdit['geofenceCenter'] != null) {
      final coordinates = roomToEdit['geofenceCenter']['coordinates'] as List?;
      if (coordinates != null && coordinates.length >= 2) {
        initialLng = (coordinates[0] as num).toDouble();
        initialLat = (coordinates[1] as num).toDouble();
      }
    }

    final numberController = TextEditingController(text: isEditing ? roomToEdit['roomNumber'] : '');
    final capacityController = TextEditingController(text: isEditing ? roomToEdit['capacity']?.toString() : '50');
    final latController = TextEditingController(text: isEditing ? initialLat.toString() : '');
    final longController = TextEditingController(text: isEditing ? initialLng.toString() : '');
    final radiusController = TextEditingController(text: isEditing ? roomToEdit['geofenceRadius']?.toString() : '50');

    showDialog(
      context: context,
      builder: (ctx) => Consumer<AdminProvider>(
        builder: (context, provider, _) => StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_location_alt : Icons.add_location_alt, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(isEditing ? "تعديل بيانات القاعة" : "إضافة قاعة جديدة", style: const TextStyle(fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400, // تحديد عرض ثابت للنافذة المنبثقة لتبدو أنيقة على الكمبيوتر
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                          controller: numberController,
                          decoration: const InputDecoration(labelText: "رقم / اسم القاعة", border: OutlineInputBorder())
                      ),
                      const SizedBox(height: 12),
                      TextField(
                          controller: capacityController,
                          decoration: const InputDecoration(labelText: "سعة القاعة (عدد الطلاب)", border: OutlineInputBorder()),
                          keyboardType: TextInputType.number
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.05),
                            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.gps_fixed, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text("الموقع الجغرافي (Geofence)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  Position? pos = await _getCurrentLocation();
                                  if (pos != null) {
                                    setDialogState(() {
                                      latController.text = pos.latitude.toString();
                                      longController.text = pos.longitude.toString();
                                    });
                                  }
                                },
                                icon: const Icon(Icons.my_location),
                                label: const Text("استخدام إحداثياتي الحالية", style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12)
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(controller: latController, decoration: const InputDecoration(labelText: "خط العرض (Latitude)"), keyboardType: TextInputType.number),
                            TextField(controller: longController, decoration: const InputDecoration(labelText: "خط الطول (Longitude)"), keyboardType: TextInputType.number),
                            TextField(controller: radiusController, decoration: const InputDecoration(labelText: "نصف قطر السماحية (بالمتر)"), keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("إلغاء", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: provider.isLoading ? null : () async {
                    if (numberController.text.isEmpty || latController.text.isEmpty || longController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("يرجى تعبئة جميع الحقول المطلوبة"), backgroundColor: Colors.red)
                      );
                      return;
                    }

                    final roomData = {
                      if (isEditing) "id": roomToEdit['id'],
                      "roomNumber": numberController.text,
                      "capacity": int.tryParse(capacityController.text) ?? 50,
                      "geofenceRadius": double.tryParse(radiusController.text) ?? 50.0,
                      "geofenceCenter": {
                        "type": "Point",
                        "coordinates": [
                          double.tryParse(longController.text) ?? 0.0,
                          double.tryParse(latController.text) ?? 0.0
                        ]
                      }
                    };

                    final success = await provider.addRoom(roomData, isEdit: isEditing);

                    if (!context.mounted) return;

                    if (success) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم الحفظ بنجاح"), backgroundColor: Colors.green)
                      );
                    }
                  },
                  child: provider.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEditing ? "حفظ التعديلات" : "إضافة القاعة", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة القاعات والمواقع"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: const Text("إضافة قاعة", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddOrEditRoomDialog(),
      ),
      // 🌟 تمركز المحتوى
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.rooms.isEmpty) return const Center(child: CircularProgressIndicator());

            if (provider.rooms.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.room_preferences, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("لا توجد قاعات مضافة حالياً.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.rooms.length,
              itemBuilder: (context, index) {
                final room = provider.rooms[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.meeting_room, color: Colors.white),
                    ),
                    title: Text("قاعة: ${room['roomNumber']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text("السعة: ${room['capacity']} طالب | السماحية: ${room['geofenceRadius']} متر", style: const TextStyle(color: Colors.blueGrey)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: "تعديل",
                          onPressed: () => _showAddOrEditRoomDialog(roomToEdit: room),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "حذف",
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text("تأكيد الحذف"),
                                    ],
                                  ),
                                  content: const Text("هل أنت متأكد من حذف هذه القاعة؟"),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(c, false),
                                        child: const Text("إلغاء", style: TextStyle(color: Colors.grey))
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text("حذف"),
                                    )
                                  ],
                                )
                            );

                            if (confirm == true) {
                              await provider.deleteRoom(room['id'].toString());

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("تم حذف القاعة بنجاح"), backgroundColor: Colors.green)
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}