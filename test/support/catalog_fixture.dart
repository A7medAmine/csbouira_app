import 'package:csbouira_app/data/models/drive_node.dart';

DriveFile driveFile(String name, String id) => DriveFile(
      name: name,
      link: 'https://drive.google.com/file/d/$id/view?usp=drivesdk',
      downloadLink: 'https://drive.google.com/uc?export=download&id=$id',
    );

DriveNode folder({
  List<DriveFile> files = const [],
  Map<String, DriveNode> subfolders = const {},
}) =>
    DriveNode(link: '', subfolders: subfolders, files: files);

/// A small tree shaped like the real Drive API response.
DriveRootData sampleRoot() => DriveRootData(
      fileCounts: const {},
      onlineResources: const {},
      years: {
        'Licence 1': folder(subfolders: {
          'S01': folder(subfolders: {
            'Analyse 1': folder(subfolders: {
              'Cours': folder(subfolders: {
                'Chapitre 01': folder(files: [
                  driveFile('01- Logique et raisonnement COURS.pdf', 'cours0000001'),
                ]),
              }),
              'Exams': folder(files: [
                driveFile('Examen Analyse 2022.pdf', 'exam00000001'),
                driveFile('Corrigé Examen 2022.pdf', 'exam00000002'),
              ]),
              'Tests': folder(files: [
                driveFile('Test 1.pdf', 'test00000001'),
              ]),
              'TDs & TPs': folder(files: [
                driveFile('TD01.pdf', 'tdtp00000001'),
              ]),
            }),
            'Algorithme': folder(subfolders: {
              'Résumé': folder(files: [
                driveFile('Résumé algorithmique.pdf', 'resu00000001'),
              ]),
            }),
          }),
          'Books & Exercices': folder(subfolders: {
            'S01': folder(subfolders: {
              'Algorithme': folder(files: [
                driveFile('Algo Exercices avec Solutions.pdf', 'book00000001'),
              ]),
            }),
          }),
        }),
      },
    );
