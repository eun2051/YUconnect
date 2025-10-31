# YU-Connect: 영남대학교 통합 민원 및 소통 커뮤니티 앱

## 프로젝트 소개 및 배경

영남대학교 학생들의 불편사항, 건의사항, 학교 생활 정보 등을 쉽고 빠르게 소통하고 해결할 수 있도록 만든 공식 모바일 애플리케이션입니다. 기존의 복잡한 민원 처리와 정보 전달 방식을 개선하고, 학생들이 실시간으로 소통할 수 있는 커뮤니티 공간을 제공하기 위해 개발되었습니다.

- **문제의식**: 학교 내 민원 처리의 비효율성, 정보 전달의 단절, 학생 간 소통의 어려움
- **목표**: 학생들이 모바일에서 쉽고 빠르게 민원을 등록/조회하고, 공지사항, FAQ, 커뮤니티, 푸시 알림 등 다양한 기능을 한 곳에서 이용할 수 있도록 지원

## 사용한 기술 및 스킬셋

- **Flutter 3.x**: iOS/Android 동시 지원 크로스플랫폼 UI 프레임워크
- **Dart**: 메인 프로그래밍 언어
- **Firebase**
  - Authentication: 이메일/비밀번호 기반 회원가입 및 로그인
  - Firestore: 실시간 데이터베이스 (민원, 공지사항, FAQ 등)
  - Storage: 이미지 등 파일 업로드
  - Cloud Messaging: 푸시 알림
- **상태관리**: Riverpod/Provider
- **기타**: 커스텀 위젯, 탭/네비게이션, 실시간 데이터 연동, 디자인 시스템 적용

## 실행 방법

### 1. Flutter 개발 환경 준비
- [Flutter 공식 홈페이지](https://flutter.dev/docs/get-started/install)에서 본인 OS에 맞는 Flutter SDK를 설치하세요.
- 환경 변수(PATH)에 Flutter를 추가하세요.
- `flutter --version` 명령어로 정상 설치를 확인하세요.
- Android Studio(또는 VS Code), Xcode(맥 사용 시) 등 개발 툴을 설치하세요.
- Android/iOS 에뮬레이터 또는 실제 기기 준비(테스트용)

### 2. 프로젝트 클론 및 의존성 설치
- 터미널(명령 프롬프트)에서 아래 명령어를 차례로 입력하세요:
```bash
git clone https://github.com/eun2051/YUconnect.git
cd yuconnect
flutter pub get
```
- `flutter pub get` 명령어로 필요한 모든 패키지를 자동으로 설치합니다.

### 3. Firebase 연동
- [Firebase 콘솔](https://console.firebase.google.com/)에서 새 프로젝트를 생성하세요.
- Android 앱 등록 후 `google-services.json` 파일을 다운로드 받아 `android/app/` 폴더에 넣으세요.
- iOS 앱 등록 후 `GoogleService-Info.plist` 파일을 다운로드 받아 `ios/Runner/` 폴더에 넣으세요.
- (필요시) Firestore, Authentication, Storage, Cloud Messaging 등 Firebase 서비스 활성화

### 4. 앱 실행하기
- Android 에뮬레이터 또는 iOS 시뮬레이터를 실행하거나, USB로 실제 기기를 연결하세요.
- 아래 명령어로 앱을 실행합니다:
```bash
flutter run
```
- 기기가 여러 대일 경우, `flutter devices`로 목록 확인 후 `flutter run -d <device_id>`로 실행할 수 있습니다.

### 5. (선택) 더미 민원 데이터 일괄 삭제 스크립트 실행
- Firestore의 `inquiries` 컬렉션에 테스트 데이터가 많을 경우, 아래 명령어로 일괄 삭제할 수 있습니다:
```bash
dart lib/scripts/delete_all_inquiries.dart
```
- 이 스크립트는 Firebase 프로젝트와 연결된 상태에서만 정상 동작합니다.

---

## 주요 폴더 구조
- `lib/screens/` : 주요 화면(UI)
- `lib/widgets/` : 재사용 위젯
- `lib/services/` : Firebase 등 서비스 연동
- `lib/repositories/` : 데이터 처리 로직
- `lib/models/` : 데이터 모델
- `lib/scripts/` : 관리용 Dart 스크립트

---

문의: gene5518@naver.com
