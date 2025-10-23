const bool isProduction = bool.fromEnvironment('dart.vm.product');

//10.0.2.2 = AVD, 192.168.0.19 = real device connecté wifi ! => ifconfig ou UI wifi trouver l'ipv4 du reseaux wifi / ethernet courant
//ubutnu : sudo ufw allow 3000
// const Map<String, String> devConfig = {
//   'baseApiUrl':
//       'http://10.0.2.2:8000/elh-api', // points to PC localhost from emulator
//   'baseApiUrlPublic': 'http://10.0.2.2:8000',
// };
const Map<String, String> devConfig = {
  'baseApiUrl':
      'http://192.168.100.2:8000/elh-api', // points to PC localhost from emulator
  'baseApiUrlPublic': 'http://192.168.100.2:8000',
};

const Map<String, String> productionConfig = {
  'baseApiUrl': 'http://192.168.100.2:8000/elh-api',
  'baseApiUrlPublic': 'http://192.168.100.2:8000',
};

final Map<String, String> environment =
    isProduction ? productionConfig : devConfig;
// final environment = productionConfig;
