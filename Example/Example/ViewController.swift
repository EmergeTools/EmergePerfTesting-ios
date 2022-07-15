import UIKit

class ViewController: UIViewController {
    
    @objc func didTapButton() {
        let controller = UIAlertController(title: "Title", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        controller.addAction(action)
        present(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton()
        button.frame = view.bounds
        button.frame.size.height /= 2
        button.setTitle("Button", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.backgroundColor = .purple
        view.addSubview(button)
    }


}

