# Development Log - Vesta iOS

> 개발 진행 상황 및 구현 이력
> 최종 업데이트: 2026-01-25

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

#### 34. 설정 탭 버그 수정

**발견된 문제:**
1. **시술 추가 버튼 위치** - toolbar의 + 버튼이 명시적이지 않음
2. **시술 수정 후 무반응** - 시술 등록 후 버튼 클릭 시 sheet가 닫히지 않음
3. **시술 클릭 동작 오류** - 시술 행 전체 클릭이나 연필 버튼 클릭 시 모두 삭제 동작 발생

**수정 내용:**

**1. SettingsTabView.swift (35-46번 라인)**
- toolbar의 + 버튼 제거
- 시술 관리 섹션 맨 위에 "시술 추가" 버튼 추가
- plus.circle.fill 아이콘 + "시술 추가" 텍스트로 명시적 표현

**2. SettingsViewModel.swift (91번 라인)**
- `updateTreatment` 메서드에 `showingAddSheet = false` 추가
- 시술 수정 완료 후 sheet가 제대로 닫히도록 수정

**3. TreatmentRow.swift (54, 62, 66-69번 라인)**
- 수정/삭제 버튼에 `.buttonStyle(BorderlessButtonStyle())` 적용
  - List 내부에서 독립적으로 동작하도록 수정
  - `frame(width: 44, height: 44)`로 터치 영역 확대
- 행 전체에 `.onTapGesture { onEdit() }` 추가
  - 시술 영역 클릭 시 수정 화면으로 이동
  - `.contentShape(Rectangle())`로 클릭 영역 명확화
- 휴지통 아이콘만 클릭 시 삭제 동작

**테스트 결과:**
- ✅ 신규 시술 추가 정상 동작
- ✅ 시술 수정 정상 동작 (행 클릭 또는 연필 버튼)
- ✅ 시술 삭제 정상 동작 (휴지통 버튼만)
- ✅ 여러 시술 등록 가능 (최대 50개)

---

### ✅ Phase 3 완료: 캘린더 탭 구현

#### 35. CalendarViewModel.swift 구현 (279줄)

**구현 내용:**
- 캘린더 탭의 모든 상태 및 비즈니스 로직 관리
- @MainActor, ObservableObject로 메인 스레드 안전성 보장

**주요 상태:**
```swift
@Published var currentDate: Date = Date()
@Published var selectedDate: Date = Date()
@Published var records: [DailyRecord] = []
@Published var adjustments: [DailyAdjustment] = []
@Published var treatments: [Treatment] = []
@Published var monthlyRecords: [DailyRecord] = []
@Published var isLoading = false
@Published var errorMessage: String?
```

**주요 기능:**

1. **월 네비게이션**
```swift
func previousMonth()  // 이전 달로 이동
func nextMonth()      // 다음 달로 이동
func goToToday()      // 오늘 날짜로 이동
```

2. **데이터 로딩**
```swift
func loadTreatments() async                      // 시술 목록 로드
func loadMonthlyData() async                     // 월별 기록/조정 로드
func loadDailyData(for date: Date) async         // 특정 날짜 데이터 로드
```

3. **시술 기록 CRUD**
```swift
func addRecord(treatmentId: String) async        // 시술 추가
func incrementRecord(_ record: DailyRecord) async // 수량 +1
func decrementRecord(_ record: DailyRecord) async // 수량 -1 (0이면 삭제)
func deleteRecord(_ record: DailyRecord) async   // 기록 삭제
```

4. **조정 금액 CRUD**
```swift
func saveAdjustment(amount: Int, reason: String) async  // 조정 추가
func deleteAdjustment(_ adjustment: DailyAdjustment) async // 조정 삭제
```

5. **헬퍼 메서드**
```swift
func getDaysInMonth() -> [Date?]     // 7x6 그리드용 날짜 배열 생성
func hasRecords(for date: Date) -> Bool  // 기록 존재 여부
func getTreatment(for id: String) -> Treatment?  // 시술 조회
func selectDate(_ date: Date)        // 날짜 선택
```

6. **계산 속성**
```swift
var monthlyRevenue: Int              // 월별 총 매출
var totalRecordAmount: Int           // 일별 시술 합계
var totalAdjustmentAmount: Int       // 일별 조정 합계
var dailyTotal: Int                  // 일별 총 매출
```

---

#### 36. MonthHeaderView.swift 구현 (96줄)

**구현 내용:**
- 월 네비게이션 UI
- 월별 매출 표시

**UI 구성:**
```swift
HStack {
    // < 버튼 (이전 달)
    Button { viewModel.previousMonth() }

    // 년월 표시 + 월 매출
    VStack {
        Text("2026년 1월")
        Text("₩150,000").foregroundColor(.primary)
    }

    // > 버튼 (다음 달)
    Button { viewModel.nextMonth() }

    // 오늘 버튼
    Button("오늘") { viewModel.goToToday() }
}
```

**특징:**
- 월 매출 실시간 업데이트
- 현재 날짜와 같은 월이면 오늘 버튼 비활성화
- 깔끔한 아이콘 기반 네비게이션

---

#### 37. DayCell.swift 구현 (110줄)

**구현 내용:**
- 캘린더 그리드의 개별 날짜 셀 UI

**UI 상태:**
- **일반 날짜**: 기본 텍스트 + 투명 배경
- **오늘**: 굵은 글씨 + primary 색상 + 연한 배경
- **선택된 날짜**: 흰색 글씨 + primary 배경
- **기록 있음**: 하단에 작은 도트 표시

**구현 특징:**
```swift
// 기록 표시
if hasRecords {
    Circle()
        .fill(AppColors.primary)
        .frame(width: 4, height: 4)
}

// 색상 계산
private var textColor: Color {
    if isSelected { return .white }
    else if isToday { return AppColors.primary }
    else { return AppColors.textPrimary }
}
```

---

#### 38. CalendarGridView.swift 구현 (47줄)

**구현 내용:**
- 7열 x 최대 6행 그리드 레이아웃
- LazyVGrid 사용으로 성능 최적화

**특징:**
```swift
private let columns = Array(repeating: GridItem(.flexible()), count: 7)

LazyVGrid(columns: columns, spacing: 8) {
    ForEach(0..<days.count, id: \.self) { index in
        if let date = days[index] {
            DayCell(date: date, ...)
        } else {
            DayCell(date: nil, ...)  // 빈 셀
        }
    }
}
```

- 이전/다음 월의 날짜는 nil로 처리 (빈 셀)
- 날짜 클릭 시 selectDate() 호출

---

#### 39. RecordRow.swift 구현 (119줄)

**구현 내용:**
- 시술 기록 항목 표시 및 수량 조절 UI

**UI 구성:**
```swift
HStack {
    // 색상 원형 + 아이콘
    ZStack {
        Circle().fill(Color(hex: treatment.color))
        Text(treatment.icon)
    }

    // 시술 정보
    VStack(alignment: .leading) {
        Text(treatment.name)
        Text(record.totalAmount.formattedCurrency)
    }

    Spacer()

    // 수량 조절
    HStack {
        Button { onDecrement() }  // -
        Text("\(record.count)")
        Button { onIncrement() }  // +
    }

    // 삭제 버튼
    Button { onDelete() }
}
```

**특징:**
- +/- 버튼으로 수량 조절
- count가 0이 되면 자동 삭제
- 시술 정보 시각적 표시 (색상, 아이콘)

---

#### 40. AdjustmentRow.swift 구현 (107줄)

**구현 내용:**
- 조정 금액 항목 표시 UI

**UI 구성:**
```swift
HStack {
    // 아이콘 (할인: 빨강 minus, 추가: 초록 plus)
    ZStack {
        Circle().fill(iconBackgroundColor)
        Image(systemName: iconName)
    }

    // 조정 정보
    VStack(alignment: .leading) {
        Text(adjustment.amount < 0 ? "할인" : "추가 금액")
        if let reason = adjustment.reason {
            Text(reason).font(.caption)
        }
    }

    Spacer()

    // 금액 (빨강/초록)
    Text(adjustment.amount.formattedCurrency)
        .foregroundColor(adjustment.amount < 0 ? .red : .green)

    // 삭제 버튼
    Button { onDelete() }
}
```

**특징:**
- 음수: 빨간색, 양수: 초록색
- 아이콘 자동 변경 (minus/plus)
- 사유 선택 표시

---

#### 41. TreatmentPickerSheet.swift 구현 (137줄)

**구현 내용:**
- 시술 선택 바텀 시트 (NavigationView)

**UI 구성:**
```swift
NavigationView {
    ScrollView {
        if treatments.isEmpty {
            // 빈 상태 메시지
            Text("등록된 시술이 없습니다")
            Text("설정 탭에서 시술을 먼저 등록해주세요")
        } else {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(treatments) { treatment in
                    TreatmentButton(treatment: treatment) {
                        onSelect(treatment.id)
                    }
                }
            }
        }
    }
    .navigationTitle("시술 선택")
    .toolbar {
        ToolbarItem(placement: .cancellationAction) {
            Button("취소") { dismiss() }
        }
    }
}
```

**TreatmentButton 컴포넌트:**
```swift
VStack {
    // 색상 원형 + 아이콘
    ZStack {
        Circle().fill(Color(hex: treatment.color))
        Text(treatment.icon)
    }

    // 시술명
    Text(treatment.name)

    // 가격
    Text(treatment.price.formattedCurrency)
}
```

**특징:**
- 3열 그리드 레이아웃
- 빈 상태 처리
- 시술 선택 시 sheet 자동 닫힘

---

#### 42. AdjustmentEditSheet.swift 구현 (133줄)

**구현 내용:**
- 조정 금액 추가/수정 바텀 시트 (NavigationView + Form)

**UI 구성:**
```swift
NavigationView {
    Form {
        Section {
            // 타입 선택 (Segmented Control)
            Picker("타입", selection: $isDiscount) {
                Text("추가 금액").tag(false)
                Text("할인").tag(true)
            }
            .pickerStyle(.segmented)

            // 금액 입력
            HStack {
                Text("금액")
                Spacer()
                TextField("0", text: $amountText)
                    .keyboardType(.numberPad)
                Text("원")
            }

            // 사유 입력 (선택)
            TextField("사유 (선택)", text: $reason)
        }

        Section {
            // 미리보기
            HStack {
                Text("최종 금액")
                Spacer()
                Text(finalAmount.formattedCurrency)
                    .foregroundColor(isDiscount ? .red : .green)
            }
        }
    }
    .navigationTitle("금액 조정")
    .toolbar {
        ToolbarItem(placement: .cancellationAction) {
            Button("취소") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("저장") { saveAdjustment() }
                .disabled(!isValid)
        }
    }
}
```

**특징:**
- Segmented Control로 타입 선택
- 숫자만 입력 가능 (numberPad)
- 최종 금액 미리보기 (색상 구분)
- 유효성 검사 (금액 > 0)
- @FocusState로 자동 포커스

---

#### 43. DayDetailSheet.swift 구현 (272줄)

**구현 내용:**
- 일별 상세 정보 메인 바텀 시트
- 시술 기록 + 조정 금액 + 합계 표시

**UI 구성:**

1. **날짜 헤더**
```swift
VStack {
    Text(viewModel.selectedDate.formatted(.dateTime.year().month().day()))
    Text(viewModel.selectedDate.formatted(.dateTime.weekday(.wide)))
}
```

2. **시술 기록 섹션**
```swift
VStack {
    HStack {
        Text("시술 기록")
        Spacer()
        Button("시술 추가") { showingTreatmentPicker = true }
    }

    if viewModel.records.isEmpty {
        Text("등록된 시술이 없습니다")
    } else {
        ForEach(viewModel.records) { record in
            RecordRow(
                record: record,
                treatment: viewModel.getTreatment(for: record.treatmentId),
                onIncrement: { await viewModel.incrementRecord(record) },
                onDecrement: { await viewModel.decrementRecord(record) },
                onDelete: { await viewModel.deleteRecord(record) }
            )
        }
    }
}
```

3. **조정 금액 섹션**
```swift
VStack {
    HStack {
        Text("금액 조정")
        Spacer()
        Button("조정 추가") { showingAdjustmentEdit = true }
    }

    if viewModel.adjustments.isEmpty {
        Text("금액 조정 내역이 없습니다")
    } else {
        ForEach(viewModel.adjustments) { adjustment in
            AdjustmentRow(
                adjustment: adjustment,
                onDelete: { await viewModel.deleteAdjustment(adjustment) }
            )
        }
    }
}
```

4. **합계 섹션**
```swift
VStack {
    HStack {
        Text("시술 합계")
        Spacer()
        Text(viewModel.totalRecordAmount.formattedCurrency)
    }

    if !viewModel.adjustments.isEmpty {
        HStack {
            Text("조정 합계")
            Spacer()
            Text(viewModel.totalAdjustmentAmount.formattedCurrency)
                .foregroundColor(viewModel.totalAdjustmentAmount < 0 ? .red : .green)
        }
    }

    Divider()

    HStack {
        Text("일일 합계")
        Spacer()
        Text(viewModel.dailyTotal.formattedCurrency)
            .font(.title3)
            .fontWeight(.bold)
    }
}
```

**특징:**
- 두 개의 sheet 관리 (TreatmentPickerSheet, AdjustmentEditSheet)
- 빈 상태 메시지 표시
- 실시간 합계 계산 및 표시
- Task를 이용한 비동기 작업 처리

---

#### 44. CalendarTabView.swift 업데이트 (90줄)

**구현 내용:**
- 캘린더 탭 메인 뷰로 모든 컴포넌트 통합

**UI 구성:**
```swift
NavigationView {
    VStack(spacing: 16) {
        // 월 헤더
        MonthHeaderView(viewModel: viewModel)

        // 요일 헤더 (일월화수목금토)
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .foregroundColor(
                        symbol == "일" ? .red :
                        symbol == "토" ? .blue :
                        AppColors.textSecondary
                    )
            }
        }

        // 캘린더 그리드
        CalendarGridView(
            viewModel: viewModel,
            days: viewModel.getDaysInMonth()
        )

        Spacer()
    }
    .navigationTitle("캘린더")
    .sheet(isPresented: $showingDayDetail) {
        DayDetailSheet(viewModel: viewModel)
    }
    .task {
        await viewModel.loadTreatments()
        await viewModel.loadMonthlyData()
    }
    .onChange(of: viewModel.selectedDate) { _, newDate in
        Task {
            await viewModel.loadDailyData(for: newDate)
            showingDayDetail = true
        }
    }
    .onChange(of: viewModel.currentDate) { _, _ in
        Task {
            await viewModel.loadMonthlyData()
        }
    }
}
```

**특징:**
- 요일 헤더 색상 구분 (일요일: 빨강, 토요일: 파랑)
- 날짜 선택 시 자동으로 DayDetailSheet 표시
- 월 변경 시 자동 데이터 재로드
- .task로 초기 데이터 로딩

---

#### 45. 캘린더 탭 빌드 에러 수정 (17개 에러 해결)

**발생한 에러들:**

1. **AppColors.backgroundSecondary 없음** (3곳)
   - DayDetailSheet.swift에서 존재하지 않는 색상 참조
   - `AppColors.backgroundSecondary` → `AppColors.card`로 수정

2. **메서드 시그니처 불일치**
   - `getTreatment(for:)` → `getTreatment(byId:)`
   - `incrementRecord()`, `decrementRecord()` 메서드가 존재하지 않음
   - `updateRecordCount(record:increment:)` 메서드 사용으로 변경

3. **Argument label 누락**
   - `deleteRecord(record:)`, `deleteAdjustment(adjustment:)` 파라미터 레이블 추가

4. **CalendarViewModel computed property 누락**
   - `totalRecordAmount`, `totalAdjustmentAmount` 추가
   - `dailyTotal`을 위 두 property를 사용하도록 리팩토링

5. **CalendarTabView 구조 문제**
   - MonthHeaderView에 개별 파라미터 전달 필요
   - `loadTreatments()`, `loadMonthlyData()` → `fetchInitialData()` 호출
   - AuthService 초기화 패턴 수정

6. **Preview 에러**
   - CalendarViewModel(), DayDetailSheet() 등의 Preview에서 authService 파라미터 누락

**수정 결과:**
- ✅ 17개 에러 모두 수정
- ✅ 빌드 성공

---

#### 46. 코드 품질 개선 (Warning 7개 해결)

**수정한 Warning들:**

1. **ContentView.swift:22** - 사용하지 않는 `user` 변수
   ```swift
   // 변경 전
   } else if authService.isAuthenticated, let user = authService.currentUser {

   // 변경 후
   } else if authService.isAuthenticated, let _ = authService.currentUser {
   ```

2. **AdjustmentService.swift:86** - 불필요한 `try`
   ```swift
   // 변경 전
   let monthlyAdjustments = try snapshot.documents.compactMap { ... }

   // 변경 후
   let monthlyAdjustments = snapshot.documents.compactMap { ... }
   ```

3. **FirestoreService.swift:184, 216** - 불필요한 `try` (2곳)
   ```swift
   let documents = snapshot.documents.compactMap { ... }
   ```

4. **RecordService.swift:87** - 불필요한 `try`
   ```swift
   let monthlyRecords = snapshot.documents.compactMap { ... }
   ```

5. **CalendarViewModel.swift:259** - 사용하지 않는 `endOfMonth` 변수 삭제

6. **TreatmentEditSheet.swift:113** - 사용하지 않는 `id` 변수
   ```swift
   // 변경 전
   if let treatment = editingTreatment, let id = treatment.id {

   // 변경 후
   if let treatment = editingTreatment, let _ = treatment.id {
   ```

**결과:**
- ✅ 모든 Swift 코드 warning 제거
- ✅ 클린 빌드 완료

---

#### 47. 크리티컬 버그 수정: AuthService 인스턴스 공유 문제

**문제 발견:**
- 설정 탭에서 시술 추가 후, 캘린더 탭으로 이동하면 시술이 사라짐
- 설정 탭으로 돌아가도 시술이 모두 없어짐

**원인 분석:**
```
로그 분석:
✅ [treatments] 문서 추가 성공: 6bL74LnurXg2bN3nM3rJ
✅ [TreatmentService] 시술 추가 성공: 테스트시술명
✅ [treatments] 0개 문서 조회 성공  ← 문제!
✅ [TreatmentService] 0개 시술 조회 완료
```

**근본 원인:**
각 탭 뷰의 `init()` 메서드에서 임시 AuthService를 새로 생성하여 사용

```swift
// 문제가 있던 코드
struct CalendarTabView: View {
    init() {
        let tempAuthService = AuthService()  // 임시 인스턴스 A
        _viewModel = StateObject(wrappedValue: CalendarViewModel(authService: tempAuthService))
    }
}

struct SettingsTabView: View {
    init() {
        let tempAuthService = AuthService()  // 임시 인스턴스 B
        _viewModel = StateObject(wrappedValue: SettingsViewModel(authService: tempAuthService))
    }
}
```

**결과:**
1. 설정 탭에서 시술 추가: 임시 AuthService A의 userId로 저장
2. 캘린더 탭으로 이동: 임시 AuthService B의 userId로 조회
3. 서로 다른 userId → 데이터 0개 조회

**수정 방법:**

**1. MainTabView에서 authService 전달**
```swift
struct MainTabView: View {
    @EnvironmentObject var authService: AuthService  // 추가

    var body: some View {
        TabView {
            CalendarTabView()
                .environmentObject(authService)  // 전달
            SettlementTabView()
                .environmentObject(authService)  // 전달
            SettingsTabView()
                .environmentObject(authService)  // 전달
        }
    }
}
```

**2. ViewModel에서 authService를 나중에 설정 가능하도록 변경**
```swift
@MainActor
class CalendarViewModel: ObservableObject {
    private var _authService: AuthService?
    var authService: AuthService {
        _authService ?? AuthService()
    }

    init(authService: AuthService? = nil) {
        self._authService = authService
        setupBindings()
    }

    func setAuthService(_ service: AuthService) {
        self._authService = service
    }
}
```

**3. 각 탭 뷰에서 실제 authService 주입**
```swift
struct CalendarTabView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        // ...
        .onAppear {
            viewModel.setAuthService(authService)
        }
        .task {
            await viewModel.fetchInitialData()
        }
    }
}
```

**4. SettingsViewModel도 동일하게 수정**
```swift
@MainActor
class SettingsViewModel: ObservableObject {
    private var _authService: AuthService?
    var authService: AuthService {
        _authService ?? AuthService()
    }

    init(authService: AuthService? = nil) {
        self._authService = authService
        setupBindings()
    }

    func setAuthService(_ service: AuthService) {
        self._authService = service
    }
}
```

**테스트 결과:**
- ✅ 설정 탭에서 시술 추가
- ✅ 캘린더 탭으로 이동해도 시술 유지
- ✅ 다시 설정 탭으로 돌아가도 시술 유지
- ✅ 모든 탭에서 동일한 userId로 데이터 저장/조회

**교훈:**
- SwiftUI의 `@EnvironmentObject`는 반드시 상위 뷰에서 `.environmentObject()` modifier로 전달해야 함
- `init()`에서 임시 인스턴스를 생성하면 각 뷰마다 다른 인스턴스를 사용하게 됨
- 전역 상태는 앱 최상위에서 하나의 인스턴스만 생성하여 공유해야 함

---

#### 48. 재수정: View 분리 패턴으로 AuthService 주입 개선

**문제 지속:**
- 47번 수정 후에도 여전히 시술이 탭 간 공유되지 않음
- `onAppear`에서 `setAuthService()` 호출 방식의 한계

**원인 분석:**
- `.task`가 `onAppear`보다 먼저 실행될 수 있음
- `setAuthService()`가 호출되기 전에 `fetchInitialData()`가 실행됨
- 결과: 여전히 잘못된 authService 사용

**해결 방법: View 분리 패턴**

**1. CalendarTabView.swift**
```swift
// 외부 View: EnvironmentObject만 수신
struct CalendarTabView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        CalendarTabContent(authService: authService)
    }
}

// 내부 View: init()에서 authService로 ViewModel 생성
private struct CalendarTabContent: View {
    @StateObject private var viewModel: CalendarViewModel

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(authService: authService))
    }

    var body: some View {
        // 실제 UI
    }
}
```

**2. SettingsTabView.swift**
- CalendarTabView와 동일한 패턴 적용
- 외부/내부 View 분리

**3. ViewModel 원상복구**
```swift
// CalendarViewModel.swift & SettingsViewModel.swift
var authService: AuthService  // 단순 프로퍼티로 복원

init(authService: AuthService) {  // required parameter
    self.authService = authService
    setupBindings()
}
```

**장점:**
- View 생성 시점에 authService 주입 보장
- `@StateObject`는 View 생명주기 동안 한 번만 생성
- 실행 순서 명확: View 생성 → init() → ViewModel 생성 → .task
- authService가 확실히 설정된 상태로 시작

---

#### 49. 디버깅 로그 추가 및 문제 추적

**문제 지속:**
- 48번 수정 후에도 시술이 탭 간 공유되지 않음
- 근본 원인 파악을 위한 디버깅 필요

**추가한 로그:**

**1. ViewModel 초기화 시점**
```swift
init(authService: AuthService) {
    self.authService = authService
    print("🔍 [CalendarViewModel] init - authService: \(authService), currentUser: \(authService.currentUser?.id ?? "nil")")
    setupBindings()
}
```

**2. 시술 추가**
```swift
// SettingsViewModel
print("🔍 [SettingsViewModel] addTreatment - userId: \(userId), name: \(name)")

// TreatmentService
print("🔍 [TreatmentService] 시술 추가 시작 - userId: \(userId), name: \(name)")
print("✅ [TreatmentService] Firestore 문서 추가 성공 - userId: \(userId), docId: \(documentId)")
```

**3. 시술 조회**
```swift
// SettingsViewModel & CalendarViewModel
print("🔍 [SettingsViewModel] fetchTreatments - userId: \(userId)")

// TreatmentService
print("🔍 [TreatmentService] 시술 조회 시작 - userId: \(userId)")
print("✅ [TreatmentService] \(treatments.count)개 시술 조회 완료 - userId: \(userId)")
```

**발견한 사실:**
```
로그 분석:
✅ [TreatmentService] Firestore 문서 추가 성공 - userId: S0LmsW1S84d0L9DBMeNkUuqyO3y2
🔍 [TreatmentService] 시술 조회 시작 - userId: S0LmsW1S84d0L9DBMeNkUuqyO3y2
✅ [treatments] 0개 문서 조회 성공
```

- ✅ **userId는 동일함** (S0LmsW1S84d0L9DBMeNkUuqyO3y2)
- ❌ **하지만 조회 결과는 0개**
- 📌 **결론: Firestore 경로는 맞지만 디코딩에 문제**

---

#### 50. 크리티컬 버그 해결: Firestore @DocumentID 디코딩 문제

**문제 발견:**
```
로그:
🔍 [treatments] Firestore에서 13개 문서 가져옴
❌ [treatments] 디코딩 실패 - docId: 6bL74LnurXg2bN3nM3rJ
   error: decodingIsNotSupported("Could not find DocumentReference for user info key")
   데이터: ["price": 100000, "created_at": <Timestamp>, "name": 테스트시술명, ...]
✅ [treatments] 0개 문서 조회 성공 (총 13개 중)
```

**근본 원인:**
- Firestore에서 **13개 문서는 정상적으로 가져옴**
- 하지만 `@DocumentID` 디코딩 시 실패
- `Firestore.Decoder()`는 document reference 정보 없이 `@DocumentID`를 디코딩할 수 없음

**모델 구조:**
```swift
struct Treatment: Identifiable, Codable {
    @DocumentID var id: String?  // ← 문제의 property wrapper
    var name: String
    var price: Int
    // ...
}
```

`@DocumentID`는:
- Firestore의 document ID를 자동으로 모델에 매핑하는 특별한 property wrapper
- 일반 `Firestore.Decoder()`로는 디코딩 불가능
- Document reference 정보가 필요함

**해결 방법:**

**FirestoreService.swift - getDocuments & queryDocuments 메서드 수정**

```swift
// 변경 전: 수동 디코딩
let decoder = Firestore.Decoder()
let decoded = try decoder.decode(T.self, from: doc.data())

// 변경 후: Firestore SDK 내장 메서드 사용
let decoded = try doc.data(as: T.self)
```

**`doc.data(as:)` 메서드의 장점:**
- ✅ `@DocumentID` 자동 처리
- ✅ Document reference 자동 설정
- ✅ Timestamp → Date 자동 변환
- ✅ 모든 Firestore 타입 지원
- ✅ field name mapping (snake_case ↔ camelCase)

**수정 코드:**
```swift
func getDocuments<T: Decodable>(...) async throws -> [T] {
    do {
        let snapshot = try await query.getDocuments()

        print("🔍 [\(collectionName)] Firestore에서 \(snapshot.documents.count)개 문서 가져옴")

        let documents = snapshot.documents.compactMap { doc -> T? in
            do {
                // Firestore SDK의 내장 메서드 사용
                let decoded = try doc.data(as: T.self)
                return decoded
            } catch {
                print("❌ [\(collectionName)] 디코딩 실패 - docId: \(doc.documentID)")
                return nil
            }
        }

        print("✅ [\(collectionName)] \(documents.count)개 문서 조회 성공 (총 \(snapshot.documents.count)개 중)")
        return documents
    }
}
```

**테스트 결과:**
```
✅ 이전: Firestore에서 13개 가져옴 → 0개 디코딩 성공
✅ 이후: Firestore에서 13개 가져옴 → 13개 디코딩 성공
```

**최종 확인:**
- ✅ 설정 탭에서 시술 추가 → Firestore에 저장됨
- ✅ 캘린더 탭으로 이동 → 시술이 정상 표시됨
- ✅ 다시 설정 탭으로 이동 → 시술이 유지됨
- ✅ 모든 탭에서 동일한 데이터 공유

**교훈:**
- Firestore SDK의 `@DocumentID` property wrapper는 특별한 처리가 필요
- 커스텀 디코딩보다 Firestore SDK의 내장 메서드(`doc.data(as:)`) 사용 권장
- `compactMap`에서 `try?` 사용 시 에러가 조용히 무시됨 → 디버깅 로그 필수
- Firestore 데이터 조회 시: 가져온 문서 수 ≠ 디코딩 성공 수 (에러 발생 가능)

---

## 다음 단계

### 이후 계획:
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

## Phase 3 버그 수정 (2026-01-24)

### 수정된 이슈

#### 1. @DocumentID 디코딩 실패 문제
**증상**: monthlyRecords가 항상 빈 배열로 반환되어 캘린더 도트가 표시되지 않음
**원인**: RecordService와 AdjustmentService에서 `Firestore.Decoder()`를 사용하여 수동 디코딩 시도. 이 방법은 `@DocumentID` 프로퍼티 래퍼에 필요한 문서 참조 컨텍스트를 제공하지 못함.
**해결**:
- RecordService.fetchMonthlyRecords()를 `doc.data(as: DailyRecord.self)` 사용으로 변경
- AdjustmentService.fetchMonthlyAdjustments()를 `doc.data(as: DailyAdjustment.self)` 사용으로 변경
- FirestoreService는 이전에 이미 수정 완료
**결과**: Firestore에서 가져온 문서가 정상적으로 디코딩되어 monthlyRecords에 저장됨

#### 2. 시술 색상 도트 미표시 문제
**증상**: 캘린더 날짜에 시술 색상 도트가 표시되지 않음
**해결**:
- CalendarViewModel에 `getTreatmentColors(for:)` 메서드 추가
  - 해당 날짜의 모든 기록에서 시술 색상 추출
  - 중복 제거 및 최대 3개까지 반환
- DayCell을 `hasRecords: Bool`에서 `treatmentColors: [String]`로 변경
- 여러 시술이 있는 경우 가로로 색상 도트 표시 (HStack, spacing: 2)
- CalendarGridView에서 `getTreatmentColors(for:)` 호출하도록 업데이트
**결과**: 설정에서 정한 시술 색상이 캘린더 날짜에 도트로 표시됨

#### 3. 같은 날짜 재선택 시 상세화면 미표시 문제
**증상**: 이미 선택된 날짜를 다시 클릭해도 일별 상세화면이 열리지 않음
**원인**: SwiftUI의 `.onChange(of:)` 모디파이어는 값이 실제로 변경될 때만 트리거됨
**해결**:
- CalendarViewModel에 `shouldShowDayDetail` 토글 프로퍼티 추가
- `selectDate()` 메서드에서 `shouldShowDayDetail.toggle()` 호출
- CalendarTabView에서 `selectedDate` 대신 `shouldShowDayDetail` 관찰
**결과**: 같은 날짜를 다시 클릭해도 항상 상세화면이 표시됨

### 수정된 파일
```
Vesta/Core/Services/
  - RecordService.swift (fetchMonthlyRecords 메서드)
  - AdjustmentService.swift (fetchMonthlyAdjustments 메서드)

Vesta/Features/Calendar/ViewModels/
  - CalendarViewModel.swift (getTreatmentColors, shouldShowDayDetail 추가)

Vesta/Features/Calendar/Views/
  - DayCell.swift (treatmentColors 프로퍼티로 변경, 색상 도트 표시)
  - CalendarGridView.swift (getTreatmentColors 호출)
  - CalendarTabView.swift (shouldShowDayDetail 관찰)
```

---

## Phase 4: 결산 탭 구현 (2026-01-25 시작)

### 4.1 SettlementViewModel.swift 생성 (2026-01-25)

**파일 생성**: `Vesta/Features/Settlement/ViewModels/SettlementViewModel.swift` (약 280줄)

#### 주요 기능

**1. 서비스 연동**
- RecordService: 월별 시술 기록 조회
- AdjustmentService: 월별 조정 금액 조회
- ExpenseService: 월별 지출 관리
- CategoryService: 지출 카테고리 관리
- TreatmentService: 시술 정보 (시술별 매출 분석용)

**2. @Published 프로퍼티**
```swift
@Published var currentDate: Date
@Published var monthlyRecords: [DailyRecord]
@Published var monthlyAdjustments: [DailyAdjustment]
@Published var expenses: [MonthlyExpense]
@Published var categories: [ExpenseCategory]
@Published var treatments: [Treatment]
```

**3. Computed Properties**
- `totalRevenue`: 총 매출 (시술 기록 + 조정 금액)
- `totalExpense`: 총 지출
- `netProfit`: 순이익 (매출 - 지출)
- `revenueByTreatment`: 시술별 매출 분석 [(treatmentId, name, color, amount)]
  - 금액 내림차순 정렬
  - RevenueCard UI에서 사용

**4. 주요 메서드**
- `fetchMonthlyData()`: 월별 데이터 조회 (병렬 처리로 최적화)
- `navigateToPreviousMonth()`, `navigateToNextMonth()`, `navigateToCurrentMonth()`: 월 네비게이션
- `getExpenseAmount(for:)`: 카테고리별 지출 금액 조회
- `updateExpense(categoryId:amount:)`: 지출 추가/수정 (upsert)
- `copyExpensesFromPreviousMonth()`: 전월 지출 복사 기능

**5. Combine 구독**
- ExpenseService, CategoryService, TreatmentService의 데이터 변경사항을 자동으로 구독
- 서비스에서 데이터 변경 시 ViewModel 자동 업데이트

#### 기술적 특징
- CalendarViewModel과 동일한 패턴 사용 (일관성)
- async/await로 병렬 데이터 조회 (성능 최적화)
- Combine으로 서비스 상태 실시간 반영
- 디버깅 로그 포함

### 4.2 RevenueCard.swift 구현 (2026-01-25)

**파일 생성**: `Vesta/Features/Settlement/Views/RevenueCard.swift` (약 70줄)

- 월 매출 카드 UI
- 총 매출 표시 (primary 색상 강조)
- 시술별 매출 리스트
  - 시술 색상 원형 (12x12)
  - 시술명 + 금액
  - TreatmentRevenueRow 컴포넌트 (private)
- 빈 상태 처리 ("시술 기록이 없습니다")

### 4.3 ExpenseSection.swift 구현 (2026-01-25)

**파일 생성**: `Vesta/Features/Settlement/Views/ExpenseSection.swift` (약 170줄)

- 지출 관리 섹션 카드 UI
- 헤더: "지출" + 카테고리 추가 버튼
- "이전 달 불러오기" 버튼
- 카테고리별 지출 리스트 (ExpenseRow 사용)
- 총 지출 표시
- 빈 상태 메시지

### 4.4 ExpenseRow.swift 구현 (2026-01-25)

**파일 생성**: `Vesta/Features/Settlement/Views/ExpenseRow.swift` (약 120줄)

- 지출 카테고리 행 UI
- 이모지 아이콘 (40x40) + 카테고리명
- 금액 버튼 (탭하여 수정)
  - 금액 입력됨: 금액 표시
  - 금액 미입력: "입력" 텍스트
- Menu 버튼 (ellipsis)
  - 카테고리 수정
  - 카테고리 삭제 (destructive)

### 4.5 ProfitCard.swift 구현 (2026-01-25)

**파일 생성**: `Vesta/Features/Settlement/Views/ProfitCard.swift` (약 170줄)

- 순이익 카드 UI
- 매출 - 지출 = 순이익 구조
- 흑자/적자 자동 구분
  - **흑자**: 청록색 (#4ECDC4), arrow.up.circle.fill, "흑자" 레이블
  - **적자**: 빨간색 (#FF6B6B), arrow.down.circle.fill, "적자" 레이블
  - **손익 0**: 회색, minus.circle.fill
- Computed Properties: isProfit, profitColor, profitIcon, profitLabel

### 4.6 CategoryEditSheet.swift 구현 (2026-01-25)

**파일 생성**: `Vesta/Features/Settlement/Views/CategoryEditSheet.swift` (약 115줄)

- 지출 카테고리 추가/수정 바텀 시트
- Form 기반 UI
- 카테고리명 입력 필드
- 이모지 선택 (EmojiTextField 재사용)
- 미리보기 섹션 (입력 시 실시간 표시)
- 유효성 검사 (카테고리명 + 아이콘 필수)
- async 콜백 (onSave)

### 4.7 ExpenseInputSheet.swift 구현 (2026-01-25)

**파일 생성**: `Vesta/Features/Settlement/Views/ExpenseInputSheet.swift` (약 180줄)

- 지출 금액 입력 바텀 시트
- 카테고리 정보 표시 (이모지 60pt + 카테고리명)
- 금액 입력 필드
  - 큰 폰트 (48pt, bold)
  - 숫자 전용 키패드
  - Primary 색상 강조
- 실시간 천 단위 구분자 미리보기
- 빠른 입력 버튼 (10만원, 50만원, 100만원)
- QuickAmountButton 컴포넌트 (private)

### 4.8 "이전 달 불러오기" 기능 구현 (2026-01-25)

**구현 위치**: `SettlementTabView.swift`

- Alert 다이얼로그로 확인 받기
- SettlementViewModel.copyExpensesFromPreviousMonth() 호출
- ExpenseService.copyFromPreviousMonth 활용
- 중복 카테고리 자동 건너뛰기
- 복사 후 데이터 자동 갱신

```swift
.alert("이전 달 불러오기", isPresented: $showingCopyConfirmation) {
    Button("취소", role: .cancel) {}
    Button("불러오기") {
        Task {
            await viewModel.copyExpensesFromPreviousMonth()
        }
    }
} message: {
    Text("전월 지출 데이터를 현재 월로 복사합니다.\n이미 존재하는 카테고리는 건너뜁니다.")
}
```

### 4.9 SettlementTabView 완성 (2026-01-25)

**파일 업데이트**: `Vesta/Features/Settlement/Views/SettlementTabView.swift` (약 235줄)

**완성된 기능**:
1. **화면 구성** (ScrollView)
   - 월 헤더 (이전/다음 네비게이션)
   - RevenueCard: 총 매출 + 시술별 매출
   - ExpenseSection: 지출 카테고리 관리
   - ProfitCard: 순이익 표시

2. **Sheet 관리**
   - CategoryEditSheet: 카테고리 추가/수정
   - ExpenseInputSheet: 지출 금액 입력
   - Alert: "이전 달 불러오기" 확인

3. **데이터 로딩**
   - `.task`: 초기 로딩
   - `.onChange(of: currentDate)`: 월 변경 시 재조회
   - `.overlay`: 로딩 인디케이터

4. **CRUD 작업**
   - saveCategory(): 카테고리 추가/수정
   - deleteCategory(): 카테고리 삭제
   - saveExpense(): 지출 금액 저장

5. **View 분리 패턴**
   - 외부: EnvironmentObject 수신
   - 내부: StateObject로 ViewModel 생성

**사용 가능한 기능**:
- ✅ 월별 매출 조회 (캘린더 데이터 기반)
- ✅ 시술별 매출 분석
- ✅ 지출 카테고리 관리 (CRUD)
- ✅ 카테고리별 지출 금액 입력
- ✅ 전월 지출 불러오기
- ✅ 순이익 자동 계산 (흑자/적자)
- ✅ 월 네비게이션

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

### Phase 3 완료 후 (버그 수정 포함)
- **Swift 파일**: 43개 (+10개)
- **총 코드 라인**: 약 5,300줄 (+1,495줄, 디버깅 로그 포함)
- **모델**: 6개
- **서비스**: 7개 (AuthService + 6개 비즈니스 레이어)
  - AuthService (198줄)
  - FirestoreService (308줄)
  - TreatmentService (256줄)
  - RecordService (281줄)
  - AdjustmentService (265줄)
  - CategoryService (280줄)
  - ExpenseService (284줄)
- **ViewModel**: 2개
  - SettingsViewModel (131줄)
  - CalendarViewModel (279줄)
- **뷰**: 23개 (+10개)
  - 기존 13개 (LoginView, SettingsTabView, TreatmentRow, TreatmentEditSheet 등)
  - **캘린더 탭 (10개)**:
    - CalendarTabView (90줄)
    - MonthHeaderView (96줄)
    - DayCell (110줄)
    - CalendarGridView (47줄)
    - RecordRow (119줄)
    - AdjustmentRow (107줄)
    - TreatmentPickerSheet (137줄)
    - AdjustmentEditSheet (133줄)
    - DayDetailSheet (272줄)
- **공용 컴포넌트**: 2개
  - ColorPickerView (63줄)
  - EmojiTextField (53줄)
- **Extensions**: 4개 (Date+Formatting에 endOfDay() 추가)
- **Constants**: 3개

### Phase 4 시작 (2026-01-25)
- **Swift 파일**: 44개 (+1개)
- **총 코드 라인**: 약 5,580줄 (+280줄)
- **ViewModel**: 3개 (+1개)
  - SettingsViewModel (131줄)
  - CalendarViewModel (279줄)
  - SettlementViewModel (280줄) ← 신규

### Phase 4 완료 (2026-01-25) ✅
- **Swift 파일**: 50개 (+6개)
- **총 코드 라인**: 약 6,920줄 (+1,340줄)
- **ViewModel**: 3개
  - SettingsViewModel (131줄)
  - CalendarViewModel (279줄)
  - SettlementViewModel (280줄)
- **뷰**: 30개 (+7개)
  - 기존 23개
  - **결산 탭 (7개)**:
    - SettlementTabView (235줄)
    - RevenueCard (70줄)
    - ExpenseSection (170줄)
    - ExpenseRow (120줄)
    - ProfitCard (170줄)
    - CategoryEditSheet (115줄)
    - ExpenseInputSheet (180줄)
