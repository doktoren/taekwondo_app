import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'oss_licenses_page.dart';
import '../providers/data_provider.dart';

/// This tab originally contained only links. Now it also includes other information.
///
/// Displays quick links to the club's website and social media pages.
/// Includes documentation and usage instructions for different tabs
/// based on the user's role. The documentation is expandable and uses
/// Markdown for formatting.
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
        const SizedBox(height: 16.0),
        TextButton(
          onPressed: () {
            // Navigate to license page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OssLicensesPage(),
              ),
            );
          },
          child: const Text('Licenses'),
        ),
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
