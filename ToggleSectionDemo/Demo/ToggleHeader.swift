import UIKit
import RxSwift
import RxCocoa

class ToggleHeader: UICollectionReusableView {
    fileprivate let titleLabel: UILabel
    fileprivate let tapGestureRecognizer: UITapGestureRecognizer

    private(set) var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        titleLabel = UILabel()
        tapGestureRecognizer = UITapGestureRecognizer(target: nil, action: nil)

        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])

        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("ToggleHeader is not NIB-initializable to keep the sample shorter")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    var title: String? {
        get {
            return titleLabel.text
        }

        set {
            titleLabel.text = newValue
        }
    }

    var titleColor: UIColor {
        get {
            return titleLabel.textColor
        }

        set {
            titleLabel.textColor = newValue
        }
    }
}

extension Reactive where Base: ToggleHeader {
    var tap: Observable<Void> {
        return base.tapGestureRecognizer.rx.event.map { _ in () }
    }

    var titleColor: Binder<UIColor> {
        return Binder(base) { view, color in view.titleColor = color }
    }
}
