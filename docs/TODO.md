# TODO - Vesta iOS 개발 계획

> 최종 업데이트: 2026-01-21

## 우선순위별 개발 계획

---

## 🔴 Priority 1: 환경 구축 및 Firebase 연동 ✅ 완료

### ✅ 완료
- [x] 1.1 iOS 프로젝트 구조 생성 (21개 Swift 파일)
- [x] 1.2 Xcode 프로젝트 생성 및 소스 통합
- [x] 1.3 Xcode에서 파일 구조 추가
- [x] 1.4 Bundle Identifier 설정
- [x] 1.5 iOS 17.0 Minimum Deployment 설정
- [x] 1.6 Firebase SDK 추가 (FirebaseAuth, FirebaseFirestore)
- [x] 1.7 Sign In with Apple Capability 추가 (Entitlements 파일 생성)
- [x] 1.8 Firebase Console 프로젝트 생성
- [x] 1.9 GoogleService-Info.plist 추가
- [x] 1.10 Firebase Authentication 설정 (Apple + Google 활성화)
- [x] 1.11 Cloud Firestore 생성 (Production 모드, asia-northeast3)
- [x] 1.12 Firestore Security Rules 설정
- [x] 1.13 첫 빌드 및 테스트 (Apple Sign In)
- [x] 1.14 빌드 에러 해결 (Info.plist, Firebase SDK, Combine, CryptoKit)

---

## 🟠 Priority 1.5: Google Sign In 추가 ✅ 완료

### ✅ 완료
- [x] 1.5.1 Firebase Console에서 Google 인증 활성화
- [x] 1.5.2 GoogleSignIn SDK 추가 (SPM)
- [x] 1.5.3 GoogleService-Info.plist 재다운로드 (CLIENT_ID 포함)
- [x] 1.5.4 Info.plist URL Schemes 설정 (REVERSED_CLIENT_ID)
- [x] 1.5.5 VestaApp.swift에 `.onOpenURL` 핸들러 추가
- [x] 1.5.6 AuthService.swift에 `signInWithGoogle()` 메서드 구현
- [x] 1.5.7 LoginView.swift에 Google Sign In 버튼 추가

### 🟡 진행 중
- [ ] **1.5.8 Google Sign In 테스트**
  - 시뮬레이터 또는 실제 기기에서 테스트
  - 로그인/로그아웃 확인

---

## 🟠 Priority 2: 핵심 서비스 레이어 구현

### Firebase 서비스 기본
- [ ] **2.1 FirestoreService.swift 생성**
  - Firestore 기본 CRUD 유틸리티
  - userId 기반 컬렉션 참조 헬퍼
  - 에러 핸들링 공통 로직

### 시술 관리
- [ ] **2.2 TreatmentService.swift 구현**
  - `fetchTreatments(userId:)` - 시술 목록 조회
  - `addTreatment(_:userId:)` - 시술 추가
  - `updateTreatment(_:userId:)` - 시술 수정
  - `deleteTreatment(id:userId:)` - 시술 삭제
  - `reorderTreatments(_:userId:)` - 순서 변경

### 일별 기록 관리
- [ ] **2.3 RecordService.swift 구현**
  - `fetchRecords(userId:date:)` - 특정 날짜 기록 조회
  - `fetchMonthlyRecords(userId:year:month:)` - 월별 기록 조회
  - `addOrUpdateRecord(userId:date:treatmentId:price:)` - 기록 추가/수정
  - `updateRecordCount(id:count:totalAmount:)` - 수량 변경
  - `deleteRecord(id:userId:)` - 기록 삭제

### 조정 금액 관리
- [ ] **2.4 AdjustmentService.swift 구현**
  - `fetchAdjustments(userId:date:)` - 특정 날짜 조정 조회
  - `addAdjustment(_:userId:)` - 조정 추가
  - `updateAdjustment(_:userId:)` - 조정 수정
  - `deleteAdjustment(id:userId:)` - 조정 삭제

### 지출 카테고리 관리
- [ ] **2.5 CategoryService.swift 구현**
  - `fetchCategories(userId:)` - 카테고리 목록 조회
  - `addCategory(_:userId:)` - 카테고리 추가
  - `updateCategory(_:userId:)` - 카테고리 수정
  - `deleteCategory(id:userId:)` - 카테고리 삭제
  - `reorderCategories(_:userId:)` - 순서 변경

### 월별 지출 관리
- [ ] **2.6 ExpenseService.swift 구현**
  - `fetchExpenses(userId:yearMonth:)` - 월별 지출 조회
  - `upsertExpense(userId:yearMonth:categoryId:amount:)` - 지출 추가/수정
  - `copyFromPreviousMonth(userId:from:to:)` - 전월 지출 복사

---

## 🟡 Priority 3: 캘린더 탭 구현

### 캘린더 UI
- [ ] **3.1 CalendarViewModel.swift 생성**
  - 월별 데이터 관리
  - 날짜 선택 상태 관리
  - RecordService, AdjustmentService 연동

- [ ] **3.2 MonthHeaderView.swift 구현**
  - 년월 표시
  - 이전/다음 달 네비게이션
  - 월 총 매출 표시

- [ ] **3.3 CalendarGridView.swift 구현**
  - 7x6 그리드 캘린더
  - 날짜별 시술 도트 표시
  - 날짜 클릭 이벤트

- [ ] **3.4 DayCell.swift 구현**
  - 날짜 셀 UI
  - 시술 도트 표시 (최대 3개 + more)
  - 오늘 날짜 강조

### 일별 상세 화면
- [ ] **3.5 DayDetailSheet.swift 구현**
  - 바텀 시트 UI
  - 일별 총 매출 표시
  - 시술 추가/조정 버튼

- [ ] **3.6 RecordRow.swift 구현**
  - 시술 기록 행 UI
  - 수량 +/- 버튼
  - 삭제 버튼

- [ ] **3.7 AdjustmentRow.swift 구현**
  - 조정 금액 행 UI
  - 할인/추가금액 구분 표시
  - 수정/삭제 버튼

- [ ] **3.8 TreatmentPickerSheet.swift 구현**
  - 시술 선택 바텀 시트
  - 3열 그리드 레이아웃
  - TreatmentButton 컴포넌트 사용

- [ ] **3.9 AdjustmentEditSheet.swift 구현**
  - 조정 금액 추가/수정 바텀 시트
  - 금액 입력 (음수/양수)
  - 사유 입력 (선택)

### 캘린더 통합
- [ ] **3.10 CalendarTabView 완성**
  - ViewModel 연동
  - 모든 하위 컴포넌트 통합
  - 데이터 흐름 테스트

---

## 🟢 Priority 4: 결산 탭 구현

### 결산 UI
- [ ] **4.1 SettlementViewModel.swift 생성**
  - 월별 매출/지출 데이터 관리
  - 순이익 계산
  - RecordService, ExpenseService 연동

- [ ] **4.2 RevenueCard.swift 구현**
  - 월 매출 카드 UI
  - 시술별 매출 합계

- [ ] **4.3 ExpenseSection.swift 구현**
  - 지출 관리 섹션
  - 카테고리별 지출 표시

- [ ] **4.4 ExpenseRow.swift 구현**
  - 지출 카테고리 행 UI
  - 금액 입력 버튼
  - 카테고리 수정/삭제 버튼

- [ ] **4.5 ProfitCard.swift 구현**
  - 순이익 카드 UI
  - 흑자/적자 구분 표시

- [ ] **4.6 CategoryEditSheet.swift 구현**
  - 지출 카테고리 추가/수정 바텀 시트
  - 카테고리명 입력
  - 이모지 선택

- [ ] **4.7 ExpenseInputSheet.swift 구현**
  - 지출 금액 입력 바텀 시트
  - 숫자 키패드
  - 천 단위 구분자 표시

### 결산 기능
- [ ] **4.8 "이전 달 불러오기" 기능 구현**
  - 전월 지출 데이터 복사
  - 확인 다이얼로그
  - 로딩 인디케이터

- [ ] **4.9 SettlementTabView 완성**
  - ViewModel 연동
  - 모든 하위 컴포넌트 통합
  - 데이터 흐름 테스트

---

## 🔵 Priority 5: 설정 탭 구현

### 시술 관리 UI
- [ ] **5.1 SettingsViewModel.swift 생성**
  - 시술 목록 관리
  - TreatmentService 연동

- [ ] **5.2 TreatmentListView.swift 구현**
  - 시술 목록 UI
  - 드래그 앤 드롭 순서 변경 (선택)

- [ ] **5.3 TreatmentRow.swift 구현**
  - 시술 행 UI
  - 색상, 아이콘, 이름, 가격 표시
  - 수정/삭제 버튼

- [ ] **5.4 TreatmentEditSheet.swift 구현**
  - 시술 추가/수정 바텀 시트
  - 시술명, 가격 입력
  - 아이콘 선택 (이모지)
  - 색상 선택 (15가지 팔레트)

### 공용 컴포넌트
- [ ] **5.5 ColorPickerView.swift 구현**
  - 15가지 색상 팔레트 그리드
  - 선택된 색상 하이라이트

- [ ] **5.6 EmojiTextField.swift 구현**
  - 이모지 입력 필드
  - 2글자 제한
  - X 버튼으로 초기화

### 앱 설정
- [ ] **5.7 앱 정보 섹션 추가**
  - 앱 버전 표시
  - 로그아웃 버튼

- [ ] **5.8 SettingsTabView 완성**
  - ViewModel 연동
  - 모든 하위 컴포넌트 통합

---

## 🟣 Priority 6: 공용 컴포넌트 및 개선

### 공용 UI 컴포넌트
- [ ] **6.1 LoadingOverlay.swift 구현**
  - 전체 화면 로딩 인디케이터
  - 반투명 배경

- [ ] **6.2 EmptyStateView.swift 구현**
  - 데이터 없을 때 표시
  - 이모지 + 메시지

- [ ] **6.3 ErrorAlertView.swift 구현**
  - 에러 메시지 표시
  - 재시도 버튼

- [ ] **6.4 CurrencyTextField.swift 구현**
  - 금액 입력 필드
  - 자동 천 단위 구분자
  - 숫자만 입력 가능

### UX 개선
- [ ] **6.5 Haptic Feedback 추가**
  - 버튼 클릭 시 햅틱 피드백
  - 성공/실패/경고 타입

- [ ] **6.6 애니메이션 개선**
  - 시트 전환 애니메이션
  - 데이터 로딩 애니메이션

- [ ] **6.7 에러 핸들링 통일**
  - 네트워크 에러
  - Firestore 에러
  - 인증 에러

---

## ⚪ Priority 7: 테스트 및 최적화

### 테스트
- [ ] **7.1 수동 테스트 체크리스트 작성**
  - 각 기능별 테스트 시나리오

- [ ] **7.2 전체 기능 테스트**
  - 로그인/로그아웃
  - 시술 CRUD
  - 기록 CRUD
  - 지출 CRUD
  - 결산 계산

- [ ] **7.3 엣지 케이스 테스트**
  - 네트워크 오프라인
  - 빈 데이터 상태
  - 동시성 이슈

### 최적화
- [ ] **7.4 Firestore 쿼리 최적화**
  - 필요한 인덱스 생성
  - 쿼리 횟수 최소화

- [ ] **7.5 메모리 최적화**
  - 이미지 캐싱 (향후)
  - 뷰 재사용

- [ ] **7.6 성능 측정**
  - 앱 시작 시간
  - 화면 전환 속도

---

## 🎨 Priority 8: 디자인 폴리싱

- [ ] **8.1 다크 모드 지원 검토**
  - 현재는 라이트 모드만 지원
  - 필요시 다크 모드 색상 정의

- [ ] **8.2 아이콘 디자인**
  - 앱 아이콘 제작
  - 런치 스크린 디자인

- [ ] **8.3 애니메이션 추가**
  - 숫자 카운팅 애니메이션
  - 카드 플립 효과

---

## 🚀 Priority 9: 배포 준비

### Apple Developer
- [ ] **9.1 App ID 등록**
  - Bundle ID 확정
  - Sign In with Apple 활성화

- [ ] **9.2 Provisioning Profile 생성**
  - Development
  - Distribution

### Firebase
- [ ] **9.3 Firebase 프로덕션 설정**
  - Security Rules 최종 검증
  - 인덱스 생성 완료

### 앱 정보
- [ ] **9.4 앱 스토어 메타데이터 준비**
  - 앱 이름: Vesta
  - 설명 작성
  - 키워드 선정
  - 스크린샷 제작 (6.7인치, 5.5인치)

### TestFlight
- [ ] **9.5 TestFlight 베타 테스트**
  - 내부 테스터 추가
  - 버그 수집 및 수정

### App Store
- [ ] **9.6 App Store 제출**
  - 개인정보 처리방침
  - 리뷰 가이드라인 확인
  - 제출 및 심사 대응

---

## 📝 Priority 10: 문서화 및 유지보수

- [ ] **10.1 사용자 가이드 작성**
  - 앱 사용 방법
  - FAQ

- [ ] **10.2 개발 문서 최종 업데이트**
  - TECHNICAL_SPEC.md 완성
  - API.md 완성

- [ ] **10.3 데이터 마이그레이션 도구**
  - PWA → iOS 데이터 이전 스크립트 (필요시)

---

## 🔮 향후 확장 계획 (v2.0)

- [ ] 위젯 (홈 화면에서 일일 매출 확인)
- [ ] 푸시 알림 (월말 결산 리마인더)
- [ ] 통계 및 분석 탭 (월별 추이 그래프)
- [ ] 시술 사진 첨부 (Firebase Storage)
- [ ] 다국어 지원 (영어)
- [ ] iPad 최적화
- [ ] Apple Watch 앱

---

## 📌 노트

- 각 우선순위 그룹은 순차적으로 진행
- 하나의 Priority가 완료되어야 다음 진행
- 중요한 버그 발견 시 즉시 우선순위 조정
