// Deterministic multipliers per pound (lbs) for environmental contribution

const double waterSavedGallonsPerLb = 2.4;
const double detergentOzPerLb = 0.25;
const double gasThermsPerLb = 0.02;
const double energyKwhPerLb = 0.1;
const double co2KgPerLb = 0.136;

Map<String, double> environmentalFromWeight(double weightLbs) {
  if (weightLbs <= 0) {
    return {
      'water': 0.0,
      'detergent': 0.0,
      'gas': 0.0,
      'energy': 0.0,
      'co2': 0.0,
    };
  }
  return {
    'water': weightLbs * waterSavedGallonsPerLb,
    'detergent': weightLbs * detergentOzPerLb,
    'gas': weightLbs * gasThermsPerLb,
    'energy': weightLbs * energyKwhPerLb,
    'co2': weightLbs * co2KgPerLb,
  };
}
