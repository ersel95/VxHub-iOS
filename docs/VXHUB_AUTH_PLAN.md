# VxHub Generic User Authentication — Uygulama Planı

> **Amaç:** VxHub üzerinde açılan her yeni app'in, ek geliştirme yapmadan
> e-posta + şifre kaydı, girişi, şifre sıfırlaması ve Google/Apple ile girişi
> kullanabilmesi. Gereken tüm konfigürasyon panelden sağlanır; SDK panelden
> gelen konfigürasyona göre kendini kurar.

**Durum:** Plan — onay bekliyor
**Tarih:** 18 Ağustos 2026
**Kapsam:** `Backend/Vx-Hub-Backend`, `Frontend/Frontend`, `VxHub - iOS`

---

## 1. Mevcut Durum Analizi

### 1.1 Bugünkü kimlik dünyaları

| Katman | Entity | Auth mekanizması | Not |
|---|---|---|---|
| Panel kullanıcısı | `user` | `auth/` — bcrypt(10) + passport-local + JWT | VxHub admin paneli |
| App son kullanıcısı | `device` | **Yok** — `X-Hub-Device-Id` + `X-Hub-Vid` header'ı yeterli | Tüm endpoint'ler `@Public()` |
| Collie analisti | `olaf_analyst` | Ayrı JWT scope, bcrypt(12), rate-limit, timing-safe | **En olgun pattern — referans alınacak** |

### 1.2 Kritik tespit

Bugün sistemde "kullanıcı" diye bir varlık yok. `device` tablosuna kimlik
kolonları eklenmiş durumda:

```
device.social_email      device.social_provider    device.social_id
device.name              device.profile_picture
```

`POST device/social-login` akışı (`device.service.ts:749`):

1. `app` tablosundan `google_client_id` / `apple_service_id` okunur
2. `google-auth-library` veya `apple-signin-auth` ile id_token doğrulanır
3. **Aynı `project_id` içinde aynı `social_email`'e sahip device aranır**
4. Bulunursa o device'a devam edilir, bulunmazsa mevcut device'a e-posta yazılır

Yani kimlik = device satırının kendisi. Premium (`device.premium_status`),
bakiye (`device_balances.device_id`), satın almalar, ticket'lar, event'ler —
hepsi `device_id`'ye bağlı.

### 1.3 Hazır olanlar

- `app` tablosunda `google_client_id`, `apple_service_id`, `apple_team_id`,
  `apple_key_id`, `apple_private_key` kolonları **mevcut**
- Panelde `projects/[slug]/third-parties` sayfasından **düzenlenebiliyor**
- `google_client_id` device register response'unda SDK'ya **zaten dönüyor**
- iOS SDK'da `signInWithGoogle` / `signInWithApple` **çalışıyor**
- iOS SDK'da `VxKeychainManager` ve `VxUserSession` (accessToken + refreshToken)
  modeli **tanımlı ama kullanılmıyor**
- Redis tabanlı `OlafRateLimitService` — fail-closed rate limiting **hazır**

### 1.4 Eksikler

- E-posta + şifre kaydı / girişi yok
- Şifre sıfırlama yok, e-posta doğrulama yok
- Refresh token / oturum yönetimi yok
- **Hiçbir mail gönderme servisi yok** (`nodemailer` bağımlılıkta duruyor,
  hiç kullanılmamış)
- Bir kullanıcının birden çok cihazı olamıyor
- Panelde app son-kullanıcı yönetimi cihaz odaklı

---

## 2. Alınan Kararlar

| Konu | Karar |
|---|---|
| Kimlik modeli | Ayrı `app_user` tablosu; `device.app_user_id` ile bağlanır. Premium/bakiye kademeli olarak user seviyesine taşınır |
| Kapsam | **Proje seviyesi** — `project_id + email` UNIQUE. iOS/Android/Web aynı hesabı paylaşır (mevcut social-login davranışı ile birebir) |
| Mail altyapısı | **Resend** + 6 haneli kod (deeplink gerektirmez) |
| Hesap birleştirme | Otomatik devral; çakışmada bakiyeler **toplanır**, premium'un uzun olanı kalır |
| Oturum | Access (15 dk) + refresh (60 gün, rotasyonlu, DB'de hash'li), iOS Keychain'de saklanır |
| E-posta doğrulama | Panelden app bazında aç/kapa; varsayılan **kapalı**. Google/Apple → otomatik doğrulanmış |
| Geriye uyumluluk | `device.social_email` backfill edilir; **eski `device/social-login` endpoint'i korunur** |
| Panel yerleşimi | `customers/` kullanıcı odaklı hale gelir + yeni `projects/[slug]/auth` ayar sayfası |
| Admin yetkileri | Manuel kullanıcı oluştur, şifre sıfırlama tetikle, ban/pasif/sil, oturumları sonlandır |
| Güvenlik | Olaf pattern'i (bcrypt 12, timing-safe, Redis rate-limit) + panelden min. şifre uzunluğu |
| SDK | Headless API + hazır UIKit/SwiftUI auth ekranları |

---

## 3. Veri Modeli

### 3.1 `app_user` — kimlik

```sql
CREATE TABLE app_user (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          integer NOT NULL REFERENCES project(id),
    email               varchar(255),
    email_normalized    varchar(255),          -- lower(trim(email)), tekillik bunun üzerinden
    password_hash       varchar(255),          -- NULL ⇒ yalnızca social ile kayıtlı
    email_verified      boolean NOT NULL DEFAULT false,
    name                varchar(255),
    profile_picture     varchar(500),
    status              varchar(20) NOT NULL DEFAULT 'active',   -- active | banned | inactive
    must_change_password boolean NOT NULL DEFAULT false,
    premium_status      boolean NOT NULL DEFAULT false,
    premium_end_date    timestamp,
    last_login_at       timestamp,
    created_at          timestamp NOT NULL DEFAULT now(),
    updated_at          timestamp NOT NULL DEFAULT now(),
    deleted_at          timestamp
);

-- Proje içinde e-posta tekil (soft-delete edilenler hariç)
CREATE UNIQUE INDEX uq_app_user_project_email
    ON app_user (project_id, email_normalized)
    WHERE deleted_at IS NULL AND email_normalized IS NOT NULL;

CREATE INDEX idx_app_user_project_created ON app_user (project_id, created_at);
CREATE INDEX idx_app_user_status          ON app_user (status);
```

> **Neden `email_normalized`?** Aynı kullanıcının `Ali@X.com` ve `ali@x.com` ile
> iki hesap açmasını engeller. Yazma anında hesaplanır, uygulama kodu her yerde
> normalize etmeyi hatırlamak zorunda kalmaz.

### 3.2 `app_user_identity` — provider bağlantıları

```sql
CREATE TABLE app_user_identity (
    id                  bigserial PRIMARY KEY,
    app_user_id         uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    project_id          integer NOT NULL REFERENCES project(id),  -- hesaptan denormalize
    provider            varchar(20) NOT NULL,   -- password | google | apple
    provider_user_id    varchar(255),           -- google sub / apple sub; password için NULL
    provider_email      varchar(255),
    created_at          timestamp NOT NULL DEFAULT now(),
    deleted_at          timestamp
);

-- Bir provider hesabı, PROJE İÇİNDE tek kullanıcıya bağlanabilir
CREATE UNIQUE INDEX uq_identity_project_provider_subject
    ON app_user_identity (project_id, provider, provider_user_id)
    WHERE deleted_at IS NULL AND provider_user_id IS NOT NULL;

CREATE INDEX idx_identity_app_user ON app_user_identity (app_user_id);
CREATE INDEX idx_identity_project  ON app_user_identity (project_id);
```

> **`project_id` neden burada?** Tekillik proje kapsamında olmak zorunda. Aynı
> Google hesabı iki farklı projeye giriş yapabilir ve bu tamamen normaldir;
> `(provider, provider_user_id)` üzerinde global bir unique index ikinci girişi
> reddeder ve backfill'i de patlatır. Bu, Faz 1 testinde yakalandı.

Bir kullanıcı hem şifreyle hem Google'la giriş yapabilir — ikisi de aynı
`app_user`'a bağlı iki `app_user_identity` satırıdır. Aynı e-postayla Google'dan
gelen kullanıcı, mevcut şifreli hesabına **otomatik bağlanır** (e-posta Google
tarafında doğrulanmış olduğu için güvenli).

### 3.3 `app_user_session` — oturumlar

```sql
CREATE TABLE app_user_session (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    app_user_id         uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    device_id           uuid REFERENCES device(id),
    refresh_token_hash  varchar(255) NOT NULL,   -- sha256, düz token asla saklanmaz
    user_agent          varchar(255),
    ip_address          varchar(64),
    platform            varchar(20),
    expires_at          timestamp NOT NULL,
    revoked_at          timestamp,
    replaced_by_id      uuid,                    -- rotasyon zinciri (reuse detection)
    last_used_at        timestamp,
    created_at          timestamp NOT NULL DEFAULT now()
);

CREATE INDEX idx_session_user     ON app_user_session (app_user_id);
CREATE UNIQUE INDEX uq_session_rt ON app_user_session (refresh_token_hash);
CREATE INDEX idx_session_expires  ON app_user_session (expires_at);
```

> **Refresh token reuse detection:** Rotasyonda eski token `replaced_by_id` ile
> işaretlenir. Zaten kullanılmış (revoked) bir refresh token tekrar gelirse,
> token çalınmış demektir → o kullanıcının **tüm** oturumları iptal edilir.

### 3.4 `app_user_verification` — doğrulama / sıfırlama kodları

```sql
CREATE TABLE app_user_verification (
    id                  bigserial PRIMARY KEY,
    app_user_id         uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    type                varchar(30) NOT NULL,    -- email_verify | password_reset
    code_hash           varchar(255) NOT NULL,   -- sha256(code + pepper)
    attempts            smallint NOT NULL DEFAULT 0,
    expires_at          timestamp NOT NULL,
    consumed_at         timestamp,
    created_at          timestamp NOT NULL DEFAULT now()
);

CREATE INDEX idx_verification_user_type ON app_user_verification (app_user_id, type, created_at DESC);
```

- Kod: 6 hane, kriptografik rastgele (`crypto.randomInt`)
- Geçerlilik: 10 dakika, tek kullanımlık
- Maksimum 5 yanlış deneme → kod iptal
- Yeni kod istendiğinde önceki aynı tipteki kodlar geçersizleşir

### 3.5 `app_auth_config` — proje bazlı auth ayarları

```sql
CREATE TABLE app_auth_config (
    id                          serial PRIMARY KEY,
    project_id                  integer NOT NULL UNIQUE REFERENCES project(id),

    -- Provider anahtarları
    auth_enabled                boolean NOT NULL DEFAULT false,
    password_enabled            boolean NOT NULL DEFAULT false,
    google_enabled              boolean NOT NULL DEFAULT false,
    apple_enabled               boolean NOT NULL DEFAULT false,

    -- Politika
    require_email_verification  boolean NOT NULL DEFAULT false,
    min_password_length         smallint NOT NULL DEFAULT 8,
    require_password_complexity boolean NOT NULL DEFAULT false,
    access_token_ttl_minutes    integer NOT NULL DEFAULT 15,
    refresh_token_ttl_days      integer NOT NULL DEFAULT 60,
    max_sessions_per_user       integer,          -- NULL = sınırsız

    -- Mail (Resend)
    mail_from_email             varchar(255),
    mail_from_name              varchar(255),
    mail_reply_to               varchar(255),
    mail_logo_url               varchar(500),
    mail_default_locale         varchar(5) NOT NULL DEFAULT 'en',
    mail_brand_color            varchar(7),

    created_at                  timestamp NOT NULL DEFAULT now(),
    updated_at                  timestamp NOT NULL DEFAULT now()
);
```

> **Provider credential'ları `app` tablosunda kalır** (`google_client_id`,
> `apple_service_id`, …) çünkü iOS / Android / Web farklı client id kullanır.
> Bu tabloda yalnızca **hangi yöntemin açık olduğu** ve **proje geneli politika**
> tutulur — kimlik proje seviyesinde tekil olduğu için politika da öyle olmalı.

### 3.6 `device` tablosuna eklenen kolon

```sql
ALTER TABLE device ADD COLUMN app_user_id uuid REFERENCES app_user(id);
CREATE INDEX idx_device_app_user ON device (app_user_id);
```

### 3.7 `app` tablosuna eklenen kolon (Apple gotcha)

```sql
ALTER TABLE app ADD COLUMN apple_bundle_id varchar(255);
```

> **Neden:** Bugün `device.service.ts` Apple id_token'ını `aud: apple_service_id`
> ile doğruluyor. Ama **native iOS** Sign in with Apple token'ının `aud`'u
> **bundle id**'dir; `service_id` yalnızca **web** akışında kullanılır. Bugün
> çalışıyorsa `apple_service_id` alanına bundle id yazılmış demektir — bu, web
> girişi eklendiğinde kırılır. Yeni kolon ikisini ayırır; doğrulama sırasında
> `[apple_bundle_id, apple_service_id]` listesinden biri eşleşirse kabul edilir.
> Mevcut değerler `apple_bundle_id`'ye kopyalanır, eski davranış korunur.

### 3.8 İlişki şeması

```
project (1) ──< app_user (N)
                   │
                   ├──< app_user_identity   (password | google | apple)
                   ├──< app_user_session    (refresh token, cihaz başına)
                   ├──< app_user_verification (kodlar)
                   ├──< app_user_merge_log  (birleştirme denetim kaydı)
                   └──< device              (N cihaz, app_user_id ile)
                            │
                            ├── device_balances
                            ├── device_transactions
                            └── purchase / ticket / event  (değişmiyor)
```

---

## 4. Migration ve Backfill

> **DİKKAT:** `app.module.ts` içinde `migrationsRun: false` ve production'da
> `synchronize` kapalı. Şema değişiklikleri **canlıda elle uygulanmalı**
> (`psql`). Bu, geçmişte de böyle yapılmış — hafızadaki not doğrulandı.

### 4.1 Migration dosyaları

| Sıra | Dosya | İçerik |
|---|---|---|
| 1 | `<ts>-CreateAppUserTables.ts` | 3.1 – 3.5 arasındaki tablolar + indeksler |
| 2 | `<ts>-AddAppUserIdToDevice.ts` | `device.app_user_id` + indeks |
| 3 | `<ts>-AddAppleBundleIdToApp.ts` | `app.apple_bundle_id` + `apple_service_id`'den kopyalama |
| 4 | `<ts>-BackfillAppUsersFromDevices.ts` | Aşağıdaki backfill |

### 4.2 Backfill mantığı

```sql
-- 1) social_email dolu her (project_id, email) çifti için tek app_user üret
INSERT INTO app_user (project_id, email, email_normalized, email_verified,
                      name, profile_picture, premium_status, premium_end_date, created_at)
SELECT  a.project_id,
        MIN(d.social_email),
        lower(trim(d.social_email)),
        true,                                   -- social ⇒ doğrulanmış
        MIN(d.name),
        MIN(d.profile_picture),
        bool_or(d.premium_status),              -- herhangi bir cihazda premium ise premium
        MAX(d.premium_end_date),                -- en uzun premium kazanır
        MIN(d.created_at)
FROM device d
JOIN app a ON a.id = d.app_id
WHERE d.social_email IS NOT NULL
  AND d.social_email <> ''
  AND d.deleted_at IS NULL
GROUP BY a.project_id, lower(trim(d.social_email));

-- 2) identity satırları
INSERT INTO app_user_identity (app_user_id, provider, provider_user_id, provider_email)
SELECT DISTINCT u.id, d.social_provider, d.social_id, d.social_email
FROM device d
JOIN app a      ON a.id = d.app_id
JOIN app_user u ON u.project_id = a.project_id
               AND u.email_normalized = lower(trim(d.social_email))
WHERE d.social_email IS NOT NULL AND d.social_provider IS NOT NULL
  AND d.deleted_at IS NULL;

-- 3) device'ları bağla
UPDATE device d
SET app_user_id = u.id
FROM app a, app_user u
WHERE a.id = d.app_id
  AND u.project_id = a.project_id
  AND u.email_normalized = lower(trim(d.social_email))
  AND d.social_email IS NOT NULL;
```

**Bakiye:** Backfill sırasında bakiyeler **taşınmaz**. `device_balances`
olduğu yerde kalır; okuma katmanı (bkz. 5.4) kullanıcının tüm cihazlarındaki
bakiyeyi toplar. Bu, geri alınabilir ve veri kaybı riski olmayan yoldur.

### 4.3 Doğrulama sorguları (migration sonrası)

```sql
-- Bağlanmamış social device kalmamalı
SELECT count(*) FROM device
WHERE social_email IS NOT NULL AND social_email <> ''
  AND app_user_id IS NULL AND deleted_at IS NULL;   -- beklenen: 0

-- Proje içinde çift e-posta olmamalı
SELECT project_id, email_normalized, count(*)
FROM app_user WHERE deleted_at IS NULL
GROUP BY 1,2 HAVING count(*) > 1;                   -- beklenen: 0 satır
```

---

## 5. Backend Uygulaması

### 5.1 Modül yapısı

```
src/app-auth/
  app-auth.module.ts
  app-auth.controller.ts          # son kullanıcı endpoint'leri (@Public + AppUserGuard)
  app-auth-panel.controller.ts    # panel endpoint'leri (JWT guard)
  services/
    app-auth.service.ts           # register / login / social / şifre
    app-user-session.service.ts   # token üretimi, refresh rotasyonu, revoke
    app-user-verification.service.ts  # kod üret / doğrula
    app-user-merge.service.ts     # anonim device → hesap birleştirme
    app-auth-config.service.ts    # panel ayarları + cache
    social-token-verifier.service.ts  # google / apple id_token doğrulama
  guards/
    app-user.guard.ts             # scope='app_user' JWT
  decorators/
    app-user.decorator.ts         # @AppUser() → IAppUserJWT
  dto/  entities/

src/shared/service/
  mail.service.ts                 # Resend gönderimi
  mail-template.service.ts        # şablon render (i18n)
  rate-limit.service.ts           # OlafRateLimitService'ten generic'e taşınır
```

> `OlafRateLimitService` → `src/shared/service/rate-limit.service.ts` olarak
> genelleştirilir; Olaf modülü yeni servisi kullanır (davranış aynı, sadece
> `olaf:rl:` prefix'i `rl:` olur). Aynı kodu ikinci kez yazmayı önler.

### 5.2 Son kullanıcı endpoint'leri

Hepsi `@Public()` (JWT guard'dan muaf) — kimlik `Authorization: Bearer` ile
taşınır ve `AppUserGuard` tarafından ayrıca doğrulanır.

**Ortak header'lar:** `X-Hub-Id` (app id), `X-Hub-Device-Id`, opsiyonel `X-Hub-Vid`

| Metot | Yol | Body | Dönüş |
|---|---|---|---|
| POST | `app-auth/register` | `{email, password, name?}` | `AuthSessionDto` |
| POST | `app-auth/login` | `{email, password}` | `AuthSessionDto` |
| POST | `app-auth/social-login` | `{provider, token, account_id?, name?, email?}` | `AuthSessionDto` |
| POST | `app-auth/refresh` | `{refresh_token}` | `AuthSessionDto` |
| POST | `app-auth/logout` | `{refresh_token?}` | `{success}` |
| POST | `app-auth/logout-all` | — | `{success, revoked_count}` |
| POST | `app-auth/forgot-password` | `{email}` | `{success: true}` (her zaman) |
| POST | `app-auth/reset-password` | `{email, code, new_password}` | `{success}` |
| POST | `app-auth/verify-email` | `{code}` | `{success, email_verified}` |
| POST | `app-auth/resend-verification` | — | `{success}` |
| POST | `app-auth/change-password` | `{current_password, new_password}` | `{success}` |
| GET | `app-auth/me` | — | `AppUserDto` |
| PATCH | `app-auth/me` | `{name?, profile_picture?}` | `AppUserDto` |
| DELETE | `app-auth/me` | — | `{success}` |
| GET | `app-auth/config` | — | `{password_enabled, google_enabled, apple_enabled, google_client_id, min_password_length, require_email_verification}` |

**`AuthSessionDto`:**

```jsonc
{
  "status": "success",
  "access_token": "eyJ…",
  "refresh_token": "3f9a…",       // opak, 256 bit rastgele
  "expires_in": 900,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "email_verified": true,
    "name": "Ali Veli",
    "profile_picture": "https://…",
    "providers": ["password", "google"],
    "premium_status": true,
    "premium_end_date": "2026-12-01T00:00:00Z",
    "balance": 700,
    "must_change_password": false,
    "created_at": "2026-08-18T10:00:00Z"
  },
  "vid": "device-uuid"             // geriye uyumluluk: SDK'nın bildiği vid
}
```

> `vid` alanı bilerek korunuyor — SDK'nın mevcut tüm çağrıları (`purchase`,
> `support`, `events`) `X-Hub-Vid` üzerinden çalışıyor. Auth eklenmesi bu
> akışların hiçbirini değiştirmiyor.

### 5.3 Panel endpoint'leri

JWT guard + `ProjectScopeGuard` — panel kullanıcısının erişebildiği projeler
`resolveAccessibleProjectIds` (mevcut `device.service.ts` mantığı) ile sınırlanır.

| Metot | Yol | Açıklama |
|---|---|---|
| GET | `app-users/panel/list` | Filtre: `project_id`, `email`, `provider`, `status`, `verified`, tarih; sayfalı |
| GET | `app-users/panel/:id` | Detay + bağlı cihazlar + oturumlar + son işlemler |
| POST | `app-users/panel` | `{project_id, email, name?, password?, send_invite?}` — şifre verilmezse üretilir, `must_change_password=true` |
| PATCH | `app-users/panel/:id` | `{name?, email_verified?, status?}` |
| POST | `app-users/panel/:id/reset-password` | `{mode: 'send_email' \| 'set_temporary'}` |
| POST | `app-users/panel/:id/ban` / `unban` | `status` değiştirir + tüm oturumları iptal eder |
| POST | `app-users/panel/:id/sessions/revoke` | `{session_id?}` — yoksa hepsi |
| DELETE | `app-users/panel/:id` | Soft delete + oturum iptali + KVKK anonimleştirme |
| GET | `project/:projectId/auth-config` | Ayarları getir |
| PUT | `project/:projectId/auth-config` | Ayarları güncelle (+ Redis cache invalidate) |

### 5.4 Premium ve bakiye çözümleme

Kırılma riskini sıfırlamak için okuma/yazma bir servis arkasına alınır:

```ts
// app_user varsa kullanıcının TÜM cihazlarındaki bakiye toplanır,
// yoksa mevcut davranış (tek device) aynen sürer.
async resolveBalance(device: Device): Promise<number>
async resolvePremium(device: Device): Promise<{ status: boolean; endDate: Date | null }>
```

- **Okuma:** `device.app_user_id` doluysa → o kullanıcının cihazlarının
  bakiye toplamı; `app_user.premium_status` VEYA herhangi bir cihazda premium
- **Yazma:** Bakiye halen `device_balances`'a yazılır (mevcut kod yolu),
  premium hem `device`'a hem `app_user`'a yazılır
- **`ResponseDeviceDto` değişmez** → yayındaki SDK'lar etkilenmez

> Bakiyenin `app_user_balances` tablosuna tam taşınması bilinçli olarak **kapsam
> dışı** bırakıldı: satın alma, promosyon, ödül ve harcama yolları çok sayıda
> yerde `device_id` kullanıyor; tek seferde taşımak bu planın risk profilini
> gereksiz büyütür. Toplama katmanı davranışı bugünden doğru kılar, taşıma
> sonraki bir işte tek bir migration ile yapılabilir.

### 5.5 Hesap birleştirme (`app-user-merge.service.ts`)

Kayıt veya girişte cihaz zaten anonim veriye sahipse:

```
Girdi: device (anonim, app_user_id = NULL), hedef app_user

1. device.app_user_id = user.id
2. Bakiye:   hedefin toplam bakiyesi += cihazın bakiyesi   (TOPLA)
             device_transactions'a type=ADMIN kaydı düşülür
3. Premium:  max(user.premium_end_date, device.premium_end_date)
             premium_status = user OR device
4. Ticket / event / purchase: device_id sabit kaldığı için dokunulmaz —
   kullanıcı detayında cihazlar üzerinden birleşik görünür
5. Audit: app_user_merge_log'a (user_id, device_id, added_balance,
   premium_before/after, merged_at) yazılır
```

Tamamı **tek transaction** içinde (`dataSource.transaction`) yürütülür.

> **Neden ayrı `app_user_merge_log`?** `process_history` tablosu ad benzerliğine
> rağmen audit log değil — `output_id` / `transaction_id` ile içerik üretim
> işlemlerini izliyor. Birleştirme kayıtlarını oraya sıkıştırmak yanlış olur.

### 5.6 Güvenlik

Olaf pattern'i birebir uygulanır:

| Önlem | Değer |
|---|---|
| Şifre hash | bcrypt, cost **12** |
| Timing attack | Kullanıcı yoksa bile `DUMMY_BCRYPT_HASH` ile compare çalıştırılır |
| Hesap enumeration | `forgot-password` her durumda `{success: true}` döner; login hep "Invalid credentials" |
| Login rate limit | 5/dk (ip+email), 20/dk (ip) — **fail-closed** |
| Kod deneme limiti | 5 deneme/kod, 3 kod isteği/saat/kullanıcı |
| Kayıt rate limit | 3/saat/ip |
| Refresh token | 256-bit rastgele, DB'de sha256, rotasyonlu, reuse → tüm oturumlar iptal |
| Doğrulama kodu | `crypto.randomInt`, DB'de hash'li, 10 dk |
| Şifre politikası | Min uzunluk panelden (varsayılan 8); karmaşıklık opsiyonel |
| Ban kontrolü | Her `AppUserGuard` geçişinde `status='active'` doğrulanır |
| JWT | `scope: 'app_user'` — panel token'ı ile karışması imkânsız |

### 5.7 Mail servisi

```ts
// src/shared/service/mail.service.ts
send(params: {
  to: string;
  templateId: 'verify_email' | 'reset_password' | 'welcome' | 'panel_invite';
  locale: string;
  vars: Record<string, string>;
  config: AppAuthConfig;    // from/reply-to/logo/renk projeden gelir
}): Promise<void>
```

- Sağlayıcı: **Resend** (`RESEND_API_KEY` env)
- İkinci taşıyıcı: **`outbox`** — mesajı göndermek yerine diske yazar. Yerelde
  doğrulama/sıfırlama akışları sağlayıcı hesabı olmadan denenebilir ve test
  koşusu yanlışlıkla gerçek bir adrese posta atamaz. Production'da reddedilir.
- Gönderim `BullMQ` kuyruğuna alınır (mail servisi yavaşsa login/register bloklanmaz)
- Şablonlar: HTML + düz metin, TR/EN başlangıç; dil `mail_default_locale` ya da
  cihazın `language_code`'undan seçilir
- Gönderim hatası **loglanır ama akışı kesmez** — kullanıcı "kod gelmedi" derse
  panelden yeniden gönderilebilir

---

## 6. Panel (Frontend)

### 6.1 `projects/[slug]/auth` — yeni sayfa

```
┌─ Kimlik Doğrulama ──────────────────────────────────────┐
│  Auth'u etkinleştir                            [ ●  ]   │
│                                                          │
│  Giriş yöntemleri                                        │
│    E-posta + şifre                             [ ●  ]   │
│    Google ile giriş                            [ ●  ]   │
│      iOS client id      ……………………  (app'ten)             │
│      Android client id  ……………………                        │
│      Web client id      ……………………                        │
│    Apple ile giriş                             [ ●  ]   │
│      Bundle id / Service id / Team id / Key id           │
│                                                          │
│  Politika                                                │
│    E-posta doğrulaması zorunlu                 [    ]   │
│    Minimum şifre uzunluğu            [ 8 ]              │
│    Şifre karmaşıklığı zorunlu                  [    ]   │
│    Access token ömrü (dk)            [ 15 ]             │
│    Refresh token ömrü (gün)          [ 60 ]             │
│    Kullanıcı başına maks. oturum     [ — ]              │
│                                                          │
│  E-posta gönderimi                                       │
│    Gönderen adı / adresi / reply-to / logo / renk / dil  │
│    [ Test maili gönder ]                                 │
└──────────────────────────────────────────────────────────┘
```

Provider credential alanları `third-parties` sayfasındaki mevcut alanların
**aynısını yazar** (tek kaynak: `app` tablosu) — iki sayfa da aynı veriyi
gösterir, çift kayıt oluşmaz.

### 6.2 `customers/` — kullanıcı odaklı liste

| Kolon | Kaynak |
|---|---|
| Kullanıcı | `email` + `name`, doğrulanmamışsa uyarı rozeti |
| Yöntemler | `password` / `google` / `apple` rozetleri |
| Durum | active / banned / inactive |
| Premium | durum + bitiş tarihi |
| Bakiye | tüm cihazların toplamı |
| Cihaz | bağlı cihaz sayısı |
| Son giriş | `last_login_at` |

Filtreler: proje, yöntem, durum, doğrulama, tarih aralığı, e-posta arama.
Anonim (hesapsız) cihazlar için "Yalnızca kayıtlı kullanıcılar" anahtarı —
kapalıyken bugünkü cihaz listesi davranışı korunur.

### 6.3 `customers/[id]` — kullanıcı detayı

Sekmeler:
- **Genel** — profil, premium, bakiye, doğrulama durumu
- **Cihazlar** — bağlı cihazlar (mevcut cihaz detay bileşeni yeniden kullanılır)
- **Oturumlar** — aktif oturumlar, cihaz/IP/son kullanım + tekil veya toplu iptal
- **İşlemler** — bakiye hareketleri (mevcut `transaction-history`)
- **Etkinlikler** — mevcut event listesi

Aksiyonlar: `Şifre sıfırlama maili gönder` · `Geçici şifre ata` ·
`Doğrulanmış işaretle` · `Banla` / `Ban kaldır` · `Oturumları kapat` · `Sil`

### 6.4 Yeni kullanıcı oluşturma modalı

`E-posta` · `Ad` · `Proje` · `Şifre (boşsa üretilir)` ·
`Davet maili gönder [✓]` · `İlk girişte şifre değiştirmeye zorla [✓]`

---

## 7. iOS SDK

### 7.1 Yeni public API

```swift
// Durum
VxHub.shared.currentUser: VxUser?        // nil ⇒ anonim
VxHub.shared.isAuthenticated: Bool
VxHub.shared.authConfig: VxAuthConfig?   // hangi yöntemler açık (panelden)

// E-posta + şifre
func signUp(email: String, password: String, name: String?,
            completion: @escaping (Result<VxUser, VxHubError>) -> Void)
func signIn(email: String, password: String,
            completion: @escaping (Result<VxUser, VxHubError>) -> Void)
func forgotPassword(email: String, completion: @escaping (Result<Void, VxHubError>) -> Void)
func resetPassword(email: String, code: String, newPassword: String,
                   completion: @escaping (Result<Void, VxHubError>) -> Void)
func verifyEmail(code: String, completion: @escaping (Result<Void, VxHubError>) -> Void)
func resendVerificationCode(completion: @escaping (Result<Void, VxHubError>) -> Void)
func changePassword(current: String, new: String,
                    completion: @escaping (Result<Void, VxHubError>) -> Void)
func updateProfile(name: String?, completion: @escaping (Result<VxUser, VxHubError>) -> Void)
func signOut(allDevices: Bool = false, completion: @escaping (Bool) -> Void)

// Mevcut — imzalar korunur, içeride yeni akışa bağlanır
func signInWithGoogle(presenting:completion:)
func signInWithApple(presenting:completion:)
func deleteAccount(completion:)

// Hepsinin async/await karşılığı da eklenir (mevcut desende)
```

### 7.2 Token yönetimi

- `VxUserSession` (**zaten tanımlı, kullanılmıyordu**) Keychain'de saklanır
- `VxNetworkManager`'a interceptor: `Authorization: Bearer <access>` eklenir
- **401 → tek seferlik otomatik refresh → isteği tekrar dener**; refresh de
  başarısızsa oturum temizlenir ve `vxHubUserSessionExpired()` delegate'i tetiklenir
- Eşzamanlı 401'lerde tek refresh çalışır (diğer istekler onu bekler)
- Uygulama silinip yeniden kurulduğunda Keychain'deki oturum kalabilir →
  `hubId` değişirse veya token reddedilirse temizlenir

### 7.3 Hazır UI ekranları

Paywall/Support ile aynı mimari: UIKit `VxNiblessViewController` + SwiftUI sarmalayıcı.

```swift
// SwiftUI
VxAuthView(
    configuration: VxAuthConfiguration(),
    onSuccess: { user in },
    onDismiss: { }
)

// UIKit
VxHub.shared.showAuth(from: viewController,
                      configuration: VxAuthConfiguration(),
                      completion: { user in })
```

Ekranlar: **Giriş** · **Kayıt** · **Şifremi unuttum** (e-posta) · **Kod girişi**
(6 haneli, otomatik ilerleyen kutular) · **Yeni şifre** · **E-posta doğrulama**

`VxAuthConfiguration` — `VxSupportConfiguration` desenini izler: 30+ renk/font
parametresi, hepsi varsayılanlı; logo, başlık metinleri, ToS/Privacy görünürlüğü,
"misafir olarak devam et" düğmesi opsiyonel.

Butonlar `authConfig`'e göre otomatik gizlenir — panelde Google kapalıysa
Google butonu hiç çizilmez. **Uygulamada tek satır kod değişmeden** panelden
provider aç/kapa yapılabilir; hedeflenen "generic" davranış tam olarak budur.

### 7.4 Yeni endpoint'ler (`VxEndPoint.swift`)

`authRegister` · `authLogin` · `authSocialLogin` · `authRefresh` · `authLogout` ·
`authForgotPassword` · `authResetPassword` · `authVerifyEmail` ·
`authResendVerification` · `authChangePassword` · `authMe` · `authUpdateProfile`

### 7.5 Localization

Tüm metinler `VxLocalizables` üzerinden — mevcut localization akışıyla (backend
`localization_url`) TR/EN ve projenin desteklediği diller otomatik gelir.

---

## 8. Fazlar

| Faz | Kapsam | Çıktı |
|---|---|---|
| **1** ✅ | Entity'ler, migration'lar, backfill, `app_auth_config` | Tamamlandı — 6 entity, 4 migration, `docs/sql/001_app_user_schema.sql` + `002_verify.sql`. Geçici PostgreSQL 16'da uçtan uca test edildi (backfill, idempotency, rollback). **Canlıya elle uygulanmayı bekliyor.** |
| **2** ✅ | Mail servisi (Resend + BullMQ + şablonlar), rate-limit servisi genelleştirme | Tamamlandı — `shared/mail/` (5 şablon × TR/EN), `resend` + `outbox` taşıyıcı, BullMQ kuyruğu; `RateLimitService` paylaşıma alındı. Auth-lab'dan uçtan uca doğrulandı. **Canlıda `RESEND_API_KEY` gerekli.** |
| **3** | `AppAuthModule`: register/login/refresh/forgot/reset/verify + `AppUserGuard` + merge servisi | Postman ile uçtan uca akış |
| **4** | Social login'in yeni yapıya bağlanması (eski endpoint korunarak) + premium/bakiye çözümleme katmanı | Yayındaki app'lerde regresyon yok |
| **5** | Panel: `projects/[slug]/auth` ayar sayfası | Provider ve mail ayarları panelden |
| **6** | Panel: `customers` kullanıcı odaklı liste + detay + admin aksiyonları | Kullanıcı yönetimi tam |
| **7** | iOS SDK: token yönetimi + headless API | Örnek uygulamada çalışan akış |
| **8** | iOS SDK: hazır auth ekranları + dokümantasyon | `VxAuthView` + güncel `CLAUDE.md` / `docs/` |

Fazlar sırayla ilerler; her fazın sonunda çalışır bir çıktı olur. Faz 4
tamamlanmadan yayındaki hiçbir davranış değişmez.

---

## 9. Test Planı

**Backend (jest)**
- Aynı e-posta ile ikinci kayıt → 400, hesap oluşmaz
- Büyük/küçük harf farklı e-posta → aynı hesap (normalizasyon)
- Yanlış şifre → "Invalid credentials", 5. denemeden sonra 429
- Olmayan kullanıcı ile login → yanıt süresi var olanla aynı mertebede (timing)
- `forgot-password` olmayan e-posta → yine `{success: true}` (enumeration yok)
- Kod: süresi dolmuş / 6. deneme / ikinci kez kullanım → reddedilir
- Refresh rotasyonu; kullanılmış refresh token tekrar → tüm oturumlar iptal
- Banlanmış kullanıcı → access token geçerli olsa da 401
- **Merge:** anonim 500 coin + hesap 200 coin → 700; premium'un uzunu kalır
- **Geriye uyumluluk:** eski `device/social-login` gövdesiyle çağrı → yanıt
  şeması bire bir aynı

**Migration**
- Staging kopyasında backfill → 4.3'teki iki doğrulama sorgusu da temiz
- Çift çalıştırma (idempotency) → yeni satır oluşmaz

**iOS**
- Kayıt → doğrulama kodu → giriş → uygulama kapat/aç → oturum sürüyor
- Access token süresi dolmuş → sessiz refresh, kullanıcı fark etmez
- Refresh de geçersiz → login ekranına düşer, delegate tetiklenir
- Google ile giriş → aynı e-postayla daha önce şifreyle açılmış hesaba bağlanır
- Panelde Google kapatılınca → butonu çizmez
- Uçak modunda giriş denemesi → anlamlı hata, çökme yok

---

## 10. Riskler ve Önlemler

| Risk | Önlem |
|---|---|
| Backfill yanlış hesap birleştirmesi | Staging'de prod kopyası üzerinde prova, doğrulama sorguları, geri alma scripti |
| Yayındaki SDK'ların kırılması | `ResponseDeviceDto` şeması sabit; eski endpoint korunuyor; Faz 4'e kadar davranış değişmiyor |
| Apple `aud` uyumsuzluğu | `apple_bundle_id` ayrı kolon; doğrulamada iki değer de kabul |
| Mail teslim edilemezse kullanıcı kilitlenir | Kuyruk + retry, panelden yeniden gönder, admin geçici şifre atayabilir |
| Redis kesintisinde rate-limit devre dışı kalır | Auth yollarında `failOpen: false` (Olaf pattern'i) |
| `migrationsRun: false` — şema canlıda elle | Faz 1 çıktısı olarak sırasıyla çalıştırılacak SQL dosyası teslim edilir |
| Bakiye iki yerde (device + user) tutarsızlığı | Yazma tek yol (`device_balances`), okuma toplama katmanından; user'a taşıma ayrı bir işe bırakıldı |

---

## 11. Bilinçli Olarak Kapsam Dışı

- Bakiyenin `app_user_balances`'a tam taşınması (5.4'teki gerekçe)
- Facebook / X / TikTok ile giriş — mimari hazır, provider eklemek yeni bir
  `app_user_identity.provider` değeri + doğrulayıcıdan ibaret
- İki adımlı doğrulama (2FA)
- Android SDK — backend ve panel hazır olur, Android istemcisi ayrı iş
- Panel kullanıcılarının (`user` tablosu) auth'unun bu yapıya taşınması
