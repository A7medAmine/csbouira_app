import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/data/models/downloaded_file.dart';
import 'package:csbouira_app/data/models/drive_node.dart';
import 'package:csbouira_app/data/providers/module_pack_provider.dart';
import 'package:csbouira_app/data/services/download_service.dart';

import '../../support/catalog_fixture.dart';

/// Records downloads instead of hitting the network. Files whose name
/// contains "fail" throw.
class FakeDownloadService extends DownloadService {
  final downloaded = <String>[];
  Completer<void>? gate;

  @override
  Future<DownloadedFile> downloadFile(DriveFile file) async {
    await gate?.future;
    if (file.name.contains('fail')) throw const DownloadException('boom');
    downloaded.add(file.name);
    return DownloadedFile(
      fileName: file.name,
      localPath: '/tmp/${file.name}',
      driveLink: file.link,
      downloadedAt: DateTime(2026),
    );
  }
}

void main() {
  late FakeDownloadService service;
  late ProviderContainer container;

  setUp(() {
    service = FakeDownloadService();
    container = ProviderContainer(overrides: [
      downloadServiceProvider.overrideWithValue(service),
    ]);
  });

  tearDown(() => container.dispose());

  ModulePackNotifier notifier() => container.read(modulePackProvider.notifier);
  ModulePackState state() => container.read(modulePackProvider);

  test('downloads every file and counts failures', () async {
    await notifier().start(
      label: 'Analyse 1',
      moduleKey: 'L1>S01>Analyse 1',
      files: [
        driveFile('a.pdf', 'aaaaaaaaaaaa'),
        driveFile('fail.pdf', 'bbbbbbbbbbbb'),
        driveFile('c.pdf', 'cccccccccccc'),
      ],
    );
    expect(service.downloaded, ['a.pdf', 'c.pdf']);
    expect(state().status, ModulePackStatus.done);
    expect(state().completed, 2);
    expect(state().failed, 1);
    expect(state().progress, 1.0);
  });

  test('cancel stops after the current file', () async {
    service.gate = Completer<void>();
    final job = notifier().start(
      label: 'x',
      moduleKey: 'k',
      files: [
        driveFile('a.pdf', 'aaaaaaaaaaaa'),
        driveFile('b.pdf', 'bbbbbbbbbbbb'),
      ],
    );
    expect(state().isRunning, isTrue);
    notifier().cancel();
    service.gate!.complete();
    await job;
    expect(service.downloaded, ['a.pdf']);
    expect(state().status, ModulePackStatus.cancelled);
  });

  test('ignores a second job while one is running, dismiss resets', () async {
    service.gate = Completer<void>();
    final job = notifier().start(
      label: 'first',
      moduleKey: 'k1',
      files: [driveFile('a.pdf', 'aaaaaaaaaaaa')],
    );
    await notifier().start(
      label: 'second',
      moduleKey: 'k2',
      files: [driveFile('b.pdf', 'bbbbbbbbbbbb')],
    );
    notifier().dismiss(); // no-op while running
    expect(state().label, 'first');
    service.gate!.complete();
    await job;
    notifier().dismiss();
    expect(state().status, ModulePackStatus.idle);
  });
}
