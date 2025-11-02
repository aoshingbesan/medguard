import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, french, kinyarwanda }

class SimpleLanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  SimpleLanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageIndex = prefs.getInt(_languageKey) ?? 0;
      if (AppLanguage.values.length > languageIndex && languageIndex >= 0) {
        _currentLanguage = AppLanguage.values[languageIndex];
      } else {
        _currentLanguage = AppLanguage.english;
      }
      notifyListeners();
    } catch (e) {
      _currentLanguage = AppLanguage.english;
      notifyListeners();
    }
  }

  Future<void> changeLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_languageKey, language.index);
      _currentLanguage = language;
      notifyListeners();
      debugPrint('Language changed to: ${language.toString()}');
    } catch (e) {
      debugPrint('Error changing language: $e');
      // Handle error silently
    }
  }

  String getLanguageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.kinyarwanda:
        return 'Kinyarwanda';
    }
  }

  // Text getters for different languages
  String get appTitle {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'MedGuard';
      case AppLanguage.french:
        return 'MedGuard';
      case AppLanguage.kinyarwanda:
        return 'MedGuard';
    }
  }

  String get home {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Home';
      case AppLanguage.french:
        return 'Accueil';
      case AppLanguage.kinyarwanda:
        return 'Urugo';
    }
  }

  String get history {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'History';
      case AppLanguage.french:
        return 'Historique';
      case AppLanguage.kinyarwanda:
        return 'Amateka';
    }
  }

  String get pharmacies {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Pharmacies';
      case AppLanguage.french:
        return 'Pharmacies';
      case AppLanguage.kinyarwanda:
        return 'Amavuriro';
    }
  }

  String get settings {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Settings';
      case AppLanguage.french:
        return 'Paramètres';
      case AppLanguage.kinyarwanda:
        return 'Igenamiterere';
    }
  }

  String get verifyYourMedicine {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Verify your Medicine validity in';
      case AppLanguage.french:
        return 'Vérifiez la validité de votre médicament en';
      case AppLanguage.kinyarwanda:
        return 'Gerageza ubwoba bw\'umuti wawe mu';
    }
  }

  String get seconds {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'seconds';
      case AppLanguage.french:
        return 'secondes';
      case AppLanguage.kinyarwanda:
        return 'amasegonda';
    }
  }

  String get scanAndVerify {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Scan and verify your medication using our barcode scanning feature';
      case AppLanguage.french:
        return 'Scannez et vérifiez vos médicaments en utilisant notre fonction de scan de codes-barres';
      case AppLanguage.kinyarwanda:
        return 'Gerageza kandi ugerageze imiti yawe ukoresheje ikiranga cyacu cyo gusuzuma';
    }
  }

  String get scanTheProduct {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Scan the Product';
      case AppLanguage.french:
        return 'Scanner le Produit';
      case AppLanguage.kinyarwanda:
        return 'Suzuma Ibicuruzwa';
    }
  }

  String get enterGtinManually {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Enter GTIN Manually';
      case AppLanguage.french:
        return 'Entrer GTIN Manuellement';
      case AppLanguage.kinyarwanda:
        return 'Injiza GTIN ukoresheje amaboko';
    }
  }

  String get selectLanguage {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Select Language';
      case AppLanguage.french:
        return 'Sélectionner la Langue';
      case AppLanguage.kinyarwanda:
        return 'Hitamo Ururimi';
    }
  }

  String get languageChanged {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Language changed successfully';
      case AppLanguage.french:
        return 'Langue changée avec succès';
      case AppLanguage.kinyarwanda:
        return 'Ururimi rwahinduwe neza';
    }
  }

  String get english {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.french:
        return 'Anglais';
      case AppLanguage.kinyarwanda:
        return 'Icyongereza';
    }
  }

  String get french {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'French';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.kinyarwanda:
        return 'Igifaransa';
    }
  }

  String get kinyarwanda {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Kinyarwanda';
      case AppLanguage.french:
        return 'Kinyarwanda';
      case AppLanguage.kinyarwanda:
        return 'Ikinyarwanda';
    }
  }

  String get error {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Error';
      case AppLanguage.french:
        return 'Erreur';
      case AppLanguage.kinyarwanda:
        return 'Ikosa';
    }
  }

  String get ok {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'OK';
      case AppLanguage.french:
        return 'OK';
      case AppLanguage.kinyarwanda:
        return 'Sawa';
    }
  }

  String get pointCameraAtBarcode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Point your camera at the barcode';
      case AppLanguage.french:
        return 'Pointez votre caméra vers le code-barres';
      case AppLanguage.kinyarwanda:
        return 'Shyira kamera yawe ku barcode';
    }
  }

  String get scanningInstructions {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Position the barcode within the frame to scan';
      case AppLanguage.french:
        return 'Positionnez le code-barres dans le cadre pour scanner';
      case AppLanguage.kinyarwanda:
        return 'Shyira barcode mu gice cyo gusuzuma';
    }
  }

  String get scanning {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Scanning...';
      case AppLanguage.french:
        return 'Scan en cours...';
      case AppLanguage.kinyarwanda:
        return 'Gusuzuma...';
    }
  }

  String get scanBarcode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Scan Barcode';
      case AppLanguage.french:
        return 'Scanner le Code-barres';
      case AppLanguage.kinyarwanda:
        return 'Suzuma Barcode';
    }
  }

  String get gtinEan13 {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'GTIN/EAN-13 Code';
      case AppLanguage.french:
        return 'Code GTIN/EAN-13';
      case AppLanguage.kinyarwanda:
        return 'Kode GTIN/EAN-13';
    }
  }

  String get enterGtinCode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Enter GTIN code';
      case AppLanguage.french:
        return 'Entrez le code GTIN';
      case AppLanguage.kinyarwanda:
        return 'Injiza kode ya GTIN';
    }
  }

  String get loading {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Loading...';
      case AppLanguage.french:
        return 'Chargement...';
      case AppLanguage.kinyarwanda:
        return 'Gutangira...';
    }
  }

  String get verifyMedicine {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Verify Medicine';
      case AppLanguage.french:
        return 'Vérifier le Médicament';
      case AppLanguage.kinyarwanda:
        return 'Emeza Umuti';
    }
  }

  // Result Screen strings
  String get medicineVerified {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Medicine Verified';
      case AppLanguage.french:
        return 'Médicament Vérifié';
      case AppLanguage.kinyarwanda:
        return 'Umuti Wagenzuwe';
    }
  }

  String get medicineNotVerified {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Medicine Not Verified';
      case AppLanguage.french:
        return 'Médicament Non Vérifié';
      case AppLanguage.kinyarwanda:
        return 'Umuti Utagenzuwe';
    }
  }

  String get back {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Back';
      case AppLanguage.french:
        return 'Retour';
      case AppLanguage.kinyarwanda:
        return 'Garuka';
    }
  }

  String get verifiedDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'This medicine is registered and verified by Rwanda FDA';
      case AppLanguage.french:
        return 'Ce médicament est enregistré et vérifié par la FDA du Rwanda';
      case AppLanguage.kinyarwanda:
        return 'Uyu muti wiyandikishije kandi wagenzuwe na FDA y\'u Rwanda';
    }
  }

  String get notVerifiedDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'This medicine could not be verified in our database';
      case AppLanguage.french:
        return 'Ce médicament n\'a pas pu être vérifié dans notre base de données';
      case AppLanguage.kinyarwanda:
        return 'Uyu muti ntishoboye kugenzurwa mu makuru yacu';
    }
  }

  String get importantNotice {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Important Notice';
      case AppLanguage.french:
        return 'Avis Important';
      case AppLanguage.kinyarwanda:
        return 'Icyitonderwa';
    }
  }

  String get safetyRecommendations {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Safety Recommendations';
      case AppLanguage.french:
        return 'Recommandations de Sécurité';
      case AppLanguage.kinyarwanda:
        return 'Ibyo Kwitabira';
    }
  }

  String get productInformation {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Product Information';
      case AppLanguage.french:
        return 'Informations sur le Produit';
      case AppLanguage.kinyarwanda:
        return 'Amakuru y\'Umuti';
    }
  }

  String get basicInformation {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Basic Information';
      case AppLanguage.french:
        return 'Informations de Base';
      case AppLanguage.kinyarwanda:
        return 'Amakuru y\'ibanze';
    }
  }

  String get dosagePackaging {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Dosage & Packaging';
      case AppLanguage.french:
        return 'Dosage et Emballage';
      case AppLanguage.kinyarwanda:
        return 'Ubwiyongere na Gupakira';
    }
  }

  String get registrationDetails {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Registration Details';
      case AppLanguage.french:
        return 'Détails d\'Enregistrement';
      case AppLanguage.kinyarwanda:
        return 'Ibyerekeye Kwiyandikisha';
    }
  }

  String get validityStorage {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Validity & Storage';
      case AppLanguage.french:
        return 'Validité et Stockage';
      case AppLanguage.kinyarwanda:
        return 'Ubuziranenge na Kubika';
    }
  }

  String get manufacturerDetails {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Manufacturer Details';
      case AppLanguage.french:
        return 'Détails du Fabricant';
      case AppLanguage.kinyarwanda:
        return 'Ibyerekeye Umukoresha';
    }
  }

  String get scanAnotherMedicine {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Scan another Medicine';
      case AppLanguage.french:
        return 'Scanner un autre Médicament';
      case AppLanguage.kinyarwanda:
        return 'Suzuma undi Muti';
    }
  }


  String get goBackHome {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Go Back Home';
      case AppLanguage.french:
        return 'Retour à l\'Accueil';
      case AppLanguage.kinyarwanda:
        return 'Garuka ku Ntangiriro';
    }
  }

  // History Screen strings
  String get noScansYet {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'No scans yet';
      case AppLanguage.french:
        return 'Aucun scan pour le moment';
      case AppLanguage.kinyarwanda:
        return 'Nta gusuzuma gushya';
    }
  }

  String get scanHistoryDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Your scan history will appear here once you start verifying medicines.';
      case AppLanguage.french:
        return 'Votre historique de scan apparaîtra ici une fois que vous commencerez à vérifier les médicaments.';
      case AppLanguage.kinyarwanda:
        return 'Amateka yawe yo gusuzuma azagaragara hano uko utangira kugenzura imiti.';
    }
  }

  String get clearHistory {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Clear history?';
      case AppLanguage.french:
        return 'Effacer l\'historique ?';
      case AppLanguage.kinyarwanda:
        return 'Siba amateka?';
    }
  }

  String get clearHistoryDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'This will remove all saved scan records.';
      case AppLanguage.french:
        return 'Cela supprimera tous les enregistrements de scan sauvegardés.';
      case AppLanguage.kinyarwanda:
        return 'Ibi bizasiba amakuru yose y\'amasegonda yasuzumye.';
    }
  }

  String get cancel {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Cancel';
      case AppLanguage.french:
        return 'Annuler';
      case AppLanguage.kinyarwanda:
        return 'Kuraho';
    }
  }

  String get clear {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Clear';
      case AppLanguage.french:
        return 'Effacer';
      case AppLanguage.kinyarwanda:
        return 'Siba';
    }
  }

  String get verified {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Verified';
      case AppLanguage.french:
        return 'Vérifié';
      case AppLanguage.kinyarwanda:
        return 'Wagenzuwe';
    }
  }

  String get notVerified {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Not Verified';
      case AppLanguage.french:
        return 'Non Vérifié';
      case AppLanguage.kinyarwanda:
        return 'Utagenzuwe';
    }
  }

  // Pharmacies Screen strings
  String get verifiedPharmacies {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Verified Pharmacies';
      case AppLanguage.french:
        return 'Pharmacies Vérifiées';
      case AppLanguage.kinyarwanda:
        return 'Farumasi Zagenzuwe';
    }
  }

  String get searchPharmacies {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Search pharmacies…';
      case AppLanguage.french:
        return 'Rechercher des pharmacies…';
      case AppLanguage.kinyarwanda:
        return 'Shakisha farumasi…';
    }
  }

  String get openNow {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Open now';
      case AppLanguage.french:
        return 'Ouvert maintenant';
      case AppLanguage.kinyarwanda:
        return 'Ufunguye ubu';
    }
  }

  String get closesSoon {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Closes soon';
      case AppLanguage.french:
        return 'Ferme bientôt';
      case AppLanguage.kinyarwanda:
        return 'Uzafunga vuba';
    }
  }

  String get call {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Call';
      case AppLanguage.french:
        return 'Appeler';
      case AppLanguage.kinyarwanda:
        return 'Hamagara';
    }
  }

  String get directions {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Directions';
      case AppLanguage.french:
        return 'Itinéraire';
      case AppLanguage.kinyarwanda:
        return 'Inzira';
    }
  }

  // Additional strings for result screen
  String get possibleReasons {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Possible Reasons';
      case AppLanguage.french:
        return 'Raisons Possibles';
      case AppLanguage.kinyarwanda:
        return 'Impamvu Zishobora';
    }
  }

  String get counterfeitMedicine {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Counterfeit or fake medicine';
      case AppLanguage.french:
        return 'Médicament contrefait ou faux';
      case AppLanguage.kinyarwanda:
        return 'Umuti w\'ibinyoma cyangwa w\'ubugome';
    }
  }

  String get unregisteredProduct {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Unregistered product';
      case AppLanguage.french:
        return 'Produit non enregistré';
      case AppLanguage.kinyarwanda:
        return 'Ibicuruzwa bitiyandikishije';
    }
  }

  String get damagedBarcode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Damaged or incorrect barcode';
      case AppLanguage.french:
        return 'Code-barres endommagé ou incorrect';
      case AppLanguage.kinyarwanda:
        return 'Barcode yononekaye cyangwa itari iyo';
    }
  }

  String get expiredRegistration {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Expired registration';
      case AppLanguage.french:
        return 'Enregistrement expiré';
      case AppLanguage.kinyarwanda:
        return 'Kwiyandikisha kwashize';
    }
  }

  String get doNotConsume {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Do not consume this medicine';
      case AppLanguage.french:
        return 'Ne consommez pas ce médicament';
      case AppLanguage.kinyarwanda:
        return 'Ntukanywa uyu muti';
    }
  }

  String get keepPackage {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Keep the medicine package for evidence';
      case AppLanguage.french:
        return 'Gardez l\'emballage du médicament comme preuve';
      case AppLanguage.kinyarwanda:
        return 'Bika umupaki w\'umuti nk\'ikimenyetso';
    }
  }

  String get reportToFDA {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Report immediately to Rwanda FDA';
      case AppLanguage.french:
        return 'Signaler immédiatement à la FDA du Rwanda';
      case AppLanguage.kinyarwanda:
        return 'Bwira vuba FDA y\'u Rwanda';
    }
  }

  String get returnToPharmacy {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Return to the pharmacy where purchased';
      case AppLanguage.french:
        return 'Retourner à la pharmacie où acheté';
      case AppLanguage.kinyarwanda:
        return 'Garuka ku farumasi wawuguriye';
    }
  }

  // Field labels for result screen
  String get gtin {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'GTIN';
      case AppLanguage.french:
        return 'GTIN';
      case AppLanguage.kinyarwanda:
        return 'GTIN';
    }
  }

  String get productName {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Product Name';
      case AppLanguage.french:
        return 'Nom du Produit';
      case AppLanguage.kinyarwanda:
        return 'Izina ry\'Umuti';
    }
  }

  String get genericName {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Generic Name';
      case AppLanguage.french:
        return 'Nom Générique';
      case AppLanguage.kinyarwanda:
        return 'Izina ry\'Ubwoko';
    }
  }

  String get dosageForm {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Dosage Form';
      case AppLanguage.french:
        return 'Forme de Dosage';
      case AppLanguage.kinyarwanda:
        return 'Uburyo bwo Kwiyongera';
    }
  }

  String get strength {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Strength';
      case AppLanguage.french:
        return 'Force';
      case AppLanguage.kinyarwanda:
        return 'Ubukana';
    }
  }

  String get packSize {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Pack Size';
      case AppLanguage.french:
        return 'Taille d\'Emballage';
      case AppLanguage.kinyarwanda:
        return 'Ubunini bwo Gupakira';
    }
  }

  String get packagingType {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Packaging Type';
      case AppLanguage.french:
        return 'Type d\'Emballage';
      case AppLanguage.kinyarwanda:
        return 'Ubwoko bwo Gupakira';
    }
  }

  String get registrationNumber {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Registration Number';
      case AppLanguage.french:
        return 'Numéro d\'Enregistrement';
      case AppLanguage.kinyarwanda:
        return 'Inomero yo Kwiyandikisha';
    }
  }

  String get registrationDate {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Registration Date';
      case AppLanguage.french:
        return 'Date d\'Enregistrement';
      case AppLanguage.kinyarwanda:
        return 'Itariki yo Kwiyandikisha';
    }
  }

  String get licenseExpiryDate {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'License Expiry Date';
      case AppLanguage.french:
        return 'Date d\'Expiration de Licence';
      case AppLanguage.kinyarwanda:
        return 'Itariki yo Gupfa kwa Lisenzi';
    }
  }

  String get shelfLife {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Shelf Life';
      case AppLanguage.french:
        return 'Durée de Conservation';
      case AppLanguage.kinyarwanda:
        return 'Igihe cyo Kubika';
    }
  }

  String get manufacturer {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Manufacturer';
      case AppLanguage.french:
        return 'Fabricant';
      case AppLanguage.kinyarwanda:
        return 'Umukoresha';
    }
  }

  String get localRepresentative {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Local Representative';
      case AppLanguage.french:
        return 'Représentant Local';
      case AppLanguage.kinyarwanda:
        return 'Umwiyereka wo Hafi';
    }
  }

  String get marketingAuthHolder {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Marketing Authorization Holder';
      case AppLanguage.french:
        return 'Titulaire de l\'Autorisation de Commercialisation';
      case AppLanguage.kinyarwanda:
        return 'Ufite Uruhushya rwo Gukora Imicuruzwa';
    }
  }

  // Settings Screen strings
  String get offlineMode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Offline Mode';
      case AppLanguage.french:
        return 'Mode Hors Ligne';
      case AppLanguage.kinyarwanda:
        return 'Uburyo Budakoresha Internet';
    }
  }

  String get offlineModeDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Enable offline verification using cached data';
      case AppLanguage.french:
        return 'Activer la vérification hors ligne en utilisant les données mises en cache';
      case AppLanguage.kinyarwanda:
        return 'Gushoboza gusuzuma utakoresha Internet ukoresheje amakuru yabikijwe';
    }
  }

  String get syncData {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Sync Data';
      case AppLanguage.french:
        return 'Synchroniser les Données';
      case AppLanguage.kinyarwanda:
        return 'Guhuza Amakuru';
    }
  }

  String get syncDataDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Download latest medicine data for offline use';
      case AppLanguage.french:
        return 'Télécharger les dernières données de médicaments pour utilisation hors ligne';
      case AppLanguage.kinyarwanda:
        return 'Kuramo amakuru mashya y\'imiti yo gukoresha utakoresha Internet';
    }
  }

  String get clearOfflineData {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Clear Offline Data';
      case AppLanguage.french:
        return 'Effacer les Données Hors Ligne';
      case AppLanguage.kinyarwanda:
        return 'Siba Amakuru Yabikijwe';
    }
  }

  String get clearOfflineDataDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Remove all cached medicine data';
      case AppLanguage.french:
        return 'Supprimer toutes les données de médicaments mises en cache';
      case AppLanguage.kinyarwanda:
        return 'Kuraho amakuru yose y\'imiti yabikijwe';
    }
  }

  String get delete {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Delete';
      case AppLanguage.french:
        return 'Supprimer';
      case AppLanguage.kinyarwanda:
        return 'Kuraho';
    }
  }

  String get syncFailed {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Sync failed';
      case AppLanguage.french:
        return 'Échec de la synchronisation';
      case AppLanguage.kinyarwanda:
        return 'Guhuza amakuru byanze';
    }
  }

  String get syncError {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Sync Error';
      case AppLanguage.french:
        return 'Erreur de Synchronisation';
      case AppLanguage.kinyarwanda:
        return 'Ikosa ry\'Guhuza Amakuru';
    }
  }

  String get offlineDataCleared {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Offline data cleared successfully';
      case AppLanguage.french:
        return 'Données hors ligne effacées avec succès';
      case AppLanguage.kinyarwanda:
        return 'Amakuru yabikijwe yasibwe neza';
    }
  }

  String get totalRecords {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Total Records';
      case AppLanguage.french:
        return 'Enregistrements Totaux';
      case AppLanguage.kinyarwanda:
        return 'Amakuru Yose';
    }
  }

  String get lastSync {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Last Sync';
      case AppLanguage.french:
        return 'Dernière Synchronisation';
      case AppLanguage.kinyarwanda:
        return 'Guhuza Amakuru Kwanyuma';
    }
  }

  String get never {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Never';
      case AppLanguage.french:
        return 'Jamais';
      case AppLanguage.kinyarwanda:
        return 'Nta narimwe';
    }
  }

  // RFDA Report Screen Strings
  String get reportToRFDA {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Report to RFDA';
      case AppLanguage.french:
        return 'Signaler à la RFDA';
      case AppLanguage.kinyarwanda:
        return 'Rapora ku RFDA';
    }
  }

  String get reportUnverifiedDrug {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Report Unverified Drug';
      case AppLanguage.french:
        return 'Signaler un Médicament Non Vérifié';
      case AppLanguage.kinyarwanda:
        return 'Rapora Umuti Utavuzwe';
    }
  }

  String get drugInformation {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Drug Information';
      case AppLanguage.french:
        return 'Informations sur le Médicament';
      case AppLanguage.kinyarwanda:
        return 'Amakuru y\'Umuti';
    }
  }

  String get takePhoto {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Take Photo';
      case AppLanguage.french:
        return 'Prendre une Photo';
      case AppLanguage.kinyarwanda:
        return 'Gufata Ifoto';
    }
  }

  String get getLocation {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Get Location';
      case AppLanguage.french:
        return 'Obtenir la Localisation';
      case AppLanguage.kinyarwanda:
        return 'Gufata Aho Uri';
    }
  }

  String get locationPermission {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Location Permission';
      case AppLanguage.french:
        return 'Permission de Localisation';
      case AppLanguage.kinyarwanda:
        return 'Uruhushya rwo Gufata Aho Uri';
    }
  }

  String get locationPermissionMessage {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Please allow location access to report the drug location';
      case AppLanguage.french:
        return 'Veuillez autoriser l\'accès à la localisation pour signaler l\'emplacement du médicament';
      case AppLanguage.kinyarwanda:
        return 'Nyamuneka emera kugira uruhushya rwo gufata aho uri kugira ngo uraporere aho umuti uri';
    }
  }

  String get cameraPermission {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Camera Permission';
      case AppLanguage.french:
        return 'Permission de Caméra';
      case AppLanguage.kinyarwanda:
        return 'Uruhushya rwo Gufata Amashusho';
    }
  }

  String get cameraPermissionMessage {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Please allow camera access to take a photo of the drug';
      case AppLanguage.french:
        return 'Veuillez autoriser l\'accès à la caméra pour prendre une photo du médicament';
      case AppLanguage.kinyarwanda:
        return 'Nyamuneka emera kugira uruhushya rwo gufata amashusho kugira ngo ufate ifoto y\'umuti';
    }
  }

  String get sendReport {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Send Report';
      case AppLanguage.french:
        return 'Envoyer le Rapport';
      case AppLanguage.kinyarwanda:
        return 'Ohereza Raporo';
    }
  }

  String get reportSent {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Report Sent Successfully';
      case AppLanguage.french:
        return 'Rapport Envoyé avec Succès';
      case AppLanguage.kinyarwanda:
        return 'Raporo Yoherejwe neza';
    }
  }

  String get reportFailed {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Failed to Send Report';
      case AppLanguage.french:
        return 'Échec de l\'Envoi du Rapport';
      case AppLanguage.kinyarwanda:
        return 'Gutanga Raporo Byanze';
    }
  }

  String get locationNotAvailable {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Location not available';
      case AppLanguage.french:
        return 'Localisation non disponible';
      case AppLanguage.kinyarwanda:
        return 'Aho uri ntibishoboka';
    }
  }

  String get photoNotTaken {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Photo not taken';
      case AppLanguage.french:
        return 'Photo non prise';
      case AppLanguage.kinyarwanda:
        return 'Ifoto ntiyafashwe';
    }
  }

  // Additional missing strings
  String get retry {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Retry';
      case AppLanguage.french:
        return 'Réessayer';
      case AppLanguage.kinyarwanda:
        return 'Kongera';
    }
  }

  String get unknownProduct {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Unknown Product';
      case AppLanguage.french:
        return 'Produit Inconnu';
      case AppLanguage.kinyarwanda:
        return 'Ibicuruzwa Bitazwi';
    }
  }

  String get failedToSync {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Failed to sync offline data';
      case AppLanguage.french:
        return 'Échec de la synchronisation des données hors ligne';
      case AppLanguage.kinyarwanda:
        return 'Guhuza amakuru yabikijwe byanze';
    }
  }

  String get dataSyncedSuccessfully {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Data synced successfully';
      case AppLanguage.french:
        return 'Données synchronisées avec succès';
      case AppLanguage.kinyarwanda:
        return 'Amakuru yahuze neza';
    }
  }

  String get errorClearingData {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Error clearing data:';
      case AppLanguage.french:
        return 'Erreur lors de l\'effacement des données :';
      case AppLanguage.kinyarwanda:
        return 'Ikosa ryo gusiba amakuru:';
    }
  }

  String get areYouSureClearOfflineData {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Are you sure you want to clear all offline data?';
      case AppLanguage.french:
        return 'Êtes-vous sûr de vouloir effacer toutes les données hors ligne ?';
      case AppLanguage.kinyarwanda:
        return 'Urakwemera gusiba amakuru yose yabikijwe?';
    }
  }

  String get offlineDataClearedSuccessfully {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Offline data cleared successfully';
      case AppLanguage.french:
        return 'Données hors ligne effacées avec succès';
      case AppLanguage.kinyarwanda:
        return 'Amakuru yabikijwe yasibwe neza';
    }
  }

  String get testingConnection {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Testing Connection...';
      case AppLanguage.french:
        return 'Test de connexion...';
      case AppLanguage.kinyarwanda:
        return 'Kugenzura ubukonekano...';
    }
  }

  String get connectedToSupabase {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Connected to Supabase';
      case AppLanguage.french:
        return 'Connecté à Supabase';
      case AppLanguage.kinyarwanda:
        return 'Wihujwe na Supabase';
    }
  }

  String get notConnected {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Not Connected';
      case AppLanguage.french:
        return 'Non Connecté';
      case AppLanguage.kinyarwanda:
        return 'Ntihanyuze';
    }
  }

  String get productsTable {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Products Table';
      case AppLanguage.french:
        return 'Table des Produits';
      case AppLanguage.kinyarwanda:
        return 'Imbonerahamwe y\'Ibicuruzwa';
    }
  }

  String get pharmaciesTable {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Pharmacies Table';
      case AppLanguage.french:
        return 'Table des Pharmacies';
      case AppLanguage.kinyarwanda:
        return 'Imbonerahamwe y\'Amavuriro';
    }
  }

  String get testConnection {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Test Connection';
      case AppLanguage.french:
        return 'Tester la Connexion';
      case AppLanguage.kinyarwanda:
        return 'Genzura Ubukonekano';
    }
  }

  String get version {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Version';
      case AppLanguage.french:
        return 'Version';
      case AppLanguage.kinyarwanda:
        return 'Inyandikorugero';
    }
  }

  String get help {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Help';
      case AppLanguage.french:
        return 'Aide';
      case AppLanguage.kinyarwanda:
        return 'Ubufasha';
    }
  }

  String get helpDescription {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'MedGuard helps you verify the authenticity of medicines using GTIN codes. You can scan barcodes or enter GTIN codes manually. The app works both online and offline.';
      case AppLanguage.french:
        return 'MedGuard vous aide à vérifier l\'authenticité des médicaments en utilisant les codes GTIN. Vous pouvez scanner les codes-barres ou saisir les codes GTIN manuellement. L\'application fonctionne en ligne et hors ligne.';
      case AppLanguage.kinyarwanda:
        return 'MedGuard ifasha kugenzura ukuri kw\'imiti ukoresheje kode za GTIN. Urashobora gusuzuma barcode cyangwa winjiza kode za GTIN ukoresheje amaboko. Porogaramu ikora kandi ikoresha Internet cyangwa itakoresha.';
    }
  }

  String get noPharmaciesFound {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'No pharmacies found';
      case AppLanguage.french:
        return 'Aucune pharmacie trouvée';
      case AppLanguage.kinyarwanda:
        return 'Nta farumasi zibanze';
    }
  }

  String get noPharmaciesMatch {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'No pharmacies match';
      case AppLanguage.french:
        return 'Aucune pharmacie ne correspond';
      case AppLanguage.kinyarwanda:
        return 'Nta farumasi zihuye na';
    }
  }

  String get addressNotAvailable {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Address not available';
      case AppLanguage.french:
        return 'Adresse non disponible';
      case AppLanguage.kinyarwanda:
        return 'Aderesi ntiboneka';
    }
  }

  String get cannotMakePhoneCall {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Cannot make phone call';
      case AppLanguage.french:
        return 'Impossible de passer un appel';
      case AppLanguage.kinyarwanda:
        return 'Ntushobora guhamagara';
    }
  }

  String get cannotOpenMaps {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Cannot open maps. Please install Google Maps or use a web browser.';
      case AppLanguage.french:
        return 'Impossible d\'ouvrir les cartes. Veuillez installer Google Maps ou utiliser un navigateur Web.';
      case AppLanguage.kinyarwanda:
        return 'Ntushobora gufungura ikarita. Nyamuneka shyiramo Google Maps cyangwa ukoreshe umusohozamubonezamubano.';
    }
  }

  String get openInBrowser {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Open in Browser';
      case AppLanguage.french:
        return 'Ouvrir dans le Navigateur';
      case AppLanguage.kinyarwanda:
        return 'Fungura mu Musohozamubonezamubano';
    }
  }

  String get lastSyncNever {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Last sync: Never';
      case AppLanguage.french:
        return 'Dernière synchronisation : Jamais';
      case AppLanguage.kinyarwanda:
        return 'Guhuza kwanyuma: Nta narimwe';
    }
  }

  String get totalMedicines {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Total Medicines';
      case AppLanguage.french:
        return 'Total des Médicaments';
      case AppLanguage.kinyarwanda:
        return 'Imiti Yose';
    }
  }

  String get verifiedMedicines {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Verified Medicines';
      case AppLanguage.french:
        return 'Médicaments Vérifiés';
      case AppLanguage.kinyarwanda:
        return 'Imiti Yagenzuwe';
    }
  }

  String get databaseConnection {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Database Connection';
      case AppLanguage.french:
        return 'Connexion à la Base de Données';
      case AppLanguage.kinyarwanda:
        return 'Ubukonekano bw\'Urubuga';
    }
  }

  String get language {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Language';
      case AppLanguage.french:
        return 'Langue';
      case AppLanguage.kinyarwanda:
        return 'Ururimi';
    }
  }

  String get offlineVerification {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Offline Verification';
      case AppLanguage.french:
        return 'Vérification Hors Ligne';
      case AppLanguage.kinyarwanda:
        return 'Gusuzuma Utakoresha Internet';
    }
  }

  String get enableOfflineVerification {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Enable offline verification for medicines';
      case AppLanguage.french:
        return 'Activer la vérification hors ligne pour les médicaments';
      case AppLanguage.kinyarwanda:
        return 'Gushoboza gusuzuma imiti utakoresha Internet';
    }
  }

  String get about {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'About';
      case AppLanguage.french:
        return 'À Propos';
      case AppLanguage.kinyarwanda:
        return 'Ibyerekeye';
    }
  }

  // Time formatting helpers
  String formatMinutesAgo(int minutes) {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return '$minutes m ago';
      case AppLanguage.french:
        return 'Il y a $minutes min';
      case AppLanguage.kinyarwanda:
        return 'Hageze $minutes min';
    }
  }

  String formatHoursAgo(int hours) {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return '$hours h ago';
      case AppLanguage.french:
        return 'Il y a $hours h';
      case AppLanguage.kinyarwanda:
        return 'Hageze $hours h';
    }
  }

  String formatDaysAgo(int days) {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return '$days d ago';
      case AppLanguage.french:
        return 'Il y a $days j';
      case AppLanguage.kinyarwanda:
        return 'Hageze $days d';
    }
  }

  String get invalidGtin {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Invalid GTIN:';
      case AppLanguage.french:
        return 'GTIN invalide :';
      case AppLanguage.kinyarwanda:
        return 'GTIN ntagomba:';
    }
  }

  String get pleaseEnterGtinCode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Please enter a GTIN code';
      case AppLanguage.french:
        return 'Veuillez entrer un code GTIN';
      case AppLanguage.kinyarwanda:
        return 'Nyamuneka winjize kode ya GTIN';
    }
  }

  String get onlyDigitsAllowed {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Only digits are allowed';
      case AppLanguage.french:
        return 'Seuls les chiffres sont autorisés';
      case AppLanguage.kinyarwanda:
        return 'Imibare gusa yemewe';
    }
  }

  String get gtinMustBeExactly13Or14Digits {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'GTIN must be exactly 13 or 14 digits';
      case AppLanguage.french:
        return 'GTIN doit contenir exactement 13 ou 14 chiffres';
      case AppLanguage.kinyarwanda:
        return 'GTIN igomba kugira imibare 13 cyangwa 14 gusa';
    }
  }

  String get enterGtin13Or14Digits {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Enter GTIN (13 or 14 digits)';
      case AppLanguage.french:
        return 'Entrez GTIN (13 ou 14 chiffres)';
      case AppLanguage.kinyarwanda:
        return 'Injiza GTIN (imibare 13 cyangwa 14)';
    }
  }

  String get validating {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Validating...';
      case AppLanguage.french:
        return 'Validation...';
      case AppLanguage.kinyarwanda:
        return 'Kugenzura...';
    }
  }

  String get validGtin {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Valid GTIN';
      case AppLanguage.french:
        return 'GTIN valide';
      case AppLanguage.kinyarwanda:
        return 'GTIN ntagomba';
    }
  }

  String get verifyGtin {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Verify GTIN';
      case AppLanguage.french:
        return 'Vérifier GTIN';
      case AppLanguage.kinyarwanda:
        return 'Genzura GTIN';
    }
  }

  String get enter13Or14DigitCode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Enter a 13-digit (EAN-13) or 14-digit (GTIN-14) code';
      case AppLanguage.french:
        return 'Entrez un code à 13 chiffres (EAN-13) ou 14 chiffres (GTIN-14)';
      case AppLanguage.kinyarwanda:
        return 'Injiza kode ifite imibare 13 (EAN-13) cyangwa 14 (GTIN-14)';
    }
  }

  String get manualGtinEntry {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Manual GTIN Entry';
      case AppLanguage.french:
        return 'Saisie Manuelle GTIN';
      case AppLanguage.kinyarwanda:
        return 'Gwinjiza GTIN ukoresheje amaboko';
    }
  }

  String get enterOrPasteGtinCode {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Enter or paste a GTIN code';
      case AppLanguage.french:
        return 'Entrez ou collez un code GTIN';
      case AppLanguage.kinyarwanda:
        return 'Injiza cyangwa winjize kode ya GTIN';
    }
  }

  String get gtinMustBe13Or14Digits {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'GTIN must be 13 or 14 digits';
      case AppLanguage.french:
        return 'GTIN doit contenir 13 ou 14 chiffres';
      case AppLanguage.kinyarwanda:
        return 'GTIN igomba kugira imibare 13 cyangwa 14';
    }
  }

  String get gtinCannotExceed14Digits {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'GTIN cannot exceed 14 digits';
      case AppLanguage.french:
        return 'GTIN ne peut pas dépasser 14 chiffres';
      case AppLanguage.kinyarwanda:
        return 'GTIN ntiyashobora kurenga imibare 14';
    }
  }

  String get scanError {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Scan Error';
      case AppLanguage.french:
        return 'Erreur de Scan';
      case AppLanguage.kinyarwanda:
        return 'Ikosa ry\'Gusuzuma';
    }
  }

  String get grantCameraAccess {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Grant Camera Access';
      case AppLanguage.french:
        return 'Accorder l\'Accès à la Caméra';
      case AppLanguage.kinyarwanda:
        return 'Emeza Uruhushya rwo Gufata Amashusho';
    }
  }

  String get scanAgain {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Scan Again';
      case AppLanguage.french:
        return 'Scanner à Nouveau';
      case AppLanguage.kinyarwanda:
        return 'Suzuma Nindi';
    }
  }

  String get rawData {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Raw Data';
      case AppLanguage.french:
        return 'Données Brutes';
      case AppLanguage.kinyarwanda:
        return 'Amakuru Abanza';
    }
  }

  String get unknownStatus {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Unknown status';
      case AppLanguage.french:
        return 'Statut inconnu';
      case AppLanguage.kinyarwanda:
        return 'Imiterere itazwi';
    }
  }

  String get unknownError {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return 'Unknown error';
      case AppLanguage.french:
        return 'Erreur inconnue';
      case AppLanguage.kinyarwanda:
        return 'Ikosa ritazwi';
    }
  }
}
