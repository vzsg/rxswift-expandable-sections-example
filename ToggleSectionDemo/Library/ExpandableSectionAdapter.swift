import RxSwift
import RxDataSources

public final class ExpandableSectionAdapter<S: AnimatableSectionModelType>: ObservableType {
    public typealias E = [S]
    private let expandByDefault: Bool
    private let active: Observable<Set<S.Identity>>
    private let output: Observable<[S]>
    public let toggle: AnyObserver<S>

    public init(_ input: Observable<[S]>, expandByDefault: Bool = true) {
        let toggleSubject = PublishSubject<S.Identity>()

        self.expandByDefault = expandByDefault
        self.active = toggleSubject.asObservable()
            .scan(Set()) { (acc, identity) in
                var acc = acc
                if acc.contains(identity) {
                    acc.remove(identity)
                } else {
                    acc.insert(identity)
                }

                return acc
            }
            .startWith(Set())
            .share(replay: 1, scope: .whileConnected)

        self.output = Observable.combineLatest(input, active) { data, active -> [S] in
            data.map { (section: S) -> S in
                guard expandByDefault == active.contains(section.identity) else {
                    return section
                }

                return S(original: section, items: [])
            }
        }

        self.toggle = AnyObserver { event in
            switch event {
            case .next(let element):
                toggleSubject.onNext(element.identity)
            default:
                break
            }
        }
    }

    public func isExpanded(_ section: S) -> Observable<Bool> {
        return active.map { [expandByDefault = self.expandByDefault] active in expandByDefault != active.contains(section.identity) }
    }

    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return output.subscribe(observer)
    }
}
