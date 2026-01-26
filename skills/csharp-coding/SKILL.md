---
name: csharp-coding
description: C#コーディングのベストプラクティスとコード品質保証。C#ファイルの作成・編集タスクを完了した際に使用。コーディングタスク終了後にdotnet format → dotnet buildでフォーマット・ビルドチェックを実行し、すべてのチェックに合格するまで修正を繰り返す。
---

# C# Coding

C#コーディングのベストプラクティスとコード品質保証を提供する。

## 必須ワークフロー

C#コーディングタスク完了時、必ず以下を実行：

```bash
~/.claude/skills/csharp-coding/scripts/check.sh <プロジェクトディレクトリ>
```

**重要**: エラーが検出された場合、すべてのエラーを修正し、チェックに合格するまでスクリプトを再実行すること。

## コーディング規約

### 命名規則

| 対象 | スタイル | 例 |
|------|----------|-----|
| クラス | PascalCase | `UserService` |
| インターフェース | I + PascalCase | `IUserRepository` |
| メソッド | PascalCase | `GetUserById` |
| プロパティ | PascalCase | `FirstName` |
| ローカル変数 | camelCase | `userName` |
| パラメータ | camelCase | `userId` |
| プライベートフィールド | _camelCase | `_userRepository` |
| 定数 | PascalCase | `MaxRetryCount` |
| 列挙値 | PascalCase | `UserStatus.Active` |

### nullability

null許容参照型を有効にし、適切に使用する。

```csharp
// プロジェクトで有効化（.csproj）
<Nullable>enable</Nullable>

// 使用例
public class UserService
{
    private readonly IUserRepository _repository;

    public User? GetUserById(int id)
    {
        return _repository.Find(id);
    }

    public User GetUserByIdOrThrow(int id)
    {
        return _repository.Find(id)
            ?? throw new NotFoundException($"User not found: {id}");
    }
}
```

### XMLドキュメントコメント

パブリックAPIには必須。

```csharp
/// <summary>
/// ユーザー情報を取得する。
/// </summary>
/// <param name="userId">ユーザーの一意識別子。</param>
/// <param name="includeDeleted">削除済みユーザーも含める場合はtrue。</param>
/// <returns>ユーザーオブジェクト。見つからない場合はnull。</returns>
/// <exception cref="ArgumentException">userIdが0以下の場合。</exception>
public User? GetUser(int userId, bool includeDeleted = false)
{
    if (userId <= 0)
        throw new ArgumentException("User ID must be positive", nameof(userId));

    // ...
}
```

### プロパティ

```csharp
// 自動実装プロパティ（推奨）
public string Name { get; set; }

// init-only プロパティ（不変オブジェクト用）
public string Id { get; init; }

// 必須プロパティ（C# 11+）
public required string Email { get; init; }

// 計算プロパティ
public string FullName => $"{FirstName} {LastName}";
```

### record型の活用

イミュータブルなデータ転送オブジェクトに使用。

```csharp
// シンプルなDTO
public record UserDto(int Id, string Name, string Email);

// プロパティ付き
public record CreateUserRequest
{
    public required string Name { get; init; }
    public required string Email { get; init; }
    public string? PhoneNumber { get; init; }
}
```

### LINQ

```csharp
// メソッド構文（推奨）
var activeUsers = users
    .Where(u => u.IsActive)
    .OrderBy(u => u.Name)
    .Select(u => new UserDto(u.Id, u.Name, u.Email))
    .ToList();

// クエリ構文（複雑なjoinに有用）
var result = from u in users
             join o in orders on u.Id equals o.UserId
             where u.IsActive
             select new { u.Name, o.OrderDate };
```

### 非同期プログラミング

```csharp
// async/await パターン
public async Task<User?> GetUserAsync(int id, CancellationToken cancellationToken = default)
{
    return await _repository.FindAsync(id, cancellationToken);
}

// 複数タスクの並列実行
public async Task<(User user, IList<Order> orders)> GetUserWithOrdersAsync(int userId)
{
    var userTask = _userRepository.FindAsync(userId);
    var ordersTask = _orderRepository.GetByUserIdAsync(userId);

    await Task.WhenAll(userTask, ordersTask);

    return (await userTask, await ordersTask);
}
```

### パターンマッチング

```csharp
// switch式
string GetStatusMessage(UserStatus status) => status switch
{
    UserStatus.Active => "アクティブ",
    UserStatus.Inactive => "非アクティブ",
    UserStatus.Banned => "停止中",
    _ => "不明"
};

// is パターン
if (result is { Success: true, Data: var data })
{
    ProcessData(data);
}

// リストパターン（C# 11+）
if (numbers is [var first, .., var last])
{
    Console.WriteLine($"First: {first}, Last: {last}");
}
```

## エラーハンドリング

```csharp
// 具体的な例外をキャッチ
try
{
    await ProcessAsync();
}
catch (HttpRequestException ex)
{
    _logger.LogWarning(ex, "HTTP request failed");
    throw;
}
catch (OperationCanceledException)
{
    _logger.LogInformation("Operation was cancelled");
    throw;
}

// カスタム例外
public class UserNotFoundException : Exception
{
    public int UserId { get; }

    public UserNotFoundException(int userId)
        : base($"User not found: {userId}")
    {
        UserId = userId;
    }
}
```

## 依存性注入

```csharp
// インターフェースを使用
public interface IUserRepository
{
    Task<User?> FindAsync(int id);
    Task<User> AddAsync(User user);
}

// コンストラクタインジェクション
public class UserService
{
    private readonly IUserRepository _repository;
    private readonly ILogger<UserService> _logger;

    public UserService(IUserRepository repository, ILogger<UserService> logger)
    {
        _repository = repository;
        _logger = logger;
    }
}

// Primary Constructor（C# 12+）
public class UserService(IUserRepository repository, ILogger<UserService> logger)
{
    public async Task<User?> GetUserAsync(int id)
        => await repository.FindAsync(id);
}
```

## プロジェクト構成

```
MyApp/
├── MyApp.csproj
├── Program.cs
├── Models/
│   ├── User.cs
│   └── Order.cs
├── Services/
│   ├── IUserService.cs
│   └── UserService.cs
├── Repositories/
│   ├── IUserRepository.cs
│   └── UserRepository.cs
└── Exceptions/
    └── NotFoundException.cs
```

## .csproj 推奨設定

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
  </PropertyGroup>
</Project>
```

## チェックツール

| ツール | 用途 |
|--------|------|
| dotnet format | コードフォーマット |
| dotnet build | コンパイル・エラーチェック |
| Roslyn Analyzers | 静的解析 |
