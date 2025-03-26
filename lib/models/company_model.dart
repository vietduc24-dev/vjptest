import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final String name;
  final int yearFounded;
  final int employees;
  final String businessCapital;
  final String address;
  final String industry;
  final String description;
  final List<String> needs;
  final Contact contact;
  final String image;
  final List<DetailImage>? detailImages;
  final List<KeyMember>? keyMembers;
  final List<Partner>? customersAndPartners;
  final String profileUrl;
  final List<String>? certifications;
  final String? vision;
  final String? mission;
  final List<String>? coreValues;
  final List<Service>? services;
  
  const Company({
    required this.name,
    required this.yearFounded,
    required this.employees,
    required this.businessCapital,
    required this.address,
    required this.industry,
    required this.description,
    required this.needs,
    required this.contact,
    required this.image,
    required this.profileUrl,
    this.detailImages,
    this.keyMembers,
    this.customersAndPartners,
    this.certifications,
    this.vision,
    this.mission,
    this.coreValues,
    this.services,
  });
  
  @override
  List<Object?> get props => [
    name,
    yearFounded,
    employees,
    businessCapital,
    address,
    industry,
    description,
    needs,
    contact,
    image,
    detailImages,
    keyMembers,
    customersAndPartners,
    profileUrl,
    certifications,
    vision,
    mission,
    coreValues,
    services,
  ];
  
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      yearFounded: json['year_founded'] ?? 0,
      employees: json['employees'] ?? 0,
      businessCapital: json['business_capital'] ?? '',
      address: json['address'] ?? '',
      industry: json['industry'] ?? '',
      description: json['description'] ?? '',
      needs: List<String>.from(json['needs'] ?? []),
      contact: Contact.fromJson(json['contact'] ?? {}),
      image: json['image'] ?? '',
      profileUrl: json['profile_url'] ?? '',
      detailImages: json['detail_images'] != null
          ? List<DetailImage>.from(json['detail_images'].map((x) => DetailImage.fromJson(x)))
          : null,
      keyMembers: json['key_members'] != null
          ? List<KeyMember>.from(json['key_members'].map((x) => KeyMember.fromJson(x)))
          : null,
      customersAndPartners: json['customers_and_partners'] != null
          ? List<Partner>.from(json['customers_and_partners'].map((x) => Partner.fromJson(x)))
          : null,
      certifications: json['certifications'] != null ? List<String>.from(json['certifications']) : null,
      vision: json['vision'],
      mission: json['mission'],
      coreValues: json['core_values'] != null ? List<String>.from(json['core_values']) : null,
      services: json['services'] != null
          ? List<Service>.from(json['services'].map((x) => Service.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year_founded': yearFounded,
      'employees': employees,
      'business_capital': businessCapital,
      'address': address,
      'industry': industry,
      'description': description,
      'needs': needs,
      'contact': contact.toJson(),
      'image': image,
      'profile_url': profileUrl,
      'detail_images': detailImages?.map((x) => x.toJson()).toList(),
      'key_members': keyMembers?.map((x) => x.toJson()).toList(),
      'customers_and_partners': customersAndPartners?.map((x) => x.toJson()).toList(),
      'certifications': certifications,
      'vision': vision,
      'mission': mission,
      'core_values': coreValues,
      'services': services?.map((x) => x.toJson()).toList(),
    };
  }

  bool get isVietnamCompany {
    return name.contains('CÔNG TY') || !name.contains('CO.,LTD');
  }
}

class Contact extends Equatable {
  final String email;
  final String phone;
  final String? website;
  final String? address;
  
  const Contact({
    required this.email,
    required this.phone,
    this.website,
    this.address,
  });
  
  @override
  List<Object?> get props => [email, phone, website, address];
  
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'],
      address: json['address'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'website': website,
      'address': address,
    };
  }
}

class DetailImage extends Equatable {
  final String url;
  final String? caption;
  
  const DetailImage({
    required this.url,
    this.caption,
  });
  
  @override
  List<Object?> get props => [url, caption];
  
  factory DetailImage.fromJson(Map<String, dynamic> json) {
    return DetailImage(
      url: json['url'] ?? '',
      caption: json['caption'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'caption': caption,
    };
  }
}

class KeyMember extends Equatable {
  final String name;
  final String position;
  final String? image;
  final String? description;
  
  const KeyMember({
    required this.name,
    required this.position,
    this.image,
    this.description,
  });
  
  @override
  List<Object?> get props => [name, position, image, description];
  
  factory KeyMember.fromJson(Map<String, dynamic> json) {
    return KeyMember(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      image: json['image'],
      description: json['description'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'image': image,
      'description': description,
    };
  }
}

class Partner extends Equatable {
  final String name;
  final String? logo;
  final String type;
  
  const Partner({
    required this.name,
    required this.type,
    this.logo,
  });
  
  @override
  List<Object?> get props => [name, logo, type];
  
  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      name: json['name'] ?? '',
      logo: json['logo'],
      type: json['type'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'type': type,
    };
  }
}

class Service extends Equatable {
  final String name;
  final String? icon;
  final String? subText;
  
  const Service({
    required this.name,
    this.icon,
    this.subText,
  });
  
  @override
  List<Object?> get props => [name, icon, subText];
  
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'] ?? '',
      icon: json['icon'],
      subText: json['sub_text'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'sub_text': subText,
    };
  }
} 