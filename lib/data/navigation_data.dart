import 'package:flutter/material.dart';

class YearInfo {
  final String name;
  final String level;
  final String? badge;
  final IconData? icon;
  final int colSpan;

  const YearInfo({
    required this.name,
    required this.level,
    this.badge,
    this.icon,
    this.colSpan = 1,
  });
}

const kYears = [
  YearInfo(name: 'Licence 1', level: 'Bachelor', colSpan: 1),
  YearInfo(name: 'Licence 2', level: 'Bachelor', colSpan: 1),
  YearInfo(name: 'Licence 3 SI', level: 'Bachelor Final Year', badge: 'CORE', colSpan: 2),
  YearInfo(name: 'Master 1 GSI', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 1 ISIL', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 1 IA', level: 'Master', badge: 'NEW', icon: Icons.psychology, colSpan: 2),
  YearInfo(name: 'Master 2 GSI', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 2 ISIL', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 2 IA', level: 'Master', colSpan: 1),
];

const kSemesters = {
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

const kFolderTypes = ['Cours', 'Exams', 'Résumé', 'TDs & TPs', 'Tests'];
