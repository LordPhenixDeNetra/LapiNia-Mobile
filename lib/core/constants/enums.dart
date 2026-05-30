enum StatutLapin {
  repos,
  enGestation,
  lactation,
  disponibleSaillie,
  engraissement,
  malade,
  vendu,
  mort;

  String get label {
    switch (this) {
      case StatutLapin.repos:
        return 'Au repos';
      case StatutLapin.enGestation:
        return 'En gestation';
      case StatutLapin.lactation:
        return 'En lactation';
      case StatutLapin.disponibleSaillie:
        return 'Disponible saillie';
      case StatutLapin.engraissement:
        return 'Engraissement';
      case StatutLapin.malade:
        return 'Malade';
      case StatutLapin.vendu:
        return 'Vendu';
      case StatutLapin.mort:
        return 'Mort';
    }
  }

  String get dbValue {
    switch (this) {
      case StatutLapin.repos:
        return 'REPOS';
      case StatutLapin.enGestation:
        return 'EN_GESTATION';
      case StatutLapin.lactation:
        return 'LACTATION';
      case StatutLapin.disponibleSaillie:
        return 'DISPONIBLE_SAILLIE';
      case StatutLapin.engraissement:
        return 'ENGRAISSEMENT';
      case StatutLapin.malade:
        return 'MALADE';
      case StatutLapin.vendu:
        return 'VENDU';
      case StatutLapin.mort:
        return 'MORT';
    }
  }

  static StatutLapin fromDbValue(String value) {
    return StatutLapin.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => StatutLapin.repos,
    );
  }
}

enum SexeLapin {
  male,
  femelle;

  String get label {
    switch (this) {
      case SexeLapin.male:
        return 'Mâle';
      case SexeLapin.femelle:
        return 'Femelle';
    }
  }

  String get dbValue {
    switch (this) {
      case SexeLapin.male:
        return 'M';
      case SexeLapin.femelle:
        return 'F';
    }
  }

  static SexeLapin fromDbValue(String value) {
    return SexeLapin.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => SexeLapin.male,
    );
  }
}

enum StatutPortee {
  enGestation,
  miseBas,
  lactation,
  sevrage,
  terminee;

  String get label {
    switch (this) {
      case StatutPortee.enGestation:
        return 'En gestation';
      case StatutPortee.miseBas:
        return 'Mise bas';
      case StatutPortee.lactation:
        return 'Lactation';
      case StatutPortee.sevrage:
        return 'Sevrage';
      case StatutPortee.terminee:
        return 'Terminée';
    }
  }

  String get dbValue {
    switch (this) {
      case StatutPortee.enGestation:
        return 'EN_GESTATION';
      case StatutPortee.miseBas:
        return 'MISE_BAS';
      case StatutPortee.lactation:
        return 'LACTATION';
      case StatutPortee.sevrage:
        return 'SEVRAGE';
      case StatutPortee.terminee:
        return 'TERMINEE';
    }
  }

  static StatutPortee fromDbValue(String value) {
    return StatutPortee.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => StatutPortee.enGestation,
    );
  }
}

enum StatutLapereau {
  vivant,
  mort,
  vendu,
  conserve,
  consomme;

  String get label {
    switch (this) {
      case StatutLapereau.vivant:
        return 'Vivant';
      case StatutLapereau.mort:
        return 'Mort';
      case StatutLapereau.vendu:
        return 'Vendu';
      case StatutLapereau.conserve:
        return 'Conservé';
      case StatutLapereau.consomme:
        return 'Consommé';
    }
  }

  String get dbValue {
    switch (this) {
      case StatutLapereau.vivant:
        return 'VIVANT';
      case StatutLapereau.mort:
        return 'MORT';
      case StatutLapereau.vendu:
        return 'VENDU';
      case StatutLapereau.conserve:
        return 'CONSERVÉ';
      case StatutLapereau.consomme:
        return 'CONSOMMÉ';
    }
  }

  static StatutLapereau fromDbValue(String value) {
    return StatutLapereau.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => StatutLapereau.vivant,
    );
  }
}

enum TypeEvenementSante {
  maladie,
  vaccin,
  traitement,
  observation,
  deces;

  String get label {
    switch (this) {
      case TypeEvenementSante.maladie:
        return 'Maladie';
      case TypeEvenementSante.vaccin:
        return 'Vaccin';
      case TypeEvenementSante.traitement:
        return 'Traitement';
      case TypeEvenementSante.observation:
        return 'Observation';
      case TypeEvenementSante.deces:
        return 'Décès';
    }
  }

  String get dbValue {
    switch (this) {
      case TypeEvenementSante.maladie:
        return 'MALADIE';
      case TypeEvenementSante.vaccin:
        return 'VACCIN';
      case TypeEvenementSante.traitement:
        return 'TRAITEMENT';
      case TypeEvenementSante.observation:
        return 'OBSERVATION';
      case TypeEvenementSante.deces:
        return 'DECES';
    }
  }

  static TypeEvenementSante fromDbValue(String value) {
    return TypeEvenementSante.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => TypeEvenementSante.observation,
    );
  }
}

enum StatutTraitement {
  enCours,
  termine,
  abandonne;

  String get label {
    switch (this) {
      case StatutTraitement.enCours:
        return 'En cours';
      case StatutTraitement.termine:
        return 'Terminé';
      case StatutTraitement.abandonne:
        return 'Abandonné';
    }
  }

  String get dbValue {
    switch (this) {
      case StatutTraitement.enCours:
        return 'EN_COURS';
      case StatutTraitement.termine:
        return 'TERMINE';
      case StatutTraitement.abandonne:
        return 'ABANDONNE';
    }
  }

  static StatutTraitement fromDbValue(String value) {
    return StatutTraitement.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => StatutTraitement.enCours,
    );
  }
}

enum TypeAlerte {
  miseBas,
  stockBas,
  vaccination,
  pesee,
  sante,
  epidemie,
  finance;

  String get label {
    switch (this) {
      case TypeAlerte.miseBas:
        return 'Mise bas';
      case TypeAlerte.stockBas:
        return 'Stock bas';
      case TypeAlerte.vaccination:
        return 'Vaccination';
      case TypeAlerte.pesee:
        return 'Pesée';
      case TypeAlerte.sante:
        return 'Santé';
      case TypeAlerte.epidemie:
        return 'Épidémie';
      case TypeAlerte.finance:
        return 'Finance';
    }
  }

  String get dbValue {
    switch (this) {
      case TypeAlerte.miseBas:
        return 'MISE_BAS';
      case TypeAlerte.stockBas:
        return 'STOCK_BAS';
      case TypeAlerte.vaccination:
        return 'VACCINATION';
      case TypeAlerte.pesee:
        return 'PESEE';
      case TypeAlerte.sante:
        return 'SANTE';
      case TypeAlerte.epidemie:
        return 'EPIDEMIE';
      case TypeAlerte.finance:
        return 'FINANCE';
    }
  }

  static TypeAlerte fromDbValue(String value) {
    return TypeAlerte.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => TypeAlerte.sante,
    );
  }
}

enum PrioriteAlerte {
  critique,
  haute,
  normale;

  int get value {
    switch (this) {
      case PrioriteAlerte.critique:
        return 1;
      case PrioriteAlerte.haute:
        return 2;
      case PrioriteAlerte.normale:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case PrioriteAlerte.critique:
        return 'Critique';
      case PrioriteAlerte.haute:
        return 'Haute';
      case PrioriteAlerte.normale:
        return 'Normale';
    }
  }

  static PrioriteAlerte fromValue(int value) {
    return PrioriteAlerte.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PrioriteAlerte.normale,
    );
  }
}

enum TypeFinance {
  recette,
  depense;

  String get label {
    switch (this) {
      case TypeFinance.recette:
        return 'Recette';
      case TypeFinance.depense:
        return 'Dépense';
    }
  }

  String get dbValue {
    switch (this) {
      case TypeFinance.recette:
        return 'RECETTE';
      case TypeFinance.depense:
        return 'DEPENSE';
    }
  }

  static TypeFinance fromDbValue(String value) {
    return TypeFinance.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => TypeFinance.depense,
    );
  }
}

enum CategorieFinance {
  alimentation,
  medicaments,
  equipements,
  venteLapins,
  mainOeuvre,
  transport,
  chargesFixe,
  autre;

  String get label {
    switch (this) {
      case CategorieFinance.alimentation:
        return 'Alimentation';
      case CategorieFinance.medicaments:
        return 'Médicaments';
      case CategorieFinance.equipements:
        return 'Équipements';
      case CategorieFinance.venteLapins:
        return 'Vente lapins';
      case CategorieFinance.mainOeuvre:
        return 'Main d\'oeuvre';
      case CategorieFinance.transport:
        return 'Transport';
      case CategorieFinance.chargesFixe:
        return 'Charges fixes';
      case CategorieFinance.autre:
        return 'Autre';
    }
  }

  String get dbValue {
    switch (this) {
      case CategorieFinance.alimentation:
        return 'ALIMENTATION';
      case CategorieFinance.medicaments:
        return 'MEDICAMENTS';
      case CategorieFinance.equipements:
        return 'EQUIPEMENTS';
      case CategorieFinance.venteLapins:
        return 'VENTE_LAPINS';
      case CategorieFinance.mainOeuvre:
        return 'MAIN_OEUVRE';
      case CategorieFinance.transport:
        return 'TRANSPORT';
      case CategorieFinance.chargesFixe:
        return 'CHARGES_FIXES';
      case CategorieFinance.autre:
        return 'AUTRE';
    }
  }

  static CategorieFinance fromDbValue(String value) {
    return CategorieFinance.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => CategorieFinance.autre,
    );
  }
}

enum ModePaiement {
  cash,
  orangeMoney,
  wave,
  virement,
  autre;

  String get label {
    switch (this) {
      case ModePaiement.cash:
        return 'Cash';
      case ModePaiement.orangeMoney:
        return 'Orange Money';
      case ModePaiement.wave:
        return 'Wave';
      case ModePaiement.virement:
        return 'Virement';
      case ModePaiement.autre:
        return 'Autre';
    }
  }

  String get dbValue {
    switch (this) {
      case ModePaiement.cash:
        return 'CASH';
      case ModePaiement.orangeMoney:
        return 'ORANGE_MONEY';
      case ModePaiement.wave:
        return 'WAVE';
      case ModePaiement.virement:
        return 'VIREMENT';
      case ModePaiement.autre:
        return 'AUTRE';
    }
  }

  static ModePaiement fromDbValue(String value) {
    return ModePaiement.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ModePaiement.cash,
    );
  }
}
