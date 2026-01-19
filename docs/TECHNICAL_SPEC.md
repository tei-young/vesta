# Technical Specification - Vesta iOS

> Vesta 뷰티샵 매출 관리 iOS 앱 기술 명세서

---

## 목차

1. [시스템 개요](#1-시스템-개요)
2. [기술 스택](#2-기술-스택)
3. [아키텍처](#3-아키텍처)
4. [데이터 모델](#4-데이터-모델)
5. [Firebase 설계](#5-firebase-설계)
6. [인증 시스템](#6-인증-시스템)
7. [서비스 레이어](#7-서비스-레이어)
8. [UI/UX 설계](#8-uiux-설계)
9. [네트워크 및 에러 처리](#9-네트워크-및-에러-처리)
10. [보안](#10-보안)
11. [성능 최적화](#11-성능-최적화)
12. [배포](#12-배포)

---

## 1. 시스템 개요

### 1.1 프로젝트 정보

| 항목 | 내용 |
|------|------|
| **프로젝트명** | Vesta |
| **설명** | 개인 뷰티샵(네일, 속눈썹, 왁싱 등) 운영자를 위한 매출 관리 iOS 앱 |
| **타겟 사용자** | 뷰티샵 개인 사업자 (100~200명) |
| **플랫폼** | iOS 17.0+ |
| **언어** | Swift 5.9+ |
| **UI 프레임워크** | SwiftUI |
| **백엔드** | Firebase (Firestore + Authentication) |

### 1.2 핵심 기능

1. **캘린더 탭**: 일별 시술 기록 및 월별 매출 확인
2. **결산 탭**: 월별 매출/지출 관리 및 순이익 계산
3. **설정 탭**: 시술 항목 관리

---

## 2. 기술 스택

### 2.1 Frontend

| 기술 | 버전 | 용도 |
|------|------|------|
| **Swift** | 5.9+ | 개발 언어 |
| **SwiftUI** | iOS 17+ | UI 프레임워크 |
| **Combine** | - | 반응형 프로그래밍 |
| **Swift Concurrency** | - | async/await, Task |

### 2.2 Backend

| 기술 | 버전 | 용도 |
|------|------|------|
| **Firebase iOS SDK** | 10.20.0+ | BaaS |
| **Firebase Authentication** | - | Apple Sign In |
| **Cloud Firestore** | - | NoSQL 데이터베이스 |
| **Firebase Analytics** | - | 사용자 분석 (선택) |

### 2.3 개발 도구

| 도구 | 버전 | 용도 |
|------|------|------|
| **Xcode** | 15.0+ | IDE |
| **Swift Package Manager** | - | 의존성 관리 |
| **Git** | - | 버전 관리 |

---

## 3. 아키텍처

### 3.1 전체 아키텍처

```
┌─────────────────────────────────────────────────┐
│                   Vesta iOS App                  │
├─────────────────────────────────────────────────┤
│  Presentation Layer (SwiftUI Views)             │
│    ├── CalendarTabView                           │
│    ├── SettlementTabView                         │
│    ├── SettingsTabView                           │
│    └── LoginView                                 │
├─────────────────────────────────────────────────┤
│  ViewModel Layer (ObservableObject)             │
│    ├── CalendarViewModel                         │
│    ├── SettlementViewModel                       │
│    └── SettingsViewModel                         │
├─────────────────────────────────────────────────┤
│  Service Layer                                   │
│    ├── AuthService                               │
│    ├── TreatmentService                          │
│    ├── RecordService                             │
│    ├── AdjustmentService                         │
│    ├── CategoryService                           │
│    └── ExpenseService                            │
├─────────────────────────────────────────────────┤
│  Data Layer                                      │
│    └── Firebase Firestore                        │
└─────────────────────────────────────────────────┘
```

### 3.2 MVVM 패턴

**View (SwiftUI)**
- 순수한 UI 렌더링
- 사용자 입력 처리
- ViewModel 관찰 (@ObservedObject, @StateObject)

**ViewModel (ObservableObject)**
- 비즈니스 로직
- 상태 관리 (@Published)
- Service 호출
- 데이터 변환 (Model → UI용 데이터)

**Model**
- 데이터 구조 정의 (Codable)
- Firestore 매핑

**Service**
- Firebase 통신
- CRUD 작업
- 에러 핸들링

### 3.3 디렉토리 구조

```
Vesta/
├── App/
│   ├── VestaApp.swift          # @main 진입점
│   └── ContentView.swift       # 루트 뷰 (인증 분기)
│
├── Features/                   # 기능별 모듈
│   ├── Auth/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Calendar/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Settlement/
│   │   ├── Views/
│   │   └── ViewModels/
│   └── Settings/
│       ├── Views/
│       └── ViewModels/
│
├── Core/                       # 핵심 비즈니스 로직
│   ├── Models/                 # 데이터 모델
│   ├── Services/               # Firebase 서비스
│   └── Repositories/           # (선택) 추상화 레이어
│
├── Shared/                     # 공용 컴포넌트
│   ├── Components/             # 재사용 가능한 UI
│   ├── Extensions/             # Swift Extensions
│   └── Constants/              # 상수 (색상, 스타일 등)
│
└── Resources/                  # 리소스 파일
    ├── Assets.xcassets
    └── GoogleService-Info.plist
```

---

## 4. 데이터 모델

### 4.1 User (사용자)

```swift
struct AppUser: Identifiable, Codable {
    let id: String              // Firebase Auth UID
    var email: String?
    var displayName: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case createdAt = "created_at"
    }
}
```

**Firestore 경로:** `users/{userId}/profile/info`

---

### 4.2 Treatment (시술)

```swift
struct Treatment: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String            // 시술명 (최대 30자)
    var price: Int              // 가격 (원)
    var icon: String?           // 이모지 (최대 2자)
    var color: String           // HEX 색상코드 (#FFA0B9)
    var order: Int              // 정렬 순서
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, price, icon, color, order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

**Firestore 경로:** `users/{userId}/treatments/{treatmentId}`

**제약 조건:**
- `name`: 사용자당 UNIQUE (클라이언트에서 검증)
- `price`: >= 0
- `icon`: 최대 2글자
- `color`: 15가지 팔레트 중 선택

---

### 4.3 DailyRecord (일별 시술 기록)

```swift
struct DailyRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date              // 시술일 (00:00:00)
    var treatmentId: String     // FK: treatments
    var count: Int              // 시술 횟수
    var totalAmount: Int        // 총 금액
    var createdAt: Date

    // 로컬 조인용 (Firestore 저장 안됨)
    var treatment: Treatment?

    enum CodingKeys: String, CodingKey {
        case id, date, count
        case treatmentId = "treatment_id"
        case totalAmount = "total_amount"
        case createdAt = "created_at"
    }

    // 단가 계산
    var unitPrice: Int {
        guard count > 0 else { return 0 }
        return totalAmount / count
    }
}
```

**Firestore 경로:** `users/{userId}/dailyRecords/{recordId}`

**제약 조건:**
- `date` + `treatmentId`: 조합 UNIQUE (클라이언트에서 검증)
- `count`: > 0
- `totalAmount`: >= 0

---

### 4.4 DailyAdjustment (일별 조정)

```swift
struct DailyAdjustment: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date              // 조정일
    var amount: Int             // 금액 (음수: 할인, 양수: 팁)
    var reason: String?         // 사유 (최대 50자)
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, date, amount, reason
        case createdAt = "created_at"
    }

    var isDiscount: Bool { amount < 0 }
    var isAddition: Bool { amount > 0 }
    var absoluteAmount: Int { abs(amount) }
}
```

**Firestore 경로:** `users/{userId}/dailyAdjustments/{adjustmentId}`

---

### 4.5 ExpenseCategory (지출 카테고리)

```swift
struct ExpenseCategory: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String            // 카테고리명 (최대 20자)
    var icon: String?           // 이모지 (최대 2자)
    var order: Int              // 정렬 순서
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, icon, order
        case createdAt = "created_at"
    }
}
```

**Firestore 경로:** `users/{userId}/expenseCategories/{categoryId}`

**제약 조건:**
- `name`: 사용자당 UNIQUE

---

### 4.6 MonthlyExpense (월별 지출)

```swift
struct MonthlyExpense: Identifiable, Codable {
    @DocumentID var id: String?
    var yearMonth: String       // "YYYY-MM" 형식
    var categoryId: String      // FK: expenseCategories
    var amount: Int             // 지출액
    var createdAt: Date

    // 로컬 조인용
    var category: ExpenseCategory?

    enum CodingKeys: String, CodingKey {
        case id, amount
        case yearMonth = "year_month"
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}
```

**Firestore 경로:** `users/{userId}/monthlyExpenses/{expenseId}`

**제약 조건:**
- `yearMonth` + `categoryId`: 조합 UNIQUE (Upsert 방식)

---

## 5. Firebase 설계

### 5.1 Firestore 데이터 구조

```
users/
  └── {userId}/                          # Firebase Auth UID
        │
        ├── profile/
        │     └── info: {                # 단일 문서
        │           email: string,
        │           display_name: string?,
        │           created_at: timestamp
        │         }
        │
        ├── treatments/                  # 시술 컬렉션
        │     ├── {treatmentId}
        │     └── ...
        │
        ├── dailyRecords/               # 일별 기록 컬렉션
        │     ├── {recordId}
        │     └── ...
        │
        ├── dailyAdjustments/           # 일별 조정 컬렉션
        │     ├── {adjustmentId}
        │     └── ...
        │
        ├── expenseCategories/          # 지출 카테고리 컬렉션
        │     ├── {categoryId}
        │     └── ...
        │
        └── monthlyExpenses/            # 월별 지출 컬렉션
              ├── {expenseId}
              └── ...
```

### 5.2 Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 인증 확인
    function isAuthenticated() {
      return request.auth != null;
    }

    // 본인 데이터 확인
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // 사용자별 모든 서브 컬렉션
    match /users/{userId}/{document=**} {
      allow read, write: if isOwner(userId);
    }
  }
}
```

### 5.3 Firestore 인덱스

**필수 인덱스:**

| 컬렉션 | 필드 1 | 필드 2 | 정렬 | 용도 |
|--------|--------|--------|------|------|
| dailyRecords | date | ASC | created_at DESC | 날짜별 기록 조회 |
| dailyRecords | date | ASC | treatment_id ASC | 중복 체크 |
| dailyAdjustments | date | ASC | created_at DESC | 날짜별 조정 조회 |
| monthlyExpenses | year_month | ASC | category_id ASC | 월별 지출 조회 |
| treatments | order | ASC | - | 정렬된 시술 목록 |
| expenseCategories | order | ASC | - | 정렬된 카테고리 목록 |

### 5.4 데이터 타입 매핑

| Swift | Firestore |
|-------|-----------|
| String | String |
| Int | Number |
| Bool | Boolean |
| Date | Timestamp |
| [String] | Array |
| [String: Any] | Map |
| nil | null |

---

## 6. 인증 시스템

### 6.1 Apple Sign In 플로우

```
1. 사용자가 "Sign In with Apple" 버튼 클릭
   ↓
2. iOS가 Apple 인증 시트 표시
   ↓
3. 사용자가 Face ID/Touch ID로 인증
   ↓
4. Apple이 identityToken과 authorizationCode 반환
   ↓
5. 앱이 nonce를 생성 및 SHA256 해싱
   ↓
6. Firebase Auth에 Apple credential로 signIn
   ↓
7. Firebase가 Custom Token 생성
   ↓
8. AuthStateDidChangeListener가 인증 상태 업데이트
   ↓
9. ContentView가 MainTabView로 전환
```

### 6.2 AuthService 구조

```swift
@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = true

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    init() {
        setupAuthStateListener()
    }

    func generateNonce() -> String { ... }
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws { ... }
    func signOut() throws { ... }
}
```

### 6.3 보안 강화

**Nonce 사용:**
- 재생 공격(replay attack) 방지
- 32자 랜덤 문자열 생성
- SHA256 해싱으로 무결성 검증

**에러 처리:**
```swift
enum AuthError: LocalizedError {
    case invalidNonce
    case invalidToken
    case signInFailed(String)
    case signOutFailed(String)
}
```

---

## 7. 서비스 레이어

### 7.1 Service 공통 패턴

모든 Service는 다음 패턴을 따릅니다:

```swift
class XXXService {
    private let db = Firestore.firestore()

    // 사용자별 컬렉션 참조
    private func userCollectionRef(userId: String) -> CollectionReference {
        db.collection("users")
          .document(userId)
          .collection("xxxCollection")
    }

    // CRUD 메서드
    func fetch(userId: String) async throws -> [Model] { ... }
    func add(_ item: Model, userId: String) async throws { ... }
    func update(_ item: Model, userId: String) async throws { ... }
    func delete(id: String, userId: String) async throws { ... }
}
```

### 7.2 TreatmentService

**메서드:**
```swift
func fetchTreatments(userId: String) async throws -> [Treatment]
func addTreatment(_ treatment: Treatment, userId: String) async throws
func updateTreatment(_ treatment: Treatment, userId: String) async throws
func deleteTreatment(id: String, userId: String) async throws
func reorderTreatments(_ treatments: [Treatment], userId: String) async throws
```

**특이사항:**
- `reorderTreatments`: Firestore Batch Write 사용
- 최대 500개 연산까지 허용

### 7.3 RecordService

**메서드:**
```swift
func fetchRecords(userId: String, date: Date) async throws -> [DailyRecord]
func fetchMonthlyRecords(userId: String, year: Int, month: Int) async throws -> [DailyRecord]
func addOrUpdateRecord(userId: String, date: Date, treatmentId: String, price: Int) async throws
func updateRecordCount(id: String, count: Int, totalAmount: Int) async throws
func deleteRecord(id: String, userId: String) async throws
```

**특이사항:**
- `addOrUpdateRecord`: 같은 날짜 + 같은 시술이면 수량만 증가 (Upsert)
- 쿼리 조건: `date >= startOfDay AND date < endOfDay`

### 7.4 ExpenseService

**메서드:**
```swift
func fetchExpenses(userId: String, yearMonth: String) async throws -> [MonthlyExpense]
func upsertExpense(userId: String, yearMonth: String, categoryId: String, amount: Int) async throws
func copyFromPreviousMonth(userId: String, from: String, to: String) async throws
```

**특이사항:**
- `upsertExpense`: 기존 문서 업데이트 또는 새 문서 생성
- `copyFromPreviousMonth`: 여러 카테고리 병렬 처리

---

## 8. UI/UX 설계

### 8.1 디자인 시스템

**색상 팔레트:**
```swift
// Primary (핑크 계열)
primary: #FFA0B9
primaryDark: #F28AA5
primaryLight: #FFCFDD

// Accent (브라운 계열)
accent: #FBF9F7
accentDark: #7C5E4A
accentLight: #F5E6D3

// Background
background: #FEFAF7
card: #FFFFFF

// Text
textPrimary: #2C2420
textSecondary: #7C5E4A
textTertiary: #A0826D
```

**타이포그래피:**
- System Font (SF Pro Display)
- 동적 타입 지원 (Dynamic Type)

**Spacing:**
```swift
xxs: 4pt
xs: 8pt
s: 12pt
m: 16pt
l: 24pt
xl: 32pt
```

### 8.2 컴포넌트 설계

**Button Styles:**
```swift
.primaryButtonStyle()       // 핑크 배경, 흰색 텍스트
.secondaryButtonStyle()     // 아이보리 배경, 브라운 텍스트
```

**Card Style:**
```swift
.cardStyle(padding: 16)     // 흰색 배경, 그림자, 라운드
```

**Sheet (바텀 시트):**
- SwiftUI `.sheet(isPresented:)`
- 기본 애니메이션 (0.3초)
- 배경 딤처리

### 8.3 화면 구성

**캘린더 탭:**
1. 헤더: 년월, 좌우 화살표, 월 총 매출
2. 캘린더: 7x6 그리드
3. 바텀 시트: 일별 상세 (2단계 중첩 가능)

**결산 탭:**
1. 상단 50%: 결산 결과 (매출, 지출, 순이익)
2. 하단 50%: 지출 관리 (카테고리 목록)
3. 바텀 시트: 금액 입력, 카테고리 편집

**설정 탭:**
1. 시술 목록
2. + 버튼으로 추가
3. 바텀 시트: 시술 편집

---

## 9. 네트워크 및 에러 처리

### 9.1 비동기 처리

**Swift Concurrency (async/await)**
```swift
Task {
    do {
        let treatments = try await treatmentService.fetchTreatments(userId: userId)
        // 성공 처리
    } catch {
        // 에러 처리
    }
}
```

**Main Actor 사용:**
```swift
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []

    func loadItems() async {
        // UI 업데이트는 자동으로 Main Thread
    }
}
```

### 9.2 에러 타입

```swift
enum ServiceError: LocalizedError {
    case networkError(Error)
    case firestoreError(Error)
    case notFound
    case unauthorized
    case invalidData

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .firestoreError(let error):
            return "데이터베이스 오류: \(error.localizedDescription)"
        case .notFound:
            return "데이터를 찾을 수 없습니다."
        case .unauthorized:
            return "권한이 없습니다."
        case .invalidData:
            return "잘못된 데이터입니다."
        }
    }
}
```

### 9.3 오프라인 지원

**Firestore 오프라인 캐싱:**
```swift
let settings = FirestoreSettings()
settings.isPersistenceEnabled = true  // 기본값
Firestore.firestore().settings = settings
```

**동작 방식:**
- 읽기: 로컬 캐시 우선 → 네트워크
- 쓰기: 로컬 즉시 반영 → 백그라운드 동기화

---

## 10. 보안

### 10.1 데이터 보안

**Firestore Security Rules:**
- 인증된 사용자만 접근
- 본인 데이터만 읽기/쓰기 가능
- 서버 측 검증

**민감 정보:**
- GoogleService-Info.plist는 Git 제외
- API Key는 Bundle에 포함 (클라이언트 앱이므로 허용)

### 10.2 입력 검증

**클라이언트 측:**
```swift
// 문자열 길이 제한
guard name.count <= AppConstants.Limits.treatmentNameMaxLength else {
    throw ValidationError.nameTooLong
}

// 가격 유효성
guard price >= 0 else {
    throw ValidationError.invalidPrice
}

// 이메일 형식
guard email.isValidEmail else {
    throw ValidationError.invalidEmail
}
```

---

## 11. 성능 최적화

### 11.1 Firestore 최적화

**쿼리 최적화:**
- 필요한 필드만 조회
- 인덱스 활용
- 페이지네이션 (필요시)

**캐싱 전략:**
- Firestore 내장 오프라인 캐싱 활용
- 자주 사용하는 데이터는 메모리에 유지

### 11.2 UI 최적화

**LazyVStack 사용:**
```swift
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
```

**이미지 최적화:**
- 현재는 이모지만 사용 (추가 최적화 불필요)
- 향후 사진 기능 추가 시 AsyncImage 사용

### 11.3 메모리 관리

**Weak Self 사용:**
```swift
authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
    // ...
}
```

**Cancellable 정리:**
```swift
deinit {
    cancellables.forEach { $0.cancel() }
}
```

---

## 12. 배포

### 12.1 App Store 정보

| 항목 | 내용 |
|------|------|
| **앱 이름** | Vesta |
| **Bundle ID** | com.yourcompany.vesta |
| **카테고리** | 비즈니스 |
| **연령 등급** | 4+ |
| **지원 언어** | 한국어 |
| **지원 기기** | iPhone (iOS 17.0+) |
| **가격** | 무료 |

### 12.2 빌드 설정

**Release Configuration:**
```
Optimization Level: -O (최적화)
Swift Compilation Mode: Whole Module
Bitcode: No (Xcode 14+에서 제거됨)
```

**Info.plist 필수 항목:**
```xml
<key>CFBundleDisplayName</key>
<string>Vesta</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<key>CFBundleVersion</key>
<string>1</string>

<key>UIUserInterfaceStyle</key>
<string>Light</string>
```

### 12.3 배포 체크리스트

**Apple Developer:**
- [ ] App ID 생성
- [ ] Sign In with Apple 활성화
- [ ] Provisioning Profile 생성

**Firebase:**
- [ ] 프로덕션 프로젝트 생성
- [ ] Security Rules 검증
- [ ] 인덱스 생성

**Xcode:**
- [ ] Archive 빌드 성공
- [ ] 앱 아이콘 추가
- [ ] 런치 스크린 설정

**App Store Connect:**
- [ ] 앱 정보 입력
- [ ] 스크린샷 업로드
- [ ] 개인정보 처리방침 링크

---

## 부록

### A. 유틸리티 함수

**날짜 포맷:**
```swift
Date.fromISOString("2026-01-20")
date.toDisplayString()  // "1월 20일"
```

**통화 포맷:**
```swift
50000.formattedKoreanCurrency  // "5만원"
50000.formattedCurrency        // "₩50,000"
```

**색상 변환:**
```swift
Color(hex: "#FFA0B9")
color.toHex()
```

### B. 코딩 컨벤션

**네이밍:**
- 클래스/구조체: PascalCase (TreatmentService)
- 함수/변수: camelCase (fetchTreatments)
- 상수: lowerCamelCase (AppConstants.Spacing.m)

**파일명:**
- 타입명과 동일 (TreatmentService.swift)
- Extensions: Type+Functionality.swift (Date+Formatting.swift)

**주석:**
```swift
// MARK: - Section Name
// MARK: Public Methods
// MARK: Private Methods
```

---

**문서 버전:** 1.0
**최종 수정:** 2026-01-20
