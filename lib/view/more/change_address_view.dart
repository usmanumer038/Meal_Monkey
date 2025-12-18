import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../common/color_extension.dart';

class ChangeAddressView extends StatefulWidget {
  const ChangeAddressView({super.key});

  @override
  State<ChangeAddressView> createState() => _ChangeAddressViewState();
}

class _ChangeAddressViewState extends State<ChangeAddressView> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> suggestions = [];

  // Default center (Mountain View). Adjust if you like.
  LatLng center = const LatLng(37.4279613358, -122.0857496559);
  LatLng? selectedLatLng;
  String selectedAddress = "";

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    // Nominatim free endpoint (respect usage policy and rate limits)
    final url =
        "https://nominatim.openstreetmap.org/search?"
        "q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5";

    final res = await http.get(
      Uri.parse(url),
      headers: {
        // Set a proper User-Agent per Nominatim policy
        "User-Agent": "yourapp/1.0 (contact@example.com)"
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      setState(() {
        suggestions = data
            .map<Map<String, dynamic>>((item) => {
          "name": item["display_name"] ?? "",
          "lat": double.tryParse(item["lat"] ?? "0") ?? 0,
          "lng": double.tryParse(item["lon"] ?? "0") ?? 0,
        })
            .toList();
      });
    } else {
      setState(() => suggestions = []);
    }
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchPlaces(val);
    });
  }

  void _selectPlace(Map<String, dynamic> p) {
    final lat = p['lat'] as double;
    final lng = p['lng'] as double;
    final addr = p['name'] as String;
    setState(() {
      selectedLatLng = LatLng(lat, lng);
      selectedAddress = addr;
      suggestions = [];
      _search.text = addr;
    });
    _mapController.move(selectedLatLng!, 15);
  }

  void _onMapTap(TapPosition tapPos, LatLng latlng) {
    setState(() {
      selectedLatLng = latlng;
      selectedAddress =
      "Lat: ${latlng.latitude.toStringAsFixed(5)}, Lng: ${latlng.longitude.toStringAsFixed(5)}";
    });
  }

  void _confirm() {
    if (selectedAddress.isEmpty || selectedLatLng == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please select an address")));
      return;
    }
    Navigator.pop(context, {
      "address": selectedAddress,
      "lat": selectedLatLng!.latitude,
      "lng": selectedLatLng!.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (selectedLatLng != null)
        Marker(
          point: selectedLatLng!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 36),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: const Text("Change Address"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search address",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: TColor.textfield,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (ctx, i) {
                  final p = suggestions[i];
                  return ListTile(
                    title: Text(p["name"] ?? ""),
                    onTap: () => _selectPlace(p),
                  );
                },
              ),
            )
          else
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: selectedLatLng ?? center,
                  initialZoom: 13,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: "com.example.app",
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _confirm,
              child: const Text("Use this address"),
            ),
          )
        ],
      ),
    );
  }
}