# Vesta iOS App

뷰티샵 매출 관리를 위한 iOS 네이티브 앱

## 🚀 시작하기

### 필수 요구사항

- **Xcode**: 15.0 이상
- **iOS**: 17.0 이상
- **Swift**: 5.9 이상
- **Firebase 프로젝트**: Firebase Console에서 생성 필요

### 1. Firebase 프로젝트 설정

1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. iOS 앱 추가:
   - Bundle ID: `com.yourcompany.vesta` (원하는 ID로 변경 가능)
3. `GoogleService-Info.plist` 다운로드
4. 다운로드한 파일을 `Vesta/Resources/` 폴더에 추가

### 2. Firebase 서비스 활성화

**Authentication**
- Firebase Console → Authentication → Sign-in method
- Apple 로그인 활성화

**Cloud Firestore**
- Firebase Console → Firestore Database
- 데이터베이스 생성 (테스트 모드로 시작)
- Security Rules 설정 (아래 참고)

### 3. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId}/{document=**} {
      allow read, write: if isOwner(userId);
    }
  }
}
```

### 4. Apple Sign In 설정

**Apple Developer Portal**
1. Identifiers → App IDs → 새 App ID 생성
2. Bundle ID: `com.yourcompany.vesta` (Firebase와 동일하게)
3. Capabilities → Sign In with Apple 체크

**Xcode**
1. 프로젝트 선택 → Signing & Capabilities
2. Team 선택
3. `+ Capability` → Sign In with Apple 추가

### 5. Xcode에서 프로젝트 열기

```bash
cd Vesta
open .
```

Xcode에서 `VestaApp.swift` 파일을 열면 자동으로 프로젝트가 인식됩니다.

또는 직접 Xcode 프로젝트 파일을 생성할 수 있습니다:
1. Xcode 열기
2. File → New → Project
3. iOS → App 선택
4. Product Name: Vesta
5. Bundle Identifier: com.yourcompany.vesta
6. Interface: SwiftUI
7. Life Cycle: SwiftUI App
8. 기존 `Vesta/` 폴더의 내용을 프로젝트에 추가

### 6. Firebase SDK 연동

**Swift Package Manager 사용**

1. Xcode에서 프로젝트 선택
2. Package Dependencies 탭
3. `+` 버튼 클릭
4. URL 입력: `https://github.com/firebase/firebase-ios-sdk.git`
5. Dependency Rule: Up to Next Major Version `10.20.0`
6. 다음 패키지 추가:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseAnalytics (선택)

### 7. 빌드 및 실행

1. Xcode에서 시뮬레이터 또는 실제 기기 선택
2. `Cmd + R` 눌러서 빌드 & 실행
3. Apple Sign In 테스트

## 📁 프로젝트 구조

```
Vesta/
├── App/
│   ├── VestaApp.swift          # @main 진입점
│   └── ContentView.swift       # 루트 뷰
│
├── Features/
│   ├── Auth/                   # 인증 (Apple Sign In)
│   ├── Calendar/               # 캘린더 탭
│   ├── Settlement/             # 결산 탭
│   └── Settings/               # 설정 탭
│
├── Core/
│   ├── Models/                 # 데이터 모델
│   └── Services/               # Firebase 서비스
│
├── Shared/
│   ├── Components/             # 공용 컴포넌트
│   ├── Extensions/             # Swift Extensions
│   └── Constants/              # 상수 (색상, 스타일 등)
│
└── Resources/
    ├── Assets.xcassets         # 이미지, 색상 에셋
    └── GoogleService-Info.plist # Firebase 설정 (Git 제외)
```

## 🎨 디자인 시스템

### 색상
- **Primary**: #FFA0B9 (메인 핑크)
- **Background**: #FEFAF7 (아이보리)
- **Text Primary**: #2C2420 (브라운 블랙)

자세한 내용은 `Shared/Constants/AppColors.swift` 참고

## 🔧 개발 현황

- [x] Phase 1: 환경 구축
  - [x] iOS 프로젝트 생성
  - [x] Firebase SDK 연동 준비
  - [x] 기본 인증 플로우 (Apple Sign In)
- [ ] Phase 2: 핵심 모델 및 서비스
- [ ] Phase 3: 캘린더 탭
- [ ] Phase 4: 결산 탭
- [ ] Phase 5: 설정 탭

## 📝 라이선스

Private Project
