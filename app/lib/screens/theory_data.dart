// theory_data.dart

/// Represents a taekwondo belt level and its associated categories and terms.
///
/// Each `Belt` contains a level, name, and a map of categories. The categories
/// map terms to their explanations, which are used in the theory training and quizzes.
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
  Belt(
    level: -1,
    name: '1. dan. - Sort bælte',
    categories: {
      'Stand': {
        'Haktari-seogi': 'Tranestand',
      },
      'Håndteknik': {
        'Batangson teok chigi': 'Slag mod hage m. håndrod',
        'Hansonnal momtong anmakki': 'Enkelt indadgående knivhåndsblokering',
        'Keumgang makki': 'Diamant blokering',
        'Keun-dolcheogi': 'Stort hængsel',
        'Santeul-makki': 'Bjerg blokering',
        'Anpalmok hecheyomakki': 'Midter sektion adskille blokering',
      },
      'Benteknik': {
      },
      'Teori': {
      },
    },
  ),
  Belt(
    level: -2,
    name: '2. dan. - Sort bælte',
    categories: {
      'Stand': {
      },
      'Håndteknik': {
        'Sonnal arae hechyo makki': 'Lav sektion "adskille" blokering m. knivhånd',
        'Keumgang momtong makki': 'Diamant blokering i midtersektion',
        'Jageun dolcheogi': 'Lille hængsel',
        'Miteuro paegi': 'Trækker rundt',
      },
      'Benteknik': {
      },
      'Teori': {
      },
    },
  ),
  Belt(
    level: -3,
    name: '3. dan. - Sort bælte',
    categories: {
      'Stand': {
      },
      'Håndteknik': {
        'Geodeureo eolgol yeop makki': 'Høj hjælpe side blokering',
        'Hechyo santeul makki': '"Adskille" bjerg blokering',
        'Dan gyo teok-chigi': 'En hånd trækker og den anden udfører apchigi (deungjumeok)',
        'Meonge-chigi': 'Albuestød til siderne',
      },
      'Benteknik': {
        'Momdolmyeo yeopchagi': 'Drej krop og udfør yeopchagi',
      },
      'Teori': {
      },
    },
  ),
  Belt(
    level: -4,
    name: '4. dan. - Sort bælte',
    categories: {
      'Stand': {
      },
      'Håndteknik': {
        'Sonnal arae eotgeoreo makki': 'Lav krydshåndsblokering m. knivhånd',
        'Sonnaldeung momtong makki': 'Omvendt knivhåndsblokering i midter sektion',
        'Keureo-olligi': 'Trækker opad',
        'Hwangso makki': 'Okse blokering',
        'Sonbadak geodeureo yeop makki': 'Håndfladen hjælper sideblokering',
        'Bawi milgi': '"Skubber en stor sten"',
        'Chet-tan-jireugi': 'Begge jumeok udfører slag i momtong',
      },
      'Benteknik': {
      },
      'Teori': {
      },
    },
  ),
  Belt(
    level: -5,
    name: '5. dan. - Sort bælte',
    categories: {
      'Stand': {
      },
      'Håndteknik': {
        'Hansonnal eolgul makki': 'Enkelt knivhåndsblokering i høj sektion',
        'Keumgang ap jireugi': 'Diamant fremadgående slag i midtersektion',
        'Me-jumeok yeop pyojeok chigi': 'Pletslag til siden med lillefingersiden af knytnæve',
      },
      'Benteknik': {
      },
      'Teori': {
      },
    },
  ),
  Belt(
    level: -6,
    name: '6. dan. - Sort bælte',
    categories: {
      'Stand': {
      },
      'Håndteknik': {
        'Nalgae pyogi': 'Spredte vinger',
        'Bam-jumeok sosum jireugi': 'Kastanje-næve slag mod hals',
        'Hwidullo makki': '”Skubbe væk”',
        'Hwidullo jabadangkigi': '”Fange og skubbe væk”',
        'Keumgang yeop jireugi': 'Diamant knytnæveslag til siden',
        'Taesan milgi': 'Skubber et stort bjerg',
        'Sonnal oesanteul makki': 'En hånds bjerg blokering med knivhånd',
        'An-palmok momtong biteuro makki': 'Vride blokering med inderside af underarm',
      },
      'Benteknik': {
      },
      'Teori': {
      },
    },
  ),
];
