# vesta

# KIMUU iOS 네이티브 앱 마이그레이션 기획서

## 문서 정보

| 항목 | 내용 |
|------|------|
| **프로젝트명** | KIMUU |
| **문서 버전** | v1.0 |
| **작성일** | 2026-01-19 |
| **목적** | PWA → iOS 네이티브 앱 전환 및 Firebase 인프라 구축 |

---

# 1. 프로젝트 개요

## 1.1 서비스 소개

**KIMUU**는 개인 뷰티샵(네일, 속눈썹, 왁싱 등) 운영자를 위한 매출 관리 앱입니다.

일별 시술 기록과 월별 결산(매출/지출/순이익)을 간편하게 관리할 수 있으며, 직관적인 캘린더 UI를 통해 한눈에 매출 현황을 파악할 수 있습니다.

## 1.2 마이그레이션 목표

| 현재 (AS-IS) | 목표 (TO-BE) |
|-------------|-------------|
| PWA (React + Vite) | iOS 네이티브 앱 (SwiftUI) |
| Supabase (PostgreSQL) | Firebase (Firestore) |
| 단일 사용자 | 100~200명 다중 사용자 |
| 인증 없음 | Apple Sign In |

## 1.3 핵심 요구사항

- 현재 PWA의 모든 기능을 iOS 네이티브로 1:1 구현
- 개별 회원가입/로그인 (Apple Sign In)
- 사용자별 데이터 완전 분리
- 기존 데이터 마이그레이션 지원

---

# 2. 현재 시스템 분석 (PWA)

## 2.1 기술 스택

### Frontend

| 기술 | 버전 | 역할 |
|------|------|------|
| React | 19.2.0 | UI 라이브러리 |
| TypeScript | 5.9.3 | 타입 안전성 |
| Vite | 7.2.2 | 빌드 도구 |
| Tailwind CSS | 3.4.18 | 스타일링 |
| React Query | 5.90.9 | 서버 상태 관리 |
| vaul | 1.1.2 | 바텀 시트 |
| date-fns | 4.1.0 | 날짜 처리 |
| lucide-react | 0.553.0 | 아이콘 |

### Backend

| 기술 | 역할 |
|------|------|
| Supabase | BaaS |
| PostgreSQL | 데이터베이스 |

## 2.2 주요 기능

### Tab 1: 캘린더 (시술 기록)

| 기능 | 설명 |
|------|------|
| 월별 캘린더 뷰 | 월 네비게이션, 날짜별 시술 도트 표시 |
| 월 총 매출 | 상단에 해당 월 총 매출 표시 |
| 일별 시술 기록 | 날짜 클릭 시 바텀 시트로 상세 조회 |
| 시술 추가 | 시술 선택 → 자동 기록 (중복 시 수량 증가) |
| 수량 조절 | +/- 버튼으로 시술 횟수 조절 |
| 금액 수정 | 개별 시술 금액 직접 수정 가능 |
| 조정 금액 | 할인(음수) 또는 팁(양수) 추가 |

### Tab 2: 결산 (월별 재무)

| 기능 | 설명 |
|------|------|
| 월별 매출 | 해당 월 시술 매출 + 조정 금액 합계 |
| 월별 지출 | 카테고리별 지출 금액 입력 |
| 순이익 계산 | 매출 - 지출 = 순이익 자동 계산 |
| 이전 달 불러오기 | 전월 지출 데이터 복사 기능 |
| 지출 카테고리 관리 | 카테고리 추가/수정/삭제 |

### Tab 3: 설정 (시술 관리)

| 기능 | 설명 |
|------|------|
| 시술 목록 | 등록된 시술 항목 조회 |
| 시술 추가 | 이름, 가격, 이모지, 색상 설정 |
| 시술 수정 | 기존 시술 정보 편집 |
| 시술 삭제 | 시술 항목 삭제 |
| 순서 변경 | 드래그로 정렬 순서 변경 |
| 색상 팔레트 | 15가지 색상 중 선택 |

## 2.3 데이터베이스 스키마 (PostgreSQL)

### treatments (시술 마스터)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID | Primary Key |
| name | TEXT | 시술명 (UNIQUE) |
| price | INTEGER | 가격 (원) |
| icon | TEXT | 이모지 (선택) |
| color | TEXT | HEX 색상코드 |
| order | INTEGER | 정렬 순서 |
| created_at | TIMESTAMPTZ | 생성일시 |
| updated_at | TIMESTAMPTZ | 수정일시 |

### daily_records (일별 시술 기록)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID | Primary Key |
| date | DATE | 시술일 |
| treatment_id | UUID | FK → treatments |
| count | INTEGER | 시술 횟수 |
| total_amount | INTEGER | 총액 |
| created_at | TIMESTAMPTZ | 생성일시 |

- UNIQUE 제약: (date, treatment_id)

### daily_adjustments (일별 조정)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID | Primary Key |
| date | DATE | 조정일 |
| amount | INTEGER | 금액 (음수=할인, 양수=팁) |
| reason | TEXT | 사유 (선택) |
| created_at | TIMESTAMPTZ | 생성일시 |

### expense_categories (지출 카테고리)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID | Primary Key |
| name | TEXT | 카테고리명 (UNIQUE) |
| icon | TEXT | 이모지 (선택) |
| order | INTEGER | 정렬 순서 |
| created_at | TIMESTAMPTZ | 생성일시 |

### monthly_expenses (월별 지출)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | UUID | Primary Key |
| year_month | TEXT | 'YYYY-MM' 형식 |
| category_id | UUID | FK → expense_categories |
| amount | INTEGER | 지출액 |
| created_at | TIMESTAMPTZ | 생성일시 |

- UNIQUE 제약: (year_month, category_id)

## 2.4 디자인 시스템

### 색상 테마

```
Primary (핑크)
├── primary: #FFA0B9 (메인)
├── primaryDark: #F28AA5 (호버)
└── primaryLight: #FFCFDD (배지)

Accent (브라운)
├── accent: #FBF9F7 (카드 배경)
├── accentDark: #7C5E4A (강조)
└── accentLight: #F5E6D3 (하이라이트)

Background
├── background: #FEFAF7 (아이보리)
└── card: #FFFFFF (화이트)

Text
├── textPrimary: #2C2420 (본문)
├── textSecondary: #7C5E4A (부제)
└── textTertiary: #A0826D (힌트)
```

### 시술 색상 팔레트 (15가지)

| 이름 | HEX 코드 |
|------|----------|
| 메인 핑크 | #FFA0B9 |
| 어두운 핑크 | #F28AA5 |
| 로즈 핑크 | #E891A3 |
| 코랄 핑크 | #F5A08C |
| 라벤더 | #C9A0DC |
| 피치 | #FFCBA4 |
| 레드 | #FF6B6B |
| 오렌지 | #FFA94D |
| 옐로우 | #FFE066 |
| 민트 | #63E6BE |
| 스카이블루 | #74C0FC |
| 퍼플 | #B197FC |
| 브라운 | #A67C52 |
| 그레이 | #868E96 |
| 라이트그레이 | #DEE2E6 |

---

# 3. iOS 네이티브 앱 설계

## 3.1 기술 스택

| 계층 | 기술 | 버전 | 비고 |
|------|------|------|------|
| Platform | iOS | 17.0+ | 최소 지원 버전 |
| Language | Swift | 5.9+ | 최신 문법 사용 |
| UI Framework | SwiftUI | - | 선언적 UI |
| Architecture | MVVM | - | SwiftUI 권장 패턴 |
| Backend | Firebase | - | BaaS |
| Database | Cloud Firestore | - | NoSQL |
| Auth | Firebase Auth | - | Apple Sign In |
| Package Manager | SPM | - | Swift Package Manager |

## 3.2 Firebase SDK 의존성

```swift
// Package.swift 또는 Xcode SPM
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
]

// 사용할 제품
- FirebaseAuth
- FirebaseFirestore
- FirebaseAnalytics (선택)
```

## 3.3 프로젝트 구조

```
KIMUU/
├── App/
│   ├── KIMUUApp.swift                 # @main 진입점
│   └── ContentView.swift              # 루트 뷰 (인증 분기)
│
├── Features/
│   ├── Auth/
│   │   ├── Views/
│   │   │   └── LoginView.swift
│   │   └── ViewModels/
│   │       └── AuthViewModel.swift
│   │
│   ├── Calendar/
│   │   ├── Views/
│   │   │   ├── CalendarTabView.swift
│   │   │   ├── MonthHeaderView.swift
│   │   │   ├── CalendarGridView.swift
│   │   │   ├── DayCell.swift
│   │   │   ├── DayDetailSheet.swift
│   │   │   ├── RecordRow.swift
│   │   │   ├── AdjustmentRow.swift
│   │   │   └── TreatmentPickerSheet.swift
│   │   └── ViewModels/
│   │       └── CalendarViewModel.swift
│   │
│   ├── Settlement/
│   │   ├── Views/
│   │   │   ├── SettlementTabView.swift
│   │   │   ├── RevenueCard.swift
│   │   │   ├── ExpenseSection.swift
│   │   │   ├── ExpenseRow.swift
│   │   │   ├── ProfitCard.swift
│   │   │   └── CategoryEditSheet.swift
│   │   └── ViewModels/
│   │       └── SettlementViewModel.swift
│   │
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsTabView.swift
│       │   ├── TreatmentListView.swift
│       │   ├── TreatmentRow.swift
│       │   └── TreatmentEditSheet.swift
│       └── ViewModels/
│           └── SettingsViewModel.swift
│
├── Core/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Treatment.swift
│   │   ├── DailyRecord.swift
│   │   ├── DailyAdjustment.swift
│   │   ├── ExpenseCategory.swift
│   │   └── MonthlyExpense.swift
│   │
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── FirestoreService.swift
│   │   ├── TreatmentService.swift
│   │   ├── RecordService.swift
│   │   ├── AdjustmentService.swift
│   │   ├── CategoryService.swift
│   │   └── ExpenseService.swift
│   │
│   └── Repositories/
│       └── (Service와 ViewModel 사이 추상화 레이어 - 선택)
│
├── Shared/
│   ├── Components/
│   │   ├── ColorPickerView.swift
│   │   ├── EmojiTextField.swift
│   │   ├── CurrencyTextField.swift
│   │   ├── LoadingOverlay.swift
│   │   └── EmptyStateView.swift
│   │
│   ├── Extensions/
│   │   ├── Date+Formatting.swift
│   │   ├── Int+Currency.swift
│   │   ├── Color+Hex.swift
│   │   └── View+Modifiers.swift
│   │
│   └── Constants/
│       ├── AppColors.swift
│       ├── TreatmentColors.swift
│       └── AppConstants.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── GoogleService-Info.plist
    └── Localizable.strings (선택)
```

## 3.4 데이터 모델 (Swift)

### User.swift

```swift
struct AppUser: Identifiable, Codable {
    let id: String              // Firebase Auth UID
    var email: String?
    var displayName: String?
    var createdAt: Date
}
```

### Treatment.swift

```swift
struct Treatment: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var price: Int
    var icon: String?
    var color: String
    var order: Int
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, price, icon, color, order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

### DailyRecord.swift

```swift
struct DailyRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var treatmentId: String
    var count: Int
    var totalAmount: Int
    var createdAt: Date

    var treatment: Treatment?  // 로컬 조인용

    enum CodingKeys: String, CodingKey {
        case id, date, count
        case treatmentId = "treatment_id"
        case totalAmount = "total_amount"
        case createdAt = "created_at"
    }
}
```

### DailyAdjustment.swift

```swift
struct DailyAdjustment: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var amount: Int         // 음수: 할인, 양수: 팁
    var reason: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, date, amount, reason
        case createdAt = "created_at"
    }
}
```

### ExpenseCategory.swift

```swift
struct ExpenseCategory: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var icon: String?
    var order: Int
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, icon, order
        case createdAt = "created_at"
    }
}
```

### MonthlyExpense.swift

```swift
struct MonthlyExpense: Identifiable, Codable {
    @DocumentID var id: String?
    var yearMonth: String       // "YYYY-MM"
    var categoryId: String
    var amount: Int
    var createdAt: Date

    var category: ExpenseCategory?  // 로컬 조인용

    enum CodingKeys: String, CodingKey {
        case id, amount
        case yearMonth = "year_month"
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}
```

---

# 4. Firebase 백엔드 설계

## 4.1 Firebase 프로젝트 구성

| 서비스 | 용도 |
|--------|------|
| Firebase Auth | 사용자 인증 (Apple Sign In) |
| Cloud Firestore | 데이터베이스 |
| Firebase Analytics | 사용자 행동 분석 (선택) |

## 4.2 Firestore 데이터 구조

```
users/
  └── {userId}/                          # Firebase Auth UID
        │
        ├── profile/                     # 사용자 정보 (단일 문서)
        │     └── info: {
        │           email: string,
        │           displayName: string?,
        │           createdAt: timestamp
        │         }
        │
        ├── treatments/                  # 시술 마스터
        │     ├── {treatmentId}: {
        │     │     name: string,
        │     │     price: number,
        │     │     icon: string?,
        │     │     color: string,
        │     │     order: number,
        │     │     created_at: timestamp,
        │     │     updated_at: timestamp
        │     │   }
        │     └── ...
        │
        ├── dailyRecords/               # 일별 시술 기록
        │     ├── {recordId}: {
        │     │     date: timestamp,
        │     │     treatment_id: string,
        │     │     count: number,
        │     │     total_amount: number,
        │     │     created_at: timestamp
        │     │   }
        │     └── ...
        │
        ├── dailyAdjustments/           # 일별 조정
        │     ├── {adjustmentId}: {
        │     │     date: timestamp,
        │     │     amount: number,
        │     │     reason: string?,
        │     │     created_at: timestamp
        │     │   }
        │     └── ...
        │
        ├── expenseCategories/          # 지출 카테고리
        │     ├── {categoryId}: {
        │     │     name: string,
        │     │     icon: string?,
        │     │     order: number,
        │     │     created_at: timestamp
        │     │   }
        │     └── ...
        │
        └── monthlyExpenses/            # 월별 지출
              ├── {expenseId}: {
              │     year_month: string,   // "2026-01"
              │     category_id: string,
              │     amount: number,
              │     created_at: timestamp
              │   }
              └── ...
```

## 4.3 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 인증된 사용자만 접근 가능
    function isAuthenticated() {
      return request.auth != null;
    }

    // 본인 데이터만 접근 가능
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // 사용자별 모든 데이터
    match /users/{userId}/{document=**} {
      allow read, write: if isOwner(userId);
    }
  }
}
```

## 4.4 Firestore 인덱스

| 컬렉션 | 필드 | 용도 |
|--------|------|------|
| dailyRecords | date (ASC), created_at (DESC) | 날짜별 기록 조회 |
| dailyRecords | date (ASC), treatment_id (ASC) | 중복 체크 |
| monthlyExpenses | year_month (ASC), category_id (ASC) | 월별 지출 조회 |
| treatments | order (ASC) | 정렬된 시술 목록 |
| expenseCategories | order (ASC) | 정렬된 카테고리 목록 |

## 4.5 인증 설정

### Apple Sign In 구성

1. **Apple Developer 설정**
   - Identifiers → App ID → Sign In with Apple 활성화
   - Keys → Sign In with Apple Key 생성

2. **Firebase Console 설정**
   - Authentication → Sign-in method → Apple 활성화

3. **Xcode 설정**
   - Signing & Capabilities → + Sign In with Apple

## 4.6 Firebase 비용 예측

### Spark Plan (무료)

| 리소스 | 무료 한도 | 예상 사용량 (200명) |
|--------|----------|-------------------|
| Firestore 읽기 | 50,000/일 | ~20,000/일 |
| Firestore 쓰기 | 20,000/일 | ~3,000/일 |
| Firestore 삭제 | 20,000/일 | ~500/일 |
| 저장 용량 | 1GB | ~100MB |
| Auth | 무제한 | 200명 |

**예상 월 비용: $0** (무료 범위 내)

---

# 5. 서비스 구현 가이드

## 5.1 AuthService

```swift
import FirebaseAuth
import AuthenticationServices

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = true

    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoading = false
            if let user = user {
                self?.currentUser = AppUser(from: user)
                self?.isAuthenticated = true
            } else {
                self?.currentUser = nil
                self?.isAuthenticated = false
            }
        }
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async throws {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidToken
        }

        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: tokenString,
            rawNonce: nonce
        )

        try await Auth.auth().signIn(with: firebaseCredential)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
```

## 5.2 TreatmentService

```swift
import FirebaseFirestore

class TreatmentService {
    private let db = Firestore.firestore()

    private func userTreatmentsRef(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("treatments")
    }

    // MARK: - Read
    func fetchTreatments(userId: String) async throws -> [Treatment] {
        let snapshot = try await userTreatmentsRef(userId: userId)
            .order(by: "order")
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Treatment.self)
        }
    }

    // MARK: - Create
    func addTreatment(_ treatment: Treatment, userId: String) async throws {
        try userTreatmentsRef(userId: userId)
            .document()
            .setData(from: treatment)
    }

    // MARK: - Update
    func updateTreatment(_ treatment: Treatment, userId: String) async throws {
        guard let id = treatment.id else { return }
        try userTreatmentsRef(userId: userId)
            .document(id)
            .setData(from: treatment, merge: true)
    }

    // MARK: - Delete
    func deleteTreatment(id: String, userId: String) async throws {
        try await userTreatmentsRef(userId: userId)
            .document(id)
            .delete()
    }

    // MARK: - Reorder
    func reorderTreatments(_ treatments: [Treatment], userId: String) async throws {
        let batch = db.batch()

        for (index, treatment) in treatments.enumerated() {
            guard let id = treatment.id else { continue }
            let ref = userTreatmentsRef(userId: userId).document(id)
            batch.updateData(["order": index], forDocument: ref)
        }

        try await batch.commit()
    }
}
```

## 5.3 RecordService

```swift
class RecordService {
    private let db = Firestore.firestore()

    private func userRecordsRef(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("dailyRecords")
    }

    // 특정 날짜 기록 조회
    func fetchRecords(userId: String, date: Date) async throws -> [DailyRecord] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let snapshot = try await userRecordsRef(userId: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: DailyRecord.self)
        }
    }

    // 월별 기록 조회
    func fetchMonthlyRecords(userId: String, year: Int, month: Int) async throws -> [DailyRecord] {
        let components = DateComponents(year: year, month: month, day: 1)
        let startOfMonth = Calendar.current.date(from: components)!
        let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!

        let snapshot = try await userRecordsRef(userId: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfMonth)
            .whereField("date", isLessThan: endOfMonth)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: DailyRecord.self)
        }
    }

    // 기록 추가 (중복 시 수량 증가)
    func addOrUpdateRecord(userId: String, date: Date, treatmentId: String, price: Int) async throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        // 같은 날짜 + 같은 시술 찾기
        let snapshot = try await userRecordsRef(userId: userId)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .whereField("treatment_id", isEqualTo: treatmentId)
            .getDocuments()

        if let existingDoc = snapshot.documents.first,
           var existingRecord = try? existingDoc.data(as: DailyRecord.self) {
            // 기존 기록 업데이트 (수량 +1)
            existingRecord.count += 1
            existingRecord.totalAmount += price
            try userRecordsRef(userId: userId)
                .document(existingDoc.documentID)
                .setData(from: existingRecord)
        } else {
            // 새 기록 생성
            let newRecord = DailyRecord(
                date: startOfDay,
                treatmentId: treatmentId,
                count: 1,
                totalAmount: price,
                createdAt: Date()
            )
            try userRecordsRef(userId: userId)
                .document()
                .setData(from: newRecord)
        }
    }
}
```

---

# 6. 기능 매핑 테이블

## PWA → iOS 컴포넌트 매핑

| PWA (React) | iOS (SwiftUI) | 비고 |
|-------------|---------------|------|
| `TabBar` | `TabView` | 네이티브 탭 |
| `Calendar` | `CalendarGridView` | 커스텀 구현 |
| `Sheet` (vaul) | `.sheet(isPresented:)` | 네이티브 시트 |
| `TreatmentButton` | `TreatmentButton` | 커스텀 뷰 |
| `ColorPicker` | `ColorPickerView` | 커스텀 뷰 |
| React Query | `@Published` + async/await | Combine 활용 |
| Supabase Client | Firebase SDK | 서비스 레이어 |

## 유틸리티 매핑

| PWA (TypeScript) | iOS (Swift) |
|------------------|-------------|
| `formatCurrency(50000)` → "5만원" | `Int.formattedKoreanCurrency` |
| `formatFullCurrency(50000)` → "₩50,000" | `Int.formattedCurrency` |
| `formatDate(date)` → "2026-01-19" | `Date.toISOString` |
| `formatDisplayDate()` → "1월 19일" | `Date.displayString` |
| `formatYearMonth()` → "2026-01" | `Date.yearMonthString` |

---

# 7. 데이터 마이그레이션

## 7.1 마이그레이션 전략

기존 Supabase 데이터를 Firebase로 이전하는 절차입니다.

### Step 1: Supabase 데이터 Export

```sql
SELECT * FROM treatments;
SELECT * FROM daily_records;
SELECT * FROM daily_adjustments;
SELECT * FROM expense_categories;
SELECT * FROM monthly_expenses;
```

### Step 2: JSON 변환

```json
{
  "treatments": [...],
  "dailyRecords": [...],
  "dailyAdjustments": [...],
  "expenseCategories": [...],
  "monthlyExpenses": [...]
}
```

### Step 3: Firebase Import 스크립트

```javascript
const admin = require('firebase-admin');
const data = require('./exported-data.json');

const userId = 'FIRST_USER_ID';

async function migrate() {
  const db = admin.firestore();
  const userRef = db.collection('users').doc(userId);

  for (const t of data.treatments) {
    await userRef.collection('treatments').doc(t.id).set({
      name: t.name,
      price: t.price,
      icon: t.icon,
      color: t.color,
      order: t.order,
      created_at: new Date(t.created_at),
      updated_at: new Date(t.updated_at)
    });
  }

  // 나머지 컬렉션도 동일하게 처리
}

migrate();
```

## 7.2 기존 PWA 앱 운영 방안

### 병행 운영 전략

기존 Supabase 기반 PWA 앱은 **그대로 유지**하고, iOS 앱은 Firebase를 사용하는 **병행 운영** 방식을 권장합니다.

```
┌─────────────────────────────────────────────────────────────┐
│                      현재 사용자                             │
│                          │                                  │
│              ┌───────────┴───────────┐                      │
│              ▼                       ▼                      │
│     ┌─────────────────┐     ┌─────────────────┐            │
│     │  기존 PWA 앱    │     │  신규 iOS 앱    │            │
│     │  (React/Vite)   │     │  (SwiftUI)      │            │
│     └────────┬────────┘     └────────┬────────┘            │
│              │                       │                      │
│              ▼                       ▼                      │
│     ┌─────────────────┐     ┌─────────────────┐            │
│     │   Supabase      │     │    Firebase     │            │
│     │  (PostgreSQL)   │     │  (Firestore)    │            │
│     └─────────────────┘     └─────────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### 운영 시나리오

| 사용자 유형 | 사용 앱 | 데이터베이스 |
|------------|--------|-------------|
| 기존 사용자 (PWA 계속 사용) | PWA | Supabase (기존 데이터 유지) |
| 기존 사용자 (iOS로 전환) | iOS | Firebase (데이터 마이그레이션) |
| 신규 사용자 | iOS | Firebase |

### 주의사항

1. **데이터 동기화 없음**: PWA와 iOS 앱 간 실시간 동기화는 지원하지 않습니다.
2. **일회성 마이그레이션**: 기존 사용자가 iOS로 전환 시, Supabase → Firebase로 일회성 데이터 복사를 수행합니다.
3. **Supabase 유지**: 기존 PWA 사용자가 있는 한 Supabase 인스턴스를 유지해야 합니다.
4. **점진적 전환**: 사용자들이 자연스럽게 iOS 앱으로 전환할 때까지 PWA를 유지합니다.

### PWA 종료 시점

다음 조건이 충족되면 PWA 및 Supabase 종료를 검토합니다:

- [ ] 모든 기존 사용자가 iOS 앱으로 전환 완료
- [ ] Supabase 접속 로그가 일정 기간 없음
- [ ] 사용자에게 PWA 종료 사전 안내 완료

## 7.3 데이터 타입 변환

| PostgreSQL | Firestore | 변환 방법 |
|------------|-----------|----------|
| UUID | String (Document ID) | 그대로 사용 또는 자동 생성 |
| DATE | Timestamp | `new Date(dateString)` |
| TIMESTAMPTZ | Timestamp | `new Date(timestampString)` |
| INTEGER | Number | 그대로 |
| TEXT | String | 그대로 |

---

# 8. 개발 체크리스트

## Phase 1: 환경 구축

- [ ] Firebase 프로젝트 생성
- [ ] iOS Xcode 프로젝트 생성
- [ ] Firebase SDK 연동
- [ ] Apple Sign In 설정
- [ ] 기본 인증 플로우 구현

## Phase 2: 핵심 모델 및 서비스

- [ ] 데이터 모델 정의 (5개)
- [ ] Firestore 서비스 구현
- [ ] AuthService 구현
- [ ] 공용 컴포넌트 구현

## Phase 3: 캘린더 탭

- [ ] CalendarTabView
- [ ] MonthHeaderView
- [ ] CalendarGridView
- [ ] DayDetailSheet
- [ ] TreatmentPickerSheet
- [ ] CalendarViewModel

## Phase 4: 결산 탭

- [ ] SettlementTabView
- [ ] RevenueCard
- [ ] ExpenseSection
- [ ] ProfitCard
- [ ] CategoryEditSheet
- [ ] SettlementViewModel

## Phase 5: 설정 탭

- [ ] SettingsTabView
- [ ] TreatmentListView
- [ ] TreatmentEditSheet
- [ ] SettingsViewModel

## Phase 6: 마무리

- [ ] 기존 데이터 마이그레이션
- [ ] 전체 테스트
- [ ] UI/UX 폴리싱
- [ ] TestFlight 배포
- [ ] App Store 출시

---

# 9. 설정 체크리스트

## Apple Developer 설정

- [ ] Apple Developer Program 등록
- [ ] App ID 생성 (Sign In with Apple 활성화)
- [ ] Provisioning Profile 생성
- [ ] Sign In with Apple Key 생성

## Firebase Console 설정

- [ ] 프로젝트 생성
- [ ] iOS 앱 등록
- [ ] GoogleService-Info.plist 다운로드
- [ ] Authentication > Apple 활성화
- [ ] Firestore Database 생성
- [ ] Security Rules 설정
- [ ] 필요한 인덱스 생성

## Xcode 프로젝트 설정

- [ ] Bundle Identifier 설정
- [ ] Team 설정
- [ ] Sign In with Apple Capability 추가
- [ ] GoogleService-Info.plist 추가
- [ ] Firebase SPM 패키지 추가
- [ ] 최소 iOS 버전 17.0 설정

---

# 10. 참고 자료

## 공식 문서

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth/ios/apple)
- [Sign In with Apple](https://developer.apple.com/sign-in-with-apple/)

---

*문서 끝*
