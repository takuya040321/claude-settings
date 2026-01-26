---
name: csharp-aspnet-webapi
description: ASP.NET Core WebAPIの基本的なCRUD開発ガイド。コントローラー設計、ルーティング、依存性注入（DI）、ミドルウェア設定をカバー。ユーザーが「WebAPIを作成して」「CRUDエンドポイントを実装して」「コントローラーを追加して」などと依頼した場合にトリガー。
---

# ASP.NET Core WebAPI

ASP.NET Core を使用した REST API 開発のベストプラクティスガイド。

## プロジェクト作成

```bash
# 新規WebAPIプロジェクト作成
~/.claude/skills/csharp-environment/scripts/init_project.sh webapi myapi
```

## Program.cs（Minimal API 構成）

```csharp
var builder = WebApplication.CreateBuilder(args);

// サービス登録
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// カスタムサービス
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

var app = builder.Build();

// ミドルウェア
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

## コントローラー設計

### 基本的なCRUDコントローラー

```csharp
using Microsoft.AspNetCore.Mvc;

namespace MyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserService userService, ILogger<UsersController> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    /// <summary>
    /// ユーザー一覧を取得
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<UserDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<UserDto>>> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var users = await _userService.GetAllAsync(page, pageSize);
        return Ok(users);
    }

    /// <summary>
    /// 指定IDのユーザーを取得
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserDto>> GetById(int id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user is null)
        {
            return NotFound();
        }
        return Ok(user);
    }

    /// <summary>
    /// 新規ユーザーを作成
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<UserDto>> Create([FromBody] CreateUserRequest request)
    {
        var user = await _userService.CreateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
    }

    /// <summary>
    /// ユーザー情報を更新
    /// </summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<UserDto>> Update(int id, [FromBody] UpdateUserRequest request)
    {
        var user = await _userService.UpdateAsync(id, request);
        if (user is null)
        {
            return NotFound();
        }
        return Ok(user);
    }

    /// <summary>
    /// ユーザーを削除
    /// </summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _userService.DeleteAsync(id);
        if (!deleted)
        {
            return NotFound();
        }
        return NoContent();
    }
}
```

## モデル / DTO

### リクエスト / レスポンス モデル

```csharp
namespace MyApi.Models;

// レスポンスDTO
public record UserDto(int Id, string Name, string Email, DateTime CreatedAt);

// 作成リクエスト
public record CreateUserRequest
{
    public required string Name { get; init; }
    public required string Email { get; init; }
    public string? PhoneNumber { get; init; }
}

// 更新リクエスト
public record UpdateUserRequest
{
    public string? Name { get; init; }
    public string? Email { get; init; }
    public string? PhoneNumber { get; init; }
}

// ページネーション
public record PagedResult<T>(
    IEnumerable<T> Items,
    int TotalCount,
    int Page,
    int PageSize)
{
    public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
    public bool HasNextPage => Page < TotalPages;
    public bool HasPreviousPage => Page > 1;
}
```

### エンティティ

```csharp
namespace MyApi.Entities;

public class User
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public required string Email { get; set; }
    public string? PhoneNumber { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
```

## サービス層

```csharp
namespace MyApi.Services;

public interface IUserService
{
    Task<IEnumerable<UserDto>> GetAllAsync(int page, int pageSize);
    Task<UserDto?> GetByIdAsync(int id);
    Task<UserDto> CreateAsync(CreateUserRequest request);
    Task<UserDto?> UpdateAsync(int id, UpdateUserRequest request);
    Task<bool> DeleteAsync(int id);
}

public class UserService : IUserService
{
    private readonly IUserRepository _repository;
    private readonly ILogger<UserService> _logger;

    public UserService(IUserRepository repository, ILogger<UserService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<IEnumerable<UserDto>> GetAllAsync(int page, int pageSize)
    {
        var users = await _repository.GetAllAsync(page, pageSize);
        return users.Select(MapToDto);
    }

    public async Task<UserDto?> GetByIdAsync(int id)
    {
        var user = await _repository.FindAsync(id);
        return user is null ? null : MapToDto(user);
    }

    public async Task<UserDto> CreateAsync(CreateUserRequest request)
    {
        var user = new User
        {
            Name = request.Name,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            CreatedAt = DateTime.UtcNow
        };

        var created = await _repository.AddAsync(user);
        _logger.LogInformation("User created: {UserId}", created.Id);

        return MapToDto(created);
    }

    public async Task<UserDto?> UpdateAsync(int id, UpdateUserRequest request)
    {
        var user = await _repository.FindAsync(id);
        if (user is null)
        {
            return null;
        }

        if (request.Name is not null) user.Name = request.Name;
        if (request.Email is not null) user.Email = request.Email;
        if (request.PhoneNumber is not null) user.PhoneNumber = request.PhoneNumber;
        user.UpdatedAt = DateTime.UtcNow;

        var updated = await _repository.UpdateAsync(user);
        return MapToDto(updated);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }

    private static UserDto MapToDto(User user) =>
        new(user.Id, user.Name, user.Email, user.CreatedAt);
}
```

## 依存性注入（DI）

### サービス登録

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// スコープ（リクエストごと）
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

// シングルトン（アプリ全体で1つ）
builder.Services.AddSingleton<ICacheService, MemoryCacheService>();

// トランジェント（毎回新規インスタンス）
builder.Services.AddTransient<IEmailSender, SmtpEmailSender>();

// DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

// HttpClient
builder.Services.AddHttpClient<IExternalApiClient, ExternalApiClient>(client =>
{
    client.BaseAddress = new Uri("https://api.example.com");
    client.Timeout = TimeSpan.FromSeconds(30);
});
```

### オプションパターン

```csharp
// 設定クラス
public class JwtSettings
{
    public required string Secret { get; init; }
    public int ExpirationMinutes { get; init; } = 60;
}

// Program.cs
builder.Services.Configure<JwtSettings>(
    builder.Configuration.GetSection("Jwt"));

// 使用側
public class AuthService
{
    private readonly JwtSettings _settings;

    public AuthService(IOptions<JwtSettings> options)
    {
        _settings = options.Value;
    }
}
```

## ミドルウェア

### カスタムミドルウェア

```csharp
// RequestLoggingMiddleware.cs
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var start = DateTime.UtcNow;

        try
        {
            await _next(context);
        }
        finally
        {
            var elapsed = DateTime.UtcNow - start;
            _logger.LogInformation(
                "{Method} {Path} {StatusCode} {ElapsedMs}ms",
                context.Request.Method,
                context.Request.Path,
                context.Response.StatusCode,
                elapsed.TotalMilliseconds);
        }
    }
}

// 拡張メソッド
public static class MiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder app)
    {
        return app.UseMiddleware<RequestLoggingMiddleware>();
    }
}

// Program.cs
app.UseRequestLogging();
```

### 例外ハンドリングミドルウェア

```csharp
public class GlobalExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (NotFoundException ex)
        {
            context.Response.StatusCode = StatusCodes.Status404NotFound;
            await context.Response.WriteAsJsonAsync(new { error = ex.Message });
        }
        catch (ValidationException ex)
        {
            context.Response.StatusCode = StatusCodes.Status400BadRequest;
            await context.Response.WriteAsJsonAsync(new { errors = ex.Errors });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception");
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await context.Response.WriteAsJsonAsync(new { error = "Internal server error" });
        }
    }
}
```

## ルーティング

### 属性ルーティング

```csharp
[ApiController]
[Route("api/v1/[controller]")]  // api/v1/users
public class UsersController : ControllerBase
{
    [HttpGet]                           // GET api/v1/users
    [HttpGet("{id:int}")]              // GET api/v1/users/5
    [HttpGet("by-email/{email}")]      // GET api/v1/users/by-email/test@example.com
    [HttpPost]                          // POST api/v1/users
    [HttpPut("{id:int}")]              // PUT api/v1/users/5
    [HttpDelete("{id:int}")]           // DELETE api/v1/users/5
    [HttpGet("{id:int}/orders")]       // GET api/v1/users/5/orders
}
```

### ルート制約

```csharp
[HttpGet("{id:int}")]           // 整数のみ
[HttpGet("{id:guid}")]          // GUIDのみ
[HttpGet("{name:alpha}")]       // アルファベットのみ
[HttpGet("{name:minlength(3)}")] // 3文字以上
[HttpGet("{name:regex(^[a-z]+$)}")] // 正規表現
```

## バリデーション

### DataAnnotations

```csharp
using System.ComponentModel.DataAnnotations;

public record CreateUserRequest
{
    [Required(ErrorMessage = "名前は必須です")]
    [StringLength(100, MinimumLength = 1)]
    public required string Name { get; init; }

    [Required]
    [EmailAddress(ErrorMessage = "メールアドレスの形式が不正です")]
    public required string Email { get; init; }

    [Phone]
    public string? PhoneNumber { get; init; }
}
```

### FluentValidation

```csharp
using FluentValidation;

public class CreateUserRequestValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("名前は必須です")
            .MaximumLength(100);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress().WithMessage("メールアドレスの形式が不正です");

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^\d{10,11}$")
            .When(x => !string.IsNullOrEmpty(x.PhoneNumber));
    }
}

// Program.cs
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserRequestValidator>();
```

## プロジェクト構成

```
MyApi/
├── src/
│   └── MyApi/
│       ├── MyApi.csproj
│       ├── Program.cs
│       ├── Controllers/
│       │   └── UsersController.cs
│       ├── Models/
│       │   ├── Requests/
│       │   │   └── CreateUserRequest.cs
│       │   └── Responses/
│       │       └── UserDto.cs
│       ├── Entities/
│       │   └── User.cs
│       ├── Services/
│       │   ├── IUserService.cs
│       │   └── UserService.cs
│       ├── Repositories/
│       │   ├── IUserRepository.cs
│       │   └── UserRepository.cs
│       ├── Middleware/
│       │   └── GlobalExceptionMiddleware.cs
│       ├── Validators/
│       │   └── CreateUserRequestValidator.cs
│       └── appsettings.json
└── tests/
    └── MyApi.Tests/
        ├── MyApi.Tests.csproj
        └── Controllers/
            └── UsersControllerTests.cs
```

## appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "Default": "Host=localhost;Database=mydb;Username=user;Password=pass"
  },
  "Jwt": {
    "Secret": "your-secret-key-here",
    "ExpirationMinutes": 60
  },
  "AllowedHosts": "*"
}
```

## 推奨パッケージ

| カテゴリ | パッケージ | 用途 |
|---------|-----------|------|
| ORM | `Microsoft.EntityFrameworkCore` | データベースアクセス |
| 検証 | `FluentValidation.AspNetCore` | バリデーション |
| ログ | `Serilog.AspNetCore` | 構造化ログ |
| ドキュメント | `Swashbuckle.AspNetCore` | Swagger/OpenAPI |
| 認証 | `Microsoft.AspNetCore.Authentication.JwtBearer` | JWT認証 |
| マッピング | `AutoMapper` | オブジェクトマッピング |
