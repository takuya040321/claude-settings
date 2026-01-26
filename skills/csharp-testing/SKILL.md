---
name: csharp-testing
description: C#テストのベストプラクティスとテスト実行。xUnitを使ったテストの作成・実行ガイド。テストを書く必要がある場合、テストを実行する場合、またはテスト関連の質問がある場合に使用。
---

# C# Testing

xUnitを使用したC#テストのベストプラクティスと実行方法を提供する。

## テスト実行

```bash
# 基本実行
~/.claude/skills/csharp-testing/scripts/run_tests.sh

# 特定プロジェクトのテスト
~/.claude/skills/csharp-testing/scripts/run_tests.sh tests/MyApp.Tests/

# カバレッジレポート付き
~/.claude/skills/csharp-testing/scripts/run_tests.sh --coverage
```

### dotnet test コマンド直接実行

```bash
# 基本
dotnet test

# 詳細出力
dotnet test --verbosity normal

# 特定のテストプロジェクト
dotnet test tests/MyApp.Tests/

# 特定のテストを実行（フィルタ）
dotnet test --filter "FullyQualifiedName~UserServiceTests"
dotnet test --filter "Category=Unit"

# 失敗時に停止しない
dotnet test --no-fail-on-no-tests

# 並列実行の制御
dotnet test -- xunit.parallelizeTestCollections=false
```

## テストの書き方

### 基本構造

```csharp
using Xunit;

namespace MyApp.Tests;

public class UserServiceTests
{
    private readonly UserService _sut; // System Under Test

    public UserServiceTests()
    {
        _sut = new UserService();
    }

    [Fact]
    public void CreateUser_WithValidEmail_ReturnsUser()
    {
        // Arrange
        var email = "test@example.com";

        // Act
        var result = _sut.CreateUser(email);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(email, result.Email);
    }

    [Fact]
    public void CreateUser_WithInvalidEmail_ThrowsArgumentException()
    {
        // Arrange
        var invalidEmail = "invalid-email";

        // Act & Assert
        var exception = Assert.Throws<ArgumentException>(() =>
            _sut.CreateUser(invalidEmail));

        Assert.Contains("Invalid email", exception.Message);
    }
}
```

### Theory（パラメータ化テスト）

```csharp
public class EmailValidatorTests
{
    [Theory]
    [InlineData("user@example.com", true)]
    [InlineData("invalid", false)]
    [InlineData("", false)]
    [InlineData("user@", false)]
    public void IsValidEmail_ReturnsExpectedResult(string email, bool expected)
    {
        var result = EmailValidator.IsValid(email);
        Assert.Equal(expected, result);
    }

    [Theory]
    [MemberData(nameof(GetTestData))]
    public void Process_WithTestData_ReturnsExpected(TestCase testCase)
    {
        var result = _sut.Process(testCase.Input);
        Assert.Equal(testCase.Expected, result);
    }

    public static IEnumerable<object[]> GetTestData()
    {
        yield return new object[] { new TestCase("a", "A") };
        yield return new object[] { new TestCase("b", "B") };
    }
}
```

### ClassData（複雑なテストデータ）

```csharp
public class UserTestData : IEnumerable<object[]>
{
    public IEnumerator<object[]> GetEnumerator()
    {
        yield return new object[] { new User("John", 25), true };
        yield return new object[] { new User("", 25), false };
        yield return new object[] { new User("John", -1), false };
    }

    IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();
}

public class UserValidatorTests
{
    [Theory]
    [ClassData(typeof(UserTestData))]
    public void Validate_ReturnsExpected(User user, bool expected)
    {
        var result = UserValidator.IsValid(user);
        Assert.Equal(expected, result);
    }
}
```

### Fixture（共有セットアップ）

```csharp
// テストクラス間で共有
public class DatabaseFixture : IDisposable
{
    public DbConnection Connection { get; }

    public DatabaseFixture()
    {
        Connection = new SqliteConnection("DataSource=:memory:");
        Connection.Open();
        // データベースのセットアップ
    }

    public void Dispose()
    {
        Connection.Close();
    }
}

[CollectionDefinition("Database")]
public class DatabaseCollection : ICollectionFixture<DatabaseFixture>
{
}

[Collection("Database")]
public class UserRepositoryTests
{
    private readonly DatabaseFixture _fixture;

    public UserRepositoryTests(DatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public void GetUser_ReturnsUser()
    {
        // _fixture.Connection を使用
    }
}
```

### IAsyncLifetime（非同期セットアップ）

```csharp
public class ApiIntegrationTests : IAsyncLifetime
{
    private HttpClient _client = null!;

    public async Task InitializeAsync()
    {
        _client = new HttpClient();
        await WarmUpApiAsync();
    }

    public async Task DisposeAsync()
    {
        _client.Dispose();
        await CleanupAsync();
    }

    [Fact]
    public async Task GetUsers_ReturnsSuccess()
    {
        var response = await _client.GetAsync("/api/users");
        Assert.True(response.IsSuccessStatusCode);
    }
}
```

### Moq（モック）

```csharp
using Moq;

public class UserServiceTests
{
    private readonly Mock<IUserRepository> _repositoryMock;
    private readonly Mock<ILogger<UserService>> _loggerMock;
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _repositoryMock = new Mock<IUserRepository>();
        _loggerMock = new Mock<ILogger<UserService>>();
        _sut = new UserService(_repositoryMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task GetUserAsync_WhenUserExists_ReturnsUser()
    {
        // Arrange
        var expectedUser = new User { Id = 1, Name = "John" };
        _repositoryMock
            .Setup(r => r.FindAsync(1))
            .ReturnsAsync(expectedUser);

        // Act
        var result = await _sut.GetUserAsync(1);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("John", result.Name);
        _repositoryMock.Verify(r => r.FindAsync(1), Times.Once);
    }

    [Fact]
    public async Task GetUserAsync_WhenUserNotFound_ReturnsNull()
    {
        // Arrange
        _repositoryMock
            .Setup(r => r.FindAsync(It.IsAny<int>()))
            .ReturnsAsync((User?)null);

        // Act
        var result = await _sut.GetUserAsync(999);

        // Assert
        Assert.Null(result);
    }

    [Fact]
    public async Task CreateUserAsync_CallsRepositoryWithCorrectData()
    {
        // Arrange
        var request = new CreateUserRequest { Name = "John", Email = "john@example.com" };

        _repositoryMock
            .Setup(r => r.AddAsync(It.IsAny<User>()))
            .ReturnsAsync((User u) => u);

        // Act
        await _sut.CreateUserAsync(request);

        // Assert
        _repositoryMock.Verify(r => r.AddAsync(
            It.Is<User>(u => u.Name == "John" && u.Email == "john@example.com")),
            Times.Once);
    }
}
```

### 例外テスト

```csharp
[Fact]
public void Divide_ByZero_ThrowsDivideByZeroException()
{
    Assert.Throws<DivideByZeroException>(() => Calculator.Divide(10, 0));
}

[Fact]
public async Task GetUserAsync_WithNegativeId_ThrowsArgumentException()
{
    await Assert.ThrowsAsync<ArgumentException>(
        () => _sut.GetUserAsync(-1));
}

[Fact]
public void Process_WithInvalidInput_ThrowsWithMessage()
{
    var exception = Assert.Throws<ValidationException>(
        () => _sut.Process(null!));

    Assert.Contains("cannot be null", exception.Message);
}
```

## テストファイル配置

```
MyApp/
├── src/
│   └── MyApp/
│       ├── MyApp.csproj
│       ├── Models/
│       │   └── User.cs
│       └── Services/
│           ├── IUserService.cs
│           └── UserService.cs
└── tests/
    └── MyApp.Tests/
        ├── MyApp.Tests.csproj
        ├── GlobalUsings.cs
        ├── Fixtures/
        │   └── DatabaseFixture.cs
        ├── Unit/
        │   └── Services/
        │       └── UserServiceTests.cs
        └── Integration/
            └── Api/
                └── UsersEndpointTests.cs
```

### GlobalUsings.cs

```csharp
// tests/MyApp.Tests/GlobalUsings.cs
global using Xunit;
global using Moq;
global using FluentAssertions; // オプション
```

## テスト命名規則

```
メソッド名_条件_期待結果
```

例：
- `GetUser_WhenUserExists_ReturnsUser`
- `CreateUser_WithInvalidEmail_ThrowsArgumentException`
- `Calculate_WithNegativeNumbers_ReturnsZero`

## カテゴリ分け

```csharp
[Trait("Category", "Unit")]
public class UnitTests { }

[Trait("Category", "Integration")]
public class IntegrationTests { }

// 実行時にフィルタ
// dotnet test --filter "Category=Unit"
```

## テストプロジェクト設定

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.*" />
    <PackageReference Include="xunit" Version="2.*" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.*">
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="coverlet.collector" Version="6.*">
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="Moq" Version="4.*" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\src\MyApp\MyApp.csproj" />
  </ItemGroup>
</Project>
```

## 推奨ツール

| ツール | 用途 |
|--------|------|
| xunit | テストフレームワーク |
| Moq | モックライブラリ |
| coverlet | カバレッジ計測 |
| FluentAssertions | 読みやすいアサーション |
| Bogus | テストデータ生成 |
| WireMock.Net | HTTPモック |
