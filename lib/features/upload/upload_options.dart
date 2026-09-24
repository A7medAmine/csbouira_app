/// Choices offered by the upload form: grades, semesters, modules and
/// categories, plus the short names used in uploaded file names.
library;

const uploadGrades = [
  'Licence 1',
  'Licence 2',
  'Licence 3 SI',
  'Master 1 GSI',
  'Master 1 ISIL',
  'Master 1 IA',
  'Master 2 GSI',
  'Master 2 ISIL',
  'Master 2 IA',
];

const uploadGradeShortcuts = {
  'Licence 1': 'L1',
  'Licence 2': 'L2',
  'Licence 3 SI': 'L3 SI',
  'Master 1 GSI': 'M1 GSI',
  'Master 1 ISIL': 'M1 ISIL',
  'Master 1 IA': 'M1 IA',
  'Master 2 GSI': 'M2 GSI',
  'Master 2 ISIL': 'M2 ISIL',
  'Master 2 IA': 'M2 IA',
};

const uploadModuleShortcuts = {
  'Algèbre 1': 'ALG1',
  'Algorithmique Et Structure De Données 1': 'ASD1',
  'Analyse 1': 'ANA1',
  'Anglais 1': 'ANG1',
  'Physique 1': 'PHY1',
  'Structure Machine 1': 'SM1',
  'Terminologie Scientifique': 'TS',
  // 'Doc Scanner Testing': 'DST',
  'Algèbre 2': 'ALG2',
  'Algorithmique Et Structure De Données 2': 'ASD2',
  'Analyse 2': 'ANA2',
  'Outils De Programmation Pour Les Mathématiques': 'OPM',
  'Physique 2': 'PHY2',
  'Probabilités Et Statistique Descriptive': 'PSD',
  'Structure Machine 2': 'SM2',
  "Technologie De L'Information Et De La Communication": 'TIC',
  'Algorithmique Et Structure De Données 3': 'ASD3',
  'Anglais 3': 'ANG3',
  'Architecture Des Ordinateurs': 'AO',
  'Logique Mathématique': 'LM',
  'Méthodes Numériques': 'MN',
  "Systèmes D'Information": 'SI',
  'Theorie Des Graphes': 'TG',
  'Anglais 4': 'ANG4',
  'Base De Donnees': 'BD',
  "Developpement D'applications Web": 'DAW',
  'Programmation Orienté Objet': 'POO',
  'Reseaux': 'RES',
  "Système D'exploitation 1": 'SE1',
  'Theorie Des Langages': 'TL',
  'Compilation': 'COMP',
  'Economie numérique et veille stratégique': 'ENVS',
  'Génie Logiciel': 'GL',
  'IHM': 'IHM',
  'Probabilités': 'PROBA',
  'Programmation Linéaire': 'PL',
  "Systèmes d'exploitation 2": 'SE2',
  'Application Mobile': 'AM',
  'Créer Une Startup': 'CUS',
  'Données Semi Structurées': 'DSS',
  'Intelligence Artificielle': 'IA',
  'Rédaction Scientifique': 'RS',
  'Sécurité Informatique': 'SECI',
  'Algorithmique avancée et complexité': 'AAC',
  'Architecture et administration des bases de données': 'AABD',
  'Architectures modernes des systèmes informatiques': 'AMSI',
  'Cloud computing': 'CC',
  'Implementation Methods and technologies': 'IMT',
  'Réseaux des couches basses': 'RCB',
  "Systèmes d'exploitation": 'SE',
  'Systèmes de communication vocaux et vidéos': 'SCVV',
  'Cybercriminalité': 'CYBER',
  "Gestion de l'incertain": 'GI',
  'Inforgraphie': 'INFO',
  'Internet of Things': 'IoT',
  'Les Middlewares pour les systèmes répartis': 'MSR',
  'Les réseaux IP': 'RIP',
  'Machine learning': 'ML',
  'Modélisation et Architectures logicielles': 'MAL',
  'Analyse de données': 'AD',
  'Bases de données avancées': 'BDA',
  "Fondements de l'intelligence artificielle": 'FIA',
  'Introduction au Machine Learning': 'IML',
  'Introduction au traitement automatique des langues naturelles': 'ITALN',
  'Modélisation et architectures logicielles': 'MAL',
  "Systèmes d'Information géographiques": 'SIG',
  'Algorithmique Avancée et Complexité': 'AAC',
  'Base de Données Avancées': 'BDA',
  "Méthodes d'optimisation": 'MO',
  'Représentation des connaissances': 'RC',
  'Réseaux Avancés': 'RA',
  'Technologies Émergentes': 'TE',
  'Computer Vision': 'CV',
  'Deep Learning': 'DL',
  "Gestion de l'Incertain": 'GI',
  'Gestion de projets informatiques': 'GPI',
  'Modélisation et simulation': 'MS',
  'Systèmes Multi Agents': 'SMA',
  'Virtualisation et Cloud': 'VC',
  'Big Data': 'BIGD',
  'Blockchain': 'BLOCK',
  'Computational Intelligence': 'CINT',
  'Evaluation de performances': 'EP',
  'Methodolohie de recherche et de documentation': 'MRD',
  'Mobile Networks': 'MNET',
  'System On Chip': 'SOC',
  'Introduction aux ERP': 'ERP',
  'Méthodologie de recherche et de documentation': 'MRD',
  'Ontologie et sémantique web': 'OSW',
  'Programmation pour le Big data': 'PBD',
  "Sécurité des systèmes d'information": 'SSI',
  "Systèmes d'Information Coopératifs": 'SIC',
  'Systèmes décisionnels et entrepôt de données': 'SDED',
  'Application de Deep Learning': 'ADL',
  'Calcul intensif': 'CALC',
  'Modèles stochastiques pour la simulation': 'MSS',
  'Programmation pour le Big Data': 'PBD',
  'Robotique': 'ROBO',
  'Vision artificielle': 'VA',
};

const uploadSemestersByGrade = {
  'Licence 1': ['S01', 'S02'],
  'Licence 2': ['S03', 'S04'],
  'Licence 3 SI': ['S05', 'S06'],
  'Master 1 GSI': ['S07', 'S08'],
  'Master 1 ISIL': ['S07', 'S08'],
  'Master 1 IA': ['S07', 'S08'],
  'Master 2 GSI': ['S09'],
  'Master 2 ISIL': ['S09'],
  'Master 2 IA': ['S09'],
};

const uploadModulesByGradeSemester = {
  'Licence 1': {
    'S01': [
      'Algèbre 1',
      'Algorithmique Et Structure De Données 1',
      'Analyse 1',
      'Anglais 1',
      'Physique 1',
      'Structure Machine 1',
      'Terminologie Scientifique'
      // 'Doc Scanner Testing'
    ],
    'S02': [
      'Algèbre 2',
      'Algorithmique Et Structure De Données 2',
      'Analyse 2',
      'Outils De Programmation Pour Les Mathématiques',
      'Physique 2',
      'Probabilités Et Statistique Descriptive',
      'Structure Machine 2',
      "Technologie De L'Information Et De La Communication"
    ]
  },
  'Licence 2': {
    'S03': [
      'Algorithmique Et Structure De Données 3',
      'Anglais 3',
      'Architecture Des Ordinateurs',
      'Logique Mathématique',
      'Méthodes Numériques',
      "Systèmes D'Information",
      'Theorie Des Graphes'
    ],
    'S04': [
      'Anglais 4',
      'Base De Donnees',
      "Developpement D'applications Web",
      'Programmation Orienté Objet',
      'Reseaux',
      "Système D'exploitation 1",
      'Theorie Des Langages'
    ]
  },
  'Licence 3 SI': {
    'S05': [
      'Compilation',
      'Economie numérique et veille stratégique',
      'Génie Logiciel',
      'IHM',
      'Probabilités',
      'Programmation Linéaire',
      "Systèmes d'exploitation 2"
    ],
    'S06': [
      'Application Mobile',
      'Créer Une Startup',
      'Données Semi Structurées',
      'Intelligence Artificielle',
      'Rédaction Scientifique',
      'Sécurité Informatique'
    ]
  },
  'Master 1 GSI': {
    'S07': [
      'Algorithmique avancée et complexité',
      'Architecture et administration des bases de données',
      'Architectures modernes des systèmes informatiques',
      'Cloud computing',
      'Implementation Methods and technologies',
      'Réseaux des couches basses',
      "Systèmes d'exploitation",
      'Systèmes de communication vocaux et vidéos'
    ],
    'S08': [
      'Cybercriminalité',
      "Gestion de l'incertain",
      'Inforgraphie',
      'Internet of Things',
      'Les Middlewares pour les systèmes répartis',
      'Les réseaux IP',
      'Machine learning',
      'Modélisation et Architectures logicielles'
    ]
  },
  'Master 1 ISIL': {
    'S08': [
      'Analyse de données',
      'Bases de données avancées',
      'Cybercriminalité',
      "Fondements de l'intelligence artificielle",
      'Introduction au Machine Learning',
      'Introduction au traitement automatique des langues naturelles',
      'Modélisation et architectures logicielles',
      'Systèmes d\'Information géographiques'
    ]
  },
  'Master 1 IA': {
    'S07': [
      'Algorithmique Avancée et Complexité',
      'Analyse de données',
      'Base de Données Avancées',
      'Machine Learning',
      "Méthodes d'optimisation",
      'Représentation des connaissances',
      'Réseaux Avancés',
      'Technologies Émergentes'
    ],
    'S08': [
      'Computer Vision',
      'Cybercriminalité',
      'Deep Learning',
      'Gestion de l\'Incertain',
      'Gestion de projets informatiques',
      'Modélisation et simulation',
      'Systèmes Multi Agents',
      'Virtualisation et Cloud'
    ]
  },
  'Master 2 GSI': {
    'S09': [
      'Big Data',
      'Blockchain',
      'Computational Intelligence',
      'Deep Learning',
      'Evaluation de performances',
      'Methodolohie de recherche et de documentation',
      'Mobile Networks',
      'System On Chip'
    ]
  },
  'Master 2 ISIL': {
    'S09': [
      'Deep Learning',
      'Introduction aux ERP',
      'Méthodologie de recherche et de documentation',
      'Ontologie et sémantique web',
      'Programmation pour le Big data',
      "Sécurité des systèmes d'information",
      'Systèmes d\'Information Coopératifs',
      'Systèmes décisionnels et entrepôt de données'
    ]
  },
  'Master 2 IA': {
    'S09': [
      'Application de Deep Learning',
      'Calcul intensif',
      "Méthodes d'optimisation",
      'Modèles stochastiques pour la simulation',
      'Programmation pour le Big Data',
      'Robotique',
      'Vision artificielle'
    ]
  }
};

const uploadCategories = ['Cours', 'Summary', 'TP', 'TD', 'Test', 'Exam', 'Other'];
