Content of ../app/lib/screens/theory_data.dart:
```
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
        'Apkoobi': 'Lang stand (Længde: 1½ skridtlængde eller harmonisk i forhold til kropsbygning. Bredde: skulderbredde)',
        'Apseogi': 'Kort stand (Bredde: moa-seogi. Længde: Gåskridt eller harmonisk i forhold til kropsbygning)',
        'Gibon-joonbi-seogi': 'Klarstand ved grundteknik. Som naranhi-seogi. Knyttede hænder foran.',
      },
      'Håndteknik': {
        'Arae hechyomakki': 'Lav sektion “adskille” blokering. (Armene 45 grader ud fra kroppen).',
        'Arae-makki': 'Lav sektion blokering. (Hånden cirka 20 cm. over benet.)',
        'Momtongmakki': 'Midter sektion blokering.(90 grader mellem over-/underarm, 45 grader mellem overarm og krop. Hånd foran midterlinien og ud for næsen, albue foran sidelinien.)',
        'Momtong anmakki': 'Midter sektion blokering (modsat arm / ben)',
        'Eolgulmakki': 'Høj sektion blokering (Hånd er en håndsbredde over panden)',
        'Eolgul jireugi': 'Slag høj sektion. (Hånden i næsehøjde)',
        'Momtong jireugi': 'Slag midter sektion (Hånden ud for solar plexus)',
        'Arae jireugi': 'Slag lav sektion (Hånd mellem navle og skamben.)',
      },
      'Benteknik': {
        'Naeryo-chagi': 'Nedadgående spark (Løft benet lige op, bøjet. Stræk det lige frem og træk nedad strakt. Hoften skydes frem.)',
        'Bakat-chagi': 'Udadgående spark (Rammer med knivfod)',
        'An-chagi': 'Indadgående spark (Rammer med flad fod)',
        'Ap-chagi': 'Front spark (Rammer med apchook)',
      },
      'Teori': {
        'Jumeok': 'Knyttet hånd',
        'Jireugi': 'Slag fra hoften m. knyttet hånd',
        'Chagi': 'Spark',
        'Ap': 'Front',
        'An': 'Inderside/indadgående',
        'Bakat': 'Yderside/udadgående',
        'Arae': 'Lav sektion',
        'Momtong': 'Midter sektion',
        'Eolgul': 'Høj sektion',
        'Charyeo': 'Indtag hilsestand',
        'Kyeongne': 'Hils (buk)',
        'Joonbi': 'Indtag klarstand',
        'Keuman': 'Stop og indtag startposition',
        'Dirro dorra': '180 graders vending',
        'Zuu': 'Hvil/slap af efterfuldt af buk for træneren',
        'Do bok': 'Taekwondo dragt',
        'Do jang': 'Taekwondo træningssal',
        'Toga-nim': 'Træner under 1. dan',
        'Kyosa-nim': 'Træner 1-3 dan',
        'Sabum-nim': 'Træner 4. dan og mere',
        'Kukki jedeharjo kyeongne': 'Hilsen til flag',
        'Nødværgeretten': '§13 stk. 1:\nHandlinger foretaget i nødværge er straffri forsåvidt de har været nødvendige for at\nmodstå eller afværge et påbegyndt eller overhængende uretmæssigt angreb, og ikke åbenbart\ngår ud over, hvad der under hensyn til angrebets farlighed, angriberens person og det\nangrebne retsgodes betydning er forsvarlig. §13 stk.2 :\nOverskrider nogen grænsen for lovlig nødværge, bliver han dog straffri, hvis\noverskridelsen er rimeligt begrundet i den ved angrebet fremkaldte skræk eller ophidselse.',
        'Hvad betyder Taekwondo': 'Tae betyder : Fod (springe eller sparke)\nKwon betyder : Næve/hånd (slag eller stød)\nDo betyder : System/filosofisk vej\nI daglig tale : “Fod-spark-næve-systemet\n',
      },
    },
  ),
  Belt(
    level: 9,
    name: '9. kup - gult bælte',
    categories: {
      'Stand': {
        'Pyeonhi-seogi': 'Hvilestand (Hænderne bag ryggen)',
      },
      'Håndteknik': {
        'Momtong bakatmakki': 'Udadgående blokering i midter sektion (Hånd ud for skulderled. Over forreste ben)',
        'Bandae jireugi': 'Slag “over forreste ben',
        'Baro jireugi': 'Slag (modsat arm / ben) (skulder lidt frem 20 grader)',
        'Sonnal eolgul bakat-chigi': 'Udadgående slag m. knivhånd (Hånd og arm vandret ud for skulderled.\nKommer fra modsatte øre. Slaget er over forreste ben.',
      },
      'Benteknik': {
        'Baldeung dollyo-chagi': 'Cirkelspark, hvor der rammes med vrist (Benet trækkes op i en\nvinkel på 45 grader og efter en hoftedrejning ender sparket)',
      },
      'Teori': {
        'Son': 'Hånd',
        'Sonnal': 'Knivhånd',
        'Baldeung': 'Vrist',
        'Dwichook': 'Underside af hæl',
        'Chigi': 'Slag, der kommer fra skulderen',
        'Dollyo': 'Cirkel',
        'Poom': 'Grundteknik',
        'Poomse': 'Sammensatte grundteknikker',
        'DTaF': 'Dansk Taekwondo Forbund',
        'Hanna': 'En (1)',
        'Dul': 'To (2)',
        'Set': 'Tre (3)',
        'Net': 'Fire (4)',
        'Il': 'Første (1.)',
      },
    },
  ),
  Belt(
    level: 8,
    name: '8. kup - orange bælte',
    categories: {
      'Stand': {
        'Dwit-koobi': 'Sidestand (Hælene på hver side af en linie trukket fra indersiden af forreste fod.\nUdgangspunktet i denne stand er moa-seogi)',
      },
      'Håndteknik': {
        'Anpalmok momtong bakatmakki': 'Udadgående blokering m. inderside af underarm (Hånd og albue ud for sidelinien. Over forreste ben)',
        'Sonnal eolgul anchigi': 'Slag med knivhånd i høj sektion (Hånden ud for midterlinien. Arm let bøjet. Over forreste ben)',
        'Hansonnal jebipoom mok-chigi': 'Slag mod hals (modsat arm / ben) Hånden ud for midterlinien. Arm let bøjet. Over bagerste ben)',
        'Sonnal momtongmakki': 'Knivhånds blokering (Trækkes med støttearmen let bøjet fra lidt bagved hoften og den aktive hånd fra hals. Over forreste ben)',
        'Hansonnal momtong bakatmakki': 'Enkelt knivhånds blokering (Trækkes med armene puls mod puls fra øjenhøjde. Kontrahånd er knyttet)',
        'Doo bon momtong jireugi': 'Dobbelt slag i midtersektion.',
      },
      'Teori': {
        'Pal': 'Arm',
        'Palmok': 'Underarm (armhals)',
        'An-palmok': 'Inderside af underarm',
        'Bakat-palmok': 'Yderside af underarm',
        'Balnal': 'Knivfod',
        'Apchook': 'Fodballe',
        'Jebipoom': 'Svaleteknik',
        'Mok': 'Hals',
        'Yeop': 'Side',
        'Tasut': 'Fem (5)',
        'Sam': 'Tredje (3.)',
        'WTF': 'World Taekwondo Federation',
        'ETU': 'European Taekwondo Union',
      },
    },
  ),
  Belt(
    level: 7,
    name: '7. kup - grønt bælte',
    categories: {
      'Stand': {
        'Na-chooeo-seogi': 'Dyb stand (Dobbelt skulderstand)',
      },
      'Håndteknik': {
        'Jebipoom mok-chigi': 'Slag mod hals - Svaleteknik (Vinkel mellem over- og underarm på slaghånden er 20 grader.\nSlaghånden udfører vandret slag mod hals over forreste ben.\nSvaleteknikken er Eolgulmakki med knivhånd)',
        'Batangson momtong nulleomakki': 'Nedadgående blokering med håndrod (Over forreste ben. Løft IKKE albuen)',
        'Ap-chigi (deung-jumeok)': 'Front slag (omvendt knoslag) (Pegefingerknoen skal være fremspringende punkt,\nså vinkel mellem håndryg og overside af underarm er 45 grader. Over forreste ben)',
        'Pyeonson-keut seweo chireugi': 'Fingerstik med lodret håndstilling (Over forreste ben. fingerspidserne gøres lige)',
        'Hansonnal momtong yeopmakki': 'Enkelt knivhånds blokering til siden',
      },
      'Benteknik': {
        'Dwit-chagi': 'Bagud spark (Ingen blokering over benet. Rammer med underside af hæl. Kig efter sparket)',
        'Bandal-chagi': 'Halvmånespark (Mellemting mellem ap-chagi og dollyo-chagi.\nDer rammes med apchook. Benet trækkes op 22,5 grader ud fra kroppen)',
        'Mileo-chagi': 'Skubbe spark (Rammer med flad fod.\nSkubber fra knæet mod brystet og vandret skinneben under hele bevægelsen.)',
      },
      'Teori': {
        'Deung-jumeok': 'Oversiden af knyttet hånd',
        'Sewoon-jumeok': 'Lodret håndstilling med knyttet hånd',
        'Batangson': 'Håndrod',
        'Son-deung': 'Håndryggen',
        'Son-keut': 'Fingerspidserne',
        'Pyeonson-keut': 'Fingerstik',
        'Balbadak': 'Fodsål',
        'Chireugi': 'Stikslag',
        'Doo bon': '2 eller dobbelt slag',
        'Mileo': 'Skubbe',
        'Hvad er og betyder “Kihap” ?': 'Kampråb - Ki = energi, hap = samle',
        'Yusot': 'Seks (6)',
        'Sah': 'Fjerde (4.)',
        'Hvad betyder poomse': 'Imaginær kamp',
        'Shijak': 'Begynd/start',
        'Kalyeo': 'Stop/”Break”',
        'Gyesok': 'Fortsæt',
      },
    },
  ),
  Belt(
    level: 6,
    name: '6. kup - blåt bælte',
    categories: {
      'Stand': {
        'Oreun-seogi': 'Højre stand (længde: Ap-seogi, fødderne i en 90 grader. Højre fod forrest)',
        'Oen-seogi': 'Venstre stand (længde: Ap-seogi, fødderne i 90 grader. Venstre fod forrest)',
        'Ap-koa-seogi': 'Forlæns krydsstand',
        'Dwit-koa-seogi': 'Støttestand (baglæns krydsstand, al vægten er på forreste ben og ”støttebenet” holder kun balancen.)',
      },
      'Håndteknik': {
        'Me-jumeok momtong naeryo-chigi': 'Nedadgående slag med ydersiden af knyttet hånd (Overkrop drejes let i forhold til slaget. Let bøjet slagarm. Rammer efter kravebenet. Over forreste ben)',
        'Palkoop dollyo-chigi': 'Cirkel albueslag (Arm holdes vandret over forreste ben)',
        'Palkoop pyojeok-chigi': 'Albue pletslag (Danner en 4-kant foran kroppen. Arme holdes vandret. Slaget rammer hånden over bagerste ben)',
        'Yeop-jireugi': 'Sideslag (I brysthøjde.)',
      },
      'Benteknik': {
        'Biteureo-chagi': 'Vridespark (Spark rammer i midterlinien)',
        'Beodeo-chagi': 'Bøje-stræk spark (Optræk ligesom ap-chagi men rammer med underside af hæl. Overkrop lænes tilbage)',
        'Ieo-chagi': 'To ens spark lige efter hinanden (forskellige ben)',
        'Seokeo-chagi': 'To forskellige spark lige efter hinanden (samme ben)',
        'Jijjigki': 'Stamp / tramp / pulverisere',
      },
      'Teori': {
        'Mit-palmok': 'Undersiden af underarm',
        'Me-jumeok': 'Ydersiden af den knyttede hånd',
        'Palkoop': 'Albue',
        'Dari': 'Ben',
        'Mooreup': 'Knæ',
        'Pyojeok': 'Plet/punkt',
        'Ilkup': 'Syv (7)',
        'Oh': 'Femte (5.)',
      },
    },
  ),
  Belt(
    level: 5,
    name: '5. kup - blåt bælte med rød streg',
    categories: {
      'Stand': {
        'Apchook-moa-seogi': 'Tæer samle stand',
        'Anchong-seogi': 'Hvilestand (fødderne indad)',
      },
      'Håndteknik': {
        'Hansonnal eolgul biteureomakki': 'Vride blokering med enkelt knivhånd (Blokeringen trækkes fra modsat øre og føres udvendigt forbi kontra armen. Kontrahånd er knyttet. Over bagerste ben)',
        'Eolgul bakatmakki': 'Udadgående blokering i høj sektion (Hånden i øjenhøjde og i sidelinien. Over forreste ben)',
        'Batangson momtongmakki': 'Håndrods blokering i midter sektion (Den åbne hånd trækkes fra siden af kroppen og drejes ud i blokeringen. Kontrahånden trækkes fra “momtong-jireugi” - position. Over forreste ben)',
      },
      'Benteknik': {
        'Twieo-chagi': 'Flyvende spark m. forreste ben (Twio efterfølges af navnet på det pågældende spark. Ex.: Twio Ap-chagi)',
        'Goolleo-chagi': 'Trampe spark (Alle er “trampe”-spark. Goolleo efterfølges af navnet på det pågældende spark)',
        'Ieo seokeo-chagi': 'To forskellige spark lige efter hinanden med forskellige ben.',
        'Momdollyo-chagi': 'Dreje kroppen spark (Alle er baglæns spark. Mom dollyo efterfølges af navnet på det pågældende spark.)',
        'Hooryo-chagi': 'Sving spark (En gruppe af spark. Alle er baglæns svingspark. Men i modsætning til Mom dollyo chagi, trækkes sparkene helt igennem med sving. Hooryo efterfølges af navnet på det pågældende spark)',
      },
      'Teori': {
        'Balkeut': 'Tåspidser',
        'Dwikoomchi': 'Hæl',
        'Mom': 'Krop',
        'Jodul': 'Otte (8)',
        'Yook': 'Sjette (6.)',
      },
    },
  ),
  Belt(
    level: 4,
    name: '4. kup - rødt bælte',
    categories: {
      'Stand': {
        'Beom-seogi': 'Tigerstand (Længde: Ap-seogi. Forreste fod rører kun med apchook. Begge ben bøjet kraftigt)',
        'Poom seogi: Bojumeok joonbi-seogi': 'Dækket næve retstand (Skulderstandsbredde. Hænderne er foldet i hagehøjde. Arme bøjet 90 grader)',
        'Mo-seogi': 'Spidsstand',
      },
      'Håndteknik': {
        'Batangson geodeureo momtong anmakki': 'Håndrods blokering med støtte (modsat arm / ben) (Støttehånden trækkes fra hoften og er knyttet med håndryggen nedad. Blokeringshånden er åben og trækkes fra den anden side af hoften ud over bagerste ben. På samme tid køres hænderne frem.)',
        'Eotgeoreo araemakki': 'Krydshånds blokering i lav sektion (Nederste hånd er over forreste ben og drejes ud i positionen fra modsatte kropsside)',
        'Gawi makki': 'Sakse blokering (arae-makki over forreste ben og anpalmok bakat-makki over bageste. Den lave blokering køres på indersiden af den udadgående og over forreste ben.)',
        'Doo jumeok jecheo jireugi': 'Dobbelt slag m. knyttet næve med håndfladen opad (Der skal være en helt lige forbindelseslinie mellem de to albuer og maven. Vinkel mellem over og underarm er 90 grader.)',
        'Momtong hechyomakki': 'Udadgående adskille blokering (Underarmene udfører en drejende bevægelse fremad og opad idet de krydses undervejs)',
        'Geodeureo deung-jumeok eolgul apchigi': 'Omvendt knoslag i høj sektion med støtte (Slag over forreste ben)',
        'Eolgul bakatchigi': 'Udadgående slag (Over forreste ben. Trækkes fra modsatte øre. Arm strakt)',
        'Batangson momtong anmakki': 'Håndrods blokering (modsat arm / ben)',
      },
      'Benteknik': {
        'Geodeup chagi': 'To spark m. samme ben (Det første SKAL være i lav sektion.)',
        'Pyojeok-chagi': 'Pletspark (Fod rammer flad hånd i midterlinien)',
        'Nakeo chagi': 'Krogspark (Rammer med hælen)',
        'Mooreupchigi': 'Knæspark/slag (rammer med knæet)',
      },
      'Teori': {
        'Pyeon jumeok': 'Kattenæve',
        'Doo jumeok': 'Dobbelt knytnæve',
        'Bo jumeok': 'Dækket næve',
        'Gomson': 'Bjørnehånd',
        'Geodeureo': 'Støtte',
        'Eotgeoreo': 'Kryds',
        'Gawi': 'Saks',
        'Ahope': 'Ni (9)',
        'Jool': 'Ti (10)',
        'Chill': 'Syvende (7.)',
      },
    },
  ),
  Belt(
    level: 3,
    name: '3. kup - rødt bælte med en sort streg',
    categories: {
      'Stand': {
        'Mo-joochoom-seogi': 'Spids hestestand (Hestestand med den ene fod lidt længere fremme end den anden)',
        'Ap-joochoom-seogi': 'Kort hestestand (Hestestand hvor det ene ben er trukket ind bag det andet så man faktisk står i en ap-seogi med bøjede ben)',
      },
      'Håndteknik': {
        'Geodeureo momtongmakki': 'Blokering i midter sektion med støtte',
        'Geodeureo araemakki': 'Blokering i lav sektion med støtte',
        'Oe-santeul makki': 'En hånds bjerg blokering (Ap-koa-seogi hvor man kigger frem over bagerste ben. Der laves arae-makki over bagerste ben og anpalmok bakat-makki over forreste.)',
        'Dan-gyo teok jireugi': 'Træk med en hånd og udfør slag med den anden hånd mod hage',
      },
      'Benteknik': {
        'Doo-baldangsang chagi': '2 flyvende spark efter hinanden, hvor det første er et “falsk spark”',
      },
      'Teori': {
        'Bamjumeok': 'Kastanjenæve',
        'Balnaldeung': 'Inderside af fod',
        'Teok': 'Hage',
        'Dangyo': 'Trække',
        'Santeul': 'Bjerg',
        'Oe-santeul': 'Halvt bjerg',
        'Pal': 'Ottende (8.)',
      },
    },
  ),
  Belt(
    level: 2,
    name: '2. kup - rødt bælte med to sorte streger',
    categories: {
      'Stand': {
        'An-chung-joochoom-seogi': 'Indaddrejet hestestand (fødderne peger indad)',
      },
      'Håndteknik': {
        'Sonnal araemakki': 'Knivhånds blokering i lav sektion',
        'Hansonnal araemakki': 'Enkelt knivhånds blokering i lav sektion',
        'Palkoop naeryochigi': 'Nedadgående albuestød (Underarm lodret. Rammer i momtong over bagerste ben)',
        'Palkoop olryeochigi': 'Opadgående albuestød (Underarm vandret. Rammer i eolgul over bagerste ben)',
      },
      'Benteknik': {
        'Twieo ieo-chagi': 'Samme spark 2 gange - flyvende',
      },
      'Teori': {
        'Jibge jumeok': 'Pincetnæve',
        'Sonnal deung': 'Modsat knivhånd',
        'Gawison keut': 'Sakse-fingerstik',
        'Hanson keut': 'Enkelt-fingerstik',
        'Moeun-dooson keut': 'Dobbelt fingerstik',
        'Moeun-seson keut': 'Tre-fingerstik',
        'Olryeo': 'Opadgående',
        'Ko': 'Niende (9.)',
        'Ship': 'Tiende (10.)',
      },
    },
  ),
  Belt(
    level: 1,
    name: '1. kup - rødt bælte med tre sorte streger',
    categories: {
      'Stand': {
        'Poom seogi: Tongmilgi joonbi-seogi': 'Skubbe klar stand (Skulderstandsbredde, hænder danner cirkel foran ansigtet med knivhånd. Albueled i 90 grader.)',
        'O-ja-seogi': 'T-stand',
        'Gyottari-seogi': 'Hjælpestand (udgangspunkt: ap-seogi, men fodballen på bagerste fod er lige ud for den anden fods svang. Bagerste hæl er løftet lidt fra gulvet. Ben let bøjet)',
      },
      'Håndteknik': {
        'Pyojeok-jireugi': 'Plet slag',
        'Palkoop yeop chigi': 'Albuestød til siden',
        'Me jumeok arae pyojeokchigi': 'Pletslag i lav sektion (rammer med lillefingersiden)',
        'Mooreup keokki': '“Knække knæ”',
        'Anpalmok hechyomakki': 'Adskille blokering med indersiden af underarm',
        'Pyeonsonkeut jechyo-chireugi': 'Fingerstik med håndfladen opad (Over bagerste ben)',
        'Kaljebi': 'Slag/stik mod hals',
      },
      'Benteknik': {
        'Twieo baggueo chagi': 'Flyvende spark med bageste ben',
      },
      'Teori': {
        'Modeumson keut': 'Femfingerstik',
        'Keokki': 'Knække',
        'Agwison': 'Rundingen mellem tommel- og pegefinger',
        'Kaljebi': 'Benævnelse for slag mod hals med agwison',
        'Je chin pyeonsonkeut': 'Håndfladen opad (fingerstik)',
      },
    },
  ),
];
```

Content of ../app/lib/screens/theory_tab.dart:
```
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb and defaultTargetPlatform
import 'theory_data.dart';

enum QuizMode { hiddenExplanation, training, hiddenTerm }

class TheoryTab extends StatefulWidget {
  const TheoryTab({super.key});

  @override
  TheoryTabState createState() => TheoryTabState();
}

class TheoryTabState extends State<TheoryTab> {
  List<Belt> selectedBelts = [];
  List<MapEntry<String, String>> terms = [];
  Map<int, bool> beltSelection = {};
  bool isQuizStarted = false;
  List<bool> showExplanationList = [];
  PageController pageController = PageController();
  QuizMode? quizMode;

  @override
  void initState() {
    super.initState();
    beltSelection = {for (var belt in allBelts) belt.level: false};
  }

  @override
  Widget build(BuildContext context) {
    if (!isQuizStarted) {
      // Belt selection screen
      return Scaffold(
        // Removed AppBar as per your request
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      'Vælg bælter',
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _selectAllBelts,
                        child: const Text('Vælg Alle'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _deselectAllBelts,
                        child: const Text('Fravælg Alle'),
                      ),
                    ],
                  ),
                  ...allBelts.map((belt) {
                    return CheckboxListTile(
                      title: Text(belt.name),
                      value: beltSelection[belt.level],
                      onChanged: (bool? value) {
                        setState(() {
                          beltSelection[belt.level] = value ?? false;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10.0,
                children: [
                  ElevatedButton(
                    onPressed: _startQuiz,
                    child: const Text('Træn skjult forklaring'),
                  ),
                  ElevatedButton(
                    onPressed: _startTraining,
                    child: const Text('Træn'),
                  ),
                  ElevatedButton(
                    onPressed: _startReverseQuiz,
                    child: const Text('Træn skjult udtryk'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Quiz interface with swipe navigation
      return Scaffold(
        // No AppBar to remove the header
        body: _buildQuiz(),
      );
    }
  }

  Widget _buildQuiz() {
    if (terms.isEmpty) {
      return const Center(
        child: Text('Ingen spørgsmål at vise.'),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: terms.length,
          itemBuilder: (context, index) {
            var term = terms[index];
            bool showAnswer = showExplanationList[index];

            String questionText;
            String answerText;
            String? buttonText;

            if (quizMode == QuizMode.hiddenExplanation) {
              // Question is term.key, answer is term.value
              questionText = term.key;
              answerText = term.value;
              buttonText = 'Vis forklaring';
            } else if (quizMode == QuizMode.hiddenTerm) {
              // Question is term.value, answer is term.key
              questionText = term.value;
              answerText = term.key;
              buttonText = 'Vis udtryk';
            } else {
              // Training mode, show both
              questionText = term.key;
              answerText = term.value;
              showAnswer = true; // Always show answer
              buttonText = null;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Spørgsmål ${index + 1} af ${terms.length}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    questionText,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (!showAnswer && buttonText != null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showExplanationList[index] = true;
                        });
                      },
                      child: Text(buttonText),
                    )
                  else if (showAnswer)
                    Text(
                      answerText,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        ),
        // Navigation buttons for desktop browsers
        if (kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux))
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.arrow_left),
                onPressed: _previousPage,
              ),
            ),
          ),
        if (kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux))
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.arrow_right),
                onPressed: _nextPage,
              ),
            ),
          ),
      ],
    );
  }

  void _previousPage() {
    if (pageController.hasClients) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _nextPage() {
    if (pageController.hasClients) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _selectAllBelts() {
    setState(() {
      for (var belt in allBelts) {
        beltSelection[belt.level] = true;
      }
    });
  }

  void _deselectAllBelts() {
    setState(() {
      for (var belt in allBelts) {
        beltSelection[belt.level] = false;
      }
    });
  }

  void _startQuiz() {
    _prepareQuiz(QuizMode.hiddenExplanation);
  }

  void _startTraining() {
    _prepareQuiz(QuizMode.training);
  }

  void _startReverseQuiz() {
    _prepareQuiz(QuizMode.hiddenTerm);
  }

  void _prepareQuiz(QuizMode mode) {
    selectedBelts = allBelts
        .where((belt) => beltSelection[belt.level] == true)
        .toList();

    if (selectedBelts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vælg mindst ét bælte for at starte quizzen')),
      );
      return;
    }

    terms = [];
    for (var belt in selectedBelts) {
      for (var category in belt.categories.values) {
        terms.addAll(category.entries);
      }
    }

    terms.shuffle();

    // Initialize the list to track which explanations are shown
    showExplanationList = List<bool>.filled(terms.length, false);

    setState(() {
      isQuizStarted = true;
      quizMode = mode;
    });
  }
}
```

Content of ../app/lib/screens/links_tab.dart:
```
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Import the package
import '../providers/data_provider.dart';

class LinksTab extends StatelessWidget {
  const LinksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final role = dataProvider.role;

    // Build list of visible tabs
    List<String> visibleTabs = ['Participants'];
    if (role == 'Coach' || role == 'Admin') {
      visibleTabs.add('Coach');
    }
    if (role == 'Admin') {
      visibleTabs.add('Admin');
    }
    visibleTabs.add('Theory');
    // 'Links' tab is current tab, so we can exclude it.

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Links in a Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLinkButton('Website', Uri.https('struertkd.dk')),
            _buildLinkButton(
                'Facebook', Uri.https('www.facebook.com', '/groups/33971838859')),
            _buildLinkButton(
                'TikTok', Uri.https('www.tiktok.com', '/@struer.taekwondo')),
          ],
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Dokumentation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        // Build documentation sections
        ...visibleTabs.map((tabName) => _buildDocumentationSection(tabName)),
      ],
    );
  }

  Widget _buildLinkButton(String label, Uri uri) {
    return TextButton(
      onPressed: () => _launchURL(uri),
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        textStyle: const TextStyle(decoration: TextDecoration.underline),
      ),
      child: Text(label),
    );
  }

  void _launchURL(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  Widget _buildDocumentationSection(String tabName) {
    String tldr = '';
    String detailedDescription = '';

    switch (tabName) {
      case 'Participants':
        tldr =
        'I denne sektion kan du tilmelde dig kommende træningssessioner. Du kan også tilføje andre brugere for at tilmelde på vegne af dem.';
        detailedDescription =
        'Deltager-fanen giver dig mulighed for at tilmelde dig til kommende træningssessioner i Struer Taekwondo klubben. Når du åbner denne sektion, vil du se en liste over planlagte træninger, hvor du kan angive din deltagelsesstatus.\n\n'
            '**Funktioner:**\n\n'
            '- **Tilmelding til træning**: For hver træningssession kan du angive, om du deltager ved at vælge \'Ja\', \'Måske\' eller \'Nej\' i rullemenuen ud for den pågældende session.\n\n'
            '- **Tilføjelse af andre brugere**: Hvis du ønsker at registrere deltagelse for andre, såsom familiemedlemmer eller venner, kan du tilføje dem ved at klikke på \'Tilføj bruger til registrering\'. Afhængigt af din brugerrolle kan du tilføje brugere ved at indtaste deres login-kode eller ved at vælge dem fra en liste (hvis du er admin).\n\n'
            '- **Administrere brugere**: Du kan se og administrere de brugere, du registrerer på vegne af, inklusive at fjerne dem fra din liste eller ændre deres deltagelsesstatus.\n\n'
            '- **Se detaljer om træning**: Ved at trykke på en træningssession kan du se detaljer som tidspunkt, sted, træner og eventuelle kommentarer.\n\n'
            '**Brugervejledning:**\n\n'
            '1. **Tjek dine valgte brugere**: Øverst kan du se en liste over de brugere, du tilmelder for. Sørg for, at de korrekte brugere er valgt.\n\n'
            '2. **Angiv deltagelse**: For hver træningssession skal du bruge rullemenuen til at angive deltagelsesstatus for de valgte brugere.\n\n'
            '3. **Tilføj ny bruger**: Klik på \'Tilføj bruger til registrering\' for at tilføje en ny bruger. Følg instruktionerne på skærmen.\n\n'
            '4. **Se træningsdetaljer**: Klik på en træningssession for at udvide og se flere detaljer.\n\n'
            '**Bemærkninger:**\n\n'
            '- Din deltagelsesstatus hjælper trænerne med at planlægge træningen effektivt.\n\n'
            '- Husk at opdatere din deltagelsesstatus, hvis dine planer ændrer sig.';
        break;
      case 'Coach':
        tldr =
        'I denne sektion kan du oprette og administrere træningssessioner. Du kan registrere deltagelse for en træningssession, der vil starte inden for 10 minutter eller allerede er startet eller afsluttet.';
        detailedDescription =
        'Coach-fanen er designet til trænere og giver adgang til avancerede funktioner til at administrere træningssessioner og deltagelse.\n\n'
            '**Funktioner:**\n\n'
            '- **Opret træningssessioner**: Som træner kan du planlægge nye træningssessioner ved at angive starttidspunkt, sluttidspunkt, ansvarlig træner og eventuelle kommentarer.\n\n'
            '- **Administrer sessioner**: Du kan opdatere eller slette eksisterende sessioner, så længe de ikke er startet.\n\n'
            '- **Registrer deltagelse**: For træningssessioner, der starter inden for 10 minutter, eller som allerede er i gang eller afsluttet, kan du registrere faktisk deltagelse. Dette giver mulighed for at notere, hvem der faktisk deltog i træningen.\n\n'
            '- **Se deltagelseshistorik**: Du kan få adgang til historiske data om deltagelse, hvilket kan hjælpe med at analysere fremmøde over tid.\n\n'
            '**Brugervejledning:**\n\n'
            '1. **Opret en ny session**: Klik på \'Tilføj træningssession\' og udfyld de nødvendige oplysninger. Vær opmærksom på at sætte korrekte tidspunkter og vælge den rigtige træner.\n\n'
            '2. **Opdater en session**: Find den session, du ønsker at ændre, og klik på \'Opdater\'. Her kan du ændre tidspunkter, træner og kommentarer.\n\n'
            '3. **Registrer deltagelse**: For en session, der snart starter eller er afsluttet, klik på \'Registrer P.\' for at markere deltagere. Vælg de medlemmer, der var til stede.\n\n'
            '4. **Se deltagelseshistorik**: Klik på \'Se deltagelseshistorik\' for at få en oversigt over tidligere sessioner og deltagelse.\n\n'
            '**Bemærkninger:**\n\n'
            '- Det er vigtigt at registrere faktisk deltagelse for at holde styr på medlemmernes fremmøde.\n\n'
            '- Sletning af en session er en permanent handling og bør udføres med forsigtighed.';
        break;
      case 'Admin':
        tldr =
        'I denne sektion kan du oprette, opdatere og slette brugere. Du kan også se deres login-koder.';
        detailedDescription =
        'Admin-fanen er tilgængelig for administratorer og giver fuld kontrol over brugeradministration i systemet.\n\n'
            '**Funktioner:**\n\n'
            '- **Opret nye brugere**: Du kan tilføje nye medlemmer til systemet ved at angive navn og rolle (Admin, Coach eller Student).\n\n'
            '- **Opdater brugeroplysninger**: Du kan redigere eksisterende brugeres navn og rolle.\n\n'
            '- **Slet brugere**: Hvis en bruger ikke længere skal have adgang, kan du slette dem fra systemet.\n\n'
            '- **Se login-koder**: For hver bruger kan du se og kopiere deres login-kode, som de skal bruge for at logge ind i appen.\n\n'
            '**Brugervejledning:**\n\n'
            '1. **Opret en bruger**: Klik på \'Opret bruger\' og indtast de nødvendige oplysninger. Efter oprettelsen får du vist brugerens login-kode.\n\n'
            '2. **Opdater en bruger**: Find den bruger, du ønsker at redigere, og klik på \'Opdater\'. Her kan du ændre navn og rolle.\n\n'
            '3. **Slet en bruger**: Klik på \'Slet bruger\' for at fjerne en bruger permanent.\n\n'
            '4. **Vis login-kode**: For at se en brugers login-kode, klik på \'Vis login\' ved siden af deres navn. Du kan kopiere koden til udlevering.\n\n'
            '**Bemærkninger:**\n\n'
            '- Vær opmærksom på at ændringer i brugerroller kan påvirke adgangen til forskellige dele af appen.\n\n'
            '- Sletning af en bruger kan ikke fortrydes.';
        break;
      case 'Theory':
        tldr =
        'I denne sektion kan du træne dine taekwondo-kommandobegreber. Du kan vælge hvilke bælter du vil inkludere, og derefter starte en quiz eller træning.';
        detailedDescription =
        'Teori-fanen er designet til at hjælpe medlemmer med at lære og repetere taekwondo-teori, herunder kommandoer, teknikker og terminologi.\n\n'
            '**Funktioner:**\n\n'
            '- **Bæltevalg**: Vælg de bælteniveauer, du ønsker at fokusere på. Dette giver dig mulighed for at tilpasse træningen til dit aktuelle niveau.\n\n'
            '- **Træn skjult forklaring**: Denne funktion viser dig taekwondo-udtryk, og du skal huske eller gætte den tilhørende forklaring eller betydning. Dette hjælper med at styrke din hukommelse af teorien.\n\n'
            '- **Træn**: Denne funktion viser både udtryk og forklaring, hvilket er nyttigt til generel repetition og læring.\n\n'
            '- **Træn skjult udtryk**: Her får du vist forklaringen, og du skal huske eller gætte det tilhørende taekwondo-udtryk. Dette er godt til at teste din evne til at koble betydning med terminologi.\n\n'
            '**Brugervejledning:**\n\n'
            '1. **Vælg bælter**: Marker de bælter, du vil inkludere i træningen. Du kan vælge flere niveauer samtidigt.\n\n'
            '2. **Start træning**: Vælg en af de tre træningsmetoder ved at trykke på den tilsvarende knap.\n\n'
            '3. **Naviger gennem spørgsmål**: Brug swipe-bevægelser til at skifte mellem spørgsmål, eller brug navigationsknapperne, hvis tilgængelige.\n\n'
            '4. **Vis svar**: Hvis du bruger en af de skjulte træningsmetoder, kan du trykke på \'Vis forklaring\' eller \'Vis udtryk\' for at se svaret.\n\n'
            '5. **Afslut træning**: Når du er færdig, kan du vende tilbage til bæltevalget ved at trykke på tilbage-knappen.\n\n'
            '**Bemærkninger:**\n\n'
            '- Regelmæssig brug af teori-fanen kan forbedre din forståelse og hukommelse af taekwondo-teori.\n\n'
            '- Tilpas træningen til dine behov ved at vælge relevante bælteniveauer og træningsmetoder.';
        break;
      default:
        tldr = '';
        detailedDescription = '';
    }

    return ExpansionTile(
      title: Text(tabName),
      expandedAlignment: Alignment.topLeft,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TL;DR: $tldr',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              MarkdownBody(
                data: detailedDescription,
                onTapLink: (text, href, title) {
                  // Handle link taps if necessary
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

Content of ../app/lib/providers/data_provider.dart:
```
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider extends ChangeNotifier {
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _authToken = '';
  String get authToken => _authToken;

  String _role = '';
  String get role => _role;

  String _userId = '';
  String get userId => _userId;

  Future<void> loadUserData() async {
    _isLoading = true;
    // Defer notifyListeners to avoid calling it during build
    Future.microtask(() => notifyListeners());

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token') ?? '';

    try {
      final data = await ApiService().anonymousShowInfo();
      _userData = data;

      final userId = await getUserIdFromToken(_authToken);
      if (userId != null) {
        final users = data['users'] as Map<String, dynamic>;
        final user = users[userId];
        _role = user['role'];
        _userId = userId;
        _userData['i_am'] = userId;
      } else {
        _role = 'Anonymous';
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<String?> getUserIdFromToken(String authToken) async {
    try {
      final userData = await ApiService().studentValidateAuthToken(authToken);
      return userData['i_am'];
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshData() async {
    await loadUserData();
  }

  void setAuthToken(String authToken) {
    _authToken = authToken;
    notifyListeners();
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = '';
    _role = 'Anonymous';
    _userId = '';
    _userData = {};
    notifyListeners();
  }
}
```

