part of 'example.dart';

class ListMedicalDocumentsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMedicalDocumentsVariablesBuilder(this._dataConnect, );
  Deserializer<ListMedicalDocumentsData> dataDeserializer = (dynamic json)  => ListMedicalDocumentsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMedicalDocumentsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListMedicalDocumentsData, void> ref() {
    
    return _dataConnect.query("ListMedicalDocuments", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMedicalDocumentsMedicalDocuments {
  final String id;
  final String documentName;
  final String? documentType;
  final Timestamp uploadDate;
  ListMedicalDocumentsMedicalDocuments.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  documentName = nativeFromJson<String>(json['documentName']),
  documentType = json['documentType'] == null ? null : nativeFromJson<String>(json['documentType']),
  uploadDate = Timestamp.fromJson(json['uploadDate']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMedicalDocumentsMedicalDocuments otherTyped = other as ListMedicalDocumentsMedicalDocuments;
    return id == otherTyped.id && 
    documentName == otherTyped.documentName && 
    documentType == otherTyped.documentType && 
    uploadDate == otherTyped.uploadDate;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, documentName.hashCode, documentType.hashCode, uploadDate.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['documentName'] = nativeToJson<String>(documentName);
    if (documentType != null) {
      json['documentType'] = nativeToJson<String?>(documentType);
    }
    json['uploadDate'] = uploadDate.toJson();
    return json;
  }

  ListMedicalDocumentsMedicalDocuments({
    required this.id,
    required this.documentName,
    this.documentType,
    required this.uploadDate,
  });
}

@immutable
class ListMedicalDocumentsData {
  final List<ListMedicalDocumentsMedicalDocuments> medicalDocuments;
  ListMedicalDocumentsData.fromJson(dynamic json):
  
  medicalDocuments = (json['medicalDocuments'] as List<dynamic>)
        .map((e) => ListMedicalDocumentsMedicalDocuments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMedicalDocumentsData otherTyped = other as ListMedicalDocumentsData;
    return medicalDocuments == otherTyped.medicalDocuments;
    
  }
  @override
  int get hashCode => medicalDocuments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['medicalDocuments'] = medicalDocuments.map((e) => e.toJson()).toList();
    return json;
  }

  ListMedicalDocumentsData({
    required this.medicalDocuments,
  });
}

