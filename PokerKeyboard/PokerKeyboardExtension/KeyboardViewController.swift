import UIKit

final class KeyboardViewController: UIInputViewController {

    // MARK: - Key model

    private enum KeyKind {
        case text(String)          // 通常のテキスト挿入
        case newline               // 改行
        case delete                // 1 文字削除
        case nextKeyboard          // キーボード切り替え
    }

    private struct Key {
        let title: String
        let kind: KeyKind
        let style: Style

        enum Style {
            case action      // f / c / r / b / x / all-in / /
            case rank        // 1..9, T, J, Q, K
            case position    // UTG, +1, ... BB
            case spade       // ♠ (黒)
            case heart       // ♥ (赤)
            case diamond     // ♦ (青)
            case club        // ♣ (緑)
            case control     // delete / newline / globe
        }
    }

    // MARK: - Layout data

    private let rows: [[Key]] = [
        // Row 1 – actions
        [
            Key(title: "f",      kind: .text("f"),      style: .action),
            Key(title: "c",      kind: .text("c"),      style: .action),
            Key(title: "r",      kind: .text("r"),      style: .action),
            Key(title: "b",      kind: .text("b"),      style: .action),
            Key(title: "x",      kind: .text("x"),      style: .action),
            Key(title: "all-in", kind: .text("all-in"), style: .action),
            Key(title: "/",      kind: .text("/"),      style: .action),
        ],
        // Row 2 – ranks
        [
            Key(title: "1", kind: .text("1"), style: .rank),
            Key(title: "2", kind: .text("2"), style: .rank),
            Key(title: "3", kind: .text("3"), style: .rank),
            Key(title: "4", kind: .text("4"), style: .rank),
            Key(title: "5", kind: .text("5"), style: .rank),
            Key(title: "6", kind: .text("6"), style: .rank),
            Key(title: "7", kind: .text("7"), style: .rank),
            Key(title: "8", kind: .text("8"), style: .rank),
            Key(title: "9", kind: .text("9"), style: .rank),
            Key(title: "T", kind: .text("T"), style: .rank),
            Key(title: "J", kind: .text("J"), style: .rank),
            Key(title: "Q", kind: .text("Q"), style: .rank),
            Key(title: "K", kind: .text("K"), style: .rank),
        ],
        // Row 3 – positions
        [
            Key(title: "UTG", kind: .text("UTG"), style: .position),
            Key(title: "+1",  kind: .text("+1"),  style: .position),
            Key(title: "+2",  kind: .text("+2"),  style: .position),
            Key(title: "LJ",  kind: .text("LJ"),  style: .position),
            Key(title: "HJ",  kind: .text("HJ"),  style: .position),
            Key(title: "CO",  kind: .text("CO"),  style: .position),
            Key(title: "BTN", kind: .text("BTN"), style: .position),
            Key(title: "SB",  kind: .text("SB"),  style: .position),
            Key(title: "BB",  kind: .text("BB"),  style: .position),
        ],
        // Row 4 – suits + controls
        [
            Key(title: "🌐", kind: .nextKeyboard,  style: .control),
            Key(title: "♠",  kind: .text("♠"),     style: .spade),
            Key(title: "♥",  kind: .text("♥"),     style: .heart),
            Key(title: "♦",  kind: .text("♦"),     style: .diamond),
            Key(title: "♣",  kind: .text("♣"),     style: .club),
            Key(title: "⌫",  kind: .delete,        style: .control),
            Key(title: "⏎",  kind: .newline,       style: .control),
        ],
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.10, green: 0.10, blue: 0.18, alpha: 1.0)
        buildKeyboard()
    }

    // MARK: - Build UI

    private func buildKeyboard() {
        let outer = UIStackView()
        outer.axis = .vertical
        outer.distribution = .fillEqually
        outer.spacing = 6
        outer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outer)

        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            outer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6),
            outer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            outer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
        ])

        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 4
            for key in row {
                rowStack.addArrangedSubview(makeButton(for: key))
            }
            outer.addArrangedSubview(rowStack)
        }
    }

    private func makeButton(for key: Key) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(key.title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: fontSize(for: key.style), weight: .semibold)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.6
        btn.setTitleColor(foreground(for: key.style), for: .normal)
        btn.backgroundColor = background(for: key.style)
        btn.layer.cornerRadius = 6
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.25
        btn.layer.shadowOffset = CGSize(width: 0, height: 1)
        btn.layer.shadowRadius = 1
        btn.showsTouchWhenHighlighted = true

        switch key.kind {
        case .text(let s):
            btn.addAction(UIAction { [weak self] _ in
                self?.textDocumentProxy.insertText(s)
            }, for: .touchUpInside)

        case .newline:
            btn.addAction(UIAction { [weak self] _ in
                self?.textDocumentProxy.insertText("\n")
            }, for: .touchUpInside)

        case .delete:
            btn.addAction(UIAction { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
            }, for: .touchUpInside)
            attachDeleteRepeat(to: btn)

        case .nextKeyboard:
            btn.addTarget(self,
                          action: #selector(handleInputModeList(from:with:)),
                          for: .allTouchEvents)
        }
        return btn
    }

    // MARK: - Long-press delete

    private var deleteTimer: Timer?

    private func attachDeleteRepeat(to btn: UIButton) {
        let long = UILongPressGestureRecognizer(target: self,
                                                action: #selector(handleDeleteLongPress(_:)))
        long.minimumPressDuration = 0.4
        btn.addGestureRecognizer(long)
    }

    @objc private func handleDeleteLongPress(_ gr: UILongPressGestureRecognizer) {
        switch gr.state {
        case .began:
            deleteTimer?.invalidate()
            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
            }
        case .ended, .cancelled, .failed:
            deleteTimer?.invalidate()
            deleteTimer = nil
        default:
            break
        }
    }

    // MARK: - Styling

    private func background(for style: Key.Style) -> UIColor {
        switch style {
        case .action:   return UIColor(red: 0.95, green: 0.61, blue: 0.07, alpha: 1) // amber
        case .rank:     return UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1) // blue
        case .position: return UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1) // purple
        case .spade,
             .heart,
             .diamond,
             .club:     return UIColor.white                                          // 白背景でスーツ色を際立たせる
        case .control:  return UIColor(white: 0.28, alpha: 1)
        }
    }

    private func foreground(for style: Key.Style) -> UIColor {
        switch style {
        case .spade:   return UIColor.black
        case .heart:   return UIColor(red: 0.90, green: 0.15, blue: 0.20, alpha: 1)   // 赤
        case .diamond: return UIColor(red: 0.10, green: 0.45, blue: 0.95, alpha: 1)   // 青 (🔷)
        case .club:    return UIColor(red: 0.15, green: 0.60, blue: 0.30, alpha: 1)   // 緑
        default:       return .white
        }
    }

    private func fontSize(for style: Key.Style) -> CGFloat {
        switch style {
        case .rank:                        return 18
        case .action:                      return 16
        case .position:                    return 14
        case .spade, .heart, .diamond, .club: return 24
        case .control:                     return 18
        }
    }
}
