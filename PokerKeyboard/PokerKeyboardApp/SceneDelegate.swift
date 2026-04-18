import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: scene)
        w.rootViewController = ViewController()
        self.window = w
        w.makeKeyAndVisible()
    }
}
