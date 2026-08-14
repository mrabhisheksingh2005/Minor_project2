class DiseaseInfo {
  final String id;
  final String cropName;
  final String diseaseName;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final List<String> prevention;

  const DiseaseInfo({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.prevention,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'description': description,
      'symptoms': symptoms,
      'causes': causes,
      'treatment': treatment,
      'prevention': prevention,
    };
  }

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
      id: json['id'] as String,
      cropName: json['cropName'] as String,
      diseaseName: json['diseaseName'] as String,
      description: json['description'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      causes: List<String>.from(json['causes'] as List),
      treatment: List<String>.from(json['treatment'] as List),
      prevention: List<String>.from(json['prevention'] as List),
    );
  }

  static const List<DiseaseInfo> cropDiseasesDataset = [
    // TOMATO
    DiseaseInfo(
      id: 'tomato_early_blight',
      cropName: 'Tomato',
      diseaseName: 'Early Blight (Alternaria solani)',
      description: 'A common fungal disease that affects tomato foliage, stems, and fruit. It typically starts on older leaves and spreads upwards, severely reducing yield if left untreated.',
      symptoms: [
        'Dark spots with concentric rings (target-like pattern) on older leaves.',
        'Leaves turn yellow and drop off prematurely.',
        'Dark, sunken lesions on stems near the soil line.'
      ],
      causes: [
        'Fungus Alternaria solani surviving in crop debris and soil.',
        'Warm, wet, and humid environmental conditions.',
        'Splashing rain or overhead irrigation spreading spores.'
      ],
      treatment: [
        'Apply copper-based fungicides or organic bio-fungicides (e.g., Bacillus subtilis).',
        'Prune lower leaves to improve air circulation.',
        'Remove and destroy infected plant parts immediately.'
      ],
      prevention: [
        'Practice 3-year crop rotation with non-solanaceous crops.',
        'Use drip irrigation instead of overhead watering to keep foliage dry.',
        'Apply organic mulch to prevent soil splashing onto leaves.'
      ],
    ),
    DiseaseInfo(
      id: 'tomato_late_blight',
      cropName: 'Tomato',
      diseaseName: 'Late Blight (Phytophthora infestans)',
      description: 'An extremely destructive water-mold pathogen that can kill whole fields within days. Famous for causing the Irish Potato Famine, it thrives in cool, wet weather.',
      symptoms: [
        'Water-soaked, dark green or black lesions on leaves and stems.',
        'White, fuzzy mold growth on the undersides of leaves in humid conditions.',
        'Large, firm, greasy brown spots on tomato fruit.'
      ],
      causes: [
        'Oomycete pathogen Phytophthora infestans.',
        'Cool, highly humid, and rainy weather.',
        'Infected seed tubers or volunteer plants nearby.'
      ],
      treatment: [
        'Apply systemic fungicides containing chlorothalonil or mancozeb.',
        'Destroy infected crop residues immediately (do not compost).',
        'Harvest remaining healthy fruit early if disease is spreading rapidly.'
      ],
      prevention: [
        'Plant resistant cultivars (like Defiant, Mountain Merit).',
        'Maintain wide plant spacing for fast drying of leaves.',
        'Monitor weather reports for blight alerts and take preventive action.'
      ],
    ),
    DiseaseInfo(
      id: 'tomato_healthy',
      cropName: 'Tomato',
      diseaseName: 'Healthy Tomato Leaf',
      description: 'The tomato plant shows no signs of active disease. The foliage is vibrant green, firm, and photosynthesis is optimal.',
      symptoms: ['Leaves are uniform green with no dark spots or dry margins.', 'Stems are strong and upright.', 'Fruits are developing normally with smooth skin.'],
      causes: ['Proper soil nutrition, optimal watering, and robust immune health.'],
      treatment: ['No treatment required. Maintain current watering and fertilizing schedule.'],
      prevention: ['Continue regular monitoring and practice preventive hygiene.'],
    ),

    // POTATO
    DiseaseInfo(
      id: 'potato_early_blight',
      cropName: 'Potato',
      diseaseName: 'Early Blight (Alternaria solani)',
      description: 'Similar to tomato early blight, this fungal disease attacks potato foliage, causing reduced tuber size and yield loss.',
      symptoms: [
        'Small, brown-to-black spots on older leaves, developing target-like concentric rings.',
        'Dry, leathery, dead patches on leaves.',
        'Sunken, dark, dry rot lesions on tubers.'
      ],
      causes: [
        'Alternaria solani fungus overwintering in soil or crop residue.',
        'Alternating wet and dry periods combined with low soil fertility.'
      ],
      treatment: [
        'Foliar spray with fungicides like mancozeb or chlorothalonil.',
        'Maintain balanced nitrogen fertilization to keep plants vigorous.'
      ],
      prevention: [
        'Plant certified disease-free seed tubers.',
        'Practice crop rotation and plow under crop debris post-harvest.',
        'Avoid overhead irrigation.'
      ],
    ),
    DiseaseInfo(
      id: 'potato_late_blight',
      cropName: 'Potato',
      diseaseName: 'Late Blight (Phytophthora infestans)',
      description: 'A rapid, devastating pathogen affecting both foliage and tubers, leading to complete plant collapse and rot.',
      symptoms: [
        'Pale green, water-soaked spots on leaf tips and margins.',
        'Rapidly expanding dark brown to black areas on leaves.',
        'White mildew on leaf undersides in wet weather.',
        'Tubers have a reddish-brown dry rot extending into the flesh.'
      ],
      causes: [
        'Phytophthora infestans spores spread by wind and rain splashing.',
        'Cool, wet weather with relative humidity above 90%.'
      ],
      treatment: [
        'Spray protective fungicides or copper sprays immediately upon first warning.',
        'Kill vines 2 weeks before harvest to prevent spore spread to tubers.'
      ],
      prevention: [
        'Plant late-blight resistant varieties.',
        'Store tubers in well-ventilated, cool areas.',
        'Remove volunteer potato plants.'
      ],
    ),
    DiseaseInfo(
      id: 'potato_healthy',
      cropName: 'Potato',
      diseaseName: 'Healthy Potato Leaf',
      description: 'The potato foliage is healthy, showing bright green color and good turgor pressure. Tuber growth is progressing normally.',
      symptoms: ['Lush green leaves without discolored patches.', 'No signs of leaf curling or wilting.'],
      causes: ['Proper soil drainage, balanced N-P-K fertilizer, and clean seeds.'],
      treatment: ['None needed.'],
      prevention: ['Maintain standard cultural practices, rotate crops annually.'],
    ),

    // RICE
    DiseaseInfo(
      id: 'rice_blast',
      cropName: 'Rice',
      diseaseName: 'Rice Blast (Magnaporthe oryzae)',
      description: 'One of the most destructive diseases of rice worldwide. It can affect leaves, nodes, panicles, and grains, causing massive yield failures.',
      symptoms: [
        'Spindle-shaped (diamond) lesions on leaves with reddish-brown borders and grey centers.',
        'Neck rot (neck blast) causing panicles to fall over or produce empty grains.',
        'Blackened nodes on the stem.'
      ],
      causes: [
        'Fungus Magnaporthe oryzae.',
        'High atmospheric humidity, cool nights, and dew on leaves.',
        'Excessive nitrogen fertilization.'
      ],
      treatment: [
        'Apply systemic fungicides like Tricyclazole or Azoxystrobin.',
        'Incorporate silicon-based soil amendments to strengthen cell walls.'
      ],
      prevention: [
        'Avoid over-application of nitrogen fertilizer.',
        'Use blast-resistant rice cultivars.',
        'Ensure continuous flooding of fields to suppress fungal spore releases.'
      ],
    ),
    DiseaseInfo(
      id: 'rice_bacterial_blight',
      cropName: 'Rice',
      diseaseName: 'Bacterial Leaf Blight (Xanthomonas oryzae)',
      description: 'A bacterial disease that causes wilting of seedlings and yellowing/drying of leaves. Common in irrigated and rainfed lowland areas.',
      symptoms: [
        'Linear yellow to straw-colored stripes with wavy margins starting from leaf tips.',
        'Bacterial ooze (milky droplets) on leaves during damp mornings.',
        'Kresekk stage: systemic wilting where leaves dry and roll up.'
      ],
      causes: [
        'Xanthomonas oryzae pv. oryzae bacteria entering through leaf wounds or stomata.',
        'Heavy rain, strong winds, and high temperature.'
      ],
      treatment: [
        'Apply copper hydroxide or streptocycline spray if severe.',
        'Drain fields temporarily to reduce humidity.'
      ],
      prevention: [
        'Plant resistant varieties.',
        'Practice clean cultivation (remove weeds and stubbles).',
        'Avoid deep flooding or high nitrogen application.'
      ],
    ),
    DiseaseInfo(
      id: 'rice_healthy',
      cropName: 'Rice',
      diseaseName: 'Healthy Rice Leaf',
      description: 'The rice plant is healthy and producing strong green tillers. Panicle emergence is normal.',
      symptoms: ['Long, narrow, bright green leaves with no lesions.', 'Sturdy culms and well-developed roots.'],
      causes: ['Proper water depth, optimal urea management, and pest control.'],
      treatment: ['None needed.'],
      prevention: ['Maintain clean field channels and monitor moisture conditions.'],
    ),

    // WHEAT
    DiseaseInfo(
      id: 'wheat_rust',
      cropName: 'Wheat',
      diseaseName: 'Leaf Rust (Puccinia triticina)',
      description: 'An airborne fungal disease that attacks wheat leaves, disrupting photosynthesis and reducing kernel weight.',
      symptoms: [
        'Small, round, orange-to-reddish pustules containing spores on leaf surfaces.',
        'Yellowing of leaves starting from the tips.',
        'Powdery orange residue that rubs off on fingers.'
      ],
      causes: [
        'Rust fungus Puccinia triticina.',
        'Mild temperatures (15-22°C) and moisture/dew on leaves.'
      ],
      treatment: [
        'Spray triazole-based fungicides (Tebuconazole or Propiconazole) at first sign.',
        'Harvest crop early if grain filling is complete.'
      ],
      prevention: [
        'Plant rust-resistant wheat varieties (highly recommended).',
        'Sow early to bypass peak rust seasons.'
      ],
    ),
    DiseaseInfo(
      id: 'wheat_healthy',
      cropName: 'Wheat',
      diseaseName: 'Healthy Wheat Leaf',
      description: 'Wheat tillers are upright, thick, and leaf tissue is deep green without rust spots.',
      symptoms: ['Even green coloration across leaf sheaths and blades.', 'No pustules or powdery spots.'],
      causes: ['Favorable growing weather, disease-free seed, balanced soil nutrition.'],
      treatment: ['None.'],
      prevention: ['Rotate with leguminous crops, perform field hygiene.'],
    ),

    // CORN
    DiseaseInfo(
      id: 'corn_leaf_blight',
      cropName: 'Corn',
      diseaseName: 'Northern Corn Leaf Blight (Exserohilum turcicum)',
      description: 'A major foliar fungal disease that causes cigar-shaped lesions on corn leaves, causing premature plant death and yield loss.',
      symptoms: [
        'Long, cigar-shaped, grey-green to tan lesions on leaves.',
        'Lesions starting on lower leaves and moving up.',
        'Dusty grey-to-black spores on leaf surfaces during damp weather.'
      ],
      causes: [
        'Fungus Exserohilum turcicum surviving on corn residue.',
        'Moderate temperatures (18-27°C) and prolonged leaf wetness.'
      ],
      treatment: [
        'Apply strobilurin or triazole fungicides if disease develops before silking.',
        'Chop and plow crop residue after harvest to accelerate decomposition.'
      ],
      prevention: [
        'Plant hybrids with NCLB resistance genes.',
        'Practice 1-2 year crop rotation away from corn.'
      ],
    ),
    DiseaseInfo(
      id: 'corn_healthy',
      cropName: 'Corn',
      diseaseName: 'Healthy Corn Leaf',
      description: 'The corn plant shows dark green, wide leaves and healthy stalk structure. Photosynthetic efficiency is high.',
      symptoms: ['Deep green leaves without long tan streaks.', 'Strong stalks and normal ear development.'],
      causes: ['Proper spacing, nitrogen availability, and adequate rain/irrigation.'],
      treatment: ['None.'],
      prevention: ['Avoid overhead watering, feed balanced fertilizers.'],
    ),

    // COTTON
    DiseaseInfo(
      id: 'cotton_leaf_spot',
      cropName: 'Cotton',
      diseaseName: 'Alternaria Leaf Spot (Alternaria macrospora)',
      description: 'A fungal disease affecting cotton seedlings and older leaves, causing defoliation and lowered cotton fiber quality.',
      symptoms: [
        'Small, circular brown spots on leaves, becoming purple-bordered.',
        'Centers of spots become grey and may fall out (shot-hole effect).',
        'Early defoliation of lower leaves.'
      ],
      causes: [
        'Fungus Alternaria macrospora.',
        'Wet conditions combined with plant stress (e.g., potassium deficiency).'
      ],
      treatment: [
        'Spray copper oxychloride or carbendazim fungicides.',
        'Apply potassium fertilizers to reduce plant susceptibility.'
      ],
      prevention: [
        'Maintain balanced soil fertility (especially potassium).',
        'Deep plow crop debris after harvesting.'
      ],
    ),
    DiseaseInfo(
      id: 'cotton_healthy',
      cropName: 'Cotton',
      diseaseName: 'Healthy Cotton Leaf',
      description: 'The cotton plant has healthy lobed leaves, strong squaring, and normal boll development.',
      symptoms: ['Clean, green, lobed leaves with no purple spots.', 'Vigorous boll formation.'],
      causes: ['Optimal sunshine, insect pest management, and good soil potassium.'],
      treatment: ['None.'],
      prevention: ['Perform regular scouting for pests and spots.'],
    ),

    // CHILI
    DiseaseInfo(
      id: 'chili_leaf_curl',
      cropName: 'Chili',
      diseaseName: 'Chili Leaf Curl Virus (ChLCV)',
      description: 'A major viral disease transmitted by whiteflies that causes severe distortion of chili leaves and halts fruit production.',
      symptoms: [
        'Upward curling and puckering of leaves (cup-like shape).',
        'Stunted growth of the plant and short internodes.',
        'Leaves become small, thick, and leathery.'
      ],
      causes: [
        'Begomovirus transmitted by the silverleaf whitefly (Bemisia tabaci).',
        'Presence of alternative weed hosts nearby.'
      ],
      treatment: [
        'No direct cure for the virus; remove and burn infected plants.',
        'Control the whitefly vector using neem oil or chemical insecticides (e.g., Imidacloprid).'
      ],
      prevention: [
        'Grow chili under insect-proof nylon nets in nursery stage.',
        'Eradicate weeds around the crop boundary.',
        'Use reflective mulches to deter whiteflies.'
      ],
    ),
    DiseaseInfo(
      id: 'chili_healthy',
      cropName: 'Chili',
      diseaseName: 'Healthy Chili Leaf',
      description: 'Chili leaves are flat, green, and the plant is actively flowering or fruiting without curling.',
      symptoms: ['Smooth, flat, pointed green leaves.', 'Healthy white flowers and glossy green/red chilies.'],
      causes: ['Absence of whitefly vector, clean seedlings, and adequate micronutrients.'],
      treatment: ['None.'],
      prevention: ['Spray neem oil preventatively to ward off sucking pests.'],
    ),

    // APPLE
    DiseaseInfo(
      id: 'apple_scab',
      cropName: 'Apple',
      diseaseName: 'Apple Scab (Venturia inaequalis)',
      description: 'A fungal disease that affects apple leaves, blossoms, and fruit. It causes cosmetic damage to fruits and weakens the tree by causing defoliation.',
      symptoms: [
        'Velvety, olive-green to black spots on leaves.',
        'Spots turn brown and corky with age.',
        'Sunken, scabby brown lesions on apple fruit, causing distortion and cracking.'
      ],
      causes: [
        'Fungus Venturia inaequalis overwintering on fallen leaves.',
        'Cool, wet weather during spring leaf-out.'
      ],
      treatment: [
        'Apply fungicides (e.g., Captan or Myclobutanil) early in the season.',
        'Rake and shred or compost fallen leaves in autumn to remove spores.'
      ],
      prevention: [
        'Plant scab-resistant cultivars (like Honeycrisp, Liberty).',
        'Prune trees annually to keep the canopy open and dry.'
      ],
    ),
    DiseaseInfo(
      id: 'apple_healthy',
      cropName: 'Apple',
      diseaseName: 'Healthy Apple Leaf',
      description: 'Apple tree foliage is healthy and glossy. Fruit skins are smooth without blemishes.',
      symptoms: ['Broad, shiny green leaves with zero black spots.', 'Smooth, growing apple fruit.'],
      causes: ['Proper pruning, fungicide scheduling, and sunny dry weather.'],
      treatment: ['None.'],
      prevention: ['Rake autumn leaf litter, apply preventive lime-sulfur spray in early spring.'],
    ),

    // GRAPES
    DiseaseInfo(
      id: 'grapes_black_rot',
      cropName: 'Grapes',
      diseaseName: 'Black Rot (Guignardia bidwellii)',
      description: 'A highly destructive fungal disease of grapes that can destroy entire crops. It attacks leaves, shoots, and berries.',
      symptoms: [
        'Small, circular tan spots with dark brown margins on leaves.',
        'Tiny black dots (fruiting bodies) in the centers of spots.',
        'Grapes turn purple-black, shrivel, and dry into hard, wrinkled mummies.'
      ],
      causes: [
        'Fungus Guignardia bidwellii overwintering in mummified berries.',
        'Warm, wet weather in early spring and summer.'
      ],
      treatment: [
        'Apply copper or synthetic fungicides (Mancozeb, Myclobutanil) from pre-bloom to harvest.',
        'Remove and bury/burn all mummified berries from the vine.'
      ],
      prevention: [
        'Train vines on high trellis systems to maximize sun and air exposure.',
        'Prune wild grapevines in the vicinity.'
      ],
    ),
    DiseaseInfo(
      id: 'grapes_healthy',
      cropName: 'Grapes',
      diseaseName: 'Healthy Grapes Leaf',
      description: 'Grapevines show lush green leaves and clean, ripening grape clusters without black rot or mildew.',
      symptoms: ['Lobed green leaves with clean veins.', 'Firm, plump grapes in healthy clusters.'],
      causes: ['Good vine management, proper airflow, and fungicide compliance.'],
      treatment: ['None.'],
      prevention: ['Keep vine canopy thin to reduce humidity around grape clusters.'],
    ),
  ];
}
