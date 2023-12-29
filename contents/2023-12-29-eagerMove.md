# `@_eagerMove` 속성.

지난번 `Array`를 내부를 보다가 새롭가 알게된 속성인 `@_eagerMove`에 대해서 부가적으로 더 학습해봤습니다.<br>

**"`@_eagerMove` 속성은 해당 타입의 변수가 마지막으로 사용된 직후에 즉시 파괴되도록 함을 의미합니다."**<br>

**이는 약한 참조나 안전하지 않은 포인터가 무효화될 수도 있음을 의미합니다:**<br>
```swift
  func takeArray(_ refs: consuming [Ref]) { ... }

  let arrayOfRefs = [Ref()]
  weak var weakRef = arrayOfRefs[0]
  takeArray(arrayOfRefs) // 마지막 사용 시 파괴됨
  print(weakRef!)  // 크래시
```
변수를 파괴하는 것은 그 값의 소비를 의미합니다.<br>

값에 참조가 포함되어 있다면 이는 참조 카운트를 감소시킵니다.<br>

`@_eagerMove`는 Copy-on-Write 시 데이터 타입에 적용됩니다: Array, Set, Dictionary, 및 String.<br>

이의 주된 이유는 실용적입니다.<br>
- CoW 값의 불필요한 인스턴스를 최적화하는 것을 실패하면 모든 컬렉션 요소들이 예상치 못하게 복사되는 드라마틱한 성능 영향을 미칩니다. 
- 실제 상황에서, 컴파일러가 약한 참조나 안전하지 않은 포인터의 존재 여부를 판단하는 것은 거의 불가능하므로 보수적인 분석에 의존하는 것은 비효과적이고 예측 불가능합니다.
    - 또한, 이 컨테이너들이 사용되지 않을 경우 생성을 최적화하고 싶습니다.

**"이 최적화를 중요한 경우에 수행하는 언어적 정당화는, 형식적으로 Swift와 Objective-C(ARC 포함)가 항상 마지막 사용 후 참조를 파괴할 수 있도록 허용하고 있다는 것입니다."**<br>

이에 대한 "사용성 측면의 이유"는 Swift에서의 CoW 데이터 타입은 값 세맨틱스를 가지고 있다는 것입니다.<br>

프로그래머에게 눈에 띄는 소멸자가 없습니다.<br>
그리고 일반적으로 프로그래머는 저장소가 언제 해제될지 예측할 수 없습니다.<br>
물론 CoW 데이터 타입의 요소들 자체가 소멸자를 가질 수 있습니다.<br>
그리고 위에서 보여진 것처럼, 요소에 대한 약한 참조가 존재할 수 있습니다.<br>
이는 CoW 데이터 타입을 사용하려는 프로그래머에게 일부 부담을 줍니다.<br>
요소들이 CoW 컨테이너를 통해 접근되지 않아도 살아 있도록 유지하고 싶을 때는 (상당히 이상한 상황이지만), CoW 컨테이너의 수명을 명시적으로 범위에 연결해야 합니다:<br>
```swift
  func takeArray(_ refs: consuming [Ref]) { ... }

  let arrayOfRefs = [Ref()]
  weak var weakRef = arrayOfRefs[0]
  defer { withExtendedLifetime(arrayOfRefs) {} }
  takeArray(arrayOfRefs) // 저장소 참조 카운트를 증가시켜 배열을 복사
  print(weakRef!)  // 정상
```

---

### 참고 문서

- [Apple ReferenceGuides](https://github.com/apple/swift/blob/f6dba90cf2b3b646de748b0fc4fbfbd1f65cb0a3/docs/ReferenceGuides/UnderscoredAttributes.md#_eagermove)
