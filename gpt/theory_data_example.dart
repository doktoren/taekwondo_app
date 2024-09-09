// theory_data.dart

class Belt {
  final int level;
  final String name;
  final Map<String, Map<String, String>> categories;

  Belt({required this.level, required this.name, required this.categories});
}

final List<Belt> allBelts = [
  Belt(
    level: 10,
    name: '10. kup - hvidt bælte med gul streg',
    categories: {
      'Stand': {
        'Moa-seogi': 'Samlet fødder stand (hilsestand)',
        'Dwichook-moa-seogi': 'Stand med samlede hæle (Knyttet håndsbredde mellem tæer)',
        'Naranhi-seogi': 'Parallel stand (skulderstandsbredde mellem fødderne)',
        'Joochoom-seogi': 'Hestestand (1½ skulderbredde mellem fødderne)',
      },
      'Håndteknik': {
        'Eolgul jireugi': 'Slag høj sektion. (Hånden i næsehøjde)',
        'Momtong jireugi': 'Slag midter sektion (Hånden ud for solar plexus)',
        'Arae jireugi': 'Slag lav sektion (Hånd mellem navle og skamben.)',
      },
      'Benteknik': {
        'Bakat-chagi': 'Udadgående spark (Rammer med knivfod)',
        'An-chagi': 'Indadgående spark (Rammer med flad fod)',
        'Ap-chagi': 'Front spark (Rammer med apchook)',
      },
      'Teori': {
        'Jumeok': 'Knyttet hånd',
        'Jireugi': 'Slag fra hoften m. knyttet hånd',
        'Chagi': 'Spark',
        'Ap': 'Front',
      },
    },
  ),
  Belt(
    level: 9,
    name: '9. kup - gult bælte',
    // More entries of the same kind ...
    categories: {
      // Similar to categories in the entry above
    },
  ),
  // More entries of the same kind ...
];
