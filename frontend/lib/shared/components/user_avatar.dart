import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? localImagePath;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.localImagePath,
    required this.name,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Estilo Neubrutalista: Borda grossa em volta do avatar
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 0,
          )
        ],
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(localImagePath!, fit: BoxFit.cover);
      } else {
        return Image.file(File(localImagePath!), fit: BoxFit.cover);
      }
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(imageUrl!, fit: BoxFit.cover);
    }
    
    return Center(
      child: Text(
        _getInitials(name),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: radius * 0.8,
          color: Colors.black,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
