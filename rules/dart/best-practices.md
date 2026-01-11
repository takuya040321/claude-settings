# Dart/Flutter ベストプラクティス

## Effective Dartスタイル

### 命名規則

| 対象 | スタイル | 例 |
|------|----------|-----|
| クラス/enum/型 | UpperCamelCase | `UserService`, `HttpStatus` |
| 変数/関数/パラメータ | lowerCamelCase | `userName`, `fetchUser` |
| 定数 | lowerCamelCase | `defaultTimeout`, `maxRetries` |
| ライブラリ/パッケージ | lowercase_with_underscores | `user_service.dart` |
| プライベート | 先頭アンダースコア | `_internalMethod` |

### Null Safety

```dart
// 非null型を優先
String name = 'John';

// nullableは明示的に
String? nickname;

// late修飾子（初期化が遅延される場合）
late final UserService _service;

// null-aware演算子
final displayName = user.nickname ?? user.name;
final length = user.nickname?.length ?? 0;
```

### 型推論

```dart
// ローカル変数はvarを使用可能
var users = <User>[];
var count = 0;

// 公開APIは型を明示
List<User> getUsers() => _users;

// finalを優先（再代入不可）
final user = User(name: 'John');

// constは可能な限り使用
const defaultTimeout = Duration(seconds: 30);
```

## Flutterベストプラクティス

### Widgetの構成

```dart
// StatelessWidgetを優先
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  final User user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}
```

### constコンストラクタ

```dart
// 可能な限りconstを使用（パフォーマンス向上）
const SizedBox(height: 16);
const EdgeInsets.all(8);
const Icon(Icons.person);

// constコンストラクタを定義
class AppColors {
  const AppColors._();

  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFF03DAC6);
}
```

### BuildContextの扱い

```dart
// asyncギャップ後のcontext使用に注意
Future<void> _handleSubmit() async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  try {
    await _submitForm();
    if (!mounted) return; // StatefulWidgetの場合
    navigator.pop();
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

## State管理

### Provider/Riverpod

```dart
// Riverpod例
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(int userId) async {
    return await ref.read(userRepositoryProvider).getUser(userId);
  }

  Future<void> updateName(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await future;
      return user.copyWith(name: name);
    });
  }
}

// 使用例
class UserScreen extends ConsumerWidget {
  const UserScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider(userId));

    return userAsync.when(
      data: (user) => UserProfile(user: user),
      loading: () => const CircularProgressIndicator(),
      error: (e, s) => ErrorWidget(error: e),
    );
  }
}
```

## テスト

### Unitテスト

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserService service;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    service = UserService(repository: mockRepository);
  });

  group('UserService', () {
    test('getUser returns user when found', () async {
      final user = User(id: 1, name: 'John');
      when(() => mockRepository.getUser(1))
          .thenAnswer((_) async => user);

      final result = await service.getUser(1);

      expect(result, equals(user));
      verify(() => mockRepository.getUser(1)).called(1);
    });

    test('getUser throws when not found', () async {
      when(() => mockRepository.getUser(any()))
          .thenThrow(UserNotFoundException(1));

      expect(
        () => service.getUser(1),
        throwsA(isA<UserNotFoundException>()),
      );
    });
  });
}
```

### Widgetテスト

```dart
void main() {
  testWidgets('UserCard displays user info', (tester) async {
    final user = User(name: 'John', email: 'john@example.com');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserCard(user: user),
        ),
      ),
    );

    expect(find.text('John'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });

  testWidgets('UserCard calls onTap when pressed', (tester) async {
    var tapped = false;
    final user = User(name: 'John', email: 'john@example.com');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserCard(
            user: user,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(UserCard));
    expect(tapped, isTrue);
  });
}
```

## プロジェクト構成

```
project/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── features/
│   │   └── user/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── core/
│   │   ├── constants/
│   │   ├── extensions/
│   │   └── utils/
│   └── shared/
│       └── widgets/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## 推奨ツール

| ツール | 用途 |
|--------|------|
| dart format | コードフォーマット |
| dart analyze | 静的解析 |
| flutter_lints | Lint設定 |
| flutter_test | テスト |
| mocktail | モック |
| freezed | イミュータブルクラス |
| riverpod | State管理 |
