import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private typealias Section = AnimatableSectionModel<String, String>

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    @IBOutlet private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(SimpleCell.self, forCellWithReuseIdentifier: "SimpleCell")
        collectionView.register(ToggleHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ToggleHeader")

        let adapter = ExpandableSectionAdapter(Observable.of(sampleData), expandByDefault: false)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<Section>(configureCell: { (ds, cv, ip, item) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "SimpleCell", for: ip) as! SimpleCell
            cell.title = item
            return cell
        }, configureSupplementaryView: { (ds, cv, kind, ip) in
            let header = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ToggleHeader", for: ip) as! ToggleHeader
            let section = ds.sectionModels[ip.section]
            header.title = section.model

            adapter.isExpanded(section).map { $0 ? UIColor.green : UIColor.red }
                .bind(to: header.rx.titleColor)
                .disposed(by: header.disposeBag)

            header.rx.tap.map { _ in section }
                .bind(to: adapter.toggle)
                .disposed(by: header.disposeBag)

            return header
        })

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        adapter.bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
}

private let sampleData: [Section] = [
    Section(model: "Section Foo", items: ["Foo A", "Foo B", "Foo C", "Foo D", "Foo E", "Foo F", "Foo G", "Foo H", "Foo I", "Foo J", "Foo K", "Foo L", "Foo M", "Foo N", "Foo O", "Foo P", "Foo Q"]),
    Section(model: "Section Bar", items: ["Bar A", "Bar B"]),
    Section(model: "Section Baz", items: ["Baz A"]),
    Section(model: "Section Qux", items: []),
]
