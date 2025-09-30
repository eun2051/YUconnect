# YU-Connect 📱

**영남대학교 통합 민원 및 소통 커뮤니티 앱**

YU-Connect는 영남대학교 학생들의 불편사항 및 건의사항을 효율적으로 처리하고, 학교 생활 편의와 소통을 활성화하기 위한 iOS/Android 통합 모바일 애플리케이션입니다.

## ✨ 주요 기능

- 🔐 **사용자 인증**: 이메일/비밀번호 기반 로그인 및 회원가입
- 📝 **민원 시스템**: 민원 등록, 현황 조회, 답변 확인
- 📢 **공지사항**: 학교 공지, 학사일정, 총학생회 행사 정보
- 💬 **학과 커뮤니티**: 학과별 소통 공간
- 🔔 **푸시 알림**: 민원 답변 및 중요 공지 알림
- 👤 **프로필 관리**: 사용자 정보 및 설정 관리

## 🛠 기술 스택

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase
  - Authentication (사용자 인증)
  - Firestore (데이터베이스)
  - Storage (파일 저장)
  - Cloud Messaging (푸시 알림)
- **State Management**: Provider/Riverpod
- **Platforms**: iOS, Android

## 📱 지원 플랫폼

- iOS 12.0+
- Android API 21+ (Android 5.0+)

## 🚀 시작하기

### 필수 조건

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode
- Firebase 프로젝트 설정

### 설치 방법

1. **저장소 클론**
   ```bash
   git clone https://github.com/eun2051/YUconnect.git
   cd YUconnect
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **Firebase 설정**
   - Firebase Console에서 프로젝트 생성
   - `android/app/google-services.json` 파일 추가
   - `ios/GoogleService-Info.plist` 파일 추가

4. **앱 실행**
   ```bash
   flutter run
   ```

## 📁 프로젝트 구조

```
lib/
├── components/       # 재사용 가능한 UI 컴포넌트
├── models/          # 데이터 모델
├── providers/       # 상태 관리
├── repositories/    # 데이터 처리 로직
├── screens/         # 화면별 UI
│   ├── auth/        # 인증 관련 화면
│   ├── main/        # 메인 기능 화면
│   ├── inquiry/     # 민원 관련 화면
│   └── profile/     # 프로필 화면
└── services/        # Firebase 연동 서비스
```

## 🔧 개발 환경 설정

### Firebase 설정

1. [Firebase Console](https://console.firebase.google.com)에서 프로젝트 생성
2. Authentication 활성화 (이메일/비밀번호)
3. Firestore Database 생성
4. Storage 버킷 생성
5. Cloud Messaging 설정

### 환경 변수

Firebase 설정 파일들은 보안상 Git에 포함되지 않습니다:
- `android/app/google-services.json`
- `ios/GoogleService-Info.plist`

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 영남대학교의 내부 프로젝트입니다.

## 📞 문의

프로젝트 관련 문의사항이 있으시면 Issues를 통해 연락해주세요.

---

**Made with ❤️ for 영남대학교 학생들**
