//
//  ViewController.swift
//  HW26
//
//  Created by Дмитрий Цветков on 03.12.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonForCheck: UIButton!
    
    @IBOutlet weak var myImgView: UIImageView!
    
    @IBOutlet weak var myTextField: UITextField!
    
    var heroes = [Hero]()
    
    var names: [String] = []
    
    var resultsOfSearch: [String] = []
    
    
    let mas = ["https://img3.akspic.ru/previews/9/6/1/9/6/169169/169169-ty_zasluzhivaesh_vsyacheskogo_schastya-schaste-strah-voda-polety_na_vozdushnom_share-500x.jpg", "https://avatars.mds.yandex.net/i?id=1de86bec0b29cc17d5367e336943cd3fcc70045e-5332070-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=d78da4217b732cc1f02b14c414bcefb8c2c22756-5234859-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=76eaad2e18d0f55bb2473ad21a21b85e-5349329-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=4fd21f52672b06636f7ce1d8c300659e-5436735-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=c220cebda8eb7b6207326d772f1308bea231c45c-5711615-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=6d680f0a41aceb085172066243526f07a316fb6c-6212678-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=84e68b572a9c10656112249811baf8dde53023a8-3584141-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=fc7a0b9cbc34c0d1f82a50acafa1da26-4118910-images-thumbs&n=13", "https://avatars.mds.yandex.net/i?id=3eb79a7a0038200bb38a51619b42324031330a95-5869855-images-thumbs&n=13"]
    var masOfImages: [UIImageView] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<mas.count {
            myImgView.downloaded(from: mas[i])
            masOfImages.append(myImgView)

            UserDefaults.standard.set(masOfImages[i].image, forKey: "Image\(i)")
            print("Картинка \(i) сохранилась")
        }

        downloadJSON {
            print("success")
            self.tableView.reloadData()
        }
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func showDataInUserDefaults(key: String){
        let str = UserDefaults.standard.string(forKey: key)
        print("\(str ?? "") хранится в UserDefaults")
    }
    
    func findName(text: String) {
        for _ in 0..<resultsOfSearch.count {
            resultsOfSearch.removeFirst()
        }
        for i in names {
            if i.contains(text) {
                resultsOfSearch.append(i)
            }
        }
    }
    
    func deleteAllFromUserDefaults() {
        for i in 0..<10 {
            UserDefaults.standard.set(nil, forKey: "Data\(i)")
            UserDefaults.standard.set(nil, forKey: "Image\(i)")
        }
    }

var mas3 = [UIImageView]()
    
    func downloadJSON(completed: @escaping () -> ()){
        let url = URL(string: "https://api.opendota.com/api/heroStats")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if error == nil {
                do {
                    self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("JSON error")
                }
            }
            for i in 0..<10 {
                UserDefaults.standard.set(self.heroes[i].name, forKey: "Data\(i)")
                self.names.append(UserDefaults.standard.value(forKey: "Data\(i)") as! String)
            }
            
        }.resume()
    }
    
    @IBAction func buttonCheckTapped(_ sender: Any) {
        
        for i in 0..<10 {
            showDataInUserDefaults(key: "Data\(i)")
        }
        for i in masOfImages {
            let imgView = UserDefaults.standard.object(forKey: "Image\(i)")
        }
        findName(text: myTextField.text ?? "")
        
        let alert = UIAlertController(title: "Поиск", message: "Найденные элементы: ", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Закрыть", style: .cancel)
        
        for i in 0..<(resultsOfSearch.count) {
            alert.addTextField()
            alert.textFields?[i].text = self.resultsOfSearch[i]
        }
        
        alert.addAction(cancelButton)
        present(alert, animated: true)
        
    }
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < 10 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            cell.textLabel?.text = heroes[indexPath.row].name

            return cell
        }
        return UITableViewCell()
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

