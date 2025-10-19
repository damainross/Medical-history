part of 'example.dart';

class UpdateMedicationVariablesBuilder {
  String medicationId;
  String newDosage;

  final FirebaseDataConnect _dataConnect;
  UpdateMedicationVariablesBuilder(this._dataConnect, {required  this.medicationId,required  this.newDosage,});
  Deserializer<UpdateMedicationData> dataDeserializer = (dynamic json)  => UpdateMedicationData.fromJson(jsonDecode(json));
  Serializer<UpdateMedicationVariables> varsSerializer = (UpdateMedicationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateMedicationData, UpdateMedicationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateMedicationData, UpdateMedicationVariables> ref() {
    UpdateMedicationVariables vars= UpdateMedicationVariables(medicationId: medicationId,newDosage: newDosage,);
    return _dataConnect.mutation("UpdateMedication", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateMedicationMedicationUpdate {
  final String id;
  UpdateMedicationMedicationUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMedicationMedicationUpdate otherTyped = other as UpdateMedicationMedicationUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateMedicationMedicationUpdate({
    required this.id,
  });
}

@immutable
class UpdateMedicationData {
  final UpdateMedicationMedicationUpdate? medication_update;
  UpdateMedicationData.fromJson(dynamic json):
  
  medication_update = json['medication_update'] == null ? null : UpdateMedicationMedicationUpdate.fromJson(json['medication_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMedicationData otherTyped = other as UpdateMedicationData;
    return medication_update == otherTyped.medication_update;
    
  }
  @override
  int get hashCode => medication_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (medication_update != null) {
      json['medication_update'] = medication_update!.toJson();
    }
    return json;
  }

  UpdateMedicationData({
    this.medication_update,
  });
}

@immutable
class UpdateMedicationVariables {
  final String medicationId;
  final String newDosage;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateMedicationVariables.fromJson(Map<String, dynamic> json):
  
  medicationId = nativeFromJson<String>(json['medicationId']),
  newDosage = nativeFromJson<String>(json['newDosage']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateMedicationVariables otherTyped = other as UpdateMedicationVariables;
    return medicationId == otherTyped.medicationId && 
    newDosage == otherTyped.newDosage;
    
  }
  @override
  int get hashCode => Object.hashAll([medicationId.hashCode, newDosage.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['medicationId'] = nativeToJson<String>(medicationId);
    json['newDosage'] = nativeToJson<String>(newDosage);
    return json;
  }

  UpdateMedicationVariables({
    required this.medicationId,
    required this.newDosage,
  });
}

