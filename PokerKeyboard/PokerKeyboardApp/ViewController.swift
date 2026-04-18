import UIKit

final class ViewController: UIViewController {

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        tv.layer.borderColor = UIColor.systemGray3.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.autocorrectionType = .no
        tv.autocapitalizationType = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let infoLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.text = """
        Poker Keyboard を有効化:

        設定 ▶ 一般 ▶ キーボード ▶ キーボード ▶ 新しいキーボードを追加
        ▶ Poker Keyboard を選択

        下のテキストフィールドで地球儀キーから切り替えて試せます。
        """
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Poker Keyboard"

        view.addSubview(infoLabel)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
}
