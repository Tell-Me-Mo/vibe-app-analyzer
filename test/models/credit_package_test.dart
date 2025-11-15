import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/models/credit_package.dart';

void main() {
  group('CreditPackage Model', () {
    test('should calculate price per credit correctly', () {
      const package = CreditPackage(
        id: 'test_pack',
        name: 'Test Pack',
        description: 'Test description',
        credits: 50,
        price: 10.0,
        priceDisplay: '\$10.00',
      );

      expect(package.pricePerCredit, equals(0.2)); // $10 / 50 = $0.20 per credit
    });

    test('should serialize to JSON correctly', () {
      const package = CreditPackage(
        id: 'test_pack',
        name: 'Test Pack',
        description: 'Test description',
        credits: 20,
        price: 4.99,
        priceDisplay: '\$4.99',
        isPopular: true,
        savings: 15,
      );

      final json = package.toJson();

      expect(json['id'], equals('test_pack'));
      expect(json['name'], equals('Test Pack'));
      expect(json['credits'], equals(20));
      expect(json['price'], equals(4.99));
      expect(json['isPopular'], equals(true));
      expect(json['savings'], equals(15));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test_pack',
        'name': 'Test Pack',
        'description': 'Test description',
        'credits': 20,
        'price': 4.99,
        'priceDisplay': '\$4.99',
        'isPopular': false,
        'savings': null,
      };

      final package = CreditPackage.fromJson(json);

      expect(package.id, equals('test_pack'));
      expect(package.name, equals('Test Pack'));
      expect(package.credits, equals(20));
      expect(package.price, equals(4.99));
      expect(package.isPopular, equals(false));
      expect(package.savings, isNull);
    });
  });

  group('Predefined Credit Packages', () {
    test('Starter Pack has correct values', () {
      expect(CreditPackages.starter.id, equals('starter_pack'));
      expect(CreditPackages.starter.credits, equals(20));
      expect(CreditPackages.starter.price, equals(4.99));
      expect(CreditPackages.starter.isPopular, isFalse);
      expect(CreditPackages.starter.savings, isNull);
    });

    test('Popular Pack has correct values and is marked popular', () {
      expect(CreditPackages.popular.id, equals('popular_pack'));
      expect(CreditPackages.popular.credits, equals(50));
      expect(CreditPackages.popular.price, equals(9.99));
      expect(CreditPackages.popular.isPopular, isTrue);
      expect(CreditPackages.popular.savings, equals(20));
    });

    test('Professional Pack has correct values', () {
      expect(CreditPackages.professional.id, equals('professional_pack'));
      expect(CreditPackages.professional.credits, equals(120));
      expect(CreditPackages.professional.price, equals(19.99));
      expect(CreditPackages.professional.savings, equals(35));
    });

    test('Enterprise Pack has correct values', () {
      expect(CreditPackages.enterprise.id, equals('enterprise_pack'));
      expect(CreditPackages.enterprise.credits, equals(300));
      expect(CreditPackages.enterprise.price, equals(39.99));
      expect(CreditPackages.enterprise.savings, equals(50));
    });

    test('All packages list contains all 4 packages', () {
      expect(CreditPackages.all.length, equals(4));
      expect(CreditPackages.all[0], equals(CreditPackages.starter));
      expect(CreditPackages.all[1], equals(CreditPackages.popular));
      expect(CreditPackages.all[2], equals(CreditPackages.professional));
      expect(CreditPackages.all[3], equals(CreditPackages.enterprise));
    });

    test('Packages have increasing value (better price per credit)', () {
      final starterPpc = CreditPackages.starter.pricePerCredit;
      final popularPpc = CreditPackages.popular.pricePerCredit;
      final professionalPpc = CreditPackages.professional.pricePerCredit;
      final enterprisePpc = CreditPackages.enterprise.pricePerCredit;

      // Higher tier should have lower price per credit
      expect(popularPpc < starterPpc, isTrue);
      expect(professionalPpc < popularPpc, isTrue);
      expect(enterprisePpc < professionalPpc, isTrue);
    });

    test('Savings percentages are accurate', () {
      // Base price (starter): $4.99 / 20 = $0.2495 per credit
      final basePricePerCredit = CreditPackages.starter.pricePerCredit;

      // Popular: 20% savings
      final popularExpectedPrice = basePricePerCredit * 0.8 * 50;
      expect(
        CreditPackages.popular.price,
        closeTo(popularExpectedPrice, 1.0),
      );

      // Professional: 35% savings
      final professionalExpectedPrice = basePricePerCredit * 0.65 * 120;
      expect(
        CreditPackages.professional.price,
        closeTo(professionalExpectedPrice, 2.0),
      );

      // Enterprise: 50% savings
      final enterpriseExpectedPrice = basePricePerCredit * 0.5 * 300;
      expect(
        CreditPackages.enterprise.price,
        closeTo(enterpriseExpectedPrice, 3.0),
      );
    });
  });
}
