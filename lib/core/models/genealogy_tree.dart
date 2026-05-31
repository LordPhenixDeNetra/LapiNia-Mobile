import 'package:equatable/equatable.dart';

import '../constants/enums.dart';

class GenealogyPerson extends Equatable {
  final String id;
  final String nom;
  final SexeLapin? sexe;
  final String? raceNom;

  const GenealogyPerson({
    required this.id,
    required this.nom,
    required this.sexe,
    required this.raceNom,
  });

  @override
  List<Object?> get props => [id, nom, sexe, raceNom];
}

class GenealogyParents extends Equatable {
  final String? pereId;
  final String? mereId;

  const GenealogyParents({required this.pereId, required this.mereId});

  @override
  List<Object?> get props => [pereId, mereId];
}

class GenealogyTree extends Equatable {
  final String centerId;
  final Map<String, GenealogyPerson> personsById;
  final Map<String, GenealogyParents> parentsByChildId;

  const GenealogyTree({
    required this.centerId,
    required this.personsById,
    required this.parentsByChildId,
  });

  GenealogyParents parentsOf(String id) {
    return parentsByChildId[id] ?? const GenealogyParents(pereId: null, mereId: null);
  }

  GenealogyPerson? personOf(String id) => personsById[id];

  @override
  List<Object?> get props => [centerId, personsById, parentsByChildId];
}

