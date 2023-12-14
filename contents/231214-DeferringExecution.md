# Defering execution 🤿

기능은 좋아보이지만 아직 완료되지 않았습니다.
다음 사용법을 고려하십시오.
아래 코드를 봐봅시다.

```swift
func ifelse<V>(_ condition: Bool,
               _ valueTrue: V,
               _ valueFalse: V) -> V {
    condition ? valueTrue : valueFalse
}

func expensiveValue1() -> Int {
    print("side-effect-1")
    return 2
}

func expensiveValue2() -> Int {
    print("side-effect-2")
    return 1729
}

let taxicab = ifelse(.random(),
                     expensiveValue1(),
                     expensiveValue2())
```

이것을 실행하면, 두 함수가 항상 호출된다는 것을 볼 수 있습니다.

> 📝 Note
> 
>그 이유는 처음 `ifelse` 가 `expensiveValue1()`과 `expensiveValue2()`를 호출하므로
기본적으로 두 함수가 항상 호출됩니다.

언어 기능으로서, 사용하는 표현식만 평가되기를 바랄 것입니다.
실행을 지연시키는 클로저를 전달함으로써 이 문제를 해결할 수 있습니다.
아래 코드를 봐봅시다.

```swift
func ifelse<V>(_ condition: Bool,
               _ valueTrue: () -> V,
               _ valueFalse: () -> V) -> V {
    condition ? valueTrue() : valueFalse()
}
```

이 코드는 실행을 연기하지만 함수를 호출하는 방법을 변경합니다.
이제 다음과 같이 호출해야 합니다.

```swift
let value = ifelse(.random(), { 100 }, { 0 })

let taxicab = ifelse(.random(),
                     { expensiveValue1() },
                     { expensiveValue2() })
```

하나의 함수만 호출되지만 인수를 클로저로 감싸는 일은 꽤 성가신 일입니다.
다행히도 Swift에는 이 문제를 해결할 수 있는 방법이 있습니다.
아래 코드를 봐봅시다.

```swift
func ifelse<V>(_ condition: Bool,
               _ valueTrue: @autoclosure () -> V,
               _ valueFalse: @autoclosure () -> V) -> V {
    condition ? valueTrue() : valueFalse()
}

func expensiveValue1() -> Int {
  print("side-effect-1")
  return 2
}

func expensiveValue2() -> Int {
  print("side-effect-2")
  return 1729
}

let value = ifelse(.random(), 100, 0)

let taxicab = ifelse(.random(),
                     expensiveValue1(),
                     expensiveValue2())
```

매개변수 타입에 `@autoclosure`를 사용하면 컴파일러가 자동으로 인자들을 클로저로 감싸게 됩니다.
이 변경으로 호출지점은 원래 상태로 복원되며, 실행을 지연시켜 사용된 인자만 평가되도록 합니다.
