# UFlix 🎬  
**넷플릭스 스타일의 영화 iOS 애플리케이션**

넷플릭스를 오마주한 iOS 영화 앱입니다. 🍿🎬  
TMDB API 기반으로 인기 영화, 평점 높은 영화, 개봉 예정 영화 등 다양한 정보를 제공하며, 검색 기능, 찜 기능, 추천 콘텐츠 등 실제 OTT 앱에서 사용하는 핵심 기능들을 구현했습니다.

![Uflix Banner](/Uflix/App/Assets.xcassets/README/UFLIX_banner.png) <!-- 배너 이미지 있으면 삽입 -->

<br> 

---

## 📱 주요 기능

| 기능 | 설명 |
|------|------|
| 🔍 **검색** | 실시간 검색어 추천, 최근 검색어 저장/삭제, 검색 결과 없음 처리 |
| 🏠 **홈 화면** | 인기 영화 / 평점 높은 영화 / 개봉 예정 영화 표시 (Compositional Layout) |
| ❤️ **찜 기능** | CoreData 기반 찜한 영화 관리, 편집 모드로 다중 선택 후 삭제 가능 |
| 🎬 **상세 화면** | 영화 포스터, 제목, 줄거리, 추천 콘텐츠 함께 표시 |
| ✅ **추천 콘텐츠** | TMDB API 기반 연관 영화 추천, 하단 가로 스크롤 표시 |
| 🎥 **미디어 재생** | AVPlayerViewController 사용한 영상 재생 기능 구현 예시 포함 |

<br> 

---

## 🧱 기술 스택

| 구분 | 기술 |
|------|------|
| Language | `Swift` |
| UI Framework | `UIKit` + `SnapKit` |
| Architecture | `MVVM` |
| Reactive Programming | `RxSwift`, `RxCocoa` |
| Local Storage | `CoreData` |
| Networking | `URLSession` + `TMDB API` |
| Image Caching | `Kingfisher` |
| Video | `AVKit`, `AVPlayerViewController` |

<br> 

---

## 🗂️ 프로젝트 구조

```bash
Uflix/
├── MainViewController.swift          # 홈 화면 (카테고리별 영화 섹션)
├── SearchViewController.swift        # 검색 화면
├── SearchResultViewController.swift # 검색 결과
├── DetailViewController.swift        # 영화 상세 화면
├── MyNetflixViewController.swift     # 찜한 영화 목록
├── ViewModels/                       # MVVM 구조에 따른 ViewModel 파일들
├── Models/                           # Movie, FavoriteMovie 등 도메인 모델
├── Network/                          # API 호출, MovieService, NetworkManager
├── Utilities/                        # CoreDataManager, SearchHistoryManager
└── Resources/                        # Assets, AppColor, Constants 등
```

<br> 

---

## 🚀 실행 방법

1. 이 저장소를 클론합니다.

```bash
bash
코드 복사
git clone https://github.com/your-username/uflix.git

```

1. `TMDB_API_KEY`를 설정합니다.

`Info.plist`에 다음 키를 추가해 주세요:

```xml
xml
코드 복사
<key>TMDB_API_KEY</key>
<string>YOUR_TMDB_API_KEY</string>

```

1. 라이브러리 설치 (RxSwift 등은 CocoaPods 또는 Swift Package Manager로 설치되어야 합니다)


<br> 

---

## 📸 UI 스크린샷

> 아래는 일부 화면 예시입니다.
> 

| 홈 화면 | 상세 화면 | 찜 목록 |
| --- | --- | --- |
|  |  |  |


<br> 

---

## 👩🏻‍💻 개발자

| 이름 | GitHub |
| --- | --- |
| 정유진 | [@yyujnn](https://github.com/yyujnn) |


<br> 

---

## 📌 향후 개선 예정

- [ ]  유튜브 API 연동 및 실제 트레일러 영상 재생
- [ ]  다국어 지원 (Localization)
- [ ]  다크 모드 대응
- [ ]  인기 검색어, 검색 자동완성 기능 개선


<br> 
