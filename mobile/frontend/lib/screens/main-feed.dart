import 'package:flutter/material.dart';
import 'modules/header.dart';

class MainFeedScreen extends StatelessWidget {
  const MainFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F5), // Cor de fundo levemente esverdeada da sua imagem
      body: Column(
        children: [
          // 1. TOPO: O Header fica fixo em cima de ponta a ponta
          const HeaderWidget(), // Substitua pelo seu widget de header.dart
          
          // 2. CORPO PRINCIPAL: Dividido entre Menu Lateral (Esquerda) e Conteúdo (Direita)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu Lateral esquerdo
                const SizedBox(
                  width: 260,
                  //child: MenuWidget(), // Substitua pelo seu menu.dart
                ),
                
                // Área central do Feed de Posts com rolagem
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Caixa para criar novo post

                        const SizedBox(height: 24),
                        
                        // Lista de Posts (Aqui você usaria uma ListView.builder no futuro)
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}