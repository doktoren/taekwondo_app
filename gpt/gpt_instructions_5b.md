I've made the command line Python script below.
It's useful for training Taekwondo theory by checking if you remember what the different Taekwondo expressions mean in Danish.
Analyze carefully how it works.

I'd like you to convert it into a new tab in the Taekwondo app.
Possibly represented by a book icon.

Since it was originally made in Danish, let's keep that tab in Danish.

Do not do a straight forward mapping to the app.
Instead investigate how the command line instructions could be replaced with a nice user interface.

For the changes needed to the home screen just show me the diff I need to add.

Contents of `taekwondo.py`:

```
"""
Expose on web using e.g. `gotty -w python taekwondo.py`

Data fetched from https://struertkd.dk/pensum.html

scp -P 1729 taekwondo.py jesper@jespertk.dk:/usr/local/etc/rc.d/taekwondo.py

In the Synology Control Panel search for "Reverse Proxy" to see the rule
forwarding https://taekwondo.jespertk.dk to the script running this program via gotty.
"""

import random

BeltQuestionT = tuple[int, str, dict[str, dict[str, str]]]
ALL_BELTS: list[BeltQuestionT] = [
    (
        10,
        "10. kup - hvidt bælte med gul streg",
        {
            "Stand": {
                "Moa-seogi": "Samlet fødder stand (hilsestand)",
                "Dwichook-moa-seogi": "Stand med samlede hæle (Knyttet håndsbredde mellem tæer",
                "Naranhi-seogi": "Parallel stand (skulderstandsbredde mellem fødderne)",
                "Joochoom-seogi": "Hestestand (1½ skulderbredde mellem fødderne)",
                "Apkoobi": "Lang stand (Længde: 1½ skridtlængde eller harmonisk i forhold til kropsbygning. Bredde: skulderbredde)",
                "Apseogi": "Kort stand (Bredde: moa-seogi. Længde: Gåskridt eller harmonisk i forhold til kropsbygning)",
                "Gibon-joonbi-seogi": "Klarstand ved grundteknik. Som naranhi-seogi. Knyttede hænder foran.",
            },
            "Håndteknik": {
                "Arae hechyomakki": "Lav sektion “adskille” blokering. (Armene 45 grader ud fra kroppen).",
                "Arae-makki": "Lav sektion blokering. (Hånden cirka 20 cm. over benet.)",
                "Momtongmakki": "Midter sektion blokering.(90 grader mellem over-/underarm, 45 grader mellem overarm og krop. Hånd foran midterlinien og ud for næsen, albue foran sidelinien.)",
                "Momtong anmakki": " Midter sektion blokering (modsat arm / ben)",
                "Eolgulmakki": "Høj sektion blokering (Hånd er en håndsbredde over panden)",
                "Eolgul jireugi": "jireugi Slag høj sektion. (Hånden i næsehøjde)",
                "Momtong jireugi": "Slag midter sektion (Hånden ud for solar plexus)",
                "Arae jireugi": "Slag lav sektion (Hånd mellem navle og skamben.)",
            },
            "Benteknik": {
                "Naeryo-chagi": "Nedadgående spark (Løft benet lige op, bøjet. Stræk det lige frem og træk nedad strakt. Hoften skydes frem.)",
                "Bakat-chagi": "Udadgående spark (Rammer med knivfod)",
                "An-chagi": "Indadgående spark (Rammer med flad fod)",
                "Ap-chagi": "Front spark (Rammer med apchook)",
            },
            "Teori": {
                "Jumeok": "Knyttet hånd",
                "Jireugi": "Slag fra hoften m. knyttet hånd",
                "Chagi": "Spark",
                "Ap": "Front",
                "An": "Inderside/indadgående",
                "Bakat": "Yderside/udadgående",
                "Arae": "Lav sektion",
                "Momtong": "Midter sektion",
                "Eolgul": "Høj sektion",
                "Charyeo": "Indtag hilsestand",
                "Kyeongne": "Hils (buk)",
                "Joonbi": "Indtag klarstand",
                "Keuman": "Stop og indtag startposition",
                "Dirro dorra": "180 graders vending",
                "Zuu": "Hvil/slap af efterfuldt af buk for træneren",
                "Do bok": "Taekwondo dragt",
                "Do jang": "Taekwondo træningssal",
                "Toga-nim": "Træner under 1. dan",
                "Kyosa-nim": "Træner 1-3 dan",
                "Sabum-nim": "Træner 4. dan og mere",
                "Kukki jedeharjo kyeongne": "Hilsen til flag",
                "Nødværgeretten": (
                    "§13 stk. 1:\n"
                    "Handlinger foretaget i nødværge er straffri forsåvidt de har været nødvendige for at\n"
                    "modstå eller afværge et påbegyndt eller overhængende uretmæssigt angreb, og ikke åbenbart\n"
                    "går ud over, hvad der under hensyn til angrebets farlighed, angriberens person og det\n"
                    "angrebne retsgodes betydning er forsvarlig. "
                    "§13 stk.2 :\n"
                    "Overskrider nogen grænsen for lovlig nødværge, bliver han dog straffri, hvis\n"
                    "overskridelsen er rimeligt begrundet i den ved angrebet fremkaldte skræk eller ophidselse."
                ),
                "Hvad betyder Taekwondo": (
                    "Tae betyder : Fod (springe eller sparke)\n"
                    "Kwon betyder : Næve/hånd (slag eller stød)\n"
                    "Do betyder : System/filosofisk vej\n"
                    "I daglig tale : “Fod-spark-næve-systemet\n"
                ),
            },
        },
    ),
    (
        9,
        "9. kup gult bælte",
        {
            "Stand": {
                "Pyeonhi-seogi": "Hvilestand (Hænderne bag ryggen)",
            },
            "Håndteknik": {
                "Momtong bakatmakki": "Udadgående blokering i midter sektion (Hånd ud for skulderled. Over forreste ben)",
                "Bandae jireugi": "Slag “over forreste ben",
                "Baro jireugi": "Slag (modsat arm / ben) (skulder lidt frem 20 grader)",
                "Sonnal eolgul bakat-chigi": (
                    "Udadgående slag m. knivhånd (Hånd og arm vandret ud for skulderled.\n"
                    "Kommer fra modsatte øre. Slaget er over forreste ben."
                ),
            },
            "Benteknik": {
                "Baldeung dollyo-chagi": (
                    "Cirkelspark, hvor der rammes med vrist (Benet trækkes op i en\n"
                    "vinkel på 45 grader og efter en hoftedrejning ender sparket)"
                ),
            },
            "Teori": {
                "Son": "Hånd",
                "Sonnal": "Knivhånd",
                "Baldeung": "Vrist",
                "Dwichook": "Underside af hæl",
                "Chigi": "Slag, der kommer fra skulderen",
                "Dollyo": "Cirkel",
                "Poom": "Grundteknik",
                "Poomse": "Sammensatte grundteknikker",
                "DTaF": "Dansk Taekwondo Forbund",
                "Hanna": "En (1)",
                "Dul": "To (2)",
                "Set": "Tre (3)",
                "Net": "Fire (4)",
                "Il": "Første (1.)",
            },
        },
    ),
    (
        8,
        "8. kup - orange bælte",
        {
            "Stand": {
                "Dwit-koobi": (
                    "Sidestand (Hælene på hver side af en linie trukket fra indersiden af forreste fod.\n"
                    "Udgangspunktet i denne stand er moa-seogi)"
                ),
            },
            "Håndteknik": {
                "Anpalmok momtong bakatmakki": (
                    "Udadgående blokering m. inderside af underarm (Hånd og albue ud for sidelinien. Over forreste ben)"
                ),
                "Sonnal eolgul anchigi": (
                    "Slag med knivhånd i høj sektion (Hånden ud for midterlinien. Arm let bøjet. Over forreste ben)"
                ),
                "Hansonnal jebipoom mok-chigi": (
                    "Slag mod hals (modsat arm / ben) Hånden ud for midterlinien. Arm let bøjet. Over bagerste ben)"
                ),
                "Sonnal momtongmakki": (
                    "Knivhånds blokering (Trækkes med støttearmen letbøjet fra lidt bagved hoften\n"
                    "og den aktive hånd fra hals. Over forreste ben)"
                ),
                "Hansonnal momtong bakatmakki": (
                    "Enkelt knivhånds blokering (Trækkes med armene puls mod puls fra øjenhøjde. Contrahånd er knyttet)"
                ),
                "Doo bon momtong jireugi": "Dobbelt slag i midtersektion.",
            },
            "Teori": {
                "Pal": "Arm",
                "Palmok": "Underarm (armhals)",
                "An-palmok": "Inderside af underarm",
                "Bakat-palmok": "Yderside af underarm",
                "Balnal": "Knivfod",
                "Apchook": "Fodballe",
                "Jebipoom": "Svaleteknik",
                "Mok": "Hals",
                "Yeop": "Side",
                "Tasut": "Fem (5)",
                "Sam": "Tredje (3.)",
                "WTF": "World Taekwondo Federation",
                "ETU": "European Taekwondo Union",
            },
        },
    ),
    (
        7,
        "7. kup - grønt bælte",
        {
            "Stand": {
                "Na-chooeo-seogi": "Dyb stand (Dobbelt skulderstand)",
            },
            "Håndteknik": {
                "Jebipoom mok-chigi": (
                    "Slag mod hals - Svaleteknik (Vinkel mellem over- og underarm på slaghånden er 20 grader.\n"
                    "Slaghånden udfører vandret slag mod hals over forreste ben.\n"
                    "Svaleteknikken er Eolgulmakki med knivhånd)"
                ),
                "Batangson momtong nulleomakki": (
                    "Nedadgående blokering med håndrod (Over forreste ben. Løft IKKE albuen)"
                ),
                "Ap-chigi (deung-jumeok)": (
                    "Front slag (omvendt knoslag) (Pegefingerknoen skal være fremspringende punkt,\n"
                    "så vinkel mellem håndryg og overside af underarm er 45 grader. Over forreste ben)"
                ),
                "Pyeonson-keut seweo chireugi": (
                    "Fingerstik med lodret håndstilling (Over forreste ben. fingerspidserne gøres lige)"
                ),
                "Hansonnal momtong yeopmakki": "Enkelt knivhånds blokering til siden",
            },
            "Benteknik": {
                "Dwit-chagi": "Bagud spark (Ingen blokering over benet. Rammer med underside af hæl. Kig efter sparket)",
                "Bandal-chagi": (
                    "Halvmånespark (Mellemting mellem abchagi og dollychagi.\n"
                    "Der rammes med apchook. Benet trækkes op 22,5 grader ud fra kroppen)"
                ),
                "Mileo-chagi": (
                    "Skubbe spark (Rammer med flad fod.\n"
                    "Skubber fra knæet mod brystet og vandret skinneben under hele bevægelsen.)"
                ),
            },
            "Teori": {
                "Deung-jumeok": "Oversiden af knyttet hånd",
                "Sewoon-jumeok": "Lodret håndstilling med knyttet hånd",
                "Batangson": "Håndrod",
                "Son-deung": "Håndryggen",
                "Son-keut": "Fingerspidserne",
                "Pyeunson-keut": "Fingerstik",
                "Balbadak": "Fodsål",
                "Chireugi": "Stikslag",
                "Doo bon": "2 eller dobbelt slag",
                "Mileo": "Skubbe",
                "Hvad er og betyder “Kihap” ?": "Kampråb - Ki = energi, hap = samle",
                "Yusot": "Seks (6)",
                "Sah": "Fjerde (4.)",
                "Hvad betyder poomse": "Imaginær kamp",
                "Shijak": "Begynd/start",
                "Kalyeo": "Stop/”Break”",
                "Gyesok": "Fortsæt",
            },
        },
    ),
    (
        6,
        "6. kup blåt bælte",
        {
            "Stand": {
                "Oreun-seogi": "Højre stand (længde: Ap-seogi, fødderne i en 90 garder. Højre fod forrest)",
                "Oen-seogi": "Venstre stand (længde: Ap-seogi, fødderne i 90 grader. Venstre fod forrest)",
                "Ap-koa-seogi": "Forlæns krydsstand",
                "Dwit-koa-seogi": "Støttestand (baglæns krydsstand, al vægten er på forreste ben og ”støttebenet” holder kun balancen.",
            },
            "Håndteknik": {
                "Me-jumeok momtong naeryo-chigi": "Nedadgående slag med ydersiden af knyttet hånd (Overkrop drejes let i forhold til slaget. Let bøjet slagarm. Rammer efter kravebenet. Over forreste ben)",
                "Palkoop dollyo-chigi": "Cirkel albueslag (Arm holdes vandret over forreste ben)",
                "Palkoop pyojeok-chigi": "Albue pletslag (Danner en 4-kant foran kroppen. Arme holdes vandret. Slaget rammer hånden over bagerste ben)",
                "Yeop-jireugi": "Sideslag (I brysthøjde.)",
            },
            "Benteknik": {
                "Biteureo-chagi": "Vridespark (Spark rammer i midterlinien)",
                "Beodeo-chagi": "Bøje-stræk spark (Optræk ligesom apchagi men rammer med underside af hæl. Overkrop lænes tilbage)",
                "Ieo-chagi": "To ens spark lige efter hinanden (forskellige ben)",
                "Seokeo-chagi": "To forskellige spark lige efter hinanden (samme ben)",
                "Jijjigki": "Stamp / tramp / pulverisere",
            },
            "Teori": {
                "Mit-palmok": "Undersiden af underarm",
                "Me-jumeok": "Ydersiden af den knyttede hånd",
                "Palkoop": "Albue",
                "Dari": "Ben",
                "Mooreup": "Knæ",
                "Pyojeok": "Plet/punkt",
                "Ilkup": "Syv (7)",
                "Oh": "Femte (5.)",
            },
        },
    ),
    (
        5,
        "5. kup - blåt bælte med rød streg",
        {
            "Stand": {
                "Apchook-moa-seogi": "Tæer samle stand",
                "Anchong-seogi": "Hvilestand (fødderne indad)",
            },
            "Håndteknik": {
                "Hansonnal eolgul biteureomakki": "Vride blokering med enkelt knivhånd (Blokeringen trækkes fra modsat øre og føres udvendigt forbi kontra armen. Kontrahånd er knyttet. Over bagerste ben)",
                "Eolgul bakatmakki": "Udadgående blokering i høj sektion (Hånden i øjenhøjde og i sidelinien. Over forreste ben)",
                "Batangson momtongmakki": "Håndrods blokering i midter sektion (Den åbne hånd trækkes fra siden af kroppen og drejes ud i blokeringen. Kontrahåndent rækkes fra “momtong-jireugi” - position. Over forreste ben)",
            },
            "Benteknik": {
                "Twieo-chagi": "Flyvende spark m. forreste ben (Twio efterfølges af navnet på det pågældende spark. Ex.: Twio Ap-chagi)",
                "Goolleo-chagi": "Trampe spark (Alle er “trampe”-spark. Goolleo efterfølges af navnet på det pågældende spark)",
                "Ieo seokeo-chagi": "To forskellige spark lige efter hinanden med forskellige ben.",
                "Momdollyo-chagi": "Dreje kroppen spark (Alle er baglæns spark. Mom dollyo efterfølges af navnet på det pågældende spark.)",
                "Hooryo-chagi": "Sving spark (En gruppe af spark. Alle er baglæns svingspark. Men i modsætning til Mom dollyo chagi, trækkes sparkene helt igennem med sving. Hoory efterfølges af navnet på det pågældende spark)",
            },
            "Teori": {
                "Balkeut": "Tåspidser",
                "Dwikoomchi": "Hæl",
                "Mom": "Krop",
                "Jodul": "Otte (8)",
                "Yook": "Sjette (6.)",
            },
        },
    ),
    (
        4,
        "4. kup - rødt bælte",
        {
            "Stand": {
                "Beom-seogi": "Tigerstand (Længde: Ap-seogi. Forreste fod rører kun med apchook. Begge ben bøjet kraftigt)",
                "Poom seogi: Bojumeok joonbi-seogi": "Dækket næve retstand (Skulderstandsbredde. Hænderne er foldet i hagehøjde. Arme bøjet 90 grader)",
                "Mo-seogi": "Spidsstand",
            },
            "Håndteknik": {
                "Batangson geodeureo momtong anmakki": "Håndrods blokering med støtte (modsat arm / ben) (Støttehånden trækkes fra hoften og er knyttet med håndryggen nedad. Blokeringshånden er åben og trækkes fra den anden side af hoften ud over bagerste ben. På sammen tid køres hænderne frem.)",
                "Eotgeoreo araemakki": "Krydshånds blokering i lav sektion (Nederste hånd er over forreste ben og drejes ud i positionen fra modsatte kropsside)",
                "Gawi makki": "Sakse blokering (area-makki over forreste ben og anpalmokbakat-makki over bageste. Den lave blokering køres på indersiden af den udadgående og over forreste ben.)",
                "Doo jumeok jecheo jireugi": "Dobbelt slag m. knyttet næve med håndfladen opad (Der skal være en helt lige forbindelseslinie mellem de to albuer og maven. Vinkel mellem over og underarm er 90 grader.)",
                "Momtong hechyomakki": "Udadgående adskille blokering (Underarmene udfører en drejende bevægelse fremad og opad idet de krydses undervejs)",
                "Geodeureo deung-jumeok eolgul apchigi": "Omvendt knoslag i høj sektion med støtte (Slag over forrste ben)",
                "Eolgul bakatchigi": "Udadgående slag (Over forreste ben. Trækkes fra modsatte øre. Arm strakt)",
                "Batangson momtong anmakki": "Håndrods blokering (modsat arm / ben)",
            },
            "Benteknik": {
                "Geodeup chagi": "To spark m. samme ben (Det første SKAL være i lav sektion.)",
                "Pyojeok-chagi": "Pletspark (Fod rammer flad hånd i midterlinien)",
                "Nakeo chagi ": "Krog spark (Rammer med hælen)",
                "Mooreupchigi": "Knæspark/slag (rammer med knæet)",
            },
            "Teori": {
                "Pyeon jumeok": "Kattenæve",
                "Doo jumeok": "Dobbelt knytnæve",
                "Bo jumeok": "Dækket næve",
                "Gomson": "Bjørnehånd",
                "Geodeureo": "Støtte",
                "Eotgeoreo": "Kryds",
                "Gawi": "Saks",
                "Ahope": "Ni (9)",
                "Jool": "Ti (10)",
                "Chill": "Syvende (7.)",
            },
        },
    ),
    (
        3,
        "3. kup - rødt bælte med en sort streg",
        {
            "Stand": {
                "Mo-joochoom-seogi": "Spids hestestand (Hestestand med den ene fod lidt længere fremme end den anden)",
                "Ap-joochoom-seogi ": "Kort hestestand (Hestestand hvor det ene ben er trukket ind bag det andet så man faktisk står i en ap-seogi med bøjede ben)",
            },
            "Håndteknik": {
                "Geodeureo momtongmakki": "Blokering i midter sektion med støtte",
                "Geodeureo araemakki": "Blokering i lav sektion med støtte",
                "Oe-santeul makki": "En hånds bjerg blokering (Ap-koobi hvor man kigger frem over bagerste ben. Der laves area-makki over bagerste ben og anpalmok-bakat-makki over forrste.",
                "Dan-gyo teok jireugi ": "Træk med en hånd og udfør slag med den anden hånd mod hage",
            },
            "Benteknik": {
                "Doo-baldangsang chagi": "2 flyvende spark efter hinanden, hvor det første er et “falsk spark”",
            },
            "Teori": {
                "Bamjumeok": "Kastanjenæve",
                "Balnaldeung": "Inderside af fod",
                "Teok": "Hage",
                "Dangyo": "Trække",
                "Santeul": "Bjerg",
                "Oe-santeul": "Halvt bjerg",
                "Pal": "Ottende (8.)",
            },
        },
    ),
    (
        2,
        "2. kup - rødt bælte med to sorte streger",
        {
            "Stand": {
                "An-chung-joochoom-seogi": "Indaddrejet hestestand (fødderne peger indad)",
            },
            "Håndteknik": {
                "Sonnal araemakki": "Knivhånds blokering i lav sektion",
                "Hansonnal araemakki": "Enkelt knivhånds blokering i lav sektion",
                "Palkoop naeryochigi": "Nedadgående albuestød (Underarm lodret. Rammer i momtong over bagerste ben)",
                "Palkoop olryeochigi": "Opadgående albuestød (Underarm vandret. Rammer i eolgul over bagerste ben)",
            },
            "Benteknik": {
                "Twieo ieo-chagi": "Samme spark 2 gange - flyvende",
            },
            "Teori": {
                "Jibge jumeok": "Pincetnæve",
                "Sonnal deung": "Modsat knivhånd",
                "Gawison keut": "Sakse-fingerstik",
                "Hanson keut": "Enkelt-fingerstik",
                "Moeun-dooson keut": "Dobbelt fingerstik",
                "Moeun-seson keut ": "Tre-fingerstik",
                "Olryeo": "Opadgående",
                "Ko": "Niende (9.)",
                "Ship": "Tiende (10.)",
            },
        },
    ),
    (
        1,
        "1. kup - rødt bælte med tre sorte streger",
        {
            "Stand": {
                "Poom seogi: Tongmilgi joonbi-seogi": "Skubbe klar stand (Skulderstandsbredde, hænder danner cirkel foran ansigtet med knivhånd. Albueled i 90 grader.",
                "O-ja-seogi": "T-stand",
                "Gyottari-seogi": "Hjælpestand (udgangspunkt: ap-seogi, men fodballen på bagerste fod er lige ud for den anden fods svang. Bagerste hæl er løftet lidt fra gulvet. Ben let bøjet)",
            },
            "Håndteknik": {
                "Pyojeok-jireugi": "Plet slag",
                "Palkoop yeop chigi": "Albuestød til siden",
                "Me jumeok arae pyojeokchigi": "Pletslag i lav sektion (rammer med lillefingersiden)",
                "Mooreup keokki ": "“Knække knæ”",
                "Anpalmok hechyomakki": "Adskille blokering med indersiden af underarm",
                "Pyeonsonkeut jechyo-chireugi": "Fingerstik med håndfladen opad (Over bagerste ben)",
                "Kaljebi": "Slag/stik mod hals",
            },
            "Benteknik": {
                "Twieo baggueo chagi": "Flyvende spark med bageste ben",
            },
            "Teori": {
                "Modeumson keut": "Femfingerstik",
                "Keokki": "Knække",
                "Agwison": "Rundingen mellem tommel- og pegefinger",
                "Kaljebi": "Benævnelse for slag mod hals med agwison",
                "Je chin pyeonsonkeut": "Håndfladen opad (fingerstik)",
            },
        },
    ),
]


def choose_belts(all_data: list[BeltQuestionT]) -> list[BeltQuestionT]:
    while True:
        print("Vælg")
        print("1: Alle gradueringer op til og med")
        print("2: Udvælg individuelle gradueringer (default)")
        match input().strip():
            case "1":
                for v, graduering, _graduering_data in all_data:
                    print(f"{v}: {graduering}")
                v = int(input("Inkluder alle gradueringer >= "))
                return [elem for elem in all_data if elem[0] >= v]
            case "2" | "":
                valgte: set[int] = set()
                while True:
                    for v, graduering, _graduering_data in all_data:
                        print(f"{'x' if v in valgte else ' '} {graduering}")
                    valg = 1
                    while True:
                        try:
                            s = input("Vælg/fravælg graduering med nr (tast 0/enter for færdig) ")
                            valg = int(s or "0")
                        except ValueError:
                            print("Ugyldigt valg")
                            continue
                        if valg == 0:
                            break
                        if valg not in {elem[0] for elem in all_data}:
                            print("Ugyldigt valg")
                            continue
                        if valg in valgte:
                            valgte.remove(valg)
                        else:
                            valgte.add(valg)
                        print()
                        break
                    if not valg:
                        break
                return [elem for elem in all_data if elem[0] in valgte]


def one_session() -> None:
    belt_data = choose_belts(ALL_BELTS)
    print()
    remaining = [
        (koreansk, f"{graduering}, {kategori}: {explanation}")
        for _, graduering, graduering_data in belt_data
        for kategori, liste in graduering_data.items()
        for koreansk, explanation in liste.items()
    ]
    random.shuffle(remaining)
    for i, (koreansk, explanation) in enumerate(remaining):
        print(f"{len(remaining) - i} spørgsmål tilbage")
        print(koreansk)
        input()
        print(explanation)
        print()
        print()


def main() -> None:
    while True:
        one_session()
        print()
        print("Done. Press enter to start over...")
        input()
        print()
        print()


main()
```
