import '../models/beach.dart';

/// Hand-picked beaches shown as one-tap suggestions in search.
const popularBeaches = <Beach>[
  Beach(name: 'Agadir Beach', region: 'Souss-Massa', country: 'Morocco', latitude: 30.4180, longitude: -9.6060),
  Beach(name: 'Taghazout', region: 'Souss-Massa', country: 'Morocco', latitude: 30.5450, longitude: -9.7090),
  Beach(name: 'Dameisha Beach', region: 'Shenzhen', country: 'China', latitude: 22.5960, longitude: 114.3070),
  Beach(name: 'Yalong Bay', region: 'Sanya', country: 'China', latitude: 18.2290, longitude: 109.6400),
  Beach(name: 'Bondi Beach', region: 'Sydney', country: 'Australia', latitude: -33.8915, longitude: 151.2767),
  Beach(name: 'Waikiki', region: 'Hawaii', country: 'USA', latitude: 21.2766, longitude: -157.8270),
  Beach(name: 'Copacabana', region: 'Rio de Janeiro', country: 'Brazil', latitude: -22.9711, longitude: -43.1822),
  Beach(name: 'Praia da Marinha', region: 'Algarve', country: 'Portugal', latitude: 37.0900, longitude: -8.4120),
  Beach(name: 'Navagio', region: 'Zakynthos', country: 'Greece', latitude: 37.8590, longitude: 20.6250),
  Beach(name: 'Maya Bay', region: 'Krabi', country: 'Thailand', latitude: 7.6780, longitude: 98.7660),
  Beach(name: 'Miami Beach', region: 'Florida', country: 'USA', latitude: 25.7907, longitude: -80.1300),
  Beach(name: 'Promenade des Anglais', region: 'Nice', country: 'France', latitude: 43.6950, longitude: 7.2650),
];

/// The beach used on first launch, before the user picks one.
const defaultBeach = Beach(
  name: 'Agadir Beach',
  region: 'Souss-Massa',
  country: 'Morocco',
  latitude: 30.4180,
  longitude: -9.6060,
);
