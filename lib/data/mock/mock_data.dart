import '../models/car_model.dart';
import '../models/maintenance_model.dart';
import '../models/market_product_model.dart';
import '../models/social_post_model.dart';

/// Mock data for testing and development
class MockData {
  // Mock Users
  static final mockUsers = [
    const UserInfo(
      id: 'user-001',
      name: 'John Doe',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      username: 'johndoe',
    ),
    const UserInfo(
      id: 'user-002',
      name: 'Jane Smith',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      username: 'janesmith',
    ),
    const UserInfo(
      id: 'user-003',
      name: 'Mike Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
      username: 'mikej',
    ),
  ];

  // Mock Vehicles
  static final mockVehicles = [
    CarModel(
      id: 'vehicle-001',
      userId: 'user-001',
      name: 'My BMW X5',
      make: 'BMW',
      model: 'X5',
      year: 2020,
      vin: 'WBAKF8C54LC123456',
      plateNumber: 'ABC-123',
      color: 'Black Sapphire',
      transmission: 'Automatic',
      drivetrain: 'AWD',
      fuelType: 'Gasoline',
      engineType: '3.0L I6 Turbo',
      mileage: 45000,
      imageUrl:
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
      model3dUrl: 'assets/3d/2020_bmw_x5_m_competition.glb',
      notes: 'Premium SUV, excellent condition',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    CarModel(
      id: 'vehicle-002',
      userId: 'user-001',
      name: 'Toyota Camry',
      make: 'Toyota',
      model: 'Camry',
      year: 2018,
      vin: '4T1BF1FK8KU123456',
      plateNumber: 'XYZ-789',
      color: 'Silver Metallic',
      transmission: 'Automatic',
      drivetrain: 'FWD',
      fuelType: 'Hybrid',
      engineType: '2.5L I4 Hybrid',
      mileage: 62000,
      imageUrl:
          'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800',
      model3dUrl: 'assets/3d/toyota_camry_2018.glb',
      notes: 'Reliable family sedan, fuel efficient',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    CarModel(
      id: 'vehicle-003',
      userId: 'user-002',
      name: 'Land Cruiser 200',
      make: 'Toyota',
      model: 'Land Cruiser 200',
      year: 2022,
      vin: 'JTMCY7AJ9N4123456',
      plateNumber: 'LUX-456',
      color: 'Pearl White',
      transmission: 'Automatic',
      drivetrain: 'AWD',
      fuelType: 'Diesel',
      engineType: '3.5L V6 Twin-Turbo',
      mileage: 28000,
      imageUrl:
          'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
      model3dUrl: 'assets/3d/2022_toyota_land_cruiser_300_vx.r.glb',
      notes: 'Premium off-road SUV, luxury package',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  // Mock Maintenance Records
  static final mockMaintenanceRecords = [
    MaintenanceModel(
      id: 'maint-001',
      garageId: 'vehicle-001',
      type: 'oil_change',
      status: MaintenanceStatus.completed,
      scheduledDate: DateTime.now().subtract(const Duration(days: 30)),
      completedDate: DateTime.now().subtract(const Duration(days: 32)),
      estimatedCost: 180.00,
      actualCost: 175.00,
      notes: 'BMW X5: Full synthetic 5W-30, new oil filter',
      serviceProvider: 'BMW Service Center',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    MaintenanceModel(
      id: 'maint-002',
      garageId: 'vehicle-001',
      type: 'tire_rotation',
      status: MaintenanceStatus.pending,
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      estimatedCost: 120.00,
      notes: 'BMW X5: Tire rotation and wheel alignment check',
      serviceProvider: 'BMW Service Center',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    MaintenanceModel(
      id: 'maint-003',
      garageId: 'vehicle-002',
      type: 'brake_inspection',
      status: MaintenanceStatus.overdue,
      scheduledDate: DateTime.now().subtract(const Duration(days: 5)),
      estimatedCost: 150.00,
      notes: 'Toyota Camry 2018: Hybrid brake system inspection',
      serviceProvider: 'Toyota Service',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
    MaintenanceModel(
      id: 'maint-004',
      garageId: 'vehicle-003',
      type: 'general_service',
      status: MaintenanceStatus.completed,
      scheduledDate: DateTime.now().subtract(const Duration(days: 15)),
      completedDate: DateTime.now().subtract(const Duration(days: 16)),
      estimatedCost: 650.00,
      actualCost: 620.00,
      notes: 'Land Cruiser 200: 30,000 km service - oil, filters, diff check',
      serviceProvider: 'Toyota Land Cruiser Center',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  // Mock Market Products
  static final mockMarketProducts = [
    const MarketProductModel(
      id: 'product-001',
      title: 'BMW X5 (G05) Front Brake Pads',
      description:
          'Premium quality ceramic brake pads for BMW X5 2020-2023. OEM equivalent performance with reduced dust and noise.',
      price: 249.99,
      category: 'parts',
      sellerId: 'seller-001',
      images: [
        'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800',
        'https://images.unsplash.com/photo-1625047509168-a7026f36de04?w=800',
      ],
      available: true,
      viewCount: 234,
      favoriteCount: 18,
      condition: 'new',
      brand: 'Brembo',
      location: 'Almaty, Kazakhstan',
      specifications: {
        'width': '155mm',
        'height': '72mm',
        'material': 'ceramic',
        'warranty': '2 years',
        'fits': 'BMW X5 2018-2023',
      },
    ),
    const MarketProductModel(
      id: 'product-002',
      title: 'Toyota Camry Hybrid Battery',
      description:
          'High-performance hybrid battery for Toyota Camry 2018-2020. 8-year warranty, tested and certified.',
      price: 2499.99,
      category: 'parts',
      sellerId: 'seller-002',
      images: [
        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=800',
      ],
      available: true,
      viewCount: 892,
      favoriteCount: 64,
      condition: 'new',
      brand: 'Toyota Genuine',
      location: 'Nur-Sultan, Kazakhstan',
      specifications: {
        'voltage': '201.6V',
        'capacity': '6.5Ah',
        'warranty': '8 years',
        'weight': '45kg',
      },
    ),
    const MarketProductModel(
      id: 'product-003',
      title: 'Land Cruiser 200 LED Light Bar',
      description:
          'Professional off-road LED light bar for Toyota Land Cruiser 200. 42-inch, waterproof IP68, 260W output.',
      price: 449.99,
      category: 'accessories',
      sellerId: 'seller-001',
      images: [
        'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
        'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?w=800',
      ],
      available: true,
      viewCount: 567,
      favoriteCount: 42,
      condition: 'new',
      brand: 'Rigid Industries',
      location: 'Almaty, Kazakhstan',
      specifications: {
        'size': '42 inch',
        'power': '260W',
        'waterproof': 'IP68',
        'lumens': '26,000',
      },
    ),
    const MarketProductModel(
      id: 'product-004',
      title: 'Universal Premium Car Cover',
      description:
          'All-weather car cover for SUVs. Fits BMW X5, Land Cruiser, and similar sized vehicles. UV protection, waterproof.',
      price: 129.99,
      category: 'accessories',
      sellerId: 'seller-003',
      images: [
        'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=800',
      ],
      available: true,
      viewCount: 890,
      favoriteCount: 65,
      condition: 'new',
      brand: 'CoverKing',
      location: 'Almaty, Kazakhstan',
      specifications: {
        'size': 'XXL (fits SUVs)',
        'material': 'multi-layer fabric',
        'waterproof': 'yes',
        'uv_protection': 'yes',
      },
    ),
  ];

  // Mock Social Posts
  static final mockSocialPosts = [
    SocialPostModel(
      id: 'post-001',
      userId: 'user-001',
      content:
          'Just finished a complete detailing on my BMW X5 2020! The ceramic coating turned out amazing. Highly recommend AutoShine in Almaty. #BMWX5 #CarCare',
      author: mockUsers[0],
      mediaUrls: const [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
        'https://images.unsplash.com/photo-1617469767053-d3b523a0b982?w=800',
      ],
      tags: const ['bmw', 'x5', 'detailing', 'carcare'],
      likeCount: 127,
      commentCount: 23,
      shareCount: 8,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SocialPostModel(
      id: 'post-002',
      userId: 'user-002',
      content:
          'My Toyota Camry Hybrid 2018 just hit 60,000 km! Still running like new, best decision ever. Fuel economy is unbeatable. #ToyotaCamry #HybridLife',
      author: mockUsers[1],
      mediaUrls: const [
        'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800',
      ],
      tags: const ['toyota', 'camry', 'hybrid', 'fueleconomy'],
      likeCount: 89,
      commentCount: 15,
      shareCount: 3,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SocialPostModel(
      id: 'post-003',
      userId: 'user-003',
      content:
          'Weekend off-road adventure with the Land Cruiser 200! Conquered the Charyn Canyon trails. This beast never disappoints. #LandCruiser #OffRoad #Kazakhstan',
      author: mockUsers[2],
      mediaUrls: const [
        'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
      ],
      tags: const ['landcruiser', 'offroad', 'adventure', 'kazakhstan'],
      likeCount: 234,
      commentCount: 67,
      shareCount: 45,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    SocialPostModel(
      id: 'post-004',
      userId: 'user-001',
      content:
          'Installed new M-Sport wheels on my X5! The stance looks aggressive now. Next up: performance exhaust. #BMWX5 #ModifiedCars #MSport',
      author: mockUsers[0],
      mediaUrls: const [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
        'https://images.unsplash.com/photo-1580414057983-c0961e2e3bdc?w=800',
      ],
      tags: const ['bmw', 'x5', 'wheels', 'modified'],
      likeCount: 156,
      commentCount: 34,
      shareCount: 12,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // Mock AI Chat Messages
  static final mockChatMessages = [
    {
      'role': 'user',
      'content': 'My engine light is on, what should I do?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'role': 'assistant',
      'content':
          'An engine light can indicate various issues. I recommend:\n\n1. Check if the gas cap is loose or damaged\n2. Look for any unusual sounds or performance issues\n3. Use an OBD2 scanner to read the error code\n4. If the light is flashing (not steady), stop driving immediately\n\nWhat make and model is your vehicle?',
      'timestamp': DateTime.now().subtract(
        const Duration(minutes: 4, seconds: 30),
      ),
    },
    {
      'role': 'user',
      'content': 'It\'s a 2020 BMW X5',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'role': 'assistant',
      'content':
          'For a 2020 BMW X5, common causes include:\n\n• Oxygen sensor issues (most common)\n• Mass airflow sensor problems\n• Spark plug or ignition coil failure\n• Catalytic converter issues\n\nBMW recommends having it diagnosed at an authorized service center. Would you like me to find BMW service centers near you?',
      'timestamp': DateTime.now().subtract(
        const Duration(minutes: 3, seconds: 45),
      ),
    },
  ];
}
