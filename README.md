# 아차 - 땅따먹기 게임

<div align="center">
<img src = "https://user-images.githubusercontent.com/76652929/207753778-a9e6be7c-9560-4d6a-87b1-4367b96b555f.png" width="400" height="400"/> 
</div>



> 땅따먹기 게임을 아시나요?  
>**아차**와 함께 재미있게 운동하며 새로운 **땅따먹기 게임**을 경험해보세요.  
>혼자 건물을 주변을 **산책**할 수도 있고, 여러 친구와 땅을 먹으며 **영역 경쟁**하는 실제 땅따먹기 게임!



<div align="center">
  
![Swift](https://img.shields.io/badge/swift-v5.7-orange?logo=swift) ![Xcode](https://img.shields.io/badge/xcode-v14.1-blue?logo=xcode)
  ![iOS](https://img.shields.io/badge/ios-v14.0-blue?logo=iOS)
  </div>

# ✨ 기능 소개

## 혼자하기 모드

- 내 주변 **땅** 중 하나를 **선택**하고, 선택한 **땅 주변을 돌아 땅따먹기** 할 수 있습니다.
- 게임 중에 현재 땅에 대해 시간순 **랭킹, 내 이전 기록**을 확인할 수 있습니다.
- 게임이 종료되면 이번 **게임에 대한 기록(땅 이름, 시간, 거리, 칼로리)**을 확인할 수 있습니다.
- 게임이 종료되면 운동 기록이 **건강 앱**에도 저장됩니다.

<div align="center">

<img src = "https://user-images.githubusercontent.com/76652929/207753956-58ba6bef-c073-4a39-bf30-0b8a08147e44.png" width="570" height="619"/>

</div>

## 같이하기 모드

- **QR코드**를 통해 방에 입장하여 친구와 함께 할 수 있습니다.
- 게임 중 **다른 플레이어의 실시간 위치와 포인트**를 확인할 수 있습니다.
- 게임 중 **실시간으로 다른 플레이어와 채팅**을 할 수 있습니다.

<div align="center">

<img src="https://user-images.githubusercontent.com/76652929/207754137-008a7726-7533-4d2e-bcf0-6e9520aa2ab9.png" width="550" height="380"/>

</div>

## 기록

- **자신의 기록**을 볼 수 있습니다.
- 여러 땅의 **랭킹**을 볼 수 있습니다.

<div align="center">
<img src="https://user-images.githubusercontent.com/76652929/207754294-335b0649-d042-4f93-a208-febb058b98de.png" width="400" height="619"/>

</div>

## 뱃지

- 게임 **결과**에 따라 다양한 **뱃지**를 획득할 수 있습니다.

<div align="center">
<img src="https://user-images.githubusercontent.com/76652929/207754567-1e9193b0-dc4a-43f8-9b5a-a23fd423ccba.png" width="370" height="379"/>
</div>

## 커뮤니티

- 커뮤니티에서 **다른 플레이어와 소통**할 수 있습니다.
- **사진**을 첨부하여 **게시글**을 올릴 수 있습니다.
- 다른 사용자의 **게시글**을 보고 **댓글**을 **작성**할 수 있습니다.
- **게시글 작성자**라면 게시글을 **수정** 및 **삭제**할 수 있습니다.

<div align="center">
<img src="https://user-images.githubusercontent.com/76652929/207754718-6f38e19b-0d48-4109-9d77-7c0a6b3ccc6a.png" width="550" height="359"/>

</div>

# ✨ 기술 스택 
<div align="center">
<img src="https://user-images.githubusercontent.com/76652929/207842188-e8797d7b-83ed-43b6-a96f-810d503441ec.png" width="500" height="309"/>
</div>

# ✨ 기술 특장점 

## RxSwift

> 사용**한 이유**
> 
- GCD를 이용한 비동기 처리 시 **코드 블록의 중첩**으로 **가독성이 떨어지는 현상을 피하기 위해** RxSwift를 선택했습니다.
- 비동기 처리 방법 중 **가장 보편적으로 사용**되고 있는 RxSwift를 사용하고자 했습니다.

> **결과**
> 
- Network Service - Repository - UseCase - ViewModel - ViewController 순서로 데이터를 주고받을 때 Observable, Observer, Operator를 사용하여 **하나의 stream**으로 연결할 수 있었습니다.
- 변화하는 사용자 위치를 받아오거나 네트워크 API 호출 등 **비동기적 처리**를 **함수형**으로 처리했습니다.
- **선언형 프로그래밍**으로 가독성을 높였습니다.
- MVVM과 함께 사용하여 ViewController에서 Model을 직접 참조하지 않고, **Model의 상태를 Observing** 하여 처리했습니다.


## **CoreLocation**

> **사용한 이유**
- 사용자의 **현재 위치**를 얻어 이동 경로, 먹는 중인 땅을 그릴수 있게 했습니다.
    


> **결과**
> 
- Data Layer에서 **LocationService**를 구현하여 위치를 사용하는 Scene에서 간편히 사용하도록 했습니다.
- **Background Modes** 설정을 통해 사용자가 화면을 꺼도 게임을 원활히 진행할 수 있게 했습니다.

## **MapKit**

> 사용**한 이유**
> 

플레이 할 수 있는 땅들과 사용자의 현재 위치, 경로 등을 지도에 표시해주기 위해 **MapKit**을 사용했습니다.

> **적용 방식**
> 
- 지도를 보여주기 위해 **MKMapView**, 땅을 표시하기 위해 **MKAnnoation**을 사용했습니다.
- **MKPolyLine**을 이용하여 땅을 먹기 위한 경로, 사용자 이동 경로를 표시해주었습니다.
- **사용자 이벤트** 에 따른 **MKPolyLine**의 **색 변화**를 위해 **MKAnnotation**을 상속하여 **MapAnnotation** 클래스에 polyLine 정보를 저장했습니다.

## 재사용 가능한 MapBase 구현하기

> **사용한 이유**
> 
- **MapKit**을 사용하는 여러화면에서 현재 위치, 권한 등 필수 **코드**의 **중복**을 **최소화**하고 싶었습니다.
- **Clean Architecture**를 따르기위해 **모든 Layer**에 **공통**으로 사용할 **MapBase**코드들을 작성했습니다.

> **적용 방식**
> 
- **UseCase**단에서 LocationService을 이용해서 **위치 권한, 현재 위치**를 **Observing**합니다.
- **ViewModel**단에서 UseCase을 이용해서 ViewController에 **위치 권한, 현재 위치**를 **Binding**합니다.
- **ViewController**단에서 **MapView**를 보여주고, 현재 위치로 지도를 focus 할 수 있는 버튼이 있습니다.
- **ViewController**단에서 좌표를 주면 해당 위치로 지도의 Region을 설정해주는 메소드를 구현했습니다.

> **결과**
> 
- **MapView** 메모리를 통합적으로 관리해 휴먼 에러를 줄였습니다.
- **Map** 보여주는 **하위 Scene**들에서, **공통**으로 필요한 ( 현재위치 권한 등 ) 부분을 **줄였**습니다.
- MapBase 클래스들만 상속하면 별도의 코드를 작성할 필요없이 사용자 위치와 지도를 사용할 수 있습니다.

## HealthKit 연동

> **사용한 이유**
> 

땅 따먹기 게임이 종료 되었을 때 달린 거리와 소비한 칼로리를 DB에 저장하게 되는데,

운동 기록을 건강 앱에도 저장하여 사용자의 **통합적 운동 관리를 도모**하기위해 Healthkit을 사용했습니다.

> **적용 방식**
> 
- `HKObjectType` 의 `stepCount`, `distanceWalkingRunning`, `activeEnergyBurned` 속성을 통해서 걸음 수, 걸은 거리, 소비한 칼로리를 저장했습니다.
- 각각 `HKUnit` 클래스를 이용해 속성을 주어서 걸음 수는  `.count()` 로 걸음 수를 단위로, 걸은 거리는 `.meter()` 로 미터 단위로, 칼로리는 `.kilocalorie()`로 킬로칼로리 단위를 기록했습니다.
- 앱에서 걸은 거리, 칼로리등을 계산해서 `HKQuantity` 로 값을 만들어주고, 시작 시간과 종료 시간을 `Date` 형으로 만들어 주고 이 값들을 이용해서 `HKQuantitySample` 형으로 만들어주어서 `HKHealthStore` 이라는 `HealthKit` 의 모든 데이터에 접근하고 관리할 수 있는 클래스를 이용해서 데이터를 저장했습니다.

> **결과**
> 

게임이 종료 되었을 때 HealthKit 과 연동을 하여 **앱을 사용하지 않을 때**도 자신의 운동 기록을 관리할 수 있게 되었습니다.



## Keychain

> **사용한 이유**
> 

사용자의 로그인 결과를 앱 내부에 저장 하기에는 **사용자의 민감한 데이터가 유출될 수 있는 취약점**이 있었습니다.

<div align="center">
<img src="https://user-images.githubusercontent.com/76652929/207755338-74a3622b-ca85-4e5f-8920-5b6452c907d3.png" width="500" height="300"/>
</div>

**Keychain Services API** 는 데이터와 같이 속성 값을 주어 **데이터를 암호화** 하고 이를 Keychain 에 저장하는 방식으로 구성 되어 보안적으로 더 나은 선택이라 생각해서 사용하게 되었습니다. 

> **적용 방식**
> 
- 애플의 Keychain services API 는 `[String: AnyObject]` 형식의 쿼리문을 만들어서 데이터를 저장합니다.
- 저장할 때는 `kSecClass` 로 데이터 종류(비밀번호, 인증 등)를 명시하고 `kSecAttrService` 로 어떤 서비스인지 `kSecAttrAccount` 로 어느 계정인지 그리고 `kSecValueData` 로 어떤 데이터를 저장할지 쿼리문을 만들어서 데이터를 저장했습니다.
- 가져올 때는 `kSecReturnData` 을 이용해서 값 수신 여부를 결정해서 `kSecMatchLimit` 로 가져올 데이터의 양을 결정해주었습니다.
- 갱신할 때는 `kSecClass` 와 `kSecAttrService` 로 쿼리문을 만들어주고 `kSecAttrAccount`와 `kSecValueData` 로 특성을 만들어 값을 갱신했습니다.
- 삭제할 때는 `kSecClass` 와 `kSecAttrService` 로 삭제할 값을 선택해주었습니다.

> **결과**
> 
- OS 에서 앱들은 하나의 keychain 에 접근할 수 있고 **유저가 기기의 잠금을 풀었을 때만 사용 가능하게 되기 때문**에 **보안적으로 더 신경쓸 수 있게 되었습니다.**
- 유저에게 정보를 계속 요청할 필요가 없어져 더 좋은 유저 경험을 제공할 수 있게 되었습니다.

## UIBezierPath & CABasicAnimation

> **사용한 이유**
> 

그래프를 UIView로 하드코딩 하던 방식을 개선하여, 동적인 느낌을 주고싶어 적용하게 되었습니다.

> **적용 방식**
> 
- `UIBezierPath`를 통해 좌표를 따라 `addLine`과 `addArc`를 사용해서 점과 그래프 선을 그려줍니다.
- `CABasicAnimation`을 통해 두개의 path로 그래프가 **y축으로 올라가는 애니메이션**과 **투명도를 조절해주는 애니메이션**을 넣어주었습니다.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/29fbbaa1-f14e-44dc-b990-87d27f84a591/Untitled.gif)

> **결과**
> 

<div align="center">
<img src="https://user-images.githubusercontent.com/76652929/207755520-4f09a629-dfd8-4ec0-8d52-650169b2ce40.gif" width="300" height="600"/>
</div>

기존의 정적인 차트에서 동적인 차트로 바뀌면서 변화가 눈에 더 잘 띌 수 있게 되었습니다. 

## MVVM-C & Clean Architecture

> **사용한 이유**
> 

MVC 에서 생기는 **ViewController 이 방대해지는 문제** 와 기존의 MVC 와 MVVM 에서 생기는 **의존성 문제**를 해결하기 위해 MVVM-C & Clean Architecture 패턴을 사용했습니다.

> **구조**

<div align="center">
<img src="https://user-images.githubusercontent.com/76652929/207755158-0803b5d1-0924-4a8a-99e6-9da1e1d8ad51.png" width="800" height="400"/>
</div>


> **결과**
> 
- 뷰 전환시 Coordinator 패턴을 사용해 **단일 책임 원칙**을 지킬 수 있었습니다.
- Clean Architecture 패턴을 적용해 레이어를 나눠 **테스트와 확장성이 용이**하게 되었습니다.
- Entity 와 DTO 를 분리하여 View Layer와 DB Layer의 **역할을 분리**할 수 있어서 **의존성을 떨어뜨릴 수** **있었고**, 화면에 필요한 데이터를 선별해 사용하여 **데이터의 은닉화**가 가능하게 되었습니다.




## 팀소개 👨‍👨‍👧‍👦
<div align="center">

S020 배남석 | S021 변상연 | S052 조승기 | S059 홍성철
-- | -- | -- | --
 <img src="https://avatars.githubusercontent.com/u/76683388?v=4" width="150"> | <img src="https://avatars.githubusercontent.com/u/68235938?v=4" width="150">  |  <img src="https://avatars.githubusercontent.com/u/57134892?v=4" width="150"> |  <img src="https://avatars.githubusercontent.com/u/76652929?v=4" width="150">
[NamSeok-Bae](https://github.com/NamSeok-Bae) | [sangyeon3](https://github.com/sangyeon3) | [seungki-cho](https://github.com/seungki-cho) | [godo129](https://github.com/godo129)


**저희들의 개발 과정은 이곳에서 보실 수 있습니다 👉👉👉** [아차의 WIKI](https://github.com/boostcampwm-2022/iOS08_Acha/wiki)

  <a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fboostcampwm-2022%2Fweb12-MOJ&count_bg=%2357CCA9&title_bg=%234F3433&icon=&icon_color=%23453A3A&title=hits&edge_flat=false"/></a>
</div>
