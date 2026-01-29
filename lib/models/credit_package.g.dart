// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditPackage _$CreditPackageFromJson(Map<String, dynamic> json) =>
    CreditPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      credits: (json['credits'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      priceDisplay: json['priceDisplay'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
      savings: (json['savings'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreditPackageToJson(CreditPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'credits': instance.credits,
      'price': instance.price,
      'priceDisplay': instance.priceDisplay,
      'isPopular': instance.isPopular,
      'savings': instance.savings,
    };
