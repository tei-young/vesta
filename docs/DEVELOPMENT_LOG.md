# Development Log - Vesta iOS

> 개발 진행 상황 및 구현 이력

---

## 2026-01-20

### ✅ Phase 1: 환경 구축 및 프로젝트 초기화

#### 1. iOS 프로젝트 구조 생성

**구현 내용:**
- README.md 기획서 기반으로 전체 프로젝트 구조 생성
- 21개 Swift 파일 생성

**디렉토리 구조:**
```
Vesta/
├── App/
│   ├── VestaApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Auth/Views/LoginView.swift
│   ├── Calendar/Views/CalendarTabView.swift
│   ├── Settlement/Views/SettlementTabView.swift
│   └── Settings/Views/SettingsTabView.swift
├── Core/
│   ├── Models/ (6개 파일)
│   │   ├── User.swift
│   │   ├── Treatment.swift
│   │   ├── DailyRecord.swift
│   │   ├── DailyAdjustment.swift
│   │   ├── ExpenseCategory.swift
│   │   └── MonthlyExpense.swift
│   └── Services/
│       └── AuthService.swift
├── Shared/
│   ├── Constants/
│   │   ├── AppColors.swift
│   │   ├── AppConstants.swift
│   │   └── TreatmentColors.swift
│   └── Extensions/
│       ├── Color+Hex.swift
│       ├── Date+Formatting.swift
│       ├── Int+Currency.swift
│       └── View+Modifiers.swift
└── Resources/
    └── Assets.xcassets/
```

**주요 결정 사항:**
- SwiftUI로 전체 UI 구현 결정
- MVVM 아키텍처 패턴 채택
- Features 기반 모듈 구조로 설계

---

#### 2. 앱 진입점 및 인증 플로우 구현

**파일:** `App/VestaApp.swift`

**구현 내용:**
```swift
@main
struct VestaApp: App {
    @StateObject private var authService = AuthService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}
```

**핵심 기능:**
- Firebase 초기화
- AuthService를 EnvironmentObject로 전역 관리
- ContentView에서 인증 상태 분기

---

#### 3. 루트 뷰 및 탭 구조 구현

**파일:** `App/ContentView.swift`

**구현 내용:**
- 인증 상태에 따른 3단계 화면 분기:
  1. `isLoading` → LoadingView
  2. `isAuthenticated` → MainTabView (3개 탭)
  3. 미인증 → LoginView

**MainTabView 구조:**
```swift
TabView {
    CalendarTabView()      // 캘린더 탭
    SettlementTabView()    // 결산 탭
    SettingsTabView()      // 설정 탭
}
```

**UI 결정:**
- SF Symbols 사용 (calendar, chart.bar.fill, gearshape.fill)
- Primary 색상 (핑크) Tint 적용

---

#### 4. 디자인 시스템 구축

**파일:** `Shared/Constants/AppColors.swift`

**구현한 색상 팔레트:**
- **Primary 색상**: 핑크 계열 (#FFA0B9, #F28AA5, #FFCFDD)
- **Accent 색상**: 브라운 계열 (#FBF9F7, #7C5E4A, #F5E6D3)
- **Background**: 아이보리 (#FEFAF7)
- **Text**: 브라운 블랙 (#2C2420, #7C5E4A, #A0826D)

**시술 색상 팔레트:** `Shared/Constants/TreatmentColors.swift`
- 15가지 색상 정의
- TreatmentColorOption 구조체로 관리
- HEX 코드로 색상 접근 가능

**상수 정의:** `Shared/Constants/AppConstants.swift`
- Spacing: xxs(4), xs(8), s(12), m(16), l(24), xl(32)
- Animation: 0.2초 ~ 0.5초
- Limits: 문자열 길이 제한
- DateFormat: 한국어 날짜 형식

---

#### 5. Swift Extensions 구현

**날짜 처리:** `Shared/Extensions/Date+Formatting.swift`

주요 메서드:
```swift
// Date → String 변환
date.toISOString()           // "2026-01-20"
date.toYearMonthString()     // "2026-01"
date.toDisplayString()       // "1월 20일"
date.toMonthDisplayString()  // "2026년 1월"

// String → Date 변환
Date.fromISOString("2026-01-20")
Date.fromYearMonthString("2026-01")

// 날짜 조작
date.startOfDay()
date.startOfMonth()
date.endOfMonth()
date.isSameDay(as: otherDate)
date.isToday()
```

**통화 포맷:** `Shared/Extensions/Int+Currency.swift`

주요 메서드:
```swift
50000.formattedKoreanCurrency  // "5만원"
50000.formattedCurrency        // "₩50,000"
50000.formattedWithComma       // "50,000"

"50,000".intFromCurrencyString // 50000
```

**색상 처리:** `Shared/Extensions/Color+Hex.swift`

```swift
Color(hex: "#FFA0B9")
color.toHex()  // "#FFA0B9"
```

**뷰 수정자:** `Shared/Extensions/View+Modifiers.swift`

유틸리티 modifier:
```swift
.cardStyle()              // 카드 스타일 적용
.primaryButtonStyle()     // 메인 버튼 스타일
.secondaryButtonStyle()   // 보조 버튼 스타일
.if(condition) { ... }    // 조건부 modifier
.dismissKeyboardOnTap()   // 탭으로 키보드 숨김
```

---

#### 6. 데이터 모델 정의

모든 모델에 Firestore 호환성 구현:
- `@DocumentID` 사용으로 Firestore ID 자동 매핑
- `CodingKeys`로 snake_case ↔ camelCase 변환
- 편의 초기화 메서드 제공

**User.swift**
```swift
struct AppUser: Identifiable, Codable {
    let id: String
    var email: String?
    var displayName: String?
    var createdAt: Date
}
```

**Treatment.swift**
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
}
```

**DailyRecord.swift**
```swift
struct DailyRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var treatmentId: String
    var count: Int
    var totalAmount: Int
    var createdAt: Date
    var treatment: Treatment?  // 로컬 조인용
}
```

**DailyAdjustment.swift**
```swift
struct DailyAdjustment: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var amount: Int        // 음수: 할인, 양수: 팁
    var reason: String?
    var createdAt: Date
}
```

**ExpenseCategory.swift**
```swift
struct ExpenseCategory: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var icon: String?
    var order: Int
    var createdAt: Date
}
```

**MonthlyExpense.swift**
```swift
struct MonthlyExpense: Identifiable, Codable {
    @DocumentID var id: String?
    var yearMonth: String  // "2026-01"
    var categoryId: String
    var amount: Int
    var createdAt: Date
    var category: ExpenseCategory?  // 로컬 조인용
}
```

**설계 포인트:**
- 모든 날짜는 `Date.startOfDay()`로 시간 정보 제거
- 조인용 필드는 `CodingKeys`에서 제외
- 계산 속성으로 부가 정보 제공 (unitPrice, absoluteAmount 등)

---

#### 7. Apple Sign In 인증 구현

**파일:** `Core/Services/AuthService.swift`

**구현한 기능:**

1. **인증 상태 관리**
```swift
@Published var currentUser: AppUser?
@Published var isAuthenticated = false
@Published var isLoading = true
```

2. **AuthStateDidChangeListener**
- Firebase Auth 상태 실시간 관찰
- 자동 로그인/로그아웃 처리

3. **Nonce 생성 및 SHA256 해싱**
```swift
func generateNonce() -> String
private func sha256(_ input: String) -> String
```

4. **Apple Sign In 처리**
```swift
func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws
```

5. **로그아웃**
```swift
func signOut() throws
```

**보안 고려사항:**
- Nonce를 사용한 재생 공격(replay attack) 방지
- SHA256 해싱으로 무결성 검증
- 에러 타입 정의 (AuthError enum)

---

#### 8. 로그인 화면 구현

**파일:** `Features/Auth/Views/LoginView.swift`

**UI 구성:**
- 앱 로고 (💅 이모지)
- 앱 이름 (Vesta)
- 설명 ("뷰티샵 매출 관리 앱")
- Sign In with Apple 버튼 (네이티브)

**기능:**
- Apple Sign In 요청 처리
- Nonce 생성 및 SHA256 해싱
- 에러 메시지 표시
- 로딩 오버레이

**UX 개선:**
- 사용자 취소 시 에러 메시지 미표시
- 로딩 중 전체 화면 어둡게
- 에러 발생 시 빨간색 텍스트

---

#### 9. Placeholder Tab Views 생성

임시 화면 구현:
- **CalendarTabView**: "📅 캘린더 탭" 표시
- **SettlementTabView**: "📊 결산 탭" 표시
- **SettingsTabView**: "⚙️ 설정 탭" + 로그아웃 버튼

**목적:**
- 앱 구조 확인
- 탭 전환 테스트
- 인증 플로우 테스트 (로그아웃 기능)

---

#### 10. Xcode 프로젝트 생성 및 통합

**진행 단계:**

1. **기존 소스 백업**
   - `Vesta/` → `Vestasource/` 이름 변경

2. **Xcode 프로젝트 생성**
   - Product Name: Vesta
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App
   - Storage: None
   - Location: `vesta/vesta/`

3. **소스 코드 통합**
   - Xcode 기본 파일 삭제
   - 제작한 소스 복사
   - Vestasource 폴더 삭제

4. **Xcode 프로젝트 설정**
   - ✅ Xcode에서 파일 그룹 추가 (App/, Features/, Core/, Shared/)
   - ✅ Bundle Identifier 설정
   - ✅ iOS 17.0 Minimum Deployment
   - ✅ Firebase SDK 추가 (FirebaseAuth, FirebaseFirestore)

5. **현재 진행 중:**
   - 🟡 Sign In with Apple Capability 추가

---

---

## 2026-01-21

### ✅ Phase 1 완료: Firebase 연동 및 첫 빌드

#### 11. Sign In with Apple Capability 추가

**문제:** Xcode GUI에서 Sign In with Apple capability가 보이지 않음

**해결:**
- `Vesta.entitlements` 파일 수동 생성
- Build Settings에서 Code Signing Entitlements 경로 설정

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.applesignin</key>
	<array>
		<string>Default</string>
	</array>
</dict>
</plist>
```

---

#### 12. Firebase Console 설정

**프로젝트 정보:**
- 프로젝트 ID: `vesta-cbba0`
- 리전: asia-northeast3 (서울)

**Firebase 서비스 설정:**

1. **Authentication**
   - Apple Sign In 활성화 ✅
   - Google Sign In 활성화 ✅

2. **Cloud Firestore**
   - **Production 모드**로 시작
   - Security Rules 적용:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. **GoogleService-Info.plist**
   - CLIENT_ID 포함 버전으로 재다운로드
   - `Vesta/Resources/` 폴더에 추가

---

#### 13. 빌드 에러 해결 과정

**Error #1: Info.plist 충돌**
```
Multiple commands produce '/Users/.../Vesta.app/Info.plist'
```
**원인:** Copy Bundle Resources에 Info.plist 중복
**해결:** 불필요한 Package.swift 파일 제거

---

**Error #2: Firebase 모듈 not found**
```
Unable to find module dependency: 'FirebaseAuth'
Unable to find module dependency: 'FirebaseFirestore'
```
**원인:** Firebase SDK가 PROJECT 레벨에만 추가되고 TARGET에 링크 안됨
**해결:**
- Xcode → TARGETS → Vesta → Frameworks, Libraries, and Embedded Content
- FirebaseAuth, FirebaseFirestore 수동 추가

---

**Error #3: ObservableObject conformance 에러**
```
Type 'AuthService' does not conform to protocol 'ObservableObject'
```
**원인:** `import Combine` 누락
**해결:** AuthService.swift 상단에 추가
```swift
import Foundation
import Combine          // 추가
import FirebaseAuth
import AuthenticationServices
import CryptoKit
```

---

**Error #4: SHA256 not found**
```
Cannot find 'SHA256' in scope
```
**원인:** `import CryptoKit` 누락
**해결:** LoginView.swift 상단에 추가
```swift
import SwiftUI
import AuthenticationServices
import CryptoKit        // 추가
```

---

#### 14. 첫 빌드 성공 ✅

**결과:**
- 빌드 성공
- 로그인 화면 표시 확인
- Apple Sign In 버튼 작동

---

### ✅ Phase 1.5: Google Sign In 추가

#### 15. Google Sign In SDK 추가

**방법:** Swift Package Manager (SPM)

1. Xcode → File → Add Package Dependencies
2. URL: `https://github.com/google/GoogleSignIn-iOS`
3. Version: Up to Next Major (7.0.0)
4. Target: Vesta

**추가된 패키지:**
- GoogleSignIn
- GoogleSignInSwift

---

#### 16. URL Schemes 설정

**Info.plist 수정:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.695726341855-uopcjetojsfedvji4nndsoglrm6nh09i</string>
        </array>
    </dict>
</array>
```

**참고:** REVERSED_CLIENT_ID를 GoogleService-Info.plist에서 가져옴

---

#### 17. VestaApp.swift 수정

**변경 사항:**

1. GoogleSignIn import 추가
2. URL 핸들링 추가

```swift
import SwiftUI
import FirebaseCore
import GoogleSignIn     // 추가

@main
struct VestaApp: App {
    @StateObject private var authService = AuthService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .onOpenURL { url in                    // 추가
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
```

---

#### 18. AuthService.swift에 Google 로그인 구현

**추가된 메서드:**

```swift
import GoogleSignIn  // 추가

/// Google Sign In 처리
func signInWithGoogle() async throws {
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        throw AuthError.invalidToken
    }

    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        throw AuthError.signInFailed("Unable to get root view controller")
    }

    do {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user

        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.invalidToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        print("✅ Google Sign In 성공: \(authResult.user.uid)")
    } catch {
        print("❌ Google Sign In 실패: \(error.localizedDescription)")
        throw AuthError.signInFailed(error.localizedDescription)
    }
}
```

**signOut() 메서드 업데이트:**

```swift
func signOut() throws {
    do {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()  // Google 로그아웃 추가
        print("✅ 로그아웃 성공")
    } catch {
        print("❌ 로그아웃 실패: \(error.localizedDescription)")
        throw AuthError.signOutFailed(error.localizedDescription)
    }
}
```

---

#### 19. LoginView.swift에 Google Sign In 버튼 추가

**UI 변경:**

```swift
// Google Sign In 버튼
Button(action: {
    handleGoogleSignIn()
}) {
    HStack {
        Image(systemName: "g.circle.fill")
            .font(.title2)
        Text("Google로 계속하기")
            .font(.headline)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 50)
    .foregroundColor(.white)
    .background(Color(red: 0.26, green: 0.52, blue: 0.96))
    .cornerRadius(12)
}

// Apple Sign In 버튼 (기존)
SignInWithAppleButton(...)
```

**핸들러 메서드 추가:**

```swift
private func handleGoogleSignIn() {
    isLoading = true
    errorMessage = nil

    Task {
        do {
            try await authService.signInWithGoogle()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
```

---

---

## 2026-01-22

### ✅ Phase 1.5 완료: Google Sign In 테스트 성공

#### 20. Google Sign In 테스트 완료

**결과:**
- ✅ Google Sign In 정상 작동 확인
- ✅ 로그인/로그아웃 정상 동작
- ✅ Firebase Console에서 인증된 사용자 확인 완료

**해결한 이슈:**
- FirebaseCore import 에러 → `Auth.auth().app?.options.clientID` 대신 GoogleService-Info.plist 직접 읽기로 변경
- URL Scheme 에러 → Clean Build 및 앱 재설치로 해결

---

### ✅ Phase 2 완료: 핵심 서비스 레이어 구현

#### 21. FirestoreService.swift 구현 (308줄)

**구현 내용:**
- Firestore 기본 CRUD 유틸리티 클래스
- 사용자별 컬렉션 참조 생성 메서드
- Generic CRUD 메서드 (addDocument, setDocument, updateDocument, deleteDocument)
- 단일/다중 문서 조회 메서드
- 쿼리 기반 문서 조회
- 배치 업데이트 (순서 변경 등에 사용)

**주요 메서드:**
```swift
func getUserCollection(userId: String, collectionName: String) -> CollectionReference
func addDocument<T: Encodable>(_:userId:collectionName:) async throws -> String
func updateDocument(documentId:data:userId:collectionName:) async throws
func deleteDocument(documentId:userId:collectionName:) async throws
func getDocuments<T: Decodable>(userId:collectionName:orderBy:) async throws -> [T]
func queryDocuments<T: Decodable>(userId:collectionName:field:isEqualTo:) async throws -> [T]
func batchUpdate(updates:userId:collectionName:) async throws
```

**에러 처리:**
- FirestoreError enum 정의
- 상세한 에러 메시지 제공

---

#### 22. TreatmentService.swift 구현 (256줄)

**구현 내용:**
- 시술 관리 서비스 (@MainActor, ObservableObject)
- @Published로 실시간 상태 관리

**주요 기능:**
```swift
func fetchTreatments(userId:) async
func addTreatment(name:price:icon:color:userId:) async throws -> String
func updateTreatment(_:userId:) async throws
func deleteTreatment(id:userId:) async throws
func reorderTreatments(_:userId:) async throws
func getTreatment(byId:) -> Treatment?
```

**특징:**
- 로컬 배열 자동 동기화
- order 값 자동 계산
- 배치 업데이트로 순서 변경

---

#### 23. RecordService.swift 구현 (281줄)

**구현 내용:**
- 일별 시술 기록 관리 서비스

**주요 기능:**
```swift
func fetchRecords(userId:date:) async
func fetchMonthlyRecords(userId:year:month:) async -> [DailyRecord]
func addOrUpdateRecord(userId:date:treatmentId:price:) async throws -> String
func updateRecordCount(id:count:totalAmount:userId:) async throws
func deleteRecord(id:userId:) async throws
func getTotalRevenue(for:) -> Int
func groupRecordsByTreatment() -> [String: [DailyRecord]]
```

**특징:**
- 동일 날짜 + 시술 ID 기록 자동 업데이트 (count 증가)
- 날짜별/월별 조회 최적화
- 시작일/종료일 기반 범위 쿼리

---

#### 24. AdjustmentService.swift 구현 (265줄)

**구현 내용:**
- 조정 금액 관리 서비스 (할인, 팁)

**주요 기능:**
```swift
func fetchAdjustments(userId:date:) async
func fetchMonthlyAdjustments(userId:year:month:) async -> [DailyAdjustment]
func addAdjustment(userId:date:amount:reason:) async throws -> String
func updateAdjustment(_:userId:) async throws
func deleteAdjustment(id:userId:) async throws
func getTotalAdjustment(for:) -> Int
func getTotalDiscount(for:) -> Int
func getTotalExtra(for:) -> Int
```

**특징:**
- 음수: 할인, 양수: 팁/추가금액
- 날짜별 총 조정 금액 계산
- 할인/추가 금액 분리 계산

---

#### 25. CategoryService.swift 구현 (280줄)

**구현 내용:**
- 지출 카테고리 관리 서비스

**주요 기능:**
```swift
func fetchCategories(userId:) async
func addCategory(name:icon:userId:) async throws -> String
func updateCategory(_:userId:) async throws
func deleteCategory(id:userId:) async throws
func reorderCategories(_:userId:) async throws
func createDefaultCategories(userId:) async throws
```

**특징:**
- 기본 카테고리 자동 생성 (재료비, 인건비, 월세, 관리비, 기타)
- 순서 변경 지원
- 이모지 아이콘 지원

---

#### 26. ExpenseService.swift 구현 (284줄)

**구현 내용:**
- 월별 지출 관리 서비스

**주요 기능:**
```swift
func fetchExpenses(userId:yearMonth:) async
func upsertExpense(userId:yearMonth:categoryId:amount:) async throws -> String
func deleteExpense(id:userId:) async throws
func copyFromPreviousMonth(userId:fromYearMonth:toYearMonth:) async throws
func getTotalExpense(for:) -> Int
func getExpenseAmount(yearMonth:categoryId:) -> Int
func groupExpensesByCategory() -> [String: MonthlyExpense]
```

**특징:**
- Upsert 방식 (기존 데이터 있으면 업데이트, 없으면 추가)
- 전월 지출 복사 기능 (중복 방지)
- yearMonth 문자열 기반 조회 ("2026-01")

---

### ✅ Phase 5 완료: 설정 탭 구현

#### 27. Date Extension 수정

**문제:** 빌드 에러 발생 (8개)
- Combine import 누락
- `Date.endOfDay()` 메서드 없음

**해결:**
- Date+Formatting.swift에 `endOfDay()` 메서드 추가 (75-80번 라인)
- 모든 서비스 파일에 `import Combine` 추가

---

#### 28. SettingsViewModel.swift 구현 (131줄)

**구현 내용:**
- 시술 관리 ViewModel (@MainActor, ObservableObject)
- TreatmentService와 연동하여 상태 관리

**주요 기능:**
```swift
func fetchTreatments() async
func addTreatment(name:price:icon:color:) async
func updateTreatment(_:) async
func deleteTreatment(_:) async
func showAddSheet()
func showEditSheet(for:)
func signOut()
```

**특징:**
- Combine을 사용한 TreatmentService 상태 구독
- @Published로 실시간 UI 업데이트
- 에러 메시지 처리

---

#### 29. ColorPickerView.swift 구현 (63줄)

**구현 내용:**
- 15색 팔레트 그리드 UI
- TreatmentColors 15가지 색상 표시

**주요 기능:**
- LazyVGrid 레이아웃
- 선택된 색상 하이라이트 (테두리)
- 50x50 원형 버튼

---

#### 30. EmojiTextField.swift 구현 (53줄)

**구현 내용:**
- 이모지 입력 전용 TextField
- 2글자 제한

**주요 기능:**
- 80x80 크기의 큰 입력 필드
- onChange로 2글자 제한 구현
- X 버튼으로 초기화
- 센터 정렬

---

#### 31. TreatmentRow.swift 구현 (88줄)

**구현 내용:**
- 시술 목록 행 UI

**UI 구성:**
- 색상 원형 (50x50) + 아이콘 (이모지)
- 시술명 (headline)
- 가격 (subheadline, formattedCurrency)
- 수정 버튼 (pencil 아이콘)
- 삭제 버튼 (trash 아이콘)

---

#### 32. TreatmentEditSheet.swift 구현 (154줄)

**구현 내용:**
- 시술 추가/수정 바텀 시트 (NavigationView + Form)

**UI 구성:**
- 시술명 입력 (TextField)
- 가격 입력 (numberPad 키보드, 숫자만 입력)
- 가격 미리보기 (formattedCurrency)
- 아이콘 선택 (EmojiTextField)
- 색상 선택 (ColorPickerView)

**기능:**
- 추가/수정 모드 자동 전환
- 유효성 검사 (이름, 가격 필수)
- 취소/저장 버튼

---

#### 33. SettingsTabView.swift 업데이트 (136줄)

**구현 내용:**
- 시술 목록 표시 (List + Section)
- 시술 추가/수정/삭제 기능
- 앱 정보 섹션

**UI 구성:**
- 시술 관리 섹션
  - 시술 목록 (ForEach + TreatmentRow)
  - 빈 상태 메시지
  - + 버튼 (toolbar)
- 앱 정보 섹션
  - 앱 버전 표시
  - 로그아웃 버튼

**기능:**
- sheet로 TreatmentEditSheet 표시
- alert로 삭제 확인
- .task로 데이터 로딩
- .overlay로 로딩 인디케이터

---

## 다음 단계

### 이후 계획:
- Phase 3: 캘린더 탭 완성
- Phase 4: 결산 탭 완성

---

## 기술적 의사결정

### 1. SwiftUI 선택 이유
- 선언적 UI로 코드 가독성 향상
- 상태 관리가 간단 (@Published, @State 등)
- iOS 17+ 타겟이므로 최신 기능 사용 가능

### 2. MVVM 패턴 채택
- SwiftUI와 궁합이 좋음
- ViewModel에서 비즈니스 로직 분리
- View는 순수하게 UI 렌더링만 담당

### 3. Firebase Firestore 선택
- 실시간 동기화 가능
- 오프라인 지원 내장
- Security Rules로 데이터 보호
- 확장성 우수

### 4. Package.swift (SPM) 사용
- CocoaPods보다 가볍고 빠름
- Xcode에 기본 통합
- 버전 관리가 명확

### 5. 사용자별 데이터 격리 구조
```
users/{userId}/treatments/...
users/{userId}/dailyRecords/...
users/{userId}/dailyAdjustments/...
users/{userId}/expenseCategories/...
users/{userId}/monthlyExpenses/...
```
- 완전한 데이터 격리
- Security Rules 적용 간단
- 멀티 테넌시 지원

---

## 이슈 및 해결

### Issue #1: Xcode 프로젝트 파일 생성
**문제:** CLI로 생성한 Swift 파일들을 Xcode 프로젝트로 통합 필요

**해결:**
1. Xcode GUI로 프로젝트 생성
2. 기본 파일 삭제 후 소스 복사
3. "Add Files to Project"로 그룹 추가

---

## 성능 고려사항

### 현재 최적화
- Lazy 로딩 사용 (LazyVStack 향후 적용)
- Firestore 쿼리 최소화 설계
- 이미지 미사용 (이모지만 사용)

### 향후 최적화 계획
- Firestore 인덱스 생성
- 페이지네이션 (필요시)
- 이미지 캐싱 (사진 기능 추가 시)

---

## 코드 통계

### Phase 5 완료 후
- **Swift 파일**: 33개 (+6개)
- **총 코드 라인**: 약 3,805줄 (+631줄)
- **모델**: 6개
- **서비스**: 7개 (AuthService + 6개 비즈니스 레이어)
  - AuthService (198줄)
  - FirestoreService (308줄)
  - TreatmentService (256줄)
  - RecordService (281줄)
  - AdjustmentService (265줄)
  - CategoryService (280줄)
  - ExpenseService (284줄)
- **ViewModel**: 1개
  - SettingsViewModel (131줄)
- **뷰**: 13개 (+5개)
  - 기존 8개 (LoginView, CalendarTabView, SettlementTabView, SettingsTabView 등)
  - TreatmentRow (88줄)
  - TreatmentEditSheet (154줄)
- **공용 컴포넌트**: 2개
  - ColorPickerView (63줄)
  - EmojiTextField (53줄)
- **Extensions**: 4개 (Date+Formatting에 endOfDay() 추가)
- **Constants**: 3개
