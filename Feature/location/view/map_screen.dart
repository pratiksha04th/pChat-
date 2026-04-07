import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

import '../../../utilities/App_Colors/App_Colors.dart';

class MapScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final String username;

  const MapScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.username,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  String? _mapStyle;
  bool _isMenuOpen = false;
  MapType _currentMapType = MapType.normal;

  @override
  void initState(){
    super.initState();
    _loadMapStyle();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }
  Future<void> _loadMapStyle() async {
    try{
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
      setState(() {});
    } catch (e) {
      print("Map style load error: $e");
    }
  }
  void _onMapCreated(GoogleMapController controller){
    _mapController = controller;

    if(_mapStyle !=null){
      controller.setMapStyle(_mapStyle);

    }
  }
  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(widget.lat, widget.lng);

    return Scaffold(
      extendBodyBehindAppBar: true,

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "${widget.username}'s Location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          /// GOOGLE MAP
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: CameraPosition(target: position, zoom: 15),

            onMapCreated: (controller) {
              _onMapCreated(controller);
            },

            markers: {
              Marker(
                markerId: const MarkerId("user"),
                position: position,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure, // for color
                ),
              ),
            },

            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          /// TOP GRADIENT
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.9),
                  Colors.blue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// FLOATING BUTTONS (RIGHT SIDE)
          Positioned(
            right: 12,
            top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                _mapButton(Icons.my_location, () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(position),
                  );
                }),
               const SizedBox(height: 10),
                _mapButton(Icons.refresh, () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(position, 16),
                  );
                }),
              ],
            ),
          ),

          Positioned(
            right: 12,
            bottom: MediaQuery.of(context).padding.bottom + 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                /// SATELLITE
                if (_isMenuOpen)
                  AnimatedOpacity(
                    opacity: _isMenuOpen ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                  child: _fabOption(
                    icon: Icons.satellite,
                    color: Colors.black,
                    onTap: () => _setMapType(MapType.satellite),
                  ),
                  ),

                const SizedBox(height: 10),

                /// HYBRID
                if (_isMenuOpen)
                  _fabOption(
                    icon: Icons.layers,
                    color: Colors.orange,
                    onTap: () => _setMapType(MapType.hybrid),
                  ),

                const SizedBox(height: 10),

                /// TERRAIN
                if (_isMenuOpen)
                  _fabOption(
                    icon: Icons.map,
                    color: Colors.green,
                    onTap: () => _setMapType(MapType.terrain),
                  ),

                const SizedBox(height: 10),

                /// MAIN BUTTON
                FloatingActionButton(
                  heroTag: "mapType",
                  backgroundColor: AppColors.themeColor,
                  onPressed: _toggleMenu,
                  child: Icon(
                    _isMenuOpen ? Icons.close : Icons.layers,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// BOTTOM CARD (MAIN UI)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// USER INFO
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.lightAvatarGradient,
                          border: Border.all(
                            color: AppColors.themeColor,
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            widget.username[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                "Live Location",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),

                      const Icon(Icons.more_vert),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// LAST UPDATED
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Last updated: Just now",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // You can integrate Google Maps navigation intent here
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: AppColors.themeColor,
                      ),
                      child: const Text(
                        "Get Directions",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CUSTOM MAP BUTTON
  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: AppColors.themeColor),
      ),
    );
  }


  void _setMapType(MapType type) {
    setState(() {
      _currentMapType = type;
      _isMenuOpen = false; // close menu after selection
    });
  }


  Widget _fabOption({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
