# Telegrama - Frontend

Este é o projeto frontend do aplicativo, desenvolvido utilizando [Flutter](https://flutter.dev/).

## Pré-requisitos

Para rodar este projeto, você precisa ter o seguinte instalado em sua máquina:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (compatível com a versão ^3.11.4 do Dart)
- Um emulador (Android/iOS) rodando, um dispositivo físico conectado ou um navegador (como o Google Chrome) para rodar na versão web.
- IDE recomendada: [Visual Studio Code](https://code.visualstudio.com/) com a extensão do Flutter, ou [Android Studio](https://developer.android.com/studio).

## Como iniciar o front-end

1. Abra o terminal e certifique-se de estar na pasta `frontend`:
   ```bash
   cd frontend
   ```

2. Baixe as dependências do projeto:
   ```bash
   flutter pub get
   ```

3. Execute o aplicativo:
   Para rodar no dispositivo ou emulador padrão ativo:
   ```bash
   flutter run
   ```

   Caso queira rodar especificamente na web (Chrome):
   ```bash
   flutter run -d chrome
   ```

## Outros comandos úteis

- Para verificar se o ambiente do Flutter está configurado corretamente:
  ```bash
  flutter doctor
  ```
- Para rodar a análise de código (linting):
  ```bash
  flutter analyze
  ```
